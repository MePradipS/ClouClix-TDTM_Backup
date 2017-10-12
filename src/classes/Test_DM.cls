@isTest
private class Test_DM {
    //Test GITHUB
    static testMethod void Test_GiftRollup() {
        Test.startTest();
        aNums__c a = new aNums__c(Name = 'Default', ContactCount__c = 8, ContactLength__c = 8, ContactPrefix__c = 'Con-', OrgCount__c = 8, OrgLength__c = 8, OrgPrefix__c = 'Con-');
        insert a;
        
        Account acc = new Account(Name = 'sss');
        insert acc;
        
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = 'test', BucketAccountId__c = acc.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
                
        Contact c = new Contact(LastName = 'Contact');
        insert c;
        //Database.executeBatch(new DMContactRollups(), 5); 
        Test.stopTest();
    }

    static testMethod void Test_AppealUtil() {
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
        Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), 'TestDataTemplates.FundWithGLCodes', true);
        Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id), true);
        Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);        
        Gift__c testGift = (Gift__c)TestDataTemplates.createSObject( new Gift__c(
            Constituent__c = testContact.Id,
            Gift_Type__c = 'Recurring'), true);
        Payment__c testPayment = (Payment__c)TestDataTemplates.createsObject(new Payment__c(
            Status__c = 'Pending',
            Donation__c = testGift.Id), true);
        Gift_Detail__c testAllocation = (Gift_Detail__c)TestDataTemplates.createSObject(new Gift_Detail__c(
            Payment__c = testPayment.Id,
            New_Campaign__c = testAppeal.Id,
            Fund__c = testFund.Id,
            Gift__c = testGift.Id), true);
        Set<Id> appealIdSet = new Set<Id>();
        appealIdSet.add(testAppeal.Id);
        Set<String> appealStringSet = (Set<String>)JSON.deserialize(JSON.serialize(appealIdSet), Set<String>.class);

        Test.startTest();
            AppealUtil.RollupAppeals(appealIdSet);
            AppealUtil.RollupCampaigns(appealIdSet);
            AppealUtil.RollupExpenses(appealStringSet);
            AppealUtil.RollupPackages(appealIdSet);
        Test.stopTest();
    }

    static testMethod void Test_CauseviewSettingsController() {
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
        PageReference pageRef = Page.Causeview_Settings;
        Test.startTest();
            Test.setCurrentPage(pageRef);
            CauseviewSettingsController cvSettingsCtrl = new CauseviewSettingsController();
            List<SelectOption> paymentTypeList = CauseviewSettingsController.getGiftAidPaymentTypePicklist();
            String unselectedRTs = cvSettingsCtrl.getUnselectedRecordTypes();
            String selectRTs  = cvSettingsCtrl.getSelectedRecordTypes();
            String unselectedPTs = cvSettingsCtrl.getUnselectedPaymentTypes();
            String selectedPTs = cvSettingsCtrl.getSelectedPaymentTypes();
            String returnRollupString = CauseviewSettingsController.staticExecuteFullRollup();
        Test.stopTest();
    }

    static testMethod void Test_HouseHoldLtng() {
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
        
        Account testAccount = (Account)TestDataTemplates.createSObject(new Account(), 'TestDataTemplates.HouseholdWithNoAddress', true);
        
        PageReference pageRef = Page.HouseHoldLtng;
        Test.startTest();
            Test.setCurrentPage(pageRef);            
            System.currentPageReference().getParameters().put('Id', testAccount.Id);
            
            HouseHoldLtng houseHoldLtngCtrl = new HouseHoldLtng();
            houseHoldLtngCtrl.ActionMemberId = '123456';            

            houseHoldLtngCtrl.saveMember();
            houseHoldLtngCtrl.queryExistingMember();
            houseHoldLtngCtrl.displayPopUp();
            houseHoldLtngCtrl.displayNewMember();
            houseHoldLtngCtrl.displaySuggestedMember();
            houseHoldLtngCtrl.displayEditMember();
            houseHoldLtngCtrl.displayExistingMember();
            houseHoldLtngCtrl.setSelectedMember();
            houseHoldLtngCtrl.setActionMemberId();
            PageReference saveAll = houseHoldLtngCtrl.saveAll();
            PageReference cancelAll = houseHoldLtngCtrl.cancelAll();
            PageReference save = houseHoldLtngCtrl.save();
            PageReference saveAndNewMember = houseHoldLtngCtrl.saveAndNewMember();
            PageReference showSuggestedMember = houseHoldLtngCtrl.showSuggestedMember();
            PageReference addSelectedMember = houseHoldLtngCtrl.addSelectedMember();
            PageReference selectExistingMember = houseHoldLtngCtrl.selectExistingMember();
            PageReference cancel = houseHoldLtngCtrl.cancel();
            PageReference newMember = houseHoldLtngCtrl.newMember();
            PageReference addExistingMember = houseHoldLtngCtrl.addExistingMember();                        
            PageReference searchExistingMember = houseHoldLtngCtrl.searchExistingMember();
            PageReference nextBtnClick = houseHoldLtngCtrl.nextBtnClick();
            PageReference previousBtnClick = houseHoldLtngCtrl.previousBtnClick();
            List<String> householdRole = houseHoldLtngCtrl.getHouseholdRole();
            List<String> solicitCodes = houseHoldLtngCtrl.getSolicitCodes();            
        Test.stopTest();
    }
}