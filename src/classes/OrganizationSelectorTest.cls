@isTest
public with sharing class OrganizationSelectorTest {

	@isTest static void TestSelectIdByOrganization() {
		Organization expectedOrg = [select Id from Organization limit 1];

		Test.startTest();
				List<Organization> results = new OrganizationSelector().SelectIdByLimit(1);
				Organization actualOrg = results.size() > 0 ? results[0] : null;
				System.AssertEquals(expectedOrg.Id, actualOrg.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectCreatedDate() {
		Organization expectedOrg = [select Id, CreatedDate from Organization];

		Test.startTest();
				List<Organization> results = new OrganizationSelector().SelectCreatedDate();
				Organization actualOrg = results.size() > 0 ? results[0] : null;
				System.AssertEquals(expectedOrg.Id, actualOrg.Id);
		Test.stopTest();
	}
}