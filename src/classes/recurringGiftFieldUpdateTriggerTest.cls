@isTest
Public class recurringGiftFieldUpdateTriggerTest{
    Public Static Fund__c testFund;
    Public Static Campaign testAppeal;
    Public Static Contact testContact;
    Public Static Recurring_Donation__c testRecurringGift;
    Public Static RD_Allocation__c testRecurringGiftAllocation;
    Public Static Gift__c testGift;

    Public Static testMethod Void NegativeAllocationFunctionalTest(){
        final Integer numberOfApprovedPayments = 1;
        final Integer numberOfDeclinedPayments = 0;
        final Integer numberOfConsecutiveDeclinedPayments = 0;

        ConfigureTest();
        Payment__c testPayment1 = GeneratePayment(testGift, 10, 'Approved');
        Gift_Detail__c testAllocation1 = GenerateAllocation(testFund, testAppeal, testGift, testPayment1, 10);

        Test.startTest();
        Payment__c testPayment2 = GeneratePayment(testGift, -10, 'Approved');
        Gift_Detail__c testAllocation2 = GenerateAllocation(testFund, testAppeal, testGift, testPayment2, -10);
        Test.stopTest();

        Recurring_Donation__c testResultRecurringGift = [SELECT Approved_Payments__c, Declined_Payments__c, Consecutive_Declined_Payments__c FROM Recurring_Donation__c WHERE Id = :testRecurringGift.Id LIMIT 1];

        System.assertEquals(numberOfApprovedPayments, testResultRecurringGift.Approved_Payments__c, 'Number of approved payments is incorrect.');
        System.assertEquals(numberOfDeclinedPayments, testResultRecurringGift.Declined_Payments__c, 'Number of declined payments is incorrect.');
        System.assertEquals(numberOfConsecutiveDeclinedPayments, testResultRecurringGift.Consecutive_Declined_Payments__c, 'Number of Consecutive declined payments is incorrect.');
    }

    Public Static testMethod Void NormalUseageFunctionalTest(){
        final Integer numberOfApprovedPayments = 1;
        final Integer numberOfDeclinedPayments = 2;
        final Integer numberOfConsecutiveDeclinedPayments = 0;

        List<Payment__c> testPaymentList = new List<Payment__c>();
        List<Gift_Detail__c> testAllocationList = new List<Gift_Detail__c>();

        ConfigureTest();

        Payment__c testPayment1 = GeneratePayment(testGift, 10, 'Approved', false);
        Gift_Detail__c testAllocation1 = GenerateAllocation(testFund, testAppeal, testGift, testPayment1, 10, false);
        Payment__c testPayment2 = GeneratePayment(testGift, 10, 'Declined', false);
        Gift_Detail__c testAllocation2 = GenerateAllocation(testFund, testAppeal, testGift, testPayment2, 10, false);
        Payment__c testPayment3 = GeneratePayment(testGift, 10, 'Declined', false);
        Gift_Detail__c testAllocation3 = GenerateAllocation(testFund, testAppeal, testGift, testPayment3, 10, false);

        testPaymentList.add(testPayment1);
        testPaymentList.add(testPayment2);
        testPaymentList.add(testPayment3);

        testAllocationList.add(testAllocation1);
        testAllocationList.add(testAllocation2);
        testAllocationList.add(testAllocation3);

        Test.startTest();
        Insert testPaymentList;
        //Insert testAllocationList;
        Test.stopTest();

        Recurring_Donation__c testResultRecurringGift = [SELECT Approved_Payments__c, Declined_Payments__c, Consecutive_Declined_Payments__c FROM Recurring_Donation__c WHERE Id = :testRecurringGift.Id LIMIT 1];

        System.assertEquals(numberOfApprovedPayments, testResultRecurringGift.Approved_Payments__c, 'Number of approved payments is incorrect.');
        System.assertEquals(numberOfDeclinedPayments, testResultRecurringGift.Declined_Payments__c, 'Number of declined payments is incorrect.');
        System.assertEquals(numberOfConsecutiveDeclinedPayments, testResultRecurringGift.Consecutive_Declined_Payments__c, 'Number of Consecutive declined payments is incorrect.');
    }


    Public Static testMethod Void BulkNormalUseageFunctionalTest(){
        final Integer numberOfApprovedPayments = 200;
        final Integer numberOfDeclinedPayments = 0;
        final Integer numberOfConsecutiveDeclinedPayments = 0;

        ConfigureTest();

        Test.startTest();
        List<Payment__c> testPaymentList = GeneratePaymentList(testGift, 10, 'Approved', 200);
        Test.stopTest();

        Recurring_Donation__c testResultRecurringGift = [SELECT Approved_Payments__c, Declined_Payments__c, Consecutive_Declined_Payments__c FROM Recurring_Donation__c WHERE Id = :testRecurringGift.Id LIMIT 1];

        System.assertEquals(numberOfApprovedPayments, testResultRecurringGift.Approved_Payments__c, 'Number of approved payments is incorrect.');
        System.assertEquals(numberOfDeclinedPayments, testResultRecurringGift.Declined_Payments__c, 'Number of declined payments is incorrect.');
        System.assertEquals(numberOfConsecutiveDeclinedPayments, testResultRecurringGift.Consecutive_Declined_Payments__c, 'Number of Consecutive declined payments is incorrect.');
    }

    Public Static testMethod Void CloningPaymentsMultipleTimes(){
        Final Integer EXPECTED_NUMBER_OF_ALLOCATIONS = 7;
        Final Integer EXPECTED_NUMBER_APPROVED_PAYMENTS = 7;
        Final Integer EXPECTED_NUMBER_DECLINED_PAYMENTS = 3;
        List<Payment__c> testPaymentList = new List<Payment__c>();

        ConfigureTest();

        Test.startTest();
        testPaymentList.add(GeneratePayment(testGift, 10, 'Approved'));
        testPaymentList.add(GeneratePayment(testGift, 10, 'Approved'));
        testPaymentList.add(GeneratePayment(testGift, 10, 'Declined'));
        testPaymentList.add(GeneratePayment(testGift, 10, 'Approved'));
        testPaymentList.add(GeneratePayment(testGift, 10, 'Approved'));
        testPaymentList.add(GeneratePayment(testGift, 10, 'Declined'));
        testPaymentList.add(GeneratePayment(testGift, 10, 'Approved'));
        testPaymentList.add(GeneratePayment(testGift, 10, 'Declined'));
        testPaymentList.add(GeneratePayment(testGift, 10, 'Approved'));
        testPaymentList.add(GeneratePayment(testGift, 10, 'Approved'));
        Test.stopTest();

        List<Gift_Detail__c> testGiftDetailResult = [SELECT Id FROM Gift_Detail__c];
        Recurring_Donation__c testResultRecurringGift = [SELECT Approved_Payments__c, Declined_Payments__c FROM Recurring_Donation__c WHERE Id = :testRecurringGift.Id LIMIT 1];


        //System.assertEquals(EXPECTED_NUMBER_OF_ALLOCATIONS, testGiftDetailResult.size(), 'Not all allocations were created as expected.');
        System.assertEquals(EXPECTED_NUMBER_APPROVED_PAYMENTS, testResultRecurringGift.Approved_Payments__c, 'Number of approved payments is incorrect.');
        System.assertEquals(EXPECTED_NUMBER_DECLINED_PAYMENTS, testResultRecurringGift.Declined_Payments__c, 'Number of declined payments is incorrect.');
    }

    Public Static Void ConfigureTest(){
        GenerateSettings();
        testFund = GenerateFund(False);
        testAppeal = GenerateCampaign(CampaignRecordTypes.Appeal);
        testContact = GenerateContact();
        testRecurringGift = GenerateRecurringGift(testContact);
        testRecurringGiftAllocation = GenerateRecurringGiftAllocation(testRecurringGift);
        testGift = GenerateTransaction(testContact, testRecurringGift);
    }

    //TEST DATA GENERATORS//

    Public Enum CampaignRecordTypes {
        Campaign,
        Appeal
    }

    Public Static String ResolveCampaignRecordTypes(CampaignRecordTypes type) {
        if(Type == CampaignRecordTypes.Campaign){
            return 'Campaign';
        }else if(Type == CampaignRecordTypes.Appeal){
            return 'Appeal';
        }else{
            return '';
        }
    }

    Public Static Void GenerateSettings(){
        Map<String, String> rtype_Map = new Map<String, String>();
        List<RecordType> Rt = [SELECT Name, Id FROM RecordType WHERE ((Name = 'Household' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Gift') AND NamespacePrefix = :Utilities.getCurrentNamespace()) OR (Name = 'Campaign')];
        for(RecordType r:Rt) {
            rtype_Map.put(r.Name,r.id);
        }
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;

        App_Settings__c app = new App_Settings__c(
                Appeal_RecordType_Id__c = rtype_Map.get('Appeal'),
                Campaign_RecordType_Id__c = rtype_Map.get('Campaign'),
                Event_RecordType_Id__c = rtype_Map.get('Event'),
                Actionpages_URL__c = 'www.example.com',
                Appeal_Donate_Now_Form_Id__c = 'sdfd',
                Event_Registration_Form_Id__c = 'dsf',
                Form_URL__c = 'www.example.com',
                Free_Event_Registration_Form_Id__c = 'gfdf',
                CV_Account_Id__c = '123',
                Default_Actionpages_Campaign__c = 'jdksf',
                Individual_App_RecordtypeId__c = '123',
                Enable_Recurring_Receipts__c = false,
                Gift_Aid_Enable__c = true,
                Gift_Aid_Eligible_Payment_Types__c = 'Credit Card - Offline,Cash,Credit Card,UK Cheque,UK Direct Debit',
                Fiscal_Start_Month__c = 1
            );
        insert app;

        BatchSettings__c bs = new BatchSettings__c(
                Name='Default',
                BatchFormID__c='123',
                BatchReportId__c='123',
                BucketAccountId__c=a.Id,
                CurrencyCode__c='123',
                RegularGiftRecordTypeId__c=rtype_Map.get('Gift'),
                Data_Migration_Mode__c = false
            );
        Insert bs;
    }

    Public Static Fund__c GenerateFund(Boolean giftAidEligible) {
        Fund__c newFund = new Fund__c(
            Fund_Name__c = 'Test Fund',
            Inactive__c = false,
            Gift_Aid_Eligible__c = giftAidEligible,
            Type__c = 'Unrestricted'
        );
        insert newFund;
        return newFund;
    }

    Public Static Campaign GenerateCampaign(CampaignRecordTypes campaignRecordType) {
        Id campaignRecordTypeId = [SELECT Id FROM RecordType WHERE Name = :ResolveCampaignRecordTypes(campaignRecordType) AND SobjectType ='Campaign' AND NamespacePrefix = :Utilities.getCurrentNamespace() LIMIT 1].Id;

        Campaign newAppeal = new Campaign(
            Name = 'Test Appeal',
            IsActive = true,
            RecordTypeId = campaignRecordTypeId
        );

        if(campaignRecordType == CampaignRecordTypes.Campaign){
            newAppeal.Name = 'Test Campaign';
        }

        insert newAppeal;
        return newAppeal;
    }

    Public Static Campaign GenerateCampaign(CampaignRecordTypes campaignRecordType, Campaign parentCampaign, Fund__c relatedFund) {
        Id campaignRecordTypeId = [SELECT Id FROM RecordType WHERE Name = :ResolveCampaignRecordTypes(campaignRecordType) AND SobjectType ='Campaign' AND NamespacePrefix = :Utilities.getCurrentNamespace() LIMIT 1].Id;

        Campaign newAppeal = new Campaign(
            Name = 'Test Appeal',
            IsActive = true,
            RecordTypeId = campaignRecordTypeId,
            ParentId = parentCampaign.Id,
            Fund__c = relatedFund.Id
        );

        if(campaignRecordType == CampaignRecordTypes.Campaign){
            newAppeal.Name = 'Test Campaign';
        }

        insert newAppeal;
        return newAppeal;
    }

    Public Static Contact GenerateContact(){
        Contact newContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                MailingCity = '123',
                MailingState = '123',
                MailingCountry = '123',
                MailingPostalCode = '123',
                MailingStreet = '123'
            );
        insert newContact;
        return newContact;
    }

    Public Static Gift__c GenerateTransaction(Contact giftingContact, Recurring_Donation__c recurringDonation){
        Gift__c newTransaction = new Gift__c(
                Constituent__c = giftingContact.Id,
                Recurring_Donation__c = recurringDonation.Id,
                Gift_Type__c = 'Recurring',
                Receipt_Type__c = 'Consolidated',
                Status__c = 'Active'
            );
        insert newTransaction;
        return newTransaction;
    }

    Public Static Gift__c GenerateTransaction(Contact giftingContact){
        Gift__c newTransaction = new Gift__c(
                Constituent__c = giftingContact.Id,
                Gift_Type__c = 'One Time Gift',
                Receipt_Type__c = 'Single Receipt',
                Status__c = 'Entered'
            );
        insert newTransaction;
        return newTransaction;
    }

    Public Static Recurring_Donation__c GenerateRecurringGift(Contact giftingContact){
        Recurring_Donation__c newRecurringGift = new Recurring_Donation__c(
                Constituent__c = giftingContact.Id,
                Start_Date__c = Date.today()
            );
        insert newRecurringGift;
        return newRecurringGift;
    }

    private Static RD_Allocation__c GenerateRecurringGiftAllocation(Recurring_Donation__c gift) {
        RD_Allocation__c allocation = new RD_Allocation__c(
                Amount__c = 10.00,
                Recurring_Gift__c = gift.Id
            );
        insert allocation;
        return allocation;
    }

    Public Static Payment__c GeneratePayment(Gift__c currentTransaction, Integer amount, String status){
        Payment__c newPayment = new Payment__c(
                Date__c = Date.today(),
                Amount__c = amount,
                Status__c = status,
                Payment_Type__c = 'Credit Card - Offline',
                Donation__c = currentTransaction.Id
            );
        insert newPayment;
        return newPayment;
    }

    Public Static Payment__c GeneratePayment(Gift__c currentTransaction, Integer amount, String status, Boolean toInsert){
        Payment__c newPayment = new Payment__c(
                Date__c = Date.today(),
                Amount__c = amount,
                Status__c = status,
                Payment_Type__c = 'Credit Card - Offline',
                Donation__c = currentTransaction.Id
            );
        if(toInsert){
            insert newPayment;
        }
        return newPayment;
    }

    Public Static List<Payment__c> GeneratePaymentList(Gift__c currentTransaction, Integer amount, String status, Integer numberOfPayments){
        List<Payment__c> newPaymentList = new List<Payment__c>();
        for(Integer i = 0; i < numberOfPayments; i++){
            Payment__c newPayment = new Payment__c(
                Date__c = Date.today(),
                Amount__c = amount,
                Status__c = status,
                Payment_Type__c = 'Credit Card - Offline',
                Donation__c = currentTransaction.Id
            );
            newPaymentList.add(newPayment);
        }
        insert newPaymentList;
        return newPaymentList;
    }

    Public Static Gift_Detail__c GenerateAllocation(Fund__c giftFund, Campaign giftAppeal, Gift__c giftTransaction, Payment__c giftPayment, Integer amount) {
        Gift_Detail__c newAllocation = new Gift_Detail__c(
            New_Campaign__c = giftAppeal.Id,
            Fund__c = giftFund.Id,
            Amount__c = amount,
            Gift__c = giftTransaction.Id,
            Payment__c = [SELECT Id FROM Payment__c WHERE Id = :giftPayment.Id LIMIT 1].Id
        );
        insert newAllocation;
        return newAllocation;
    }

    Public Static Gift_Detail__c GenerateAllocation(Fund__c giftFund, Campaign giftAppeal, Gift__c giftTransaction, Payment__c giftPayment, Integer amount, Boolean toInsert) {
        Gift_Detail__c newAllocation = new Gift_Detail__c(
            New_Campaign__c = giftAppeal.Id,
            Fund__c = giftFund.Id,
            Amount__c = amount,
            Gift__c = giftTransaction.Id,
            Payment__c = giftPayment.Id
        );
        if(toInsert){
            insert newAllocation;
        }
        return newAllocation;
    }

    Public Static List<Gift_Detail__c> GenerateAllocationList(Fund__c giftFund, Campaign giftAppeal, Gift__c giftTransaction, List<Payment__c> giftPaymentList, Integer amount) {
        List<Gift_Detail__c> newAllocationList = new List<Gift_Detail__c>();
        for(Payment__c p : giftPaymentList){
            Gift_Detail__c newAllocation = new Gift_Detail__c(
                New_Campaign__c = giftAppeal.Id,
                Fund__c = giftFund.Id,
                Amount__c = amount,
                Gift__c = giftTransaction.Id,
                Payment__c = p.Id
            );
            newAllocationList.add(newAllocation);
        }
        insert newAllocationList;
        return newAllocationList;
    }

    ////////////////////////
}