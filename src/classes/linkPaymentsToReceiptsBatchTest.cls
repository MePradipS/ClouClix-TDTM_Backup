@isTest
public class linkPaymentsToReceiptsBatchTest{
    public static testMethod void linkPaymentsToReceiptsBatch(){
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
            Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;
        
        String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> rtypes = database.query(rtypesQuery);
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  

        if (rtypes.size() > 0)
        {
            BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
            insert cs2;
        }
        
        Contact contacts = new Contact();
        contacts.LastName = 'Constituent Test';
        Insert contacts;
        
        Gift__c gift1 = new Gift__c();
        
        gift1.Status__c = 'Active';
        gift1.Constituent__c = contacts.Id;
        gift1.Gift_Date__c = Date.newinstance(2015, 2, 17);
        gift1.Gift_Type__c  = 'one time';
        Insert gift1;
        
        
        Receipt__c r = new Receipt__c();
       r.Receipt_Type__c = 'Single';
       r.Gift__c = gift1.Id;
       r.Amount_Not_Eligible__c= 0;
        r.Status__c = 'Issued';
        insert r;
        
        
        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'Check';
        p2.Amount__c = 85;
        p2.Donation__c = gift1.Id;
        p2.Status__c  = 'Approved';
        insert p2;

        Test.StartTest();
        linkPaymentsToReceiptsBatch N = new linkPaymentsToReceiptsBatch();     
       
        Database.executeBatch(N);
        
        ReceiptBodyExportController re = new ReceiptBodyExportController();
        string str = re.content;
        
        ReceiptAttachExportController re1 = new ReceiptAttachExportController();
        string str1 = re1.content;
        
        Test.stopTest();
    }
}