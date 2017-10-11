@isTest
public class CPlaceApplicantTest{

  public static testMethod void CPlaceApplicantTest(){
		BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
		App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);

		Contact c = (Contact)TestDataTemplates.createSObject(new Contact(
			FirstName = 'Test',
	    LastName = 'Test',
			Preferred_Program_1__c='tst',
	    Preferred_Program_2__c = 'testss',
	    Preferred_Locales__c = 'test',
	    Languages__c = 'test;Hindi;English;',
	    Professional_Skills__c = 'testing',
	    Volunteer_Availability__c = 'Monday Morning;Monday Afternoon'), true);

		Volunteer_Application__c volapp = (Volunteer_Application__c)TestDataTemplates.createSObject(new Volunteer_Application__c(Volunteer__c = c.Id), true);
		Volunteer_Opportunity__c volopp = (Volunteer_Opportunity__c)TestDataTemplates.createSObject(new Volunteer_Opportunity__c(Status__c = 'Proposed'), true);
		Volunteer_Role__c vol = (Volunteer_Role__c)TestDataTemplates.createSObject(new Volunteer_Role__c(Volunteer_Opportunity__c = volopp.Id), true);
    Volunteer_Application__c volapp1 = (Volunteer_Application__c)TestDataTemplates.createSObject(new Volunteer_Application__c(Volunteer__c = c.Id, Volunteer_Role__c = vol.Id), true);
		Volunteer_Shift__c vlshift = (Volunteer_Shift__c)TestDataTemplates.createSObject(new Volunteer_Shift__c(
			Location_City__c='test',
			Location_State__c='test',
			Frequency__c='Flexible',
			Volunteer_Role__c = volapp1.Volunteer_Role__c,
			Volunteer__c = volapp1.Volunteer__c,
			Start_Time__c = datetime.newInstance(2014, 9, 15, 12, 30, 0),
			End_Time__c = datetime.newInstance(2014, 9, 15, 13, 30, 0),
			Start_Day__c=Date.Today(),
			End_Day__c=Date.Today()+10), true);

		PageReference pageRef = Page.ManagePlacements;
    Test.startTest();
			Test.setCurrentPage(pageRef);
	    ApexPages.currentPage().getParameters().put('id',volapp1.Id);
	    CPlaceApplicant cpapp = new CPlaceApplicant();
	    CPlaceApplicant.PlacementWrapper pwrapp = new CPlaceApplicant.PlacementWrapper();
	    pwrapp.shift=vlshift;
	    cpapp.place();
    Test.stopTest();
  }
}