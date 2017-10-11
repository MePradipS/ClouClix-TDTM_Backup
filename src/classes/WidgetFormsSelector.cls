public with sharing class WidgetFormsSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			WidgetForms__c.Id, WidgetForms__c.Name, WidgetForms__c.FormId__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return WidgetForms__c.sObjectType;
	}

	public List<WidgetForms__c> SelectWidgetFormsWithLimit() {
		List<Schema.SObjectField> customWidgetFormFieldList = new List<Schema.SObjectField> { WidgetForms__c.Id, WidgetForms__c.Name, WidgetForms__c.FormId__c };
		IsCustomAccessible(customWidgetFormFieldList);

		String queryString = String.format('SELECT {0} FROM {1} LIMIT 200',
			new List<String> { GetFieldListString(customWidgetFormFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}
}