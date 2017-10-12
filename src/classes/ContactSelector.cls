public with sharing class ContactSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Contact.Id, Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, Contact.MailingStreet,
			Contact.Email, Contact.FirstName, Contact.LastName, Contact.Phone };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Contact.sObjectType;
	}

	public List<Contact> SelectNameById(Set<Id> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Name };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectEmailById(Set<Id> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Email };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectIdByEmail(String email) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Email };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Email = :email',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Contact> SelectVolunteerAvailabilityById(Set<Id> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Volunteer_Availability__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectVolunteerInfoById(Set<Id> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.FirstName, Contact.LastName, Contact.Preferred_Program_1__c, Contact.Preferred_Program_2__c,
			Contact.Professional_Skills__c, Contact.Languages__c, Contact.Preferred_Locales__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectConstituentIdByConstituentId(Set<String> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.Constituent_ID__c, Contact.CreatedDate, Contact.LastModifiedDate };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Constituent_ID__c in :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectConstituentIdByConstituentIdNotId(Set<String> conIdSet, Set<Id> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.Constituent_ID__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Constituent_ID__c in :conIdSet and Id <> :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectAllConstituentInfoByConstituentId(Set<String> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.Middle_Name__c, Contact.Trade_Status__c, Contact.Constituent_ID__c, Contact.Solicit_Codes__c,
			Contact.Primary_Salutation__c, Contact.Name, Contact.Salutation, Contact.FirstName,
			Contact.LastName, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState,
			Contact.MailingCity, Contact.MailingStreet, Contact.Region__c, Contact.Email,
			Contact.Phone, Contact.Primary_Addressee__c, Contact.Constituent_Codes__c, Contact.AccountId,
			Contact.Household__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Constituent_ID__c in :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectEventAttendanceById(Set<Id> idSet) {
		List<Schema.SObjectField> campaignFieldList = new List<Schema.SObjectField> {
			Campaign.Name, Campaign.StartDate };
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.Date_of_Last_Event_Attended__c, Contact.Event_Attended__c, Contact.Name_of_Last_Event_Attended__c };
		IsCustomAccessible(customContactFieldList);

		new EventRegistrationSelector().IsCustomAccessible(new List<Schema.SObjectField> { Event_Registration__c.Registration_Date__c, Event_Registration__c.Status__c});
		new CampaignSelector().IsCustomAccessible(campaignFieldList);

		String queryString = String.format('select {0}, (SELECT Registration_Date__c, Event__r.Name,Event__r.StartDate from Event_Registrations__r where Status__c = \'\'Attended\'\' order by Registration_Date__c desc) from {1} where Id in :idSet for update',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectAccountInfoById(Set<String> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.AccountId, Contact.FirstName, Contact.LastName, Contact.Constituent_ID__c };
		IsCustomAccessible(customContactFieldList);
		IsCustomAccessible(new List<Schema.SObjectField>{Contact.Constituent_ID__c});

		String queryString = String.format('select {0} from {1} where Constituent_ID__c in :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectOwnerAndAccountById(Set<Id> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.OwnerId, Contact.AccountId };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectLastModifiedContactBySearch(String search) {
		List<Schema.SObjectField> userFieldList = new List<Schema.SObjectField> { User.Name };
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.Name, Contact.Constituent_ID__c, Contact.MailingState, Contact.MailingStreet, Contact.MailingPostalCode,
			Contact.MailingCity, Contact.LastModifiedDate, Contact.FirstName, Contact.LastName };
		IsCustomAccessible(customContactFieldList);
		new UserSelector().IsCustomAccessible(userFieldList);

		String searchString = (search == null) ? null : (search + '%');
		String queryString = String.format('select {0}, LastModifiedBy.Name from {1} where (FirstName like :searchString or LastName like :searchString or Constituent_ID__c like :searchString or MailingPostalCode like :searchString or Name like :searchString) order by Name limit 100',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectDonorsInPastYear(Date lastYear, Date currentDate) {
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Date_of_First_Gift__c };
		IsCustomAccessible(contactFieldList);

		String queryString = String.format('select COUNT_DISTINCT(Id)donorCount from {0} where Date_of_First_Gift__c >= :lastYear and Date_of_First_Gift__c <= :currentDate',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectRetainedDonors(Date lastTwoYears, Date lastYear, Date currentDate) {
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.Date_of_First_Gift__c, Contact.Total_Lifetime_Giving__c, Contact.Date_of_Last_Gift__c };
		IsCustomAccessible(contactFieldList);

		String queryString = String.format('select COUNT_DISTINCT(Id)donorCount from {0} where Total_Lifetime_Giving__c > 0 and Date_of_First_Gift__c <= :lastTwoYears and (Date_of_Last_Gift__c >= :lastYear and Date_of_Last_Gift__c <= :currentDate)',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectVolunteerStatusById(Set<Id> ConIds) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Volunteer_Status__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Id in :ConIds',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectContactExitDetails(Set<Id> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Date_of_Last_Exit__c,
		Contact.Last_Role_Exited__c, Contact.Reason_for_Last_Exit__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectContactDataCompleteDetails(Set<Id> contactIds) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Data_complete_for_Gift_Aid__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Id in :contactIds',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Contact> SelectVolunteerTotalsById(Set<Id> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Total_Service_Hours_Completed_This_Year__c, Contact.Total_Miles_Traveled_This_Year__c, Contact.Total_Miles_Traveled__c, Contact.Total_Service_Hours_Completed__c };
		IsCustomAccessible(customContactFieldList);
		IsCustomAccessible(new List<Schema.SObjectField>{Contact.AccountId});

		String queryString = String.format('SELECT {0} FROM {1} WHERE AccountId IN :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Contact> SelectAllContactInfoById(Set<String> idSet) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
								Contact.AccountId,Contact.Age__c,Contact.Currently_employed__c,Contact.AssistantName,
								Contact.AssistantPhone,Contact.Birthdate,Contact.Anonymous__c,Contact.Appeal_Recovery_Gift_Date__c,
								Contact.Consecutive_Years_of_Giving__c,Contact.Consecutive_Years_of_Transactions__c,Contact.Constituent_Codes__c,Contact.Constituent_Count__c,
								Contact.Constituent_ID__c,Contact.Date_of_First_Gift__c,Contact.Date_of_Last_Event_Attended__c,Contact.Date_of_Last_Gift__c,Contact.Days_Since_Last_Gift__c,
								Contact.Deceased_Date__c,Contact.Deceased__c,Contact.Direct_Mail_Recipient__c,Contact.Donor_Level__c,Contact.Event_Attended__c,
								Contact.First_Time_Donor__c,Contact.Gender__c,Contact.Giving_of_Income__c,Contact.Household_Primary_Contact__c,Contact.Household_Role__c,
								Contact.Household__c,Contact.Income__c,Contact.Lifetime_Appeal_Amount__c,Contact.Major_Gift_Donor__c,
								Contact.Name_of_Last_Event_Attended__c,Contact.Newsletter_Subscriber__c,Contact.Primary_Addressee__c,Contact.Primary_Salutation__c,
								Contact.Receipt_Preference__c,Contact.Region__c,Contact.Same_as_Household__c,Contact.Secondary_Addressee__c,Contact.Secondary_Salutation__c,
								Contact.Solicit_Codes__c,Contact.Student__c,Contact.Suffix__c,Contact.Total_Fiscal_Gifts__c,Contact.Total_Fiscal_Transactions__c,
								Contact.Total_Fiscal_Transaction_Amount__c,Contact.Total_Fiscal_Year_Giving__c,Contact.Total_Lifetime_Fundraising__c,Contact.Total_Lifetime_Gifts__c,
								Contact.Total_Lifetime_Giving__c,Contact.Total_Lifetime_Transactions__c,Contact.Total_Lifetime_Transaction_Amount__c,Contact.Trade_Status__c,
								Contact.Use_Household_Salutation_Addressee__c,Contact.CreatedById,Contact.CreatedDate,Contact.Department,Contact.Description,Contact.Description_of_Work__c,
								Contact.Does_Your_Employer_Offer__c,Contact.Education_Level__c,Contact.Email,Contact.EmailBouncedDate,Contact.EmailBouncedReason,Contact.Fax,Contact.FirstName,
								Contact.HomePhone,Contact.How_Did_You_Hear_About_Us__c,Contact.Id,Contact.IsDeleted,Contact.Jigsaw,Contact.JigsawContactId,Contact.Languages__c,Contact.LastActivityDate,
								Contact.LastCURequestDate,Contact.LastCUUpdateDate,Contact.LastModifiedById,Contact.LastModifiedDate,Contact.LastName,Contact.LeadSource,Contact.MailingCity,
								Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingState,Contact.MailingStreet,Contact.MasterRecordId,Contact.Middle_Name__c,
								Contact.Miles_Willing_to_Travel_One_Way__c,Contact.MobilePhone,Contact.Professional_Skills__c,Contact.Name,Contact.Name_of_Educational_Institution__c,
								Contact.OtherCity,Contact.OtherCountry,Contact.OtherPhone,Contact.OtherPostalCode,Contact.OtherState,Contact.OtherStreet,Contact.OwnerId,Contact.Phone,
								Contact.Preferred_Locales__c,Contact.Reasons_For_Volunteering__c,Contact.ReportsToId,Contact.Salutation,
								Contact.SystemModstamp,Contact.Title };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id IN :idSet',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Contact> SelectContactGiftsByIdForUpdate(Set<Id> contactIds) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Date_of_Last_Gift__c,
		Contact.Date_of_First_Gift__c, Contact.Largest_Gift__c, Contact.Average_Gift__c, Contact.Date_of_Last_Transaction__c, Contact.Date_of_First_Transaction__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('Select {0} From {1} Where Id IN :contactIds FOR UPDATE',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public Database.QueryLocator queryContactIdNameByIdStatusAndDate() {
        List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {Contact.Id, Contact.Name };
        IsCustomAccessible(customContactFieldList);

        new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Amount__c, Gift__c.Receipt_Type__c, Gift__c.Status__c, Gift__c.Gift_Date__c, Gift__c.Constituent__c });
        String queryString = String.format('Select {0}, (Select Id, Amount__c, Receipt_Type__c, Status__c From Gifts__r WHERE Receipt_Type__c = \'\'Consolidated\'\'  AND Status__c != \'\'Acknowledged\'\' AND Status__c != \'\'Cancelled\'\' AND Gift_Date__c = LAST_YEAR) From {1} WHERE Id IN (SELECT Constituent__c FROM Gift__c WHERE Receipt_Type__c = \'\'Consolidated\'\' AND Status__c != \'\'Acknowledged\'\' AND Status__c != \'\'Cancelled\'\' AND Gift_Date__c = LAST_YEAR AND Amount__c > 0)',

            new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
                return Database.getQueryLocator(queryString);
    }

    public List<Contact> SelectContactTotalsWhereIdInIds(Set<Id> contactIds) {
        List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Consecutive_Years_of_Giving__c, Contact.Consecutive_Years_of_Transactions__c,
        	Contact.Total_Lifetime_Gifts__c, Contact.Total_Lifetime_Giving__c, Contact.Total_Fiscal_Gifts__c, Contact.Total_Fiscal_Year_Giving__c, Contact.Total_Lifetime_Transactions__c,
        	Contact.Total_Lifetime_Transaction_Amount__c, Contact.Total_Fiscal_Fundraising__c, Contact.Total_Fiscal_Transactions__c, Contact.Total_Fiscal_Transaction_Amount__c, Contact.Total_Lifetime_Fundraising__c};
        IsCustomAccessible(customContactFieldList);

        new SolicitorSelector().IsCustomAccessible(new List<Schema.SObjectField> { Solicitor__c.Id, Solicitor__c.Gift_Date__c, Solicitor__c.Amount__c, Solicitor__c.Gift_Status__c });
        new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Gift_Date__c, Gift__c.Amount__c, Gift__c.Status__c, Gift__c.RecordTypeId, Gift__c.CreatedDate });
        new hedRelationshipSelector().IsCustomAccessible(new List<Schema.SObjectField> { hed__Relationship__c.hed__RelatedContact__c, hed__Relationship__c.Apply_Soft_Credit__c });
        String queryString = String.format('Select {0}, (Select Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId From Gifts__r ORDER BY Gift_Date__c DESC , CreatedDate DESC), (Select Id, Amount__c, Gift_Status__c, Gift_Date__c From Additional_Solicitations__r), (Select Id, Amount__c, Status__c ,Gift_Date__c From Gifts1__r), (Select hed__RelatedContact__c FROM hed__Relationships1__r where Apply_Soft_Credit__c=true) From {1} WHERE id IN :contactIds FOR UPDATE',

            new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
                return Database.query(queryString);
    }

	public Database.QueryLocator LocateConsolidatedReciptBatch() {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Name };
		IsCustomAccessible(customContactFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Id, Gift__c.Amount__c, Gift__c.Receipt_Type__c, Gift__c.Status__c, Gift__c.Gift_Date__c, Gift__c.Constituent__c});

		String queryString = String.format('Select Id, Name, (Select Id, Amount__c, Receipt_Type__c, Status__c From Gifts__r WHERE Receipt_Type__c = \'\'Consolidated\'\'  AND Status__c != \'\'Acknowledged\'\' AND Status__c != \'\'Cancelled\'\' AND Gift_Date__c = LAST_YEAR) From {0} WHERE Id IN (SELECT Constituent__c FROM Gift__c WHERE Receipt_Type__c = \'\'Consolidated\'\' AND Status__c != \'\'Acknowledged\'\' AND Status__c != \'\'Cancelled\'\' AND Gift_Date__c = LAST_YEAR AND Amount__c > 0)',
			new List<String> { GetSObjectName() });
				return Database.getQueryLocator(queryString);
	}

	public Database.QueryLocator LocateRollupBatchForConsecutiveYears() {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.Consecutive_Years_of_Giving__c, Contact.Consecutive_Years_of_Transactions__c, Contact.Last_Gift_Amount__c,
			Contact.Total_Lifetime_Gifts__c, Contact.Total_Lifetime_Giving__c, Contact.Total_Fiscal_Gifts__c, Contact.Total_Fiscal_Year_Giving__c, Contact.Total_Lifetime_Transactions__c,
			Contact.Total_Lifetime_Transaction_Amount__c, Contact.Total_Fiscal_Transactions__c, Contact.Total_Fiscal_Transaction_Amount__c, Contact.Total_Lifetime_Fundraising__c };
		IsCustomAccessible(customContactFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Id, Gift__c.Amount__c, Gift__c.Status__c});
		new hedRelationshipSelector().IsCustomAccessible(new List<Schema.SObjectField> { hed__Relationship__c.hed__RelatedContact__c, hed__Relationship__c.Apply_Soft_Credit__c});

		String queryString = String.format('SELECT Id, Consecutive_Years_of_Giving__c, Consecutive_Years_of_Transactions__c, Last_Gift_Amount__c, Total_Lifetime_Gifts__c, Total_Lifetime_Giving__c, Total_Fiscal_Gifts__c, Total_Fiscal_Year_Giving__c, Total_Lifetime_Transactions__c, Total_Lifetime_Transaction_Amount__c, Total_Fiscal_Transactions__c, Total_Fiscal_Transaction_Amount__c, Total_Lifetime_Fundraising__c, (Select Id, Amount__c, Status__c From Gifts1__r), (Select hed__RelatedContact__c FROM hed__Relationships1__r where Apply_Soft_Credit__c=true) FROM {0}',
			new List<String> { GetSObjectName() });
				return Database.getQueryLocator(queryString);
	}

	public List<Contact> SelectVolunteerByContactId(Id cId) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Professional_Skills__c, Contact.Preferred_Program_1__c, Contact.Preferred_Program_2__c, Contact.Suffix__c, Contact.FirstName, Contact.LastName, Contact.Middle_Name__c,
			Contact.Salutation, Contact.Nickname__c, Contact.MailingStreet, Contact.Apt_Unit__c, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.Phone,
			Contact.OtherPhone, Contact.Email, Contact.BirthDate, Contact.Gender__c };
		IsCustomAccessible(customContactFieldList);

		new VolunteerApplicationSelector().IsCustomAccessible(new List<Schema.SObjectField> {Volunteer_Application__c.Id, Volunteer_Application__c.Date_of_Background_Check__c,
			Volunteer_Application__c.Status__c});
		new AccountSelector().IsCustomAccessible(new List<Schema.SObjectField> {Account.Name});

		String queryString = String.format('SELECT {0}, Account.Name, (SELECT Id, Date_of_Background_Check__c, Status__c FROM Volunteer_Applications__r WHERE Status__c = \'\'Approved\'\' OR Status__c = \'\'Placed\'\') FROM Contact WHERE Id = :cId',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Contact> SelectContactWithDynamicClause(String clause) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone, Contact.Household__c, Contact.MailingCity, Contact.MailingCountry,
			Contact.MailingPostalCode, Contact.MailingState, Contact.MailingStreet };
		IsCustomAccessible(customContactFieldList);

		new AccountSelector().IsCustomAccessible(new List<Schema.SObjectField> {Account.Name});

		String queryString = String.format('SELECT {0}, Household__r.Name FROM {1} ' + clause,
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Contact> SelectVolunteerWithDynamicClause(String clause) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> {
			Contact.FirstName, Contact.LastName, Contact.Phone, Contact.Id, Contact.Email, Contact.Sys_No_Availability__c, Contact.Volunteer_Availability__c,
			Contact.Professional_Skills__c, Contact.Preferred_Locales__c, Contact.Languages__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('SELECT FirstName, LastName, Phone, Id, Email, Sys_No_Availability__c FROM {0} ' + clause,
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Contact> SelectIdByEmailList(Set<string> contactEmails) {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Id, Contact.Email };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select {0} from {1} where Email IN :contactEmails AND Email != \'\'\'\'',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<AggregateResult> SelectSumOfIncome() {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Income__c, Contact.firstname };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('select SUM(Income__c ), firstname from {0} GROUP BY firstName',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}
	
	public List<Contact> SelectTopTenDonors() {
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Name, Contact.Id, Contact.Total_Fiscal_Transaction_Amount__c };
		IsCustomAccessible(customContactFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Total_Fiscal_Transaction_Amount__c != NULL ORDER BY Total_Fiscal_Transaction_Amount__c DESC LIMIT 10',
			new List<String> { GetFieldListString(customContactFieldList), GetSObjectName() });
				return Database.query(queryString);
	}
}