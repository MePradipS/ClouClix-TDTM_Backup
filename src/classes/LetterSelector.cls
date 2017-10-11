public with sharing class LetterSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Letter__c.Id, Letter__c.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Letter__c.sObjectType;
	}
}