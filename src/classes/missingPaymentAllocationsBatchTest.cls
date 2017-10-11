@isTest(SeeAllData=false)
private class missingPaymentAllocationsBatchTest {    
    static testmethod void testMissingRecurringGiftAllocation() {
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
            Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Map<string, decimal> conversionRates = new Map <string, decimal>();
        
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        
        Id rtypes = rtype_Map.get('Gift');
        Id rtypes1 = rtype_Map.get('Matching Gift');
        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes,Record_Type_Id_for_Rollups__c = rtypes, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;

        //Initialize Causeview
        //App_Settings__c CvAppSettings = GetAppSettings();
        //BatchSettings__c CvBatchSettings = GetBatchSettings();        
        Fund__c testFund = CreateTestFund();
        Campaign testAppeal = CreateTestAppeal(testFund.Id);

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
        gift.Gift_Date__c = system.today();
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
        payment1.Donation__c = gift.Id;
        payment1.Status__c = 'Approved';
        Insert payment1;
        
        Test.startTest();       
        	Database.executeBatch(new MissingPaymentAllocationsBatch(),200);
      	Test.stopTest();
    }
    
    static testmethod void testMissingPaymentAllocation() {
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
            Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Map<string, decimal> conversionRates = new Map <string, decimal>();
        
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        
        Id rtypes = rtype_Map.get('Gift');
        Id rtypes1 = rtype_Map.get('Matching Gift');
        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes,Record_Type_Id_for_Rollups__c = rtypes, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;

        //Initialize Causeview
        //App_Settings__c CvAppSettings = GetAppSettings();
        //BatchSettings__c CvBatchSettings = GetBatchSettings();        
        Fund__c testFund = CreateTestFund();
        Campaign testAppeal = CreateTestAppeal(testFund.Id);
        
        // create contacts
        List<Contact> contactList = CreateTestContact(2);
        List<Recurring_Donation__c> recurringGiftList = new List<Recurring_Donation__c>();
        // create recurring gifts
        for(Contact con: contactList){
            recurringGiftList.add(CreateTestRecurringGift(1, con.Id));
        }
        // create recurring gift allocation
        List<RD_Allocation__c> recurringGiftAllocationList = new List<RD_Allocation__c>();
        for(Recurring_Donation__c rgi: recurringGiftList){
            recurringGiftAllocationList.add(CreateTestRecurringGiftAllocation(rgi.Id));
        }
        // create transactions
        List<Gift__c> transactionList = new List<Gift__c>();
        for(Recurring_Donation__c recG: recurringGiftList){
            transactionList.add(CreateTestTransaction(1, recG.Id, recG.Constituent__c));
        }
        // create payments
        List<Payment__c> paymentList = new List<Payment__c>();
        for(Gift__c trans:transactionList){
            paymentList.add(CreateTestPayment(trans.Id));
        }        

        Test.startTest();       
            Database.executeBatch(new MissingPaymentAllocationsBatch(),200);
        Test.stopTest();
    }    
    
    static testmethod void testMissingPaymentAllocationData() {
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
            Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;
        
        Map<string, decimal> conversionRates = new Map <string, decimal>();
        
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        
        Id rtypes = rtype_Map.get('Gift');
        Id rtypes1 = rtype_Map.get('Matching Gift');
        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes,Record_Type_Id_for_Rollups__c = rtypes, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;

        //Initialize Causeview
        //App_Settings__c CvAppSettings = GetAppSettings();
        //BatchSettings__c CvBatchSettings = GetBatchSettings();
        Fund__c testFund = CreateTestFund();
        Campaign testAppeal = CreateTestAppeal(testFund.Id);
        
        // create contacts
        List<Contact> contactList = CreateTestContact(2);
        List<Recurring_Donation__c> recurringGiftList = new List<Recurring_Donation__c>();
        // create recurring gifts
        for(Contact con: contactList){
            recurringGiftList.add(CreateTestRecurringGift(1, con.Id));
        }
        // create recurring gift allocation
        List<RD_Allocation__c> recurringGiftAllocationList = new List<RD_Allocation__c>();
        for(Recurring_Donation__c rgi: recurringGiftList){
            recurringGiftAllocationList.add(CreateTestRecurringGiftAllocation(rgi.Id));
        }
        // create transactions
        List<Gift__c> transactionList = new List<Gift__c>();
        for(Recurring_Donation__c recG: recurringGiftList){
            transactionList.add(CreateTestTransaction(1, recG.Id, recG.Constituent__c));
        }
        // create payments
        List<Payment__c> paymentList = new List<Payment__c>();
        for(Gift__c trans:transactionList){
            paymentList.add(CreateTestPayment(trans.Id));
        }
        // create payment allocation
        //   
        //List<Gift_Detail__c> paymentAllocationList = new List<Gift_Detail__c>();
        //for(Payment__c pay: paymentList){
        //    paymentAllocationList.add( CreateTestPaymentAllocation(testAppeal.Id, testFund.Id, pay.Donation__c, pay.Id, pay.Amount__c) );
        //s}        
        
        Test.startTest();       
            Database.executeBatch(new MissingPaymentAllocationsBatch(),200);
        Test.stopTest();
    }   
    
    static testmethod void testPassingSinglePaymentId() {
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
            Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Map<string, decimal> conversionRates = new Map <string, decimal>();
        
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        
        Id rtypes = rtype_Map.get('Gift');
        Id rtypes1 = rtype_Map.get('Matching Gift');
        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes,Record_Type_Id_for_Rollups__c = rtypes, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;

        //Initialize Causeview
        //App_Settings__c CvAppSettings = GetAppSettings();
        //BatchSettings__c CvBatchSettings = GetBatchSettings();
        Fund__c testFund = CreateTestFund();
        Campaign testAppeal = CreateTestAppeal(testFund.Id);

        // create contacts
        List < Contact > contactList = CreateTestContact(2);
        List < Recurring_Donation__c > recurringGiftList = new List < Recurring_Donation__c > ();
        // create recurring gifts
        for (Contact con: contactList) {
            recurringGiftList.add(CreateTestRecurringGift(1, con.Id));
        }
        // create recurring gift allocation
        List < RD_Allocation__c > recurringGiftAllocationList = new List < RD_Allocation__c > ();
        for (Recurring_Donation__c rgi: recurringGiftList) {
            recurringGiftAllocationList.add(CreateTestRecurringGiftAllocation(rgi.Id));
        }
        // create transactions
        List < Gift__c > transactionList = new List < Gift__c > ();
        for (Recurring_Donation__c recG: recurringGiftList) {
            transactionList.add(CreateTestTransaction(1, recG.Id, recG.Constituent__c));
        }
        // create payments
        List < Payment__c > paymentList = new List < Payment__c > ();
        for (Gift__c trans: transactionList) {
            paymentList.add(CreateTestPayment(trans.Id));
        }

        Test.startTest();
        Database.executeBatch(new MissingPaymentAllocationsBatch(paymentList[0].Id), 200);
        Test.stopTest();
    }

    static testmethod void testPassingPaymentList() {
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
            Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;
        
        Map<string, decimal> conversionRates = new Map <string, decimal>();
        
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        
        Id rtypes = rtype_Map.get('Gift');
        Id rtypes1 = rtype_Map.get('Matching Gift');
        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes,Record_Type_Id_for_Rollups__c = rtypes, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;

        //Initialize Causeview
        //App_Settings__c CvAppSettings = GetAppSettings();
        //BatchSettings__c CvBatchSettings = GetBatchSettings();
        Fund__c testFund = CreateTestFund();
        Campaign testAppeal = CreateTestAppeal(testFund.Id);

        // create contacts
        List < Contact > contactList = CreateTestContact(2);
        List < Recurring_Donation__c > recurringGiftList = new List < Recurring_Donation__c > ();
        // create recurring gifts
        for (Contact con: contactList) {
            recurringGiftList.add(CreateTestRecurringGift(1, con.Id));
        }
        // create recurring gift allocation
        List < RD_Allocation__c > recurringGiftAllocationList = new List < RD_Allocation__c > ();
        for (Recurring_Donation__c rgi: recurringGiftList) {
            recurringGiftAllocationList.add(CreateTestRecurringGiftAllocation(rgi.Id));
        }
        // create transactions
        List < Gift__c > transactionList = new List < Gift__c > ();
        for (Recurring_Donation__c recG: recurringGiftList) {
            transactionList.add(CreateTestTransaction(1, recG.Id, recG.Constituent__c));
        }
        // create payments
        List < Payment__c > paymentList = new List < Payment__c > ();
        for (Gift__c trans: transactionList) {
            paymentList.add(CreateTestPayment(trans.Id));
        }
        Set<Id> paymentIdSet = new Set<Id>();
        for(Payment__c payment: paymentList){
            paymentIdSet.add(payment.Id);
        }

        Test.startTest();
        Database.executeBatch(new MissingPaymentAllocationsBatch(paymentIdSet), 200);
        Test.stopTest();
    }

    static testmethod void testRunAuto() {
        CauseViewCustomSetting.defaultANumSettings();
        CauseViewCustomSetting.defaultBatchSettings();
        CauseViewCustomSetting.defaultAppSettings();
        CauseViewCustomSetting.defaultAppTemplateSettings();

        //Initialize Causeview
        App_Settings__c CvAppSettings = GetAppSettings();
        BatchSettings__c CvBatchSettings = GetBatchSettings();
        Fund__c testFund = CreateTestFund();
        Campaign testAppeal = CreateTestAppeal(testFund.Id);        

        Test.startTest();
        Database.executeBatch(new MissingPaymentAllocationsBatch('Auto'), 200);
        Test.stopTest();
    }

    static testmethod void testCommit() {
        CauseViewCustomSetting.defaultANumSettings();
        CauseViewCustomSetting.defaultBatchSettings();
        CauseViewCustomSetting.defaultAppSettings();
        CauseViewCustomSetting.defaultAppTemplateSettings();

        //Initialize Causeview
        App_Settings__c CvAppSettings = GetAppSettings();
        BatchSettings__c CvBatchSettings = GetBatchSettings();
        Fund__c testFund = CreateTestFund();
        Campaign testAppeal = CreateTestAppeal(testFund.Id);        

        Test.startTest();
        Database.executeBatch(new MissingPaymentAllocationsBatch('Commit'), 200);
        Test.stopTest();
    }
    
    //
    // data factory
    //
    public static List<Contact> CreateTestContact(Integer numberOfContacts){
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numberOfContacts; i++){
            Contact contact = new Contact(
                FirstName = 'Test', 
                LastName = 'Contact' + Math.random(), 
                MailingCity = 'Markham', 
                MailingCountry = 'Canada', 
                MailingPostalCode = 'A1A1A1', 
                MailingState = 'Ontario', 
                MailingStreet = '355 Applecreek blv.');
            contacts.add(contact);
        }
        insert contacts;
        return contacts;
    }
    
    public static Recurring_Donation__c CreateTestRecurringGift(Integer numberOfGifts, Id contactId){
        //List<Recurring_Donation__c> recurringGifts = new List<Recurring_Donation__c>();
        //for(Integer i = 0; i < numberOfGifts; i++){
        //    Recurring_Donation__c gift = new Recurring_Donation__c(
        //        Constituent__c = contactId,
        //        Start_Date__c = system.Today(),
        //        Credit_Card_Type__c = 'Visa',
        //        Credit_Card__c = '4222222222222220',
        //        Credit_Card_Expiry_Date__c = system.Today()+2000
        //    );
        //    recurringGifts.add(gift);
        //}
        //return recurringGifts;   
        Recurring_Donation__c recurringGift = new Recurring_Donation__c(
                Constituent__c = contactId,
                Start_Date__c = system.Today(),
                Credit_Card_Type__c = 'Visa',
                Credit_Card__c = '4222222222222220',
                Credit_Card_Expiry_Date__c = system.Today()+2000
            );
        insert recurringGift;
        return recurringGift;
    }
    
    public static RD_Allocation__c CreateTestRecurringGiftAllocation(Id recurringGiftId){        
        RD_Allocation__c recurringGiftAllocation = new RD_Allocation__c(
                Recurring_Gift__c  = recurringGiftId
            );
        insert recurringGiftAllocation;
        return recurringGiftAllocation;
    }
    
    public static Gift__c CreateTestTransaction(Integer numberOfPayments, Id recurringGiftId, Id contactId){
        //List<Gift__c> transactionList = new List<Gift__c>();
        //for(Integer i = 0; i < numberOfPayments; i++){
        //    Gift__c payment = new Gift__c(
        //        Recurring_Donation__c = recurringGiftId,
        //        Status__c = 'Active',
        //        Constituent__c = contactId,
        //        Gift_Date__c = system.today(),
        //        Gift_Type__c  = 'Recurring'
        //    );
        //    transactionList.add(payment);
        //}
        //return transactionList;
        Gift__c gift =  new Gift__c(
            Recurring_Donation__c = recurringGiftId,
            Status__c = 'Active',
            Constituent__c = contactId,
            Gift_Date__c = system.today(),
            Gift_Type__c  = 'Recurring'
        );
        insert gift;
        return gift;
    }    
    
    public static Payment__c CreateTestPayment(Id giftId){
        //List<Payment__c> paymentList = new List<Payment__c>();
        //for(Integer i = 0; i < numberOfPayments; i++){
        //    Payment__c payment = new Payment__c(
        //        Date__c = System.Today(),
        //        Amount__c = 1000.00,
        //        Payment_Type__c = 'other',
        //        Donation__c = giftId,
        //        Status__c = 'Approved'            
        //    );
        //    paymentList.add(payment);
        //}
        //return paymentList;

        Payment__c payment = new Payment__c(
            Date__c = System.Today(),
            Amount__c = 1000.00,
            Payment_Type__c = 'Credit Card',
            Donation__c = giftId,
            Status__c = 'Approved'            
        );
        insert payment;
        return payment;
    }
    
    public static Gift_Detail__c CreateTestPaymentAllocation(Id appealId, Id fundId, Id transactionId, Id paymentId, Decimal allocationAmount){
        Gift_Detail__c paymentAllocation = new Gift_Detail__c(
            New_Campaign__c  = appealId,
            Fund__c  = fundId,
            Gift__c  = transactionId,
            Payment__c  = paymentId,
            Amount__c  = allocationAmount            
        );
        insert paymentAllocation;
        return paymentAllocation;
    }
    
    public static App_Settings__c GetAppSettings(){
        CauseViewCustomSetting.defaultAppSettings();
        return App_Settings__c.getInstance();
    }
    
    public static BatchSettings__c GetBatchSettings(){
        CauseViewCustomSetting.defaultBatchSettings();
        return BatchSettings__c.getInstance('Default');
    }
    
    public static Fund__c CreateTestFund(){
        try{
            Fund__c testFund = new Fund__c(Fund_Name__c = 'Test Fund', Start_Date__c = Date.Today());
            insert testFund;
            return testFund;
        }
        catch( Exception e){
            return null;
        }
    }
    
    public static Campaign CreateTestAppeal(Id fundId){
        try{
            Campaign testAppeal = new Campaign(Name = 'Test Appeal',Fund__c = fundId,  RecordTypeId = Utilities.GetRecordTypeId('Campaign','Appeal'), IsActive = True, Status = 'In Porgress', StartDate = Date.Today());
            insert testAppeal;
            return testAppeal;
        }
        catch( Exception e){
            return null;
        }
    }
    
}