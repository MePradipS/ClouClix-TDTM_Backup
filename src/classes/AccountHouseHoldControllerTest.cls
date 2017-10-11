@isTest
private class AccountHouseHoldControllerTest {
	
	@isTest static void TestSetDirectPage() {
		PageReference pageRef = Page.AccountHouseHoldRedirect;
		Account testAccount = (Account)TestDataTemplates.createSObject(new Account());

		Test.startTest();
		Test.setCurrentPage(pageRef);
		AccountHouseHoldController ahhc = new AccountHouseHoldController(new ApexPages.StandardController(testAccount));
		
		System.AssertEquals('HouseHold', ahhc.SetRedirectPage());
		Test.stopTest();
	}
	
	@isTest static void TestSetUrlParameters() {
		PageReference pageRef = Page.AccountHouseHoldRedirect;
		Account testAccount = (Account)TestDataTemplates.createSObject(new Account());

		Test.startTest();
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getHeaders().put('Referer', 'OldPage');
		AccountHouseHoldController ahhc = new AccountHouseHoldController(new ApexPages.StandardController(testAccount));
		
		System.AssertEquals('?Url=OldPage', ahhc.SetUrlParameters());
		Test.stopTest();
	}
	
}