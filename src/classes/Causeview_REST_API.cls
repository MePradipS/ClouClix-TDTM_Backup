public class Causeview_REST_API 
{
    private string token;
    private string api_url;
    
    public Causeview_REST_API() {
        App_Settings__c settings = App_Settings__c.getInstance();
        if (settings != null) {
            token = settings.CV_Auth_Token__c;
            api_url = settings.Causeview_REST_API_URL__c;
        }
    }
    
    public Actionpage GetActionpage(string form_id) {
        Actionpage retVal = new Actionpage();
        string results = HttpGet(api_url + '/Form/' + form_id);
        if (results != '') { retVal = (Actionpage)JSON.deserialize(results, Actionpage.class); }
        return retVal;
    }        
    
    private string HttpGet(string url) {
        Http h = new Http();    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');       
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        
        if (!Test.isRunningTest()) { 
            HttpResponse res = h.send(req);    
            if (res.getStatusCode() >= 200 && res.getStatusCode() <= 299) {
                if (res.getBody() == '') return 'OK';
                return res.getBody();                   
            }
        }
        return '';        
    }
}