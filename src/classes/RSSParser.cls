public class RSSParser {
     
    public class channel {
        public String title {get;set;}
        public String link {get;set;}
        public String description {get;set;}
        public String author {get;set;}
        public String category {get;set;}
        public String copyright {get;set;}
        public String docs {get;set;}
        public RSSParser.image image {get;set;}
        public list<RSSParser.item> items {get;set;}
        public channel() {
            items = new list<RSSParser.item>();
        }
    }
     
    public class image {
        public String url {get;set;}
        public String title {get;set;}
        public String link {get;set;}
    }
     
    public class item {
        public String title {get;set;}
        public String guid {get;set;}
        public String link {get;set;}
        public String description {get;set;}
        public String pubDate {get;set;}
        public String source {get;set;}
        public Date getPublishedDate() {
            Date result = (pubDate != null) ? Date.valueOf(pubDate) : null;
            return result;
        }
        public DateTime getPublishedDateTime() {
            DateTime result = (pubDate != null) ? convertDateTime(pubDate) : null;
            return result;
        }
        public DateTime convertDateTime(string strDT){

            Map<string,integer> MapMonthList = new Map<string,integer>();
            MapMonthList.put('Jan',1);
            MapMonthList.put('Feb',2);
            MapMonthList.put('Mar',3);
            MapMonthList.put('Apr',4);
            MapMonthList.put('May',5);
            MapMonthList.put('Jun',6);
            MapMonthList.put('Jul',7);
            MapMonthList.put('Aug',8);
            MapMonthList.put('Sep',9);
            MapMonthList.put('Oct',10);
            MapMonthList.put('Nov',11);
            MapMonthList.put('Dec',12);

            String[] strDTDivided = strDT.split(' ');

            string day = strDTDivided.get(1).replace(',', '');
            string month = String.ValueOf(MapMonthList.get(strDTDivided.get(2)));

            string year = strDTDivided.get(3);

            string hour = strDTDivided.get(4).split(':').get(0);
            string minute = strDTDivided.get(4).split(':').get(1);
            string second = strDTDivided.get(4).split(':').get(2);

            string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;

            return datetime.valueOf(stringDate);

        }

    }
     
    public static RSSParser.channel getRSSData(string feedURL) {
         
        HttpRequest req = new HttpRequest();
        req.setEndpoint(feedURL);
        req.setMethod('GET');
         
        Dom.Document doc = new Dom.Document();
        Http h = new Http();
        
        

            String res = h.send(req).getBody();


            res = res.replaceAll('<description><!\\[CDATA\\[<p>','<description>'); 
            res = res.replaceAll('&#8230; <a[\\s\\S]*?]]>', '');

            doc.load(res);

        
         
        Dom.XMLNode rss = doc.getRootElement();

        Dom.XMLNode channel = rss.getChildElements()[0];
         
        RSSParser.channel result = new RSSParser.channel();
         
        list<RSSParser.item> rssItems = new list<RSSParser.item>();

        for(Dom.XMLNode elements : channel.getChildElements()) {
            if('title' == elements.getName()) {
                result.title = elements.getText();
            }
            if('link' == elements.getName()) {
                result.link = elements.getText();
            }
            if('description' == elements.getName()) {
                result.description = elements.getText();
            }
            if('category' == elements.getName()) {
                result.category = elements.getText();
            }
            if('copyright' == elements.getName()) {
                result.copyright = elements.getText();
            }
            if('docs' == elements.getName()) {
                result.docs = elements.getText();
            }
            if('image' == elements.getName()) {
                RSSParser.image img = new RSSParser.image();
                
                for(Dom.XMLNode xmlImage : elements.getChildElements()) {
                    if('url' == xmlImage.getName()) {
                        img.url = xmlImage.getText();
                    }
                    if('title' == xmlImage.getName()) {
                        img.title = xmlImage.getText();
                    }
                    if('link' == xmlImage.getName()) {
                        img.link = xmlImage.getText();
                    }
                }
                result.image = img;
            }
             
            if('item' == elements.getName()) {
                RSSParser.item rssItem = new RSSParser.item();
                
                for(Dom.XMLNode xmlItem : elements.getChildElements()) {
                    if('title' == xmlItem.getName()) {
                        rssItem.title = xmlItem.getText();
                    }
                    if('guid' == xmlItem.getName()) {
                        rssItem.guid = xmlItem.getText();
                    }
                    if('link' == xmlItem.getName()) {
                        
                        rssItem.link = xmlItem.getText();
                    }
                    if('description' == xmlItem.getName()) {
                        rssItem.description = xmlItem.getText();
                    }
                    if('pubDate' == xmlItem.getName()) {
                        rssItem.pubDate = xmlItem.getText();
                    }
                    if('source' == xmlItem.getName()) {
                        rssItem.source = xmlItem.getText();
                    }
                }
                rssItems.add(rssItem);
            }
             
        }
        result.items = rssItems;
         
        return result;
         
    }
}