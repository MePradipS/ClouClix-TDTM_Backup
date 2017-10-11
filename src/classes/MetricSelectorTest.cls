@isTest
public with sharing class MetricSelectorTest {
	public static Metric__c CreateSObject() {
			BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
			App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
			Metric__c testMetric = (Metric__c)TestDataTemplates.createSObject(new Metric__c(), true);

			return testMetric;
	}

	@isTest static void TestSelectByCreatedDateGteDate() {
		Metric__c expectedMetric = CreateSObject();

		Test.startTest();
				List<Metric__c> results = new MetricSelector().SelectByCreatedDateGteDate(Date.today());
				Metric__c actualMetric = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedMetric.Id, actualMetric.Id);
		Test.stopTest();
	}
}