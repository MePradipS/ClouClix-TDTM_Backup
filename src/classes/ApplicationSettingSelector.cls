public with sharing class ApplicationSettingSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Application_Setting__c.Id, Application_Setting__c.Name, Application_Setting__c.Org_Count__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Application_Setting__c.sObjectType;
	}

	public List<Application_Setting__c> SelectByNameAndLimit(String name, Integer recordLimit) {
	IsAccessible();

	String queryString = String.format('select {0} from {1} where Name = :name limit :recordLimit',
		new List<String> { GetFieldListString(), GetSObjectName() });
			return Database.query(queryString);
	}
}