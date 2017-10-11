public with sharing class FundSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Fund__c.Id, Fund__c.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Fund__c.sObjectType;
	}

	public List<Fund__c> SelectCreditAndDebitRecords(Set<Id> fundIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Fund__c.GL_Credit__c, Fund__c.GL_Debit__c,
			Fund__c.GL_In_Kind_Credit__c, Fund__c.GL_In_Kind_Debit__c, Fund__c.GL_Matching_Pledge_Cash_Credit__c, Fund__c.GL_Matching_Pledge_Cash_Debit__c,
			Fund__c.GL_Matching_Pledge_In_Kind_Credit__c, Fund__c.GL_Matching_Pledge_In_Kind_Debit__c, Fund__c.GL_Matching_Pledge_Property_Credit__c,
			Fund__c.GL_Matching_Pledge_Property_Debit__c, Fund__c.GL_Matching_Pledge_Stock_Credit__c, Fund__c.GL_Matching_Pledge_Stock_Debit__c, Fund__c.GL_Matching_Pledge_Write_off_Credit__c,
			Fund__c.GL_Matching_Pledge_Write_off_Debit__c, Fund__c.GL_Other_Credit__c, Fund__c.GL_Other_Debit__c, Fund__c.GL_Pledge_Credit__c, Fund__c.GL_Pledge_Debit__c,
			Fund__c.GL_Pledge_In_Kind_Credit__c, Fund__c.GL_Pledge_In_Kind_Debit__c, Fund__c.GL_Pledge_Property_Credit__c, Fund__c.GL_Pledge_Property_Debit__c, Fund__c.GL_Pledge_Stock_Credit__c,
			Fund__c.GL_Pledge_Stock_Debit__c, Fund__c.GL_Pledge_Write_off_Credit__c, Fund__c.GL_Pledge_Write_off_Debit__c, Fund__c.GL_Recurring_Credit__c, Fund__c.GL_Recurring_Debit__c,
			Fund__c.GL_Stock_Credit__c, Fund__c.GL_Stock_Debit__c, Fund__c.GL_Matching_Pledge_Current_Fiscal__c, Fund__c.GL_Matching_Pledge_Current_Fiscal_Debit__c, Fund__c.GL_Pledge_Current_Fiscal_Credit__c,
			Fund__c.GL_Pledge_Current_Fiscal_Debit__c, Fund__c.GL_Property_Credit__c, Fund__c.GL_Property_Debit__c };
		IsCustomAccessible(customGiftFieldList);

		IsCustomAccessible(new List<Schema.SObjectField> {Fund__c.Id});

		String queryString = String.format('select {0} from {1} where Id IN: fundIds',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<sObject> ConvertOppQueryFund(String whereClause)
	{
			new FundSelector().isCustomAccessible(new List<Schema.SObjectField>{Fund__c.Id,Fund__c.Name,Fund__c.Fund_Name__c,Fund__c.Inactive__c});

			String soql = 'SELECT Id,Name,Fund_Name__c FROM Fund__c WHERE ' + whereClause;
			return Database.query(soql);
	}
}