@isTest
public class TestInsertSoftCreditTrigger{

    private static string NamespacePrefix = Utilities.getCurrentNamespace();
    private static String NamespaceField = NamespacePrefix + (String.isEmpty(NamespacePrefix) ? '' : '__');
    private static String NamespacePayment = NamespaceField + 'Payment__c';

    static testmethod void TestInsertingSoftCredit () {
    
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
        
        Contact c = testMapping.createContact();
        
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Gift__c g = testMapping.createGift(c);
        g.RecordTypeId = '012A000000128DT';
        Payment__c p = new Payment__c(
            CC_Reference__c = 'SSSESESE',
            Donation__c = g.Id,
            Amount__c = 200,
            Status__c = 'Approved',
            Payment_Type__c = 'Cash');
        p.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = :NamespacePayment AND Name = 'Standard'].Id;            
        insert p;
        
        Campaign camp = new Campaign (Name='CADDFFD');
        Fund__c fund = new Fund__c();
        Gift_Detail__c alloc1 = new Gift_Detail__c(
            Amount__c = 200,
            Campaign__c = camp.Id,
            Fund__c = fund.Id);
            

        Test.startTest();
        Solicitor__c SoftCredit = new Solicitor__c(
            Gift__c = g.Id,
            Solicitor__c = g.Constituent__c
        );

        
    }    
        
}