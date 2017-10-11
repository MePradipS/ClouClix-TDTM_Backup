public with sharing class SolicitorSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Solicitor__c.Id, Solicitor__c.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Solicitor__c.sObjectType;
	}

	public String SelectById(Set<string> cid) {
		List<Schema.SObjectField> customSolicitorFieldList = new List<Schema.SObjectField> {
			Solicitor__c.Id, Solicitor__c.Amount__c, Solicitor__c.Solicitor__c, Solicitor__c.Gift_Date__c, Solicitor__c.Gift_Status__c };
		IsCustomAccessible(customSolicitorFieldList);

		String queryString = String.format('select {0} from {1} where Solicitor__c in :cid',
			new List<String> { GetFieldListString(customSolicitorFieldList), GetSObjectName() });
        return queryString;
	}

	public List<Solicitor__c> SelectByAccountIdAndConvert(Set<Id> accountIds) {
			List<Schema.SObjectField> customSolicitorFieldList = new List<Schema.SObjectField> {
				Solicitor__c.Id, Solicitor__c.Amount__c, Solicitor__c.Gift_Date__c, Solicitor__c.Gift_Status__c, Solicitor__c.Organization_Solicitor__c };
			IsCustomAccessible(customSolicitorFieldList);

			String queryString = String.format('select Id, convertCurrency(Amount__c), Gift_Date__c, Gift_Status__c, Organization_Solicitor__c from {0} where Organization_Solicitor__c IN :accountIds',
				new List<String> { GetSObjectName() });
					return Database.query(queryString);
			}

	public List<Solicitor__c> SelectByAccountId(Set<Id> accountIds) {
			List<Schema.SObjectField> customSolicitorFieldList = new List<Schema.SObjectField> {
				Solicitor__c.Id, Solicitor__c.Amount__c, Solicitor__c.Gift_Date__c, Solicitor__c.Gift_Status__c, Solicitor__c.Organization_Solicitor__c };
			IsCustomAccessible(customSolicitorFieldList);

			String queryString = String.format('select {0} from {1} where Organization_Solicitor__c IN :accountIds',
				new List<String> { GetFieldListString(customSolicitorFieldList), GetSObjectName() });
					return Database.query(queryString);
	}


	public AggregateResult[] SelectAmountAndYearBySolicitorAndPastFourYears(String contAccid) {
		List<Schema.SObjectField> customSolicitorFieldList = new List<Schema.SObjectField> { Solicitor__c.Amount__c, Solicitor__c.Gift_Date__c, Solicitor__c.Solicitor__c };
		IsCustomAccessible(customSolicitorFieldList);

		String queryString = String.format('select SUM(Amount__c) total, CALENDAR_YEAR(Gift_Date__c) year from {0} where Solicitor__c = :contAccid and (Gift_Date__c = LAST_N_YEARS:4 OR Gift_Date__c = THIS_YEAR) group by CALENDAR_YEAR(Gift_Date__c) order by CALENDAR_YEAR(Gift_Date__c)',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectAmountAndYearByOrganizationSolicitorAndPastFourYears(String contAccid) {
		List<Schema.SObjectField> customSolicitorFieldList = new List<Schema.SObjectField> { Solicitor__c.Amount__c, Solicitor__c.Gift_Date__c, Solicitor__c.Organization_Solicitor__c };
		IsCustomAccessible(customSolicitorFieldList);

		String queryString = String.format('select SUM(Amount__c) total, CALENDAR_YEAR(Gift_Date__c) year from {0} where Organization_Solicitor__c = :contAccid and (Gift_Date__c = LAST_N_YEARS:4 OR Gift_Date__c = THIS_YEAR) group by CALENDAR_YEAR(Gift_Date__c) order by CALENDAR_YEAR(Gift_Date__c)',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}
	public List<AggregateResult> SelectSolicitorSummaryByClause(Id contactId, String whereField) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Organization__c, Gift__c.Constituent__c};
		new GiftSelector().IsCustomAccessible(customGiftFieldList);

		IsCustomAccessible(new List<Schema.SObjectField> {Solicitor__c.Amount__c, Solicitor__c.Gift_Date__c, Solicitor__c.Solicitor__c, Solicitor__c.Organization_Solicitor__c});

		String queryString = String.format('SELECT SUM(Amount__c) total, CALENDAR_YEAR(Gift_Date__c) year FROM {0} WHERE '+ whereField +' = \':contactId\' AND (Gift_Date__c = LAST_N_YEARS:4 OR Gift_Date__c = THIS_YEAR) GROUP BY CALENDAR_YEAR(Gift_Date__c) ORDER BY CALENDAR_YEAR(Gift_Date__c)',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Solicitor__c> SelectSolicitorContacts(Set<Id> contactIds) {
		List<Schema.SObjectField> customSolicitorFieldList = new List<Schema.SObjectField> {Solicitor__c.Id, Solicitor__c.Solicitor__c};
		IsCustomAccessible(customSolicitorFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{Gift__c.Constituent__c});

		String queryString = String.format('SELECT Id, Solicitor__c, Gift__r.Constituent__c FROM {0} WHERE Gift__r.Constituent__c IN :contactIds',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Solicitor__c> SelectSolicitorInfoAndConvert(Set<Id> contactIds) {
		List<Schema.SObjectField> customSolicitorFieldList = new List<Schema.SObjectField> {
			Solicitor__c.Id, Solicitor__c.Amount__c, Solicitor__c.Gift_Date__c, Solicitor__c.Gift_Status__c, Solicitor__c.Solicitor__c};
		IsCustomAccessible(customSolicitorFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{Gift__c.Constituent__c});

		String queryString = String.format('SELECT Id, convertCurrency(Amount__c), Gift_Date__c, Gift_Status__c, Solicitor__c FROM {0} WHERE Gift__r.Constituent__c IN :contactIds AND Amount__c > 0',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Solicitor__c> SelectSolicitorInfoNoConvert(Set<Id> contactIds) {
		List<Schema.SObjectField> customSolicitorFieldList = new List<Schema.SObjectField> {
			Solicitor__c.Id, Solicitor__c.Amount__c, Solicitor__c.Gift_Date__c, Solicitor__c.Gift_Status__c, Solicitor__c.Solicitor__c};
		IsCustomAccessible(customSolicitorFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{Gift__c.Constituent__c});

		String queryString = String.format('SELECT Id, Amount__c, Gift_Date__c, Gift_Status__c, Solicitor__c FROM {0} WHERE Gift__r.Constituent__c IN :contactIds AND Amount__c > 0',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}
}