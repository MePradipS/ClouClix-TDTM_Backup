@isTest
public class EventIdUpdateOnGiftTriggerTest{
    public testMethod static void EventIdUpdateOnGiftTriggerTest(){
        String eventTypeQuery = 'Select Name, Id From RecordType where Name = \'Event\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> eventType = database.query(eventTypeQuery);
        
        String appealTypeQuery = 'Select Name, Id From RecordType where Name = \'Appeal\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> AppealType = database.query(appealTypeQuery);
        
        String campaignTypeQuery = 'Select Name, Id From RecordType where Name = \'Campaign\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> CampaignType = database.query(campaignTypeQuery);

        String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> rtypes = database.query(rtypesQuery);
        
        if (CampaignType.size() > 0 && AppealType.size() > 0 && eventType.size() > 0)
        {
            App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = AppealType[0].id, Campaign_RecordType_Id__c = CampaignType[0].id, 
            Event_RecordType_Id__c = eventType[0].id, Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
            insert app;
        }

        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1; 
           
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;

        if (rtypes.size() > 0)
        {
            BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id, BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
            insert cs2;
        }
        
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
    
        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        insert g;
      
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Check';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Pending';
        p1.Donation__c = g.Id;
        insert p1;
        
        if (eventType.size() > 0)
        {
            Campaign camp = new Campaign();
            camp.RecordTypeId = eventType[0].id;
            camp.Name = 'sss';
            insert camp;
            
            Event_Level__c elev = new Event_Level__c();
            elev.Event__c = camp.Id;
            elev.Quantity_Available__c = 50;
            insert elev;    
          
            Gift_Detail__c gd = new Gift_Detail__c();
            gd.New_campaign__c = camp.Id;
            gd.Event_Level__c  = elev.Id;
            gd.Gift__c = g.Id;
            gd.Payment__c = p1.Id;
            gd.Quantity__c = 50;
            insert gd; 
            
            List<Gift__c> giftList = new GiftSelector().SelectEventById(new Set<Id> { g.id });
            Gift__c g1 = giftList[0];
            System.assertEquals(g1.Event_Id__c,gd.New_Campaign__c);
        }
    } 
}