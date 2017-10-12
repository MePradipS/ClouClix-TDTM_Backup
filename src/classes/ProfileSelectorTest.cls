@isTest
public with sharing class ProfileSelectorTest {

		@isTest static void TestSelectIdByName() {
			Profile expectedProfile = [select Id, Name from Profile limit 1];

			Test.startTest();
					Profile actualProfile = new ProfileSelector().SelectIdByName(expectedProfile.Name);
			System.AssertEquals(expectedProfile.Id, actualProfile.Id);
			Test.stopTest();
		}
}