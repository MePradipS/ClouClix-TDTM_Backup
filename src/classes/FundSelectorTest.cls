@isTest
public with sharing class FundSelectorTest {
	public static Fund__c CreateSObject() {
			Fund__c fundObject = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), 'TestDataTemplates.FundWithGLCodes', false);
			insert fundObject;
			return fundObject;
	}

	@isTest static void TestConvertOppQueryFund() {
		Fund__c expectedFund = CreateSObject();
		String clause = 'Id = \''+expectedFund.Id+'\'';

		Test.startTest();
				List<Fund__c> results = new FundSelector().ConvertOppQueryFund(clause);
				Fund__c actualFund = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedFund.Id, actualFund.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectCreditAndDebitRecords() {
		Fund__c expectedFund = CreateSObject();
		Set<Id> fundIds = new Set<Id>{expectedFund.Id};

		Test.startTest();
				List<Fund__c> results = new FundSelector().SelectCreditAndDebitRecords(fundIds);
				Fund__c actualFund = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedFund.Id, actualFund.Id);
		Test.stopTest();
	}
}