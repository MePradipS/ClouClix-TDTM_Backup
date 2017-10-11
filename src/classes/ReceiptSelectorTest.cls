@isTest
public with sharing class ReceiptSelectorTest {
	public static Receipt__c CreateSObject() {
			BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
			App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
			Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), true);
			String appealId = [SELECT Id FROM RecordType WHERE Name = 'Appeal'].Id;
			Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id, Name = 'Test Appeal', RecordTypeId = appealId), true);
			Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
			Recurring_Donation__c testRecurringDonation = (Recurring_Donation__c)TestDataTemplates.createSObject(new Recurring_Donation__c(Constituent__c = testContact.Id), true);
			Gift__c testGift = (Gift__c)TestDataTemplates.createSObject( new Gift__c(Constituent__c = testContact.Id, Recurring_Donation__c = testRecurringDonation.Id, Gift_Date__c = Date.today(), Status__c = 'Active'), true);
			Payment__c testPayment = (Payment__c)TestDataTemplates.createSObject(new Payment__c(Donation__c = testGift.Id), true);
			Receipt__c testReceipt = (Receipt__c)TestDataTemplates.createSObject(new Receipt__c(Constituent__c = testContact.Id, Gift__c = testGift.Id), true);

			return testReceipt;
	}

	@isTest static void TestSelectReceiptTypeById() {
		Receipt__c expectedReceipt = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedReceipt.Id};

		Test.startTest();
				List<Receipt__c> results = new ReceiptSelector().SelectReceiptTypeById(idSet);
				Receipt__c actualReceipt = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedReceipt.Id, actualReceipt.Id);
		Test.stopTest();
	}

	@isTest static void TestUpdateReceiptOnTrigger() {
		Receipt__c expectedReceipt = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedReceipt.Gift__c};

		Test.startTest();
				List<Receipt__c> results = new ReceiptSelector().UpdateReceiptOnTrigger(idSet);
				Receipt__c actualReceipt = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedReceipt.Id, actualReceipt.Id);
		Test.stopTest();
	}
}