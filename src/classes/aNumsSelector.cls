public with sharing class aNumsSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			aNums__c.Id, aNums__c.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return aNums__c.sObjectType;
	}
}