@isTest
public with sharing class UserSelectorTest {
	public static User CreateSObject() {
			List<Profile> Profiles = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
			String profileId = Profiles[0].Id;
			User userObject = (User)TestDataTemplates.createSObject(new User(
				isActive = true,
				Receive_CC_Updates__c = true,
				Username = 'Username@causeview.com',
				LastName = 'LastName',
				Email = 'Test@email.com',
				Alias = 'tester',
				CommunityNickname = 'test1',
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'ISO-8859-1',
				ProfileId = profileId,
				LanguageLocaleKey = 'en_US'), true);

			return userObject;
	}

	@isTest static void TestSelectByReceiveCCUpdatesAndIsActive() {
		User expectedUser = CreateSObject();

		Test.startTest();
				List<User> results = new UserSelector().SelectByReceiveCCUpdatesAndIsActive();
				User actualUser = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedUser.Id, actualUser.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectBatchById() {
		User expectedUser = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedUser.Id};

		Test.startTest();
				List<User> results = new UserSelector().SelectBatchById(idSet);
				User actualUser = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedUser.Id, actualUser.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectContactIdById() {
		User expectedUser = CreateSObject();

		Test.startTest();
				List<User> results = new UserSelector().SelectContactIdById(expectedUser.Id);
				User actualUser = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedUser.Id, actualUser.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectUserCountByLicenseKey() {
		User expectedUser = CreateSObject();

		Test.startTest();
				Integer results = new UserSelector().SelectUserCountByLicenseKey(expectedUser.Id, '', '');
		System.AssertEquals(0, results);
		Test.stopTest();
	}
}