@isTest
class testupdateConstAndOrgLookupsTrigger {
    static testMethod void testTrigger() {
        String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> rtypes = database.query(rtypesQuery);

        Contact c = new Contact(lastName='testContact', Email='test@contact.com');
        Insert c;
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        
        if (rtypes.size() > 0)
        {
            BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id, BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
            insert cs2;
        }
        Gift__c d1 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert d1;
        Gift__c d2 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=null, Organization__c=a.Id); 
        Insert d2;

        Test.startTest();

        Receipt__c r1 = new Receipt__c(Gift__c=d1.Id);
        Insert r1;
        r1.Amount_Receipted__c = 100;
        Update r1;

        Receipt__c r2 = new Receipt__c(Gift__c=d2.Id);
        Insert r2;

        Test.stopTest();
    }
}