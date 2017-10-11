public with sharing class RSSFeedReaderController {
     
    private String rssURL {get;set;}
     
    public RSSFeedReaderController() {       
        rssURL = 'http://causeview.com/category/advancement-blog/feed/';         
    }
     
    public RSSParser.channel getRSSFeed() {
        return RSSParser.getRSSData(rssURL);
    }
}