@isTest
public class CSearchPosTest{
    public static testMethod void CSearchPosTest(){
			BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
			App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
			Volunteer_Opportunity__c volopp = (Volunteer_Opportunity__c)TestDataTemplates.createSObject(new Volunteer_Opportunity__c(Status__c='Proposed'), true);
			Volunteer_Role__c vol = (Volunteer_Role__c)TestDataTemplates.createSObject(new Volunteer_Role__c(Volunteer_Opportunity__c=volopp.Id, Role_Locale__c='test'), true);
			Contact c = (Contact)TestDataTemplates.createSObject(new Contact(
				FirstName = 'Test',
		    LastName = 'Test',Preferred_Program_1__c='tst',
		    Preferred_Program_2__c='testss',
		    Preferred_Locales__c='test',
		    Languages__c='test;Hindi;English;',
		    Professional_Skills__c='testing',
		    Volunteer_Availability__c='Monday Morning;Monday Afternoon'), true);

			PageReference pageRef = Page.SearchPos;
	    Test.startTest();
				Test.setCurrentPage(pageRef);
		    ApexPages.currentPage().getParameters().put('id',vol.Id);
		    CSearchPos   cserchposi=new CSearchPos();
		    cserchposi.back();
		    cserchposi.getTypes();
		    cserchposi.getPreferredLocales();
		    cserchposi.getVolunteerAvailability();
		    cserchposi.con=c;
		    String t1='1';
		    Boolean t2=true;
		    CSearchPos.CKvp  ckvpvalues=new CSearchPos.CKvp(t1,t2);
		    cserchposi.filterOptions.add(ckvpvalues);
		    cserchposi.filterOptionsLang.add(ckvpvalues);
		    cserchposi.refreshList();

		    CSearchPos.resultWrapper  rewrap=new CSearchPos.resultWrapper(c);
		    cserchposi.addToCampaign();
		    cserchposi.addConfirm();
	    Test.stopTest();
    }
}