public with sharing class Generic_Form_Admin_Panel_Controller {

    public String accountId { get; set; }
    public String sessionId{ get; set; }
    public String pageUrl { get; set; }

    public Generic_Form_Admin_Panel_Controller(){
            
        App_Settings__c settings = App_Settings__c.getInstance();
        accountId = settings.CV_Account_Id__c;
        
        
    }

}