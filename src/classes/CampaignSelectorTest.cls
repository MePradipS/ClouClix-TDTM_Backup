@isTest
public with sharing class CampaignSelectorTest {
	public static Campaign CreateSObject() {
			String rtypeId = [SELECT Id FROM RecordType WHERE Name = 'Appeal'].Id;
			BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
			App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
			Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), true);
			Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id, Name = 'Test Appeal', RecordTypeId = rtypeId), true);
			Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
			Gift__c testGift = (Gift__c)TestDataTemplates.createSObject( new Gift__c(Constituent__c = testContact.Id), true);

			return testAppeal;
	}

	@isTest static void TestSelectIdAndRecordTypeNameById() {
		Campaign expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Campaign> results = new CampaignSelector().SelectIdAndRecordTypeNameById(idSet);
				Campaign actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectCampaignAndFundById() {
		Campaign expectedCampaign = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedCampaign.Id};

		Test.startTest();
				List<Campaign> results = new CampaignSelector().SelectCampaignAndFundById(idSet);
				Campaign actualCampaign = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedCampaign.Id, actualCampaign.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectCampaignFundAndLetterById() {
		Campaign expectedCampaign = CreateSObject();
		List<RecordType> idSet = new List<RecordType>{new RecordType(Id = expectedCampaign.RecordTypeId)};

		Test.startTest();
				List<Campaign> results = new CampaignSelector().SelectCampaignFundAndLetterById(idSet);
				Campaign actualCampaign = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedCampaign.Id, actualCampaign.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectCampaignFundAndLetterBySearch() {
		Campaign expectedCampaign = CreateSObject();
		List<RecordType> idSet = new List<RecordType>{new RecordType(Id = expectedCampaign.RecordTypeId)};

		Test.startTest();
				List<Campaign> results = new CampaignSelector().SelectCampaignFundAndLetterBySearch(idSet, 'Test Appeal');
				Campaign actualCampaign = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedCampaign.Id, actualCampaign.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectRecordTypeIdByStringId() {
		Campaign expectedCampaign = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedCampaign.Id};

		Test.startTest();
				List<Campaign> results = new CampaignSelector().SelectRecordTypeIdByStringId(idSet);
				Campaign actualCampaign = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedCampaign.Id, actualCampaign.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectCampaignAndRelatedFund() {
		Campaign expectedCampaign = CreateSObject();

		Test.startTest();
				List<Campaign> results = new CampaignSelector().SelectCampaignAndRelatedFund('Appeal', 'Test Appeal');
				Campaign actualCampaign = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedCampaign.Id, actualCampaign.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectCampaignIdByRecordTypeId() {
		Campaign expectedCampaign = CreateSObject();

		Test.startTest();
				Database.QueryLocator results = new CampaignSelector().SelectCampaignIdByRecordTypeId('');
				Database.QueryLocatorIterator it = results.iterator();
				Campaign actualCampaign = new Campaign();
				while(it.hasNext()){
					actualCampaign = (Campaign)it.next();
					break;
				}
		System.AssertEquals(expectedCampaign.Id, actualCampaign.Id);
		Test.stopTest();
	}

}