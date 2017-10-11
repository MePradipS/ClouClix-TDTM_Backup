@isTest
public with sharing class VolunteerShiftSelectorTest {
	public static Volunteer_Shift__c CreateSObject() {
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
				RecordTypeId = Utilities.getObjectRecordTypeId(Volunteer_Application__c.SObjectType, 'Individual Application')), true);
			Volunteer_Shift__c testShift = (Volunteer_Shift__c)TestDataTemplates.createSObject(new Volunteer_Shift__c(
				Volunteer_Role__c = testRole.Id,
				Volunteer__c = testContact.Id,
				Volunteer_Application__c = testApplication.Id), true);

			return testShift;
	}

	@isTest static void TestSelectByVolunteerRoleAndVolunteer() {
		Volunteer_Shift__c expectedShift = CreateSObject();

		Test.startTest();
				List<Volunteer_Shift__c> results = new VolunteerShiftSelector().SelectByVolunteerRoleAndVolunteer(expectedShift.Volunteer_Role__c, expectedShift.Volunteer__c);
				Volunteer_Shift__c actualShift = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedShift.Id, actualShift.Id);
		Test.stopTest();
	}
}