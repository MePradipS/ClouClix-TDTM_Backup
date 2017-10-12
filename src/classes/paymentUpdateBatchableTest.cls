@isTest
public class paymentUpdateBatchableTest{
    public static testMethod Void paymentUpdateBatchableTest(){
        
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
        
        Recurring_Donation__c recurringGift = new Recurring_Donation__c();
        recurringGift.Constituent__c = contacts.Id;
        recurringGift.Start_Date__c = system.Today();
        recurringGift.Credit_Card_Type__c = 'Visa';
        recurringGift.Credit_Card__c = '4222222222222220';
        recurringGift.Credit_Card_Expiry_Date__c = system.Today()+2000;
        Insert recurringGift;
        
        Gift__c gift = new Gift__c();
        gift.Recurring_Donation__c = recurringGift.Id;
        gift.Status__c = 'Active';
        gift.Constituent__c = contacts.Id;
        gift.Gift_Date__c = system.today().addyears(-1);
        gift.Gift_Type__c  = 'Recurring';
        Insert gift;
        
        
        Gift__c gift1 = new Gift__c();
        gift1.Recurring_Donation__c = recurringGift.Id;
        gift1.Status__c = 'Active';
        gift1.Organization__c = a.Id;
        gift1.Gift_Date__c = system.today();
        gift1.Gift_Type__c  = 'Recurring';
        Insert gift1;
        
        Payment__c payment = new Payment__c();
        payment.Date__c = System.Today();
        payment.Amount__c = 1000.00;
        payment.Payment_Type__c = 'other';
        payment.Donation__c = gift.Id;
        payment.Status__c = 'Approved';
        Insert payment;
        
        Payment__c payment1 = new Payment__c();
        payment1.Date__c = System.Today()+365;
        payment1.Amount__c = 1000.00;
        payment1.Payment_Type__c = 'other';
        payment1.Donation__c = gift1.Id;
        payment1.Status__c = 'Approved';
        Insert payment1;
        paymentUpdateBatchable p = new paymentUpdateBatchable();
        Database.executeBatch(p);
    }
}