@isTest
public with sharing class ContactSelectorTest {
	public static Contact CreateSObject() {
			Date dateObj = Date.today();

			Account accountObject = (Account)TestDataTemplates.createSObject(new Account(), true);
			accountObject.Name = 'Test Account';

			Contact contactObject = new Contact(
				LastName = 'Tester',
				Email = 'Test@email.com',
				Constituent_ID__c = '1000666',
				Total_Lifetime_Giving__c = 5.00,
				Date_of_First_Gift__c = dateObj.addYears(-1).addDays(7),
				Date_of_Last_Gift__c = dateObj.addDays(-3),
				AccountId = accountObject.Id
			);

			insert contactObject;

			Gift__c testGift = (Gift__c)TestDataTemplates.createSObject(new Gift__c(
			Constituent__c = contactObject.Id,
			Receipt_Type__c = 'Consolidated',
			Status__c = 'Active',
			Gift_Date__c = dateObj.addYears(-1).addDays(7)), true);
			Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), true);
			Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id), true);
			Payment__c testPayment = (Payment__c)TestDataTemplates.createsObject(new Payment__c(Donation__c = testGift.Id), true);

			return contactObject;
	}

	public static Contact CreateSObjectForRetainedDonors() {
			Account accountObject = (Account)TestDataTemplates.createSObject(new Account(), true);
			accountObject.Name = 'Test Account';

			Date dateObj = Date.today();

			Contact contactObject = new Contact(
				LastName = 'Tester',
				Email = 'Test@email.com',
				Constituent_ID__c = '1000666',
				Total_Lifetime_Giving__c = 5.00,
				Date_of_First_Gift__c = dateObj.addYears(-2).addDays(-7),
				Date_of_Last_Gift__c = dateObj.addDays(-3),
				AccountId = accountObject.Id
			);

			insert contactObject;
			return contactObject;
	}

	@isTest static void TestSelectNameById() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectNameById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectEmailById() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectEmailById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectIdByEmail() {
		Contact expectedContact = CreateSObject();

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectIdByEmail(expectedContact.Email);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectVolunteerAvailabilityById() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectVolunteerAvailabilityById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectVolunteerInfoById() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectVolunteerInfoById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectConstituentIdByConstituentId() {
		Contact expectedContact = CreateSObject();
		Set<String> idSet = new Set<String>{'1000666'};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectConstituentIdByConstituentId(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectConstituentIdByConstituentIdNotId() {
		Contact expectedContact = CreateSObject();
		Set<String> conIdSet = new Set<String>{'1000666'};
		Set<Id> idSet = new Set<Id>{};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectConstituentIdByConstituentIdNotId(conIdSet, idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectAllConstituentInfoByConstituentId() {
		Contact expectedContact = CreateSObject();
		Set<String> idSet = new Set<String>{'1000666'};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectAllConstituentInfoByConstituentId(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectEventAttendanceById() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectEventAttendanceById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectAccountInfoById() {
		Contact expectedContact = CreateSObject();
		Set<String> idSet = new Set<String>{'1000666'};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectAccountInfoById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectOwnerAndAccountById() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectOwnerAndAccountById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectLastModifiedContactBySearch() {
		Contact expectedContact = CreateSObject();

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectLastModifiedContactBySearch('Tester');
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectDonorsInPastYear() {
		Contact expectedContact = CreateSObject();
		Date lastYear = Date.today();
		lastYear = lastYear.AddYears(-1);
		Date currentDate = Date.today();

		Test.startTest();
				AggregateResult[] results = new ContactSelector().SelectDonorsInPastYear(lastYear,currentDate);
				AggregateResult actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(1, actualContact.get('donorCount'));
		Test.stopTest();
	}

	@isTest static void TestSelectRetainedDonors() {
		Contact expectedContact = CreateSObjectForRetainedDonors();
		Date lastYear = Date.today();
		Date last2Years = Date.today();
		Date currentDate = Date.today();
		last2Years = last2Years.AddYears(-2);
		lastYear = lastYear.AddYears(-1);

		Test.startTest();
				AggregateResult[] results = new ContactSelector().SelectRetainedDonors(last2Years, lastYear, currentDate);
				AggregateResult actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(1, actualContact.get('donorCount'));
		Test.stopTest();
	}

	@isTest static void TestSelectVolunteerStatusById() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectVolunteerStatusById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectContactExitDetails() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectContactExitDetails(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectContactDataCompleteDetails() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectContactDataCompleteDetails(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectVolunteerTotalsById() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.AccountId};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectVolunteerTotalsById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectAllContactInfoById() {
		Contact expectedContact = CreateSObject();
		Set<String> idSet = new Set<String>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectAllContactInfoById(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : null;
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectContactGiftsByIdForUpdate() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectContactGiftsByIdForUpdate(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : new Contact();
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectContactTotalsWhereIdInIds() {
		Contact expectedContact = CreateSObject();
		Set<Id> idSet = new Set<Id>{expectedContact.Id};

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectContactTotalsWhereIdInIds(idSet);
				Contact actualContact = results.size() > 0 ? results[0] : new Contact();
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestLocateConsolidatedReciptBatch() {
		Contact expectedContact = CreateSObject();

		Test.startTest();
				Database.QueryLocator results = new ContactSelector().LocateConsolidatedReciptBatch();
				Database.QueryLocatorIterator it = results.iterator();
				Contact actualContact = new Contact();
				while(it.hasNext()){
					actualContact = (Contact)it.next();
					break;
				}
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestqueryContactIdNameByIdStatusAndDate() {
		Contact expectedContact = CreateSObject();

		Test.startTest();
				Database.QueryLocator results = new ContactSelector().queryContactIdNameByIdStatusAndDate();
				Database.QueryLocatorIterator it = results.iterator();
				Contact actualContact = new Contact();
				while(it.hasNext()){
					actualContact = (Contact)it.next();
					break;
				}
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestLocateRollupBatchForConsecutiveYears() {
		Contact expectedContact = CreateSObject();

		Test.startTest();
				Database.QueryLocator results = new ContactSelector().LocateRollupBatchForConsecutiveYears();
				Database.QueryLocatorIterator it = results.iterator();
				Contact actualContact = new Contact();
				while(it.hasNext()){
					actualContact = (Contact)it.next();
					break;
				}
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectVolunteerByContactId() {
		Contact expectedContact = CreateSObject();

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectVolunteerByContactId(expectedContact.Id);
				Contact actualContact = results.size() > 0 ? results[0] : new Contact();
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectContactWithDynamicClause() {
		Contact expectedContact = CreateSObject();
		String clause = ' WHERE Id=\'\''+expectedContact.Id+'\'\'';

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectContactWithDynamicClause(clause);
				Contact actualContact = results.size() > 0 ? results[0] : new Contact();
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}

	@isTest static void TestSelectVolunteerWithDynamicClause() {
		Contact expectedContact = CreateSObject();
		String clause = ' WHERE Id=\'\''+expectedContact.Id+'\'\'';

		Test.startTest();
				List<Contact> results = new ContactSelector().SelectVolunteerWithDynamicClause(clause);
				Contact actualContact = results.size() > 0 ? results[0] : new Contact();
		System.AssertEquals(expectedContact.Id, actualContact.Id);
		Test.stopTest();
	}
}