@isTest
Public class RollupBatchTest{
    public static testMethod void RollupBatchTest(){
        
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
            Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;
        
        String retypeQuery = 'SELECT Id FROM RecordType WHERE SobjectType = \'Account\' AND Name = \'Household\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' Limit 1';
        List<RecordType> retype = database.query(retypeQuery);
        
         Map<string, decimal> conversionRates = new Map <string, decimal>();
        
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        
        Id rtypes = rtype_Map.get('Gift');
        Id rtypes1 = rtype_Map.get('Matching Gift');
        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes,Record_Type_Id_for_Rollups__c = rtypes, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
        
        Contact contacts = new Contact(FirstName = 'Test', LastName = 'Test');
        insert contacts;
        contacts.Total_Lifetime_Giving__c=0;
        contacts.Total_Lifetime_Transaction_Amount__c=0;
        
        
        Contact contacts1 = new Contact(FirstName = 'Test1', LastName = 'Test12');
        insert contacts1;
        
        Contact contacts3 = new Contact(FirstName = 'Test13', LastName = 'Test13');
        insert contacts3;
        
        if (retype.size() > 0)
        {
            Account acObj = new Account (Name = 'Test Household', RecordTypeId = retype[0].Id);
            Insert acObj;
            
            contacts.Household__c = acObj.Id;
            update contacts;
        }
        
        Gift__c gift = new Gift__c();
        gift.Status__c = 'Active';
        gift.Constituent__c = contacts.Id;
        gift.Gift_Date__c = system.today();
        gift.Gift_Type__c  = 'One Time Gift';
        gift.RecordTypeId  = rtypes;
        //gift.Status__c = 'Active';
        Insert gift;
        
        Gift__c gift1 = new Gift__c();
        gift1.Status__c = 'Active';
        gift1.Constituent__c = contacts1.Id;
        gift1.Gift_Date__c = system.today();
        gift1.Gift_Type__c  = 'One Time Gift';
        gift1.RecordTypeId  = rtypes;
        //gift1.Status__c = 'Active';
        Insert gift1;
        
        Payment__c payment = new Payment__c();
        payment.Date__c = System.Today();
        payment.Amount__c = 1000.00;
        payment.Payment_Type__c = 'other';
        payment.Donation__c = gift.Id;
        payment.Status__c = 'Approved';
        Insert payment;
        
        Payment__c payment1 = new Payment__c();
        payment1.Date__c = System.Today();
        payment1.Amount__c = 1000.00;
        payment1.Payment_Type__c = 'other';
        payment1.Donation__c = gift1.Id;
        payment1.Status__c = 'Approved';
        Insert payment1;
        
        Gift__c gift3 = new Gift__c();
        gift3.Status__c = 'Active';
        gift3.Constituent__c = contacts1.Id;
        gift3.Gift_Date__c = system.today();
        gift3.Gift_Type__c  = 'One Time Gift';
        gift3.RecordTypeId  = rtypes1;
        //gift1.Status__c = 'Active';
        Insert gift3;
        
        Payment__c payment3 = new Payment__c();
        payment3.Date__c = System.Today();
        payment3.Amount__c = 1000.00;
        payment3.Payment_Type__c = 'other';
        payment3.Donation__c = gift3.Id;
        payment3.Status__c = 'Approved';
        Insert payment3;
        
        Gift__c gift4 = new Gift__c();
        gift4.Status__c = 'Active';
        gift4.Constituent__c = contacts1.Id;
        gift4.Primary_Solicitor__c = contacts1.Id;
        gift4.Gift_Date__c = system.today();
        gift4.Gift_Type__c  = 'One Time Gift';
        gift4.RecordTypeId  = rtypes1;
        //gift1.Status__c = 'Active';
        Insert gift4;
        
        Payment__c payment4 = new Payment__c();
        payment4.Date__c = System.Today();
        payment4.Amount__c = 1000.00;
        payment4.Payment_Type__c = 'other';
        payment4.Donation__c = gift4.Id;
        payment4.Status__c = 'Approved';
        Insert payment4;
        
        Solicitor__c softCredit = new Solicitor__c(Gift__c=gift1.id, Custom_Amount__c =8, Solicitor__c = contacts1.id);
        insert softCredit;
        
        date todaysdate = system.today();
        DateTime n =system.today();
        
        Gift__c gift5 = new Gift__c();
        gift5.Status__c = 'Active';
        gift5.Constituent__c = contacts1.Id;
        gift5.Gift_Date__c = todaysdate.addYears(-2);
        gift5.Gift_Type__c  = 'One Time Gift';
        gift5.RecordTypeId  = rtypes;
        //gift1.Status__c = 'Active';
        Insert gift5;
        
        Payment__c payment5 = new Payment__c();
        payment5.Date__c = todaysdate.addYears(-2);
        payment5.Amount__c = 1000.00;
        payment5.Payment_Type__c = 'other';
        payment5.Donation__c = gift5.Id;
        payment5.Status__c = 'Approved';
        Insert payment5;
        
        Gift__c gift6 = new Gift__c();
        gift6.Status__c = 'Active';
        gift6.Constituent__c = contacts1.Id;
        gift6.Gift_Date__c = todaysdate.addYears(-1);
        gift6.Gift_Type__c  = 'One Time Gift';
        gift6.RecordTypeId  = rtypes;
        //gift1.Status__c = 'Active';
        Insert gift6;
        
        Payment__c payment6 = new Payment__c();
        payment6.Date__c = todaysdate.addYears(-1);
        payment6.Amount__c = 1000.00;
        payment6.Payment_Type__c = 'other';
        payment6.Donation__c = gift6.Id;
        payment6.Status__c = 'Approved';
        Insert payment6;
        
        Gift__c gift7 = new Gift__c();
        gift7.Status__c = 'Active';
        gift7.Constituent__c = contacts3.Id;
        gift7.Gift_Date__c = system.today();
        gift7.Gift_Type__c  = 'One Time Gift';
        gift7.RecordTypeId  = rtypes;
        //gift1.Status__c = 'Active';
        Insert gift7;
        
        Payment__c payment7 = new Payment__c();
        payment7.Date__c = system.today();
        payment7.Amount__c = 1000.00;
        payment7.Payment_Type__c = 'other';
        payment7.Donation__c = gift7.Id;
        payment7.Status__c = 'Approved';
        Insert payment7;
        
        delete payment7;
        delete gift7;

        Test.startTest();
        
        RollupBatch r = new RollupBatch();
        Database.executeBatch(r); 
        RollupBatch.conversionRates.put('USD',1.00);
        RollupBatch.conversionRates.put('CAD',1.00);
        decimal dd = 78.00;
        Decimal d = RollupBatch.ConvertCurrencyWithApexCode('USD','CAD', dd);
       
        
        RollupBatch r1 = new RollupBatch(n);
        Database.executeBatch(r1); 

        Test.stopTest();   
       
        Contact c=[select id,name, Last_Payment_Date__c,Average_Gift__c,Largest_Gift__c,Date_of_First_Gift__c,Date_of_Last_Gift__c,Date_of_First_Transaction__c,Date_of_Last_Transaction__c,Total_Giving_Two_Years_Ago__c,Total_Giving_Last_Year__c ,Consecutive_Years_of_Transactions__c,Total_Fundraising_Last_Fiscal_Year__c,Consecutive_Years_of_Giving__c,Total_Fiscal_Fundraising__c,Total_Lifetime_Fundraising__c,Last_Payment_Amount__c,Last_Gift_Amount__c, Total_Fiscal_Transaction_Amount__c,Total_Fiscal_Transactions__c,Total_Lifetime_Transaction_Amount__c,Total_Lifetime_Transactions__c,Total_Lifetime_Gifts__c,Total_Lifetime_Giving__c,Total_Fiscal_Gifts__c,Total_Fiscal_Year_Giving__c from Contact where id =:contacts.id];
       
        system.assertEquals(1,c.Total_Lifetime_Gifts__c);
        system.assertEquals(1000.00,c.Total_Fiscal_Year_Giving__c);
        system.assertEquals(1,c.Total_Lifetime_Transactions__c);
        system.assertEquals(1000.00,c.Total_Lifetime_Transaction_Amount__c);
        system.assertEquals(1,c.Total_Fiscal_Transactions__c);
        system.assertEquals(1000.00,c.Total_Fiscal_Transaction_Amount__c);
        system.assertEquals(1000.00,c.Last_Gift_Amount__c);
        system.assertEquals(1000.00,c.Last_Payment_Amount__c);
        system.assertEquals(1000.00,c.Total_Lifetime_Fundraising__c);
        system.assertEquals(1000.00,c.Total_Fiscal_Fundraising__c);
        system.assertEquals(1,c.Consecutive_Years_of_Giving__c);
        system.assertEquals(0.00,c.Total_Fundraising_Last_Fiscal_Year__c);
        system.assertEquals(1,c.Consecutive_Years_of_Transactions__c);
        system.assertEquals(0.00,c.Total_Giving_Last_Year__c);
        system.assertEquals(0.00,c.Total_Giving_Two_Years_Ago__c);
        system.assertEquals(system.today(),c.Date_of_Last_Transaction__c);
        system.assertEquals(system.today(),c.Date_of_First_Transaction__c);
        system.assertEquals(system.today(),c.Date_of_Last_Gift__c);
        system.assertEquals(system.today(),c.Date_of_First_Gift__c);
        system.assertEquals(1000.00,c.Largest_Gift__c);
        system.assertEquals(1000.00,c.Average_Gift__c);
        system.assertEquals(system.today(),c.Last_Payment_Date__c);
        
    }

    public static testMethod void testPostInstallNull(){
        PostInstall testPost = new PostInstall();
        Test.testInstall(testPost,  null);
    }

    public static testMethod void TestPostInstallVersion()
    {
        PostInstall testPost = new PostInstall();
        Test.testInstall(testPost,  new Version(1, 0));
    }
}