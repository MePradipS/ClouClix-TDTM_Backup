@isTest
public with sharing class GiftSelectorTest {
	public static Gift__c CreateSObjectContactRelated() {
			BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
			App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
			Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), true);
			String appealId = [SELECT Id FROM RecordType WHERE Name = 'Appeal'].Id;
			Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id, Name = 'Test Appeal', RecordTypeId = appealId), true);
			Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
			Recurring_Donation__c testRecurringDonation = (Recurring_Donation__c)TestDataTemplates.createSObject(new Recurring_Donation__c(Constituent__c = testContact.Id), true);
			Gift__c testGift = (Gift__c)TestDataTemplates.createSObject( new Gift__c(Constituent__c = testContact.Id, Recurring_Donation__c = testRecurringDonation.Id, Gift_Date__c = Date.today(), Status__c = 'Active'), true);
			Payment__c testPayment = (Payment__c)TestDataTemplates.createSObject(new Payment__c(Donation__c = testGift.Id), true);

			return testGift;
	}

	public static Gift__c CreateSObjectOrgRelated() {
			BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
			App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
			Account testAccount = (Account)TestDataTemplates.createSObject(new Account(Name = 'Test Account'), true);
			Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), true);
			String appealId = [SELECT Id FROM RecordType WHERE Name = 'Appeal'].Id;
			Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id, Name = 'Test Appeal', RecordTypeId = appealId), true);
			Gift__c testGift = (Gift__c)TestDataTemplates.createSObject( new Gift__c(Organization__c = testAccount.Id, Foundation_Credit__c = testAccount.Id, Gift_Date__c = Date.today(), Status__c = 'Active'), true);

			return testGift;
	}

	@isTest static void TestSelectIdByOrganization() {
		Gift__c expectedGift = CreateSObjectOrgRelated();

		Test.startTest();
				List<Gift__c> results = new GiftSelector().SelectIdByOrganization(expectedGift.Organization__c);
				Gift__c actualGift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectIdByConstituent() {
		Gift__c expectedGift = CreateSObjectContactRelated();

		Test.startTest();
				List<Gift__c> results = new GiftSelector().SelectIdByConstituent(expectedGift.Constituent__c);
				Gift__c actualGift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectIdByRecurringDonation() {
		Gift__c expectedGift = CreateSObjectContactRelated();

		Test.startTest();
				List<Gift__c> results = new GiftSelector().SelectIdByRecurringDonation(expectedGift.Recurring_Donation__c);
				Gift__c actualGift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectGiftConstituentOrganizationRecurringDonationById() {
		Gift__c expectedGift = CreateSObjectContactRelated();
		Set<Id> idSet = new Set<Id>{expectedGift.Id};

		Test.startTest();
				List<Gift__c> results = new GiftSelector().SelectGiftConstituentOrganizationRecurringDonationById(idSet);
				Gift__c actualGift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectAllRecurringInfoById() {
		Gift__c expectedGift = CreateSObjectContactRelated();
		Set<Id> idSet = new Set<Id>{expectedGift.Id};

		Test.startTest();
				List<Gift__c> results = new GiftSelector().SelectAllRecurringInfoById(idSet);
				Gift__c actualGift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectOrganizationNameByOrganizationId() {
		Gift__c expectedGift = CreateSObjectOrgRelated();
		Set<Id> idSet = new Set<Id>{expectedGift.Organization__c};

		Test.startTest();
				List<Gift__c> results = new GiftSelector().SelectOrganizationNameByOrganizationId(idSet);
				Gift__c actualGift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectOrganizationNameAndConstituentNameById() {
		Gift__c expectedGift = CreateSObjectOrgRelated();
		Set<Id> idSet = new Set<Id>{expectedGift.Organization__c};

		Test.startTest();
				List<Gift__c> results = new GiftSelector().SelectOrganizationNameAndConstituentNameById(idSet);
				Gift__c actualGift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectGiftAndRecurringDonationWhereIdInIdsAndWithinYearRangs() {
		Gift__c expectedGift = CreateSObjectContactRelated();
		Set<Id> idSet = new Set<Id>{expectedGift.Recurring_Donation__c};
		Date today = Date.today();
		Date thisYear = today.addDays(-7);
		Date nextYear = today.addYears(1);

		Test.startTest();
				List<Gift__c> results = new GiftSelector().SelectGiftAndRecurringDonationWhereIdInIdsAndWithinYearRangs(idSet, thisYear, nextYear);
				Gift__c actualGift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectRecurringDonationAmountById() {
		Gift__c expectedGift = CreateSObjectContactRelated();
		Set<Id> idSet = new Set<Id>{expectedGift.Recurring_Donation__c};

		Test.startTest();
				List<Gift__c> results = new GiftSelector().SelectRecurringDonationAmountById(idSet);
				Gift__c actualGift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	@isTest static void TestLocateGiftAndPayments() {
		Gift__c expectedGift = CreateSObjectContactRelated();

		Test.startTest();
				Database.QueryLocator results = new GiftSelector().LocateGiftAndPayments();
				Database.QueryLocatorIterator it = results.iterator();
				Gift__c actualGift = new Gift__c();
				while(it.hasNext()){
					actualGift = (Gift__c)it.next();
					break;
				}
		System.AssertEquals(expectedGift.Id, actualGift.Id);
		Test.stopTest();
	}

	//MULTICURRENCY TEST ONLY!!
	// @isTest static void TestSelectGiftByFoundationCreditAndConvert() {
	// 	Gift__c expectedGift = CreateSObjectOrgRelated();
	// 	Set<Id> idSet = new Set<Id>{expectedGift.Foundation_Credit__c};
	//
	// 	Test.startTest();
	// 			List<Gift__c> results = new GiftSelector().SelectGiftByFoundationCreditAndConvert(idSet);
	// 			Gift__c actualGift = results.size() > 0 ? results[0] : null;
	// 	System.AssertEquals(expectedGift.Id, actualGift.Id);
	// 	Test.stopTest();
	// }

	// @isTest static void TestSelectByAccountIdAndConvert() {
	// 	Gift__c expectedGift = CreateSObjectOrgRelated();
	// 	Set<Id> idSet = new Set<Id>{expectedGift.Organization__c};
	//
	// 	Test.startTest();
	// 			List<Gift__c> results = new GiftSelector().SelectByAccountIdAndConvert(idSet);
	// 			Gift__c actualGift = results.size() > 0 ? results[0] : null;
	// 	System.AssertEquals(expectedGift.Id, actualGift.Id);
	// 	Test.stopTest();
	// }

	// @isTest static void TestSelectGiftInfoAndConvert() {
	// 	Gift__c expectedGift = CreateSObjectContactRelated();
	// 	Set<Id> idSet = new Set<Id>{expectedGift.Constituent__c};
	//
	// 	Test.startTest();
	// 			List<Gift__c> results = new GiftSelector().SelectGiftInfoAndConvert(idSet);
	// 			Gift__c actualGift = results.size() > 0 ? results[0] : null;
	// 	System.AssertEquals(expectedGift.Id, actualGift.Id);
	// 	Test.stopTest();
	// }
}