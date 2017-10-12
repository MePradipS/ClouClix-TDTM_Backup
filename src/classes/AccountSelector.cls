public with sharing class AccountSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Account.Id, Account.Name, Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState,
			Account.BillingStreet, Account.Email__c, Account.Phone };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Account.sObjectType;
	}

	public List<Account> SelectEmailById(Set<Id> idSet) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> { Account.Email__c };
		IsCustomAccessible(customAccountFieldList);
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectIdNameById(Set<Id> idSet) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> { Account.Id, Account.Name };
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectIdNameByIdRecordTypeIdLimit(String idValue, String recordTypeId, List<String> notIdList, Integer recordLimit) {
		return SelectIdNameByNameIdRecordTypeIdLimit(null, idValue, recordTypeId, notIdList, recordLimit);
	}

	public List<Account> SelectIdNameByNameIdRecordTypeIdLimit(String name, String idValue, String recordTypeId, List<String> notIdList, Integer recordLimit) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> { Account.Id, Account.Name };
		IsCustomAccessible(customAccountFieldList);
		IsCustomAccessible(new List<Schema.SObjectField>{Account.RecordTypeId});

		String accountName = (name == null) ? null : '%' + name + '%';
		String nameWhereClause = (accountName == null) ? '' : 'Name like :accountName and';
		String queryString = String.format('select {0} from {1} where {2} Id != :idValue and RecordTypeId != :recordTypeId and Id not in :notIdList limit :recordLimit',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName(), nameWhereClause });
        return Database.query(queryString);
	}

	public List<Account> SelectOrganizationIdById(Set<String> idSet) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Organization_ID__c, Account.CreatedDate, Account.LastModifiedDate };
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('select {0} from {1} where Organization_ID__c in :idSet',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectOrganizationIdByOrganizationIdNotId(Set<String> orgIdSet, Set<Id> idSet) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Organization_ID__c, Account.Id };
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('select {0} from {1} where Organization_ID__c in :orgIdSet and Id <> :idSet',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectByOrganizationId(Set<String> idSet) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Id, Account.Organization_ID__c, Account.Solicit_Codes__c, Account.Constituent_Codes__c, Account.Trade_Status__c,
			Account.Type, Account.Region__c, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState,
			Account.BillingCity, Account.BillingStreet, Account.Name, Account.Phone, Account.Fax,
			Account.Website, Account.Email__c };
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('select {0} from {1} where Organization_ID__c in :idSet',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectAccountAndRecordTypeNameById(Set<Id> idSet) {
		IsAccessible();
		new RecordTypeSelector().IsAccessible();

		String queryString = String.format('select {0}, RecordType.Name from {1} where Id in :idSet',
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectLastModifiedAccountBySearch(String search) {
		List<Schema.SObjectField> userFieldList = new List<Schema.SObjectField> { User.Name };
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Id, Account.Organization_ID__c, Account.BillingPostalCode, Account.BillingCity, Account.Name, Account.LastModifiedDate };
		IsCustomAccessible(customAccountFieldList);
		new UserSelector().IsCustomAccessible(userFieldList);

		String searchString = (search == null) ? null : (search + '%');
		String queryString = String.format('select {0}, LastModifiedBy.Name from {1} where (Name like :searchString or Organization_ID__c like :searchString or BillingPostalCode like :searchString) order by Name limit 100',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectBillingAndHouseholdContactsByIdAndRecordTypeId(Set<Id> idSet, String recordTypeId) {
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.Use_Household_Salutation_Addressee__c, Contact.Same_as_Household__c, Contact.Primary_Addressee__c,
			Contact.Primary_Salutation__c, Contact.HomePhone, Contact.MailingStreet, Contact.MailingState, Contact.MailingCountry,
			Contact.MailingPostalCode, Contact.MailingCity };
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Id, Account.BillingStreet, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Account.BillingCity,
			Account.Phone, Account.Household_Addressee__c, Account.Household_Salutation__c, Account.RecordTypeId };
		IsCustomAccessible(customAccountFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);

		String contactQuery = '(SELECT Id, Use_Household_Salutation_Addressee__c, Same_as_Household__c, Primary_Addressee__c, Primary_Salutation__c, HomePhone, MailingStreet, MailingState, MailingCountry, MailingPostalCode, MailingCity FROM HouseholdContacts__r)';
		String queryString = String.format('select {0}, {1} from {2} where Id in :idSet and RecordTypeId = :recordTypeId',
			new List<String> { GetFieldListString(customAccountFieldList), contactQuery, GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectBillingAndShippingById(Set<Id> idSet) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.BillingState,
			Account.BillingCountry, Account.ShippingStreet, Account.ShippingCity, Account.ShippingPostalCode, Account.ShippingState,
			Account.ShippingCountry };
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectVolunteerTotalsById(Set<String> orgIds, String defaultId) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Id, Account.Total_Service_Hours_Completed_This_Year__c, Account.Total_Service_Hours_Completed__c,
			Account.Total_Miles_Traveled_This_Year__c, Account.Total_Miles_Traveled__c};
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id IN :orgIds AND Id != :defaultId',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Account> SelectAccountFirstAndLastGiftDateByIdsForUpdate(Set<Id> orgIds) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Id,  Account.Date_of_Last_Gift__c, Account.Date_of_First_Gift__c };
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('Select {0} From {1} Where Id IN :orgIds FOR UPDATE',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectAccountIdAndNameWithLimit(Integer setLimit) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> { Account.Id,  Account.Name };
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('SELECT {0} FROM {1} limit :setLimit',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Account> SelectHouseholdContactTotalsWhereIdInIds(Set<Id> hhIds) {
        List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {Account.Id, Account.Total_Fiscal_Household_Transactions__c, Account.Total_Household_Transactions__c,
        	Account.Total_Fiscal_Household_Giving__c, Account.Total_Household_Giving__c};
        IsCustomAccessible(customAccountFieldList);

        new ContactSelector().IsCustomAccessible(new List<Schema.SObjectField> { Contact.Id, Contact.Total_Fiscal_Transaction_Amount__c, Contact.Total_Lifetime_Transaction_Amount__c,
        	Contact.Total_Fiscal_Year_Giving__c, Contact.Total_Lifetime_Fundraising__c, Contact.Total_Lifetime_Giving__c, Contact.Total_Fiscal_Fundraising__c });
        String queryString = String.format('SELECT {0}, (SELECT Id, Total_Fiscal_Transaction_Amount__c, Total_Lifetime_Transaction_Amount__c, Total_Fiscal_Year_Giving__c, Total_Lifetime_Fundraising__c, Total_Lifetime_Giving__c , Total_Fiscal_Fundraising__c FROM HouseholdContacts__r) FROM {1} WHERE Id IN :hhIds FOR UPDATE',

            new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
                return Database.query(queryString);
    }

    public List<Account> SelectHouseholdTotalsWhereIdInIds(Set<Id> orgIds) {
        List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {Account.Id, Account.Consecutive_Years_of_Giving__c, Account.Consecutive_Years_of_Transactions__c,
        	Account.Total_Lifetime_Gifts__c, Account.Total_Lifetime_Giving__c, Account.Total_Fiscal_Gifts__c, Account.Total_Fiscal_Year_Giving__c, Account.Total_Lifetime_Transactions__c,
            Account.Total_Lifetime_Transaction_Amount__c, Account.Total_Fiscal_Transactions__c, Account.Total_Fiscal_Transaction_Amount__c};
        IsCustomAccessible(customAccountFieldList);

        new SolicitorSelector().IsCustomAccessible(new List<Schema.SObjectField> { Solicitor__c.Id, Solicitor__c.Gift_Date__c, Solicitor__c.Amount__c });
        new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Gift_Date__c, Gift__c.Amount__c, Gift__c.Status__c, Gift__c.RecordTypeId, Gift__c.CreatedDate });
        String queryString = String.format('Select {0}, (select Id, Gift_Date__c, Amount__c from Soft_Credits__r), (Select Id, Amount__c, Status__c, Gift_Date__c, RecordTypeId From Orders__r ORDER BY CreatedDate DESC, Gift_Date__c DESC), (select Id, Amount__c, Gift_Date__c from Orders1__r ) From {1} WHERE id IN :orgIds FOR UPDATE',

            new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
                return Database.query(queryString);
    }

    public List<Account> SelectAccountPaymentsById(Set<Id> orgIds) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Id, Account.Last_Payment_Amount__c, Account.Last_Payment_Date__c, Account.Largest_Gift__c,
			Account.Average_Gift__c, Account.Total_Giving_Last_Year__c, Account.Total_Giving_Two_Years_Ago__c, Account.Date_of_Last_Gift__c, Account.Date_of_First_Gift__c,
			Account.Date_of_First_Transaction__c, Account.Date_of_Last_Transaction__c };
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('Select {0} From {1} Where Id IN :orgIds',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public Account SelectByHouseHoldId(Id houseHoldId) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Id, Account.OwnerId, Account.AccountSource, Account.CVAActive__c, Account.Active__c, Account.Constituent_Codes__c, Account.CustomerPriority__c,
			Account.Industry, Account.Ownership, Account.Rating, Account.Region__c, Account.SLA__c, Account.Solicit_Codes__c, Account.Trade_Status__c, Account.Type, Account.UpsellOpportunity__c};
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('SELECT {0} FROM {1} where id=\':houseHoldId\' LIMIT 1',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Account> SelectPaymentInfoById(Set<Id> orgIds) {
		List<Schema.SObjectField> customAccountFieldList = new List<Schema.SObjectField> {
			Account.Id, Account.Last_Payment_Amount__c, Account.Last_Payment_Date__c, Account.Largest_Gift__c, Account.Average_Gift__c, Account.Total_Giving_Last_Year__c,
			Account.Total_Giving_Two_Years_Ago__c, Account.Date_of_Last_Gift__c, Account.Date_of_First_Gift__c, Account.Date_of_First_Transaction__c, Account.Date_of_Last_Transaction__c};
		IsCustomAccessible(customAccountFieldList);

		String queryString = String.format('SELECT {0} FROM {1} where id IN :orgIds',
			new List<String> { GetFieldListString(customAccountFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public Account SelectByRecordTypeIdLimit(Id recordTypeId) {
		IsAccessible();
		new RecordTypeSelector().IsAccessible();

		String queryString = String.format('SELECT RecordType.Name FROM {0} where RecordTypeId = :recordTypeId LIMIT 1',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}
}