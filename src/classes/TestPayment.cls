@isTest
Public with sharing class TestPayment {
    Public class TestPaymentConfiguration {
        Public BatchSettings__c testBatchSettings;
        Public App_Settings__c testAppSettings;
        Public Fund__c testEligibleFund;
        Public Fund__c testIneligibleFund;
        Public Fund__c testChangingFund;
        Public Campaign testCampaign;
        Public Campaign testEligibleAppeal;
        Public Campaign testIneligibleAppeal;
        Public Contact testContact;
        Public Gift__c testGift;
        Public Gift_Aid_Declaration__c testGAD;

        TestPaymentConfiguration(){
            testBatchSettings = GenerateBatchSettings();
            testAppSettings = GenerateAppSettings();
            testEligibleFund = recurringGiftFieldUpdateTriggerTest.GenerateFund(True);
            testIneligibleFund = recurringGiftFieldUpdateTriggerTest.GenerateFund(False);
            testChangingFund = recurringGiftFieldUpdateTriggerTest.GenerateFund(False);
            testCampaign = recurringGiftFieldUpdateTriggerTest.GenerateCampaign(recurringGiftFieldUpdateTriggerTest.CampaignRecordTypes.Campaign);
            testEligibleAppeal = recurringGiftFieldUpdateTriggerTest.GenerateCampaign(recurringGiftFieldUpdateTriggerTest.CampaignRecordTypes.Appeal, testCampaign, testEligibleFund);
            testIneligibleAppeal = recurringGiftFieldUpdateTriggerTest.GenerateCampaign(recurringGiftFieldUpdateTriggerTest.CampaignRecordTypes.Appeal, testCampaign, testIneligibleFund);
        }

        Public BatchSettings__c GenerateBatchSettings(){
            Map<String, String> rtype_Map = new Map<String, String>();
            List<RecordType> Rt = [SELECT Name, Id FROM RecordType WHERE ((Name = 'Household' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Gift') AND NamespacePrefix = :Utilities.getCurrentNamespace()) OR (Name = 'Campaign')];
            for(RecordType r:Rt) {
                rtype_Map.put(r.Name,r.id);
            }

            Account a = new Account(name='testAccount', Email__c='test@account.com');
            Insert a;

            BatchSettings__c bs = new BatchSettings__c(
                    Name='Default',
                    BatchFormID__c='123',
                    BatchReportId__c='123',
                    BucketAccountId__c=a.Id,
                    CurrencyCode__c='123',
                    RegularGiftRecordTypeId__c=rtype_Map.get('Gift'),
                    Data_Migration_Mode__c = false
                );
            insert bs;
            return bs;
        }

        Public App_Settings__c GenerateAppSettings(){
            Map<String, String> rtype_Map = new Map<String, String>();
            List<RecordType> Rt = [SELECT Name, Id FROM RecordType WHERE ((Name = 'Household' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Gift') AND NamespacePrefix = :Utilities.getCurrentNamespace()) OR (Name = 'Campaign')];
            for(RecordType r:Rt) {
                rtype_Map.put(r.Name,r.id);
            }

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
            return app;
        }
    }

    Public Static testMethod Void StandardPaymentFirstGiftAidFunctionalTest(){
        final Integer EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT = 10;
        final Decimal EXPECTED_GIFT_AID_AMOUNT = 2.50;
        final Boolean EXPECTED_PAYMENT_ELIGABLITY = TRUE;
        final Boolean EXPECTED_CONTACT_ELIGABLITY = TRUE;
        final Boolean EXPECTED_FUND_ELIGABLITY = TRUE;
        final Boolean EXPECTED_ALLOCATION_ELIGABLITY = TRUE;

        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();
        testConfiguration.testContact = recurringGiftFieldUpdateTriggerTest.GenerateContact();
        testConfiguration.testGAD = GenerateGAD(testConfiguration.testContact);
        testConfiguration.testGift = recurringGiftFieldUpdateTriggerTest.GenerateTransaction(testConfiguration.testContact);

        Test.startTest();
          Payment__c testPayment1 = (Payment__c)TestDataTemplates.createSObject(new Payment__c(
            Status__c = 'Approved',
            Donation__c = testConfiguration.testGift.Id,
            Date__c = Date.today(),
            Amount__c = 10,
            Payment_Type__c = 'Credit Card - Offline'), true);

          Gift_Detail__c testAllocation1 = (Gift_Detail__c)TestDataTemplates.createSObject(new Gift_Detail__c(
            New_Campaign__c = testConfiguration.testEligibleAppeal.Id,
            Fund__c = testConfiguration.testEligibleFund.Id,
            Amount__c = 10,
            Gift__c = testConfiguration.testGift.Id,
            Payment__c = testPayment1.Id), true);
        Test.stopTest();

        Payment__c testResultPayment = [SELECT Id, Total_Gift_Aid_Eligible_Amount__c, Gift_Aid_Amount__c, Gift_Aid_Declaration__c, Gift_Aid_Eligible__c FROM Payment__c WHERE Id = :testPayment1.Id];
        Gift_Detail__c testResultAllocation = [SELECT Id, Is_Payment_GA_Eligible__c, Is_Donor_GA_Eligible__c, Is_Fund_GA_Eligible__c, Allocation_GA_Eligible__c FROM Gift_Detail__c WHERE Id = :testAllocation1.Id];
        Gift__c testResultGift = [SELECT Total_Gift_Aid_Eligible_Amount__c FROM Gift__c WHERE Id = :testConfiguration.testGift.Id];

        //ALLOCATION RESULTS//
        System.assertEquals(EXPECTED_PAYMENT_ELIGABLITY, testResultAllocation.Is_Payment_GA_Eligible__c, 'Payment is not eligible when it should be.');
        System.assertEquals(EXPECTED_CONTACT_ELIGABLITY, testResultAllocation.Is_Donor_GA_Eligible__c, 'Donor is not eligible when it should be.');
        System.assertEquals(EXPECTED_FUND_ELIGABLITY, testResultAllocation.Is_Fund_GA_Eligible__c, 'Fund is not eligible when it should be.');
        System.assertEquals(EXPECTED_ALLOCATION_ELIGABLITY, testResultAllocation.Allocation_GA_Eligible__c, 'Allocation is not eligible when it should be.');
        //////////////////////

        //PAYMENT RESULTS//
        System.assertEquals(EXPECTED_PAYMENT_ELIGABLITY, testResultPayment.Gift_Aid_Eligible__c, 'Payment is not eligible when it should be.');
        System.assertEquals(testConfiguration.testGAD.Id, testResultPayment.Gift_Aid_Declaration__c, 'Payments GAD is incorrect.');
        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testResultPayment.Total_Gift_Aid_Eligible_Amount__c, 'Total gift aid eligible amount on payment is incorrect.');
        System.assertEquals(EXPECTED_GIFT_AID_AMOUNT, testResultPayment.Gift_Aid_Amount__c, 'Gift aid amount is not what it should be.');
        ///////////////////

        //TRANSACTION RESULTS//
        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testResultGift.Total_Gift_Aid_Eligible_Amount__c, 'Total gift aid eligible amount on transaction is incorrect.');
        ///////////////////////
    }

    Public Static testMethod Void MultipleAllocationGiftAidPaymentFunctionalTest(){
        final Integer EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT = 5;

        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();
        testConfiguration.testContact = recurringGiftFieldUpdateTriggerTest.GenerateContact();
        testConfiguration.testGAD = GenerateGAD(testConfiguration.testContact);
        testConfiguration.testGift = recurringGiftFieldUpdateTriggerTest.GenerateTransaction(testConfiguration.testContact);

        Test.startTest();
        Payment__c testPayment1 = recurringGiftFieldUpdateTriggerTest.GeneratePayment(testConfiguration.testGift, 10, 'Approved');
        Gift_Detail__c testAllocation1 = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testEligibleFund, testConfiguration.testEligibleAppeal, testConfiguration.testGift, testPayment1, 5);
        Gift_Detail__c testAllocation2 = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testIneligibleFund, testConfiguration.testEligibleAppeal, testConfiguration.testGift, testPayment1, 5);
        Test.stopTest();

        Payment__c testResultPayment = [SELECT Id, Total_Gift_Aid_Eligible_Amount__c FROM Payment__c WHERE Id = :testPayment1.Id];

        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testResultPayment.Total_Gift_Aid_Eligible_Amount__c, 'Total gift aid eligible amount is incorrect.');
    }

    Public Static testMethod Void MultipleAllocationExcludeAllocationFromGiftAidPaymentFunctionalTest(){
        final Integer EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT = 5;

        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();
        testConfiguration.testContact = GenerateNoAddressContact();
        testConfiguration.testGAD = GenerateGAD(testConfiguration.testContact);
        testConfiguration.testGift = recurringGiftFieldUpdateTriggerTest.GenerateTransaction(testConfiguration.testContact);

        Test.startTest();
        Payment__c testPayment1 = recurringGiftFieldUpdateTriggerTest.GeneratePayment(testConfiguration.testGift, 10, 'Approved');
        Gift_Detail__c testAllocation1 = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testEligibleFund, testConfiguration.testEligibleAppeal, testConfiguration.testGift, testPayment1, 5);
        Gift_Detail__c testAllocation2 = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testEligibleFund, testConfiguration.testEligibleAppeal, testConfiguration.testGift, testPayment1, 5);

        testConfiguration.testContact.MailingCity = '123';
        testConfiguration.testContact.MailingState = '123';
        testConfiguration.testContact.MailingCountry = '123';
        testConfiguration.testContact.MailingPostalCode = '123';
        testConfiguration.testContact.MailingStreet = '123';
        update testConfiguration.testContact;

        testAllocation2.Exclude_From_Gift_Aid__c = True;
        testAllocation2.Gift_Aid_Exclusion_Reason__c = 'Test';
        update testAllocation2;
        Test.stopTest();

        Payment__c testResultPayment = [SELECT Id, Total_Gift_Aid_Eligible_Amount__c FROM Payment__c WHERE Id = :testPayment1.Id];

        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testResultPayment.Total_Gift_Aid_Eligible_Amount__c, 'Total gift aid eligible amount is incorrect.');
    }

    Public Static testMethod Void MultipleAllocationExcludeFundFromGiftAidPaymentFunctionalTest(){
        final Integer EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT = 5;

        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();
        testConfiguration.testContact = recurringGiftFieldUpdateTriggerTest.GenerateContact();
        testConfiguration.testGAD = GenerateGAD(testConfiguration.testContact);
        testConfiguration.testGift = recurringGiftFieldUpdateTriggerTest.GenerateTransaction(testConfiguration.testContact);

        Test.startTest();
        Payment__c testPayment1 = recurringGiftFieldUpdateTriggerTest.GeneratePayment(testConfiguration.testGift, 10, 'Approved');
        Gift_Detail__c testAllocation1 = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testIneligibleFund, testConfiguration.testEligibleAppeal, testConfiguration.testGift, testPayment1, 5);
        Gift_Detail__c testAllocation2 = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testChangingFund, testConfiguration.testEligibleAppeal, testConfiguration.testGift, testPayment1, 5);

        testAllocation1.Fund__c = testConfiguration.testEligibleFund.Id;
        update testAllocation1;
        Test.stopTest();

        Payment__c testResultPayment = [SELECT Id, Total_Gift_Aid_Eligible_Amount__c FROM Payment__c WHERE Id = :testPayment1.Id];

        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testResultPayment.Total_Gift_Aid_Eligible_Amount__c, 'Total gift aid eligible amount is incorrect.');
    }

    Public Static testMethod Void ScalingGiftAidPaymentFunctionalTest(){
        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();
        testConfiguration.testContact = recurringGiftFieldUpdateTriggerTest.GenerateContact();
        testConfiguration.testGAD = GenerateGAD(testConfiguration.testContact);
        testConfiguration.testGift = recurringGiftFieldUpdateTriggerTest.GenerateTransaction(testConfiguration.testContact);
        testConfiguration.testGift.Gift_Type__c = 'One Time';
        testConfiguration.testGift.Recurring_Donation__c = null;
        testConfiguration.testGift.Receipt_Type__c = 'Single';
        update testConfiguration.testGift;

        List<Payment__c> testPaymentList = recurringGiftFieldUpdateTriggerTest.GeneratePaymentList(testConfiguration.testGift, 10, 'Approved', 200);
        List<Gift_Detail__c> testAllocationList = recurringGiftFieldUpdateTriggerTest.GenerateAllocationList(testConfiguration.testEligibleFund, testConfiguration.testEligibleAppeal, testConfiguration.testGift, testPaymentList, 10);

        Test.startTest();
        Gift_Aid_Declaration__c testGAD2 = GenerateGAD(testConfiguration.testContact);
        Test.stopTest();

        System.assertEquals(true, true, 'This is just to test if there are hard errors with scale for now.');
    }

    Public Static testMethod Void DeclarationCreatedAfterGift(){
        Final Decimal EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT = 10;

        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();

        Test.startTest();
        Contact testEligibleContact = recurringGiftFieldUpdateTriggerTest.GenerateContact();
        Gift_Aid_Declaration__c testDeclaration = GenerateGAD(testEligibleContact);
        Gift__c testOneTimeGift = GenerateOneTimeTransaction(testEligibleContact);
        Payment__c testOneTimeGiftPayment = GeneratePayment(testOneTimeGift, 10, 'Approved');
        Gift_Detail__c testOneTimeGiftAllocation = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testEligibleFund, testConfiguration.testEligibleAppeal, testOneTimeGift, testOneTimeGiftPayment, 10);
        Test.stopTest();

        Payment__c testOneTimeGiftPaymentResult = [SELECT Id, Gift_Aid_Declaration__c, Total_Gift_Aid_Eligible_Amount__c FROM Payment__c WHERE Id = :testOneTimeGiftPayment.Id];

        System.assertEquals(testDeclaration.Id, testOneTimeGiftPaymentResult.Gift_Aid_Declaration__c, 'Gift Aid declaration is incorrect!');
        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testOneTimeGiftPaymentResult.Total_Gift_Aid_Eligible_Amount__c, 'Total Gift Aid Eligible Amount is incorrect!');
    }

    Public Static testMethod Void ContactBecomingEligible(){
        Final Decimal EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT = 10;

        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();

        Test.startTest();
        Contact testIneligibleContact = GenerateNoAddressContact();
        Gift_Aid_Declaration__c testDeclaration = GenerateGAD(testIneligibleContact);
        Gift__c testOneTimeGift = GenerateOneTimeTransaction(testIneligibleContact);
        Payment__c testOneTimeGiftPayment = GeneratePayment(testOneTimeGift, 10, 'Approved');
        Gift_Detail__c testOneTimeGiftAllocation = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testEligibleFund, testConfiguration.testEligibleAppeal, testOneTimeGift, testOneTimeGiftPayment, 10);
        testIneligibleContact.MailingCity = '123';
        testIneligibleContact.MailingState = '123';
        testIneligibleContact.MailingCountry = '123';
        testIneligibleContact.MailingPostalCode = '123';
        testIneligibleContact.MailingStreet = '123';
        update testIneligibleContact;
        Test.stopTest();

        Payment__c testOneTimeGiftPaymentResult = [SELECT Id, Gift_Aid_Declaration__c, Total_Gift_Aid_Eligible_Amount__c FROM Payment__c WHERE Id = :testOneTimeGiftPayment.Id];

        System.assertEquals(testDeclaration.Id, testOneTimeGiftPaymentResult.Gift_Aid_Declaration__c, 'Gift Aid declaration is incorrect!');
        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testOneTimeGiftPaymentResult.Total_Gift_Aid_Eligible_Amount__c, 'Total Gift Aid Eligible Amount is incorrect!');
    }

    Public Static testMethod Void PendingPaymentBecomingApproved(){
        Final Decimal EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT = 10;
        Final Boolean EXPECTED_PAYMENT_ELIGABLITY = TRUE;

        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();

        Test.startTest();
        Contact testEligibleContact = recurringGiftFieldUpdateTriggerTest.GenerateContact();
        Gift_Aid_Declaration__c testDeclaration = GenerateGAD(testEligibleContact);
        Gift__c testOneTimeGift = GenerateOneTimeTransaction(testEligibleContact);
        Payment__c testOneTimeGiftPayment = GeneratePayment(testOneTimeGift, 10, 'Pending');
        Gift_Detail__c testOneTimeGiftAllocation = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testEligibleFund, testConfiguration.testEligibleAppeal, testOneTimeGift, testOneTimeGiftPayment, 10);
        testOneTimeGiftPayment.Status__c = 'Approved';
        update testOneTimeGiftPayment;
        Test.stopTest();

        Payment__c testOneTimeGiftPaymentResult = [SELECT Id, Total_Gift_Aid_Eligible_Amount__c, Gift_Aid_Eligible__c, Gift_Aid_Declaration__c FROM Payment__c WHERE Id = :testOneTimeGiftPayment.Id];

        System.assertEquals(EXPECTED_PAYMENT_ELIGABLITY, testOneTimeGiftPaymentResult.Gift_Aid_Eligible__c, 'Payment is not eligible when it should be!');
        System.assertEquals(testDeclaration.Id, testOneTimeGiftPaymentResult.Gift_Aid_Declaration__c, 'Payment has the wrong GAD!');
        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testOneTimeGiftPaymentResult.Total_Gift_Aid_Eligible_Amount__c, 'Total gift aid eligible amount is incorrect.');
    }

    Public Static testMethod Void IneligiblePaymentBecomingEligible(){
        Final Decimal EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT = 10;
        Final Boolean EXPECTED_PAYMENT_ELIGABLITY = TRUE;

        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();
        testConfiguration.testAppSettings.Gift_Aid_Eligible_Payment_Types__c = 'Cash,Credit Card,UK Cheque,UK Direct Debit';
        update testConfiguration.testAppSettings;

        Test.startTest();
        Contact testEligibleContact = recurringGiftFieldUpdateTriggerTest.GenerateContact();
        Gift_Aid_Declaration__c testDeclaration = GenerateGAD(testEligibleContact);
        Gift__c testOneTimeGift = GenerateOneTimeTransaction(testEligibleContact);
        Payment__c testOneTimeGiftPayment = GeneratePayment(testOneTimeGift, 10, 'Approved');
        Gift_Detail__c testOneTimeGiftAllocation = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testEligibleFund, testConfiguration.testEligibleAppeal, testOneTimeGift, testOneTimeGiftPayment, 10);
        testConfiguration.testAppSettings.Gift_Aid_Eligible_Payment_Types__c = 'Credit Card - Offline,Cash,Credit Card,UK Cheque,UK Direct Debit';
        update testConfiguration.testAppSettings;
        testOneTimeGiftPayment.Description__c = '123';
        update testOneTimeGiftPayment;
        Test.stopTest();

        Payment__c testOneTimeGiftPaymentResult = [SELECT Id, Total_Gift_Aid_Eligible_Amount__c, Gift_Aid_Declaration__c, Gift_Aid_Eligible__c FROM Payment__c WHERE Id = :testOneTimeGiftPayment.Id];

        System.assertEquals(EXPECTED_PAYMENT_ELIGABLITY, testOneTimeGiftPaymentResult.Gift_Aid_Eligible__c, 'Payment is not eligible when it should be!');
        System.assertEquals(testDeclaration.Id, testOneTimeGiftPaymentResult.Gift_Aid_Declaration__c, 'Payment has the wrong GAD!');
        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testOneTimeGiftPaymentResult.Total_Gift_Aid_Eligible_Amount__c, 'Total gift aid eligible amount is incorrect.');
    }

    Public Static testMethod Void DeclarationCreatedAfterGiftIneligibleContact(){
        Final Decimal EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT = 0;
        Final Boolean EXPECTED_PAYMENT_ELIGABLITY = TRUE;
        Final Id EXPECTED_DELCARATION = null;

        TestPaymentConfiguration testConfiguration = new TestPaymentConfiguration();

        Test.startTest();
        Contact testIneligibleContact = GenerateGAIneligibleContact();
        Gift__c testOneTimeGift = GenerateOneTimeTransaction(testIneligibleContact);
        Payment__c testOneTimeGiftPayment = GeneratePayment(testOneTimeGift, 10, 'Approved');
        Gift_Detail__c testOneTimeGiftAllocation = recurringGiftFieldUpdateTriggerTest.GenerateAllocation(testConfiguration.testEligibleFund, testConfiguration.testEligibleAppeal, testOneTimeGift, testOneTimeGiftPayment, 10);
        Payment__c testOneTimeGiftPaymentResultish = [SELECT Id, Total_Gift_Aid_Eligible_Amount__c, Gift_Aid_Eligible__c, Gift_Aid_Declaration__c FROM Payment__c WHERE Id = :testOneTimeGiftPayment.Id];
        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testOneTimeGiftPaymentResultish.Total_Gift_Aid_Eligible_Amount__c, 'Total gift aid eligible amount is incorrect.');
        Gift_Aid_Declaration__c testDeclaration = GenerateGAD(testIneligibleContact);
        Test.stopTest();

        Payment__c testOneTimeGiftPaymentResult = [SELECT Id, Total_Gift_Aid_Eligible_Amount__c, Gift_Aid_Eligible__c, Gift_Aid_Declaration__c FROM Payment__c WHERE Id = :testOneTimeGiftPayment.Id];

        System.assertEquals(EXPECTED_DELCARATION, testOneTimeGiftPaymentResult.Gift_Aid_Declaration__c, 'Payment has the wrong GAD!');
        System.assertEquals(EXPECTED_PAYMENT_ELIGABLITY, testOneTimeGiftPaymentResult.Gift_Aid_Eligible__c, 'Payment is not eligible when it should be!');
        System.assertEquals(EXPECTED_TOTAL_GIFT_AID_ELIGABLE_AMOUNT, testOneTimeGiftPaymentResult.Total_Gift_Aid_Eligible_Amount__c, 'Total gift aid eligible amount is incorrect.');
    }

    Public Static Gift_Aid_Declaration__c GenerateGAD(Contact donor){
        Gift_Aid_Declaration__c newGAD = new Gift_Aid_Declaration__c(
                Donor__c = donor.Id,
                Method__c = 'Electronic',
                Type__c = 'This donation, and all future & historic'
            );
        insert newGAD;
        return newGAD;
    }

    Public Static Contact GenerateNoAddressContact(){
        Contact newContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact'
            );
        insert newContact;
        return newContact;
    }

    Public Static Contact GenerateGAIneligibleContact(){
        Contact newContact = new Contact(
                FirstName = '',
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

    Public Static Gift__c GenerateOneTimeTransaction(Contact giftingContact){
        Gift__c newTransaction = new Gift__c(
                Constituent__c = giftingContact.Id,
                Gift_Type__c = 'One Time Gift',
                Receipt_Type__c = 'Single Receipt',
                Status__c = 'Entered'
            );
        insert newTransaction;
        return newTransaction;
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

    //// The TestFactory will pre-fill all the fields we typically need
    //Account a = (Account)TestFactory.createSObject(new Account());
    //insert a;

    //// You can also set values to be used. Any values set in the constructor will override the defaults
    //Opportunity o = (Opportunity)TestFactory.createSObject(new Opportunity(AccountId = a.Id));

    //// You can also specify a specific set of overrides for different scenarios
    //Account a = (Account)TestFactory.createSObject(new Account(), 'TestFactory.AccountDefaults');

    //// Finally, get a bunch of records for testing bulk
    //Account[] aList = (Account[])TestFactory.createSObjectList(new Account(), 200);

    //// You can optionally insert records as created like this:
    //// Note the final parameter of true.
    //Account a = (Account) TestFactory.createSObject(new Account(), true);
    //Contact c = (Contact) TestFactory.createSObject(new Contact(AccountID = a.Id), true);

    Public Static testMethod Void thisIsNotADrill(){
        Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
        Gift__c testGift = (Gift__c)TestDataTemplates.createSObject(new Gift__c(Constituent__c = testContact.Id), true);

        System.assertNotEquals(null, testContact.Id, 'NoGift.exe');
        System.assertEquals('Test',testGift.Description__c, 'Nope.exe');
        System.assertEquals(testContact.Id, testGift.Constituent__c, 'Noper.exe');
    }

    Public Static testMethod Void ContactLegacyAddress(){
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);

        Account testAccount = (Account)TestDataTemplates.createSObject(new Account(), 'TestDataTemplates.HouseholdWithNoAddress', true);
        Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(
            Household__c = testAccount.Id,
            Same_as_Household__c = true), true);

        Test.startTest();
            Update testContact;
        Test.stopTest();

        testAccount = [SELECT Id, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry FROM Account WHERE Id = :testAccount.Id];

        System.assertEquals(testContact.MailingStreet,testAccount.BillingStreet);
        System.assertEquals(testContact.MailingCity,testAccount.BillingCity);
        System.assertEquals(testContact.MailingPostalCode,testAccount.BillingPostalCode);
        System.assertEquals(testContact.MailingState,testAccount.BillingState);
        System.assertEquals(testContact.MailingCountry,testAccount.BillingCountry);
    }

    Public Static testMethod Void EventRegistrationRollupToTransaction(){
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);

        Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
        Gift__c testGift = (Gift__c)TestDataTemplates.createSObject( new Gift__c(
            Constituent__c = testContact.Id), true);
        Campaign testEvent = (Campaign)TestDataTemplates.createSObject(new Campaign(), 'TestDataTemplates.CampaignEventDefaults', true);
        Event_Registration__c testEventRegistration1 = (Event_Registration__c)TestDataTemplates.createSObject(new Event_Registration__c(
            Transaction__c = testGift.Id,
            Individual__c = testContact.Id,
            Event__c = testEvent.Id,
            Registration_Date__c = Date.Today()), true);
        Event_Registration__c testEventRegistration2 = (Event_Registration__c)TestDataTemplates.createSObject(new Event_Registration__c(
            Transaction__c = testGift.Id,
            Individual__c = testContact.Id,
            Event__c = testEvent.Id,
            Registration_Date__c = Date.Today()), true);

        Test.startTest();
            Update testGift;
        Test.stopTest();

        Integer eventTransaction = (Integer)[SELECT Attendee_Names_Received__c FROM Gift__c WHERE Id = :testGift.Id].Attendee_Names_Received__c;
        Integer eventRegistrationCount = [SELECT Count() FROM Event_Registration__c WHERE Transaction__c = :testGift.Id];

        System.assertEquals(eventTransaction,eventRegistrationCount);
    }

    Public Static testMethod Void GLAllocationfieldUpdateTest(){
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
        Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), 'TestDataTemplates.FundWithGLCodes', true);
        Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id), true);
        Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
        Gift__c testGift = (Gift__c)TestDataTemplates.createSObject( new Gift__c(
            Constituent__c = testContact.Id), true);
        Payment__c testPayment = (Payment__c)TestDataTemplates.createsObject(new Payment__c(
            Status__c = 'Pending',
            Donation__c = testGift.Id), true);
        Gift_Detail__c testAllocation = (Gift_Detail__c)TestDataTemplates.createSObject(new Gift_Detail__c(
            Payment__c = testPayment.Id,
            New_Campaign__c = testAppeal.Id,
            Fund__c = testFund.Id,
            Gift__c = testGift.Id), true);

        System.assertNotEquals(testFund.GL_Credit__c, testAllocation.GL_Auto_Credit_Account__c);
        System.assertNotEquals(testFund.GL_Debit__c, testAllocation.GL_Auto_Debit_Account__c);

        Test.startTest();
            testPayment.Status__c = 'Approved';
            Update testPayment;
        Test.stopTest();

        testAllocation = [SELECT Id, GL_Auto_Credit_Account__c, GL_Auto_Debit_Account__c FROM Gift_Detail__c WHERE Id = :testAllocation.Id];

        System.assertEquals(testFund.GL_Debit__c, testAllocation.GL_Auto_Debit_Account__c);
        System.assertEquals(testFund.GL_Credit__c, testAllocation.GL_Auto_Credit_Account__c);
    }

    ///////////////////////////////////
    //NEW GIFT INTERFACE TEST CLASSES//
    ///////////////////////////////////

    // New Gift - One Time
    Public Static testMethod Void NewGiftOneTimeTest(){
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
        Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
        Gift__c testGift = (Gift__c)TestDataTemplates.createSObject(new Gift__c(Constituent__c = testContact.Id), true);
        Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), True);
        Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id), true);

        PageReference pageRef = Page.SingleTransaction;

        Test.startTest();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', testContact.Id);
        GiftControllerExtension controller = new GiftControllerExtension(new ApexPages.StandardController(testGift));

        controller.cId = testContact.Id;
        controller.theGift.Expected_Amount__c = 10;
        controller.theGiftDetails[0].Amount__c = 10;
        controller.theGiftDetails[0].New_Campaign__c = testAppeal.Id;
        controller.theGiftDetails[0].Fund__c = testFund.Id;
        controller.theGiftDetails[0].Allocation_Date__c = Date.Today();
        controller.thePayment.Payment_Type__c = 'Offline - Credit Card';

        controller.Submit();

        Test.stopTest();

        Id newGiftAllocation = controller.theGiftDetails[0].Id;

        List<Payment__c> testPaymentsListResult = [SELECT
            Id, Date__c, Amount__c, Status__c, Donation__c, Receipt__c
            FROM Payment__c
            WHERE Id =: controller.thePayment.Id];

        List<Gift_Detail__c> testAllocationListResult = [SELECT
            Id, Fund__c, Allocation_Date__c, New_Campaign__c, Gift__c, Payment__c
            FROM Gift_Detail__c
            WHERE Id =: newGiftAllocation];

        List<Receipt__c> testReceiptListResult = [SELECT
            Id, Receipt_Amount__c, Receipt_Date__c, Receipt_Type__c, Gift__c, Status__c, Receipt_Email_Address__c
            FROM Receipt__c];

        List<Gift__c> testGiftListResult = [SELECT
            Id, Expected_Amount__c, Status__c, Gift_Type__c, Total_Allocations__c, RecordType.Name, Gift_Date__c, Constituent__c, Amount__c, Receipt_Type__c
            FROM Gift__c
            WHERE Id =: controller.theGift.Id];

        Gift__c testGiftResult = testGiftListResult[0];
        Payment__c testPaymentResult = testPaymentsListResult[0];
        Gift_Detail__c testAllocationResult = testAllocationListResult[0];
        Receipt__c testReceiptResult = testReceiptListResult[0];

        //Transaction Asserts//
        System.assertEquals(10, testGiftResult.Expected_Amount__c);
        System.assertEquals(testContact.Id, testGiftResult.Constituent__c);
        System.assertEquals(10, testGiftResult.Amount__c);
        System.assertEquals('Single Receipt', testGiftResult.Receipt_Type__c);
        System.assertEquals('Entered', testGiftResult.Status__c);
        System.assertEquals('One Time Gift', testGiftResult.Gift_Type__c);
        System.assertEquals('Gift', testGiftResult.RecordType.Name);
        System.assertEquals(Date.Today(), testGiftResult.Gift_Date__c);
        System.assertEquals(10, testGiftResult.Total_Allocations__c);

        //Payment Asserts//
        System.assertEquals(Date.Today(), testPaymentResult.Date__c);
        System.assertEquals(10, testPaymentResult.Amount__c);
        System.assertEquals('Approved', testPaymentResult.Status__c);
        System.assertEquals(testGiftResult.Id, testPaymentResult.Donation__c);
        System.assertEquals(testReceiptResult.Id, testPaymentResult.Receipt__c);

        //Allocation Asserts//
        System.assertEquals(testAppeal.Id, testAllocationResult.New_Campaign__c);
        System.assertEquals(testFund.Id, testAllocationResult.Fund__c);
        System.assertEquals(testGiftResult.Id, testAllocationResult.Gift__c);
        System.assertEquals(testPaymentResult.Id, testAllocationResult.Payment__c);
        System.assertEquals(Date.Today(), testAllocationResult.Allocation_Date__c);

        //Receipt Asserts//
        System.assertEquals(10, testReceiptResult.Receipt_Amount__c);
        System.assertEquals(Date.Today(), testReceiptResult.Receipt_Date__c);
        System.assertEquals('Single', testReceiptResult.Receipt_Type__c);
        System.assertEquals(testGiftResult.Id, testReceiptResult.Gift__c);
        System.assertEquals('To be Issued', testReceiptResult.Status__c);
        System.assertEquals('test@test.com', testReceiptResult.Receipt_Email_Address__c);
    }

    // New Gift - Recurring
    Public Static testMethod Void NewGiftRecurringTest(){
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
        Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
        Gift__c testGift = (Gift__c)TestDataTemplates.createSObject(new Gift__c(Constituent__c = testContact.Id), true);
        Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), True);
        Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id), true);

        PageReference pageRef = Page.SingleTransaction;

        Test.startTest();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('cid', testContact.Id);
        GiftControllerExtension controller = new GiftControllerExtension(new ApexPages.StandardController(testGift));

        controller.cId = testContact.Id;
        controller.theGiftDetails[0].Amount__c = 10;
        controller.theGiftDetails[0].New_Campaign__c = testAppeal.Id;
        controller.theGiftDetails[0].Fund__c = testFund.Id;
        controller.thePayment.Payment_Type__c = 'Offline - Credit Card';

        controller.Submit();
        Test.stopTest();

        List<Payment__c> testPaymentsListResult = [SELECT Id FROM Payment__c];
        List<Gift_Detail__c> testAllocationListResult = [SELECT Id FROM Gift_Detail__c];
        List<Receipt__c> testReceiptListResult = [SELECT Id FROM Receipt__c];

        System.assertEquals(True, Limits.getQueries() < 40, 'New Gift is using too many queries!');
        System.assertEquals(1,testPaymentsListResult.size(), 'Payments were not entered!');
        System.assertEquals(1,testAllocationListResult.size(), 'Allocations were not entered!');
        System.assertEquals(1,testReceiptListResult.size(), 'Receipts were not entered!');
    }

    // New Gift - One Time
    Public Static testMethod Void AccountNewGiftOneTimeTest(){
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
        Account testAccount = (Account)TestDataTemplates.createSObject(new Account(), true);
        Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(
            AccountId = testAccount.Id), true);
        Gift__c testGift = (Gift__c)TestDataTemplates.createSObject(new Gift__c());
        Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), True);
        Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id), true);

        PageReference pageRef = Page.SingleTransaction;

        Test.startTest();
        Test.setCurrentPage(pageRef);
        GiftControllerExtension.TestContactId = testAccount.Id;
        GiftControllerExtension controller = new GiftControllerExtension(new ApexPages.StandardController(testGift));

        controller.theGift.Affiliated_Contact__c = testContact.Id;
        controller.theGift.Expected_Amount__c = 10;
        controller.theGiftDetails[0].Amount__c = 10;
        controller.theGiftDetails[0].New_Campaign__c = testAppeal.Id;
        controller.theGiftDetails[0].Fund__c = testFund.Id;
        controller.theGiftDetails[0].Allocation_Date__c = Date.Today();
        controller.thePayment.Payment_Type__c = 'Offline - Credit Card';

        controller.Submit();

        Test.stopTest();

        Id newGiftAllocation = controller.theGiftDetails[0].Id;

        List<Payment__c> testPaymentsListResult = [SELECT
            Id, Date__c, Amount__c, Status__c, Donation__c, Receipt__c
            FROM Payment__c
            WHERE Id =: controller.thePayment.Id];

        List<Gift_Detail__c> testAllocationListResult = [SELECT
            Id, Fund__c, Allocation_Date__c, New_Campaign__c, Gift__c, Payment__c
            FROM Gift_Detail__c
            WHERE Id =: newGiftAllocation];

        List<Receipt__c> testReceiptListResult = [SELECT
            Id, Receipt_Amount__c, Receipt_Date__c, Receipt_Type__c, Gift__c, Status__c, Receipt_Email_Address__c
            FROM Receipt__c];

        List<Gift__c> testGiftListResult = [SELECT
            Id, Expected_Amount__c, Status__c, Gift_Type__c, Total_Allocations__c, RecordType.Name, Gift_Date__c, Organization__c, Amount__c, Receipt_Type__c
            FROM Gift__c
            WHERE Id =: controller.theGift.Id];

        Gift__c testGiftResult = testGiftListResult[0];
        Payment__c testPaymentResult = testPaymentsListResult[0];
        Gift_Detail__c testAllocationResult = testAllocationListResult[0];
        Receipt__c testReceiptResult = testReceiptListResult[0];

        //Transaction Asserts//
        System.assertEquals(10, testGiftResult.Expected_Amount__c);
        System.assertEquals(testAccount.Id, testGiftResult.Organization__c);
        System.assertEquals(10, testGiftResult.Amount__c);
        System.assertEquals('Single Receipt', testGiftResult.Receipt_Type__c);
        System.assertEquals('Entered', testGiftResult.Status__c);
        System.assertEquals('One Time Gift', testGiftResult.Gift_Type__c);
        System.assertEquals('Gift', testGiftResult.RecordType.Name);
        System.assertEquals(Date.Today(), testGiftResult.Gift_Date__c);
        System.assertEquals(10, testGiftResult.Total_Allocations__c);

        //Payment Asserts//
        System.assertEquals(Date.Today(), testPaymentResult.Date__c);
        System.assertEquals(10, testPaymentResult.Amount__c);
        System.assertEquals('Approved', testPaymentResult.Status__c);
        System.assertEquals(testGiftResult.Id, testPaymentResult.Donation__c);
        System.assertEquals(testReceiptResult.Id, testPaymentResult.Receipt__c);

        //Allocation Asserts//
        System.assertEquals(testAppeal.Id, testAllocationResult.New_Campaign__c);
        System.assertEquals(testFund.Id, testAllocationResult.Fund__c);
        System.assertEquals(testGiftResult.Id, testAllocationResult.Gift__c);
        System.assertEquals(testPaymentResult.Id, testAllocationResult.Payment__c);
        System.assertEquals(Date.Today(), testAllocationResult.Allocation_Date__c);

        //Receipt Asserts//
        System.assertEquals(10, testReceiptResult.Receipt_Amount__c);
        System.assertEquals(Date.Today(), testReceiptResult.Receipt_Date__c);
        System.assertEquals('Single', testReceiptResult.Receipt_Type__c);
        System.assertEquals(testGiftResult.Id, testReceiptResult.Gift__c);
        System.assertEquals('To be Issued', testReceiptResult.Status__c);
        System.assertEquals('test@test.com', testReceiptResult.Receipt_Email_Address__c);
    }
}