@isTest
public class creditDetailUpdationOnGiftTest{
    public static testMethod void creditDetailUpdationOnGiftTest(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Event\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes_Map.put(r.Name, r.Id);
        }
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;     
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact contacts = new Contact();
        contacts.LastName = 'Constituent Test';
        Insert contacts;
        
        Gift__c gift = new Gift__c();
        gift.Status__c = 'Active';
        gift.Constituent__c = contacts.Id;
        Insert gift;    
        
        
        Payment__c payment = new Payment__c();
        payment.Date__c = System.Today()-2;
        payment.Amount__c = 1000.00;
        payment.Payment_Type__c = 'Credit Card';
        payment.Donation__c = gift.Id;
        payment.Status__c = 'Approved';
        payment.Credit_Card_Type__c = 'Visa';
        payment.Credit_Card_Number__c = '1234567891234567';
        Insert payment;
        
        Payment__c payment1 = new Payment__c();
        payment1.Date__c = System.Today()-1;
        payment1.Amount__c = 1000.00;
        payment1.Payment_Type__c = 'Credit Card';
        payment1.Donation__c = gift.Id;
        payment1.Status__c = 'Approved';
        payment1.Credit_Card_Type__c = 'Visa';
        payment1.Credit_Card_Number__c = '4222222222222220';
        Test.StartTest();
        Insert payment1;
        Test.StopTest();
        //System.assertEquals(payment1.Credit_Card_Number__c, gift.Credit_Card_Number__c);
        //System.assertEquals(payment1.Credit_Card_Type__c, gift.Credit_Card_Type__c);
        delete payment1;
    }
}