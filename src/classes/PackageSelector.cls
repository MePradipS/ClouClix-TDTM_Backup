public with sharing class PackageSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Package__c.Id, Package__c.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Package__c.sObjectType;
	}
}