@isTest
private class FundTriggerTest {
    @isTest static void missingAppSettingsTest() {
				Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), true);
        FundTriggerHelper.updatePaymentTotalGiftAidEligableAmount(new Set<Id>{testFund.Id});
    }

    @isTest static void missingAppSettingsFieldTest() {
        Map<String, String> recordTypesMap = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund')]){
            recordTypesMap.put(r.Name, r.Id);
        }
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();

        Id rtypes = rtype_Map.get('Gift');
        RecordType retype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Organization' Limit 1];
				BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
				App_Settings__c newAppSettings = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(
						Appeal_RecordType_Id__c = recordTypesMap.get('Appeal'),
						Campaign_RecordType_Id__c = recordTypesMap.get('Campaign'),
            Event_RecordType_Id__c = recordTypesMap.get('Event'),
						Actionpages_URL__c = 'www.example.com',
						Appeal_Donate_Now_Form_Id__c = 'sdfd',
						Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com',
						Gift_Aid_Enable__c=true,
            Free_Event_Registration_Form_Id__c = 'gfdf',
						CV_Account_Id__c = '123',
						Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123',
						Enable_Recurring_Receipts__c = false), true);
				Account acObj = (Account)TestDataTemplates.createSObject(new Account(Name = 'Test Organization', RecordTypeId = retype.Id), true);
				Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), true);
				Contact contacts = (Contact)TestDataTemplates.createSObject(new Contact(FirstName = 'Test', LastName = 'Test', Household__c = acObj.Id), true);
				Gift__c gift = (Gift__c)TestDataTemplates.createSObject(new Gift__c(
					Status__c = 'Active',
	        Organization__c=acObj.Id,
	        Gift_Date__c = system.today(),
	        Gift_Type__c  = 'One Time Gift',
	        RecordTypeId  = rtypes), true);
				Payment__c payment = (Payment__c)TestDataTemplates.createSObject(new Payment__c(
					Date__c = System.Today(),
					Amount__c = 1000.00,
					Payment_Type__c = 'other',
					Donation__c = gift.Id,
					Status__c = 'Approved'), true);
				Gift_Detail__c gd = (Gift_Detail__c)TestDataTemplates.createSObject(new Gift_Detail__c(
					Gift__c = gift.Id,
	        Payment__c=payment.Id,
	        Fund__c = testFund.id), true);

        FundTriggerHelper.updatePaymentTotalGiftAidEligableAmount(new Set<Id>{testFund.Id});
    }
}