@isTest
public with sharing class PaymentSelectorTest {
	public static Payment__c CreateSObject() {
			BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
			App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
			Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), true);
			String appealId = [SELECT Id FROM RecordType WHERE Name = 'Appeal'].Id;
			Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id, Name = 'Test Appeal', RecordTypeId = appealId), true);
			Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
			Recurring_Donation__c testRecurringDonation = (Recurring_Donation__c)TestDataTemplates.createSObject(new Recurring_Donation__c(Constituent__c = testContact.Id), true);
			Gift__c testGift = (Gift__c)TestDataTemplates.createSObject( new Gift__c(
				Constituent__c = testContact.Id,
				Recurring_Donation__c = testRecurringDonation.Id,
				Gift_Date__c = Date.today(),
				Status__c = 'Active',
				Gift_Type__c = 'One Time Gift'), true);
			Payment__c testPayment = (Payment__c)TestDataTemplates.createSObject(new Payment__c(Donation__c = testGift.Id, Date__c = Date.today()), true);

			return testPayment;
	}

	public static Payment__c CreateSObjectRecurring() {
			BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
			App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
			Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), true);
			String appealId = [SELECT Id FROM RecordType WHERE Name = 'Appeal'].Id;
			Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id, Name = 'Test Appeal', RecordTypeId = appealId), true);
			Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
			Recurring_Donation__c testRecurringDonation = (Recurring_Donation__c)TestDataTemplates.createSObject(new Recurring_Donation__c(Constituent__c = testContact.Id), true);
			Gift__c testGift = (Gift__c)TestDataTemplates.createSObject( new Gift__c(
				Constituent__c = testContact.Id,
				Recurring_Donation__c = testRecurringDonation.Id,
				Gift_Date__c = Date.today(),
				Status__c = 'Active',
				Gift_Type__c = 'Recurring'), true);
			Payment__c testPayment = (Payment__c)TestDataTemplates.createSObject(new Payment__c(Donation__c = testGift.Id, Date__c = Date.today()), true);

			return testPayment;
	}

	@isTest static void TestSelectCountDateRange() {
		Payment__c expectedPayment = CreateSObject();

		Test.startTest();
				Integer results = new PaymentSelector().SelectCountDateRange('One Time Gift', 'Active', Date.today(), Date.today().addDays(-7), Date.today().addDays(-7), Date.today().addDays(7));
		System.AssertEquals(results, 1);
		Test.stopTest();
	}

	@isTest static void TestSelectPaymentsByTransactionForTargetYear() {
		Payment__c expectedPayment = CreateSObjectRecurring();
		
		Test.startTest();
				Database.QueryLocator results = new PaymentSelector().SelectPaymentsByTransactionForTargetYear(Date.today(), Date.today().addDays(-7), Date.today().addDays(-7), Date.today().addDays(7));
				Database.QueryLocatorIterator it = results.iterator();
				Payment__c actualPayment = new Payment__c();
				while(it.hasNext()){
					actualPayment = (Payment__c)it.next();
					break;
				}
				System.AssertEquals(expectedPayment.Id, actualPayment.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectPaymentByAccountAndRecordIds() {
		Payment__c expectedPayment = CreateSObject();
		Set<Id> accountIds = new Set<Id>{[SELECT Donation__r.Organization__c FROM Payment__c].Donation__r.Organization__c};
		Set<Id> recordIds = new Set<Id>{[SELECT Donation__r.RecordTypeId FROM Payment__c].Donation__r.RecordTypeId};

		Test.startTest();
				List<Payment__c> results = new PaymentSelector().SelectPaymentByAccountAndRecordIds(accountIds, recordIds);
				Payment__c actualPayment = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedPayment.Id, actualPayment.Id);
		Test.stopTest();
	}
}