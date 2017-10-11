@isTest
public class NewYearTransaction2016batchSchedulerTest {
    public static testMethod void NewYearTransaction2016batchSchedulerTest(){
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
        
        
        Recurring_Donation__c recurringGift1 = new Recurring_Donation__c();
        recurringGift1.Constituent__c = contacts.Id;
        recurringGift1.Start_Date__c = system.Today();
        recurringGift1.Credit_Card_Type__c = 'Visa';
        recurringGift1.Credit_Card__c = '4222222222222220';
        recurringGift1.Credit_Card_Expiry_Date__c = system.Today()+2000;
        recurringGift1.Status__c='Active';
        Insert recurringGift1;
        
        Recurring_Donation__c recurringGift2 = new Recurring_Donation__c();
        recurringGift2.Constituent__c = contacts.Id;
        recurringGift2.Start_Date__c = system.Today();
        recurringGift2.Credit_Card_Type__c = 'Visa';
        recurringGift2.Credit_Card__c = '4222222222222220';
        recurringGift2.Credit_Card_Expiry_Date__c = system.Today()+2000;
        recurringGift2.Status__c='On Hold';
        Insert recurringGift2;
        
        Recurring_Donation__c recurringGift3 = new Recurring_Donation__c();
        recurringGift3.Constituent__c = contacts.Id;
        recurringGift3.Start_Date__c = system.Today();
        recurringGift3.Credit_Card_Type__c = 'Visa';
        recurringGift3.Credit_Card__c = '4222222222222220';
        recurringGift3.Credit_Card_Expiry_Date__c = system.Today()+2000;
        recurringGift3.Status__c='Cancelled';
        Insert recurringGift3;
        
        Gift__c gift1 = new Gift__c();
        gift1.Recurring_Donation__c = recurringGift1.Id;
        gift1.Status__c = 'Active';
        gift1.Constituent__c = contacts.Id;
        gift1.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift1.Gift_Type__c  = 'Recurring';
        Insert gift1;
        
        Gift__c gift2 = new Gift__c();
        gift2.Recurring_Donation__c = recurringGift1.Id;
        gift2.Status__c = 'Acknowledged';
        gift2.Constituent__c = contacts.Id;
        gift2.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift2.Gift_Type__c  = 'Recurring';
        Insert gift2;
        
        Gift__c gift3 = new Gift__c();
        gift3.Recurring_Donation__c = recurringGift1.Id;
        gift3.Status__c = 'Payment Received';
        gift3.Constituent__c = contacts.Id;
        gift3.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift3.Gift_Type__c  = 'Recurring';
        Insert gift3;
        
        Gift__c gift31 = new Gift__c();
        gift31.Recurring_Donation__c = recurringGift1.Id;
        gift31.Status__c = 'Entered';
        gift31.Constituent__c = contacts.Id;
        gift31.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift31.Gift_Type__c  = 'Recurring';
        Insert gift31;
        
        Gift__c gift32 = new Gift__c();
        gift32.Recurring_Donation__c = recurringGift1.Id;
        gift32.Status__c = 'Cancelled';
        gift32.Constituent__c = contacts.Id;
        gift32.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift32.Gift_Type__c  = 'Recurring';
        Insert gift32;
        
        Gift__c gift4 = new Gift__c();
        gift4.Recurring_Donation__c = recurringGift2.Id;
        gift4.Status__c = 'Active';
        gift4.Constituent__c = contacts.Id;
        gift4.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift4.Gift_Type__c  = 'Recurring';
        Insert gift4;
        
        Gift__c gift5 = new Gift__c();
        gift5.Recurring_Donation__c = recurringGift2.Id;
        gift5.Status__c = 'Acknowledged';
        gift5.Constituent__c = contacts.Id;
        gift5.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift5.Gift_Type__c  = 'Recurring';
        Insert gift5;
        
        Gift__c gift6 = new Gift__c();
        gift6.Recurring_Donation__c = recurringGift2.Id;
        gift6.Status__c = 'Payment Received';
        gift6.Constituent__c = contacts.Id;
        gift6.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift6.Gift_Type__c  = 'Recurring';
        Insert gift6;
        
        Gift__c gift61 = new Gift__c();
        gift61.Recurring_Donation__c = recurringGift2.Id;
        gift61.Status__c = 'Entered';
        gift61.Constituent__c = contacts.Id;
        gift61.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift61.Gift_Type__c  = 'Recurring';
        Insert gift61;
        
        Gift__c gift62 = new Gift__c();
        gift62.Recurring_Donation__c = recurringGift2.Id;
        gift62.Status__c = 'Completed';
        gift62.Constituent__c = contacts.Id;
        gift62.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift62.Gift_Type__c  = 'Recurring';
        Insert gift62;
        
        Gift__c gift7 = new Gift__c();
        gift7.Recurring_Donation__c = recurringGift3.Id;
        gift7.Status__c = 'Active';
        gift7.Constituent__c = contacts.Id;
        gift7.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift7.Gift_Type__c  = 'Recurring';
        Insert gift7;
        
        Gift__c gift8 = new Gift__c();
        gift8.Recurring_Donation__c = recurringGift3.Id;
        gift8.Status__c = 'Acknowledged';
        gift8.Constituent__c = contacts.Id;
        gift8.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift8.Gift_Type__c  = 'Recurring';
        Insert gift8;
        
        Gift__c gift9 = new Gift__c();
        gift9.Recurring_Donation__c = recurringGift3.Id;
        gift9.Status__c = 'Payment Received';
        gift9.Constituent__c = contacts.Id;
        gift9.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift9.Gift_Type__c  = 'Recurring';
        Insert gift9;
        
        Gift__c gift91 = new Gift__c();
        gift91.Recurring_Donation__c = recurringGift3.Id;
        gift91.Status__c = 'Entered';
        gift91.Constituent__c = contacts.Id;
        gift91.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift91.Gift_Type__c  = 'Recurring';
        Insert gift91;
        
        Gift__c gift92 = new Gift__c();
        gift92.Recurring_Donation__c = recurringGift3.Id;
        gift92.Status__c = 'Cancelled';
        gift92.Constituent__c = contacts.Id;
        gift92.Gift_Date__c = Date.newinstance(2016, 2, 17);
        gift92.Gift_Type__c  = 'Recurring';
        Insert gift92;
        
        
        
        Test.StartTest();
        NewYearTransaction2016batch N = new NewYearTransaction2016batch();     
        
        Database.executeBatch(N);
        Test.stopTest();
    }
}