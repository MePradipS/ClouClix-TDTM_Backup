public with sharing class OrganizationSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Organization.Id, Organization.City, Organization.Country, Organization.Name, Organization.Phone, Organization.PostalCode,
			Organization.State, Organization.Street };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Organization.sObjectType;
	}

	public List<Organization> SelectFiscalYearStartMonthByIdAndLimit(Set<Id> idSet, Integer recordLimit) {
		List<Schema.SObjectField> customOrganizationFieldList = new List<Schema.SObjectField> { Organization.Id, Organization.FiscalYearStartMonth };
		IsCustomAccessible(customOrganizationFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet limit :recordLimit',
			new List<String> { GetFieldListString(customOrganizationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Organization> SelectIdByLimit(Integer recordLimit) {
		List<Schema.SObjectField> customOrganizationFieldList = new List<Schema.SObjectField> { Organization.Id };
		IsCustomAccessible(customOrganizationFieldList);

		String queryString = String.format('select {0} from {1} limit :recordLimit',
			new List<String> { GetFieldListString(customOrganizationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public Organization SelectIsSandbox() {
		List<Schema.SObjectField> customOrganizationFieldList = new List<Schema.SObjectField> { Organization.IsSandbox };
		IsCustomAccessible(customOrganizationFieldList);

		String queryString = String.format('SELECT {0} FROM {1} LIMIT 1',
			new List<String> { GetFieldListString(customOrganizationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Organization> SelectCreatedDate() {
		List<Schema.SObjectField> customOrganizationFieldList = new List<Schema.SObjectField> { Organization.Id, Organization.CreatedDate };
		IsCustomAccessible(customOrganizationFieldList);

		String queryString = String.format('select {0} from {1}',
			new List<String> { GetFieldListString(customOrganizationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Organization> SelectFiscalYearStartMonthAndDefaultLocaleSidKeyByLimit(Integer recordLimit) {
		List<Schema.SObjectField> customOrganizationFieldList = new List<Schema.SObjectField> {
			Organization.Id, Organization.FiscalYearStartMonth, Organization.DefaultLocaleSidKey };
		IsCustomAccessible(customOrganizationFieldList);

		String queryString = String.format('select {0} from {1} limit :recordLimit',
			new List<String> { GetFieldListString(customOrganizationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Organization> SelectFiscalYearStartMonthBySingleIdAndLimit(String idSet, Integer recordLimit) {
		List<Schema.SObjectField> customOrganizationFieldList = new List<Schema.SObjectField> { Organization.Id, Organization.FiscalYearStartMonth };
		IsCustomAccessible(customOrganizationFieldList);

		String queryString = String.format('select {0} from {1} where Id =:idSet limit :recordLimit', 
			new List<String> { GetFieldListString(customOrganizationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public Organization SelectFiscalStartById(Id orgId) {
		List<Schema.SObjectField> customOrganizationFieldList = new List<Schema.SObjectField> { Organization.FiscalYearStartMonth};
		IsCustomAccessible(customOrganizationFieldList);
		IsCustomAccessible(new List<Schema.SObjectField> { Organization.id});

		String queryString = String.format('select {0} from {1} where id= :orgId LIMIT 1',
			new List<String> { GetFieldListString(customOrganizationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}
}