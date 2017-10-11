@isTest
public class CSearchTest{

    public static testMethod void CSearchTest(){
	    Contact c = new Contact(FirstName = 'Test', LastName = 'Test');
	    insert c;
	    ApexPages.currentPage().getParameters().put('id',c.Id);
	    CSearch  csearchs=new CSearch();
	    csearchs.getTypes();
	    csearchs.refreshList();

	    csearchs.signUp();
    }

    public static testMethod void CSearch1Test(){

    Volunteer_Opportunity__c volopp=new Volunteer_Opportunity__c();
	    volopp.Status__c='Proposed';
	    volopp.Program__c='test;Hindi;English';
	    insert volopp;

	    Volunteer_Role__c     vol=new  Volunteer_Role__c();
	    vol.Volunteer_Opportunity__c=volopp.Id;

	    insert vol;

	    Contact c = new Contact(FirstName = 'Test', LastName = 'Test',Preferred_Program_1__c='tst',Preferred_Program_2__c='testss',Preferred_Locales__c='test',Languages__c='test;Hindi;English;',Professional_Skills__c='testing');
	    insert c;

	    Volunteer_Application__c volapp=new Volunteer_Application__c();

	    ApexPages.currentPage().getParameters().put('id',c.Id);

	    CSearch  csearchs=new CSearch();

	    csearchs.theOpp=volopp;

	    ApexPages.currentPage().getParameters().put('Index','12');
	    String t1='1';
	    Boolean t2=true;
	    CSearch.CKvp  ckvpvalues=new CSearch.CKvp(t1,t2);
	    csearchs.filterOptions.add(ckvpvalues);
	    csearchs.refreshList();
	    csearchs.signUp();
    }
}