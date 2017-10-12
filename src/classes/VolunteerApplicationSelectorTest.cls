@isTest
public with sharing class VolunteerApplicationSelectorTest {
	public static Volunteer_Application__c CreateSObject() {
			BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
			App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
			Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
			Volunteer_Opportunity__c testOpportunity = (Volunteer_Opportunity__c)TestDataTemplates.createSObject(new Volunteer_Opportunity__c(
				Name = 'Test Opportunity'), true);
			Volunteer_Role__c testRole = (Volunteer_Role__c)TestDataTemplates.createSObject(new Volunteer_Role__c(
				Name = 'Test Role',
				Volunteer_Opportunity__c = testOpportunity.Id), true);
			Volunteer_Application__c testApplication = (Volunteer_Application__c)TestDataTemplates.createSObject(new Volunteer_Application__c(
				Volunteer__c = testContact.Id,
				Volunteer_Role__c = testRole.Id,
				Status__c = 'Approved',
				RecordTypeId = [Select Id FROM RecordType WHERE Name = 'Individual Application'].Id), true);
			Volunteer_Shift__c testShift = (Volunteer_Shift__c)TestDataTemplates.createSObject(new Volunteer_Shift__c(
				Volunteer_Role__c = testRole.Id,
				Volunteer__c = testContact.Id,
				Volunteer_Application__c = testApplication.Id), true);

			return testApplication;
	}

	@isTest static void TestSelectVolunteerDetailsByContactId() {
		Volunteer_Application__c expectedApplication = CreateSObject();

		Test.startTest();
				List<Volunteer_Application__c> results = new VolunteerApplicationSelector().SelectVolunteerDetailsByContactId(expectedApplication.Volunteer__c);
				Volunteer_Application__c actualApplication = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedApplication.Id, actualApplication.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectVolunteerApplicationInfo() {
		Volunteer_Application__c expectedApplication = CreateSObject();

		Test.startTest();
				List<Volunteer_Application__c> results = new VolunteerApplicationSelector().SelectVolunteerApplicationInfo(expectedApplication.Volunteer__c, 'Approved');
				Volunteer_Application__c actualApplication = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedApplication.Id, actualApplication.Id);
		Test.stopTest();
	}
}