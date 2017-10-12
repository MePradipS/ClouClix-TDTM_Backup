public with sharing class ApexClassSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			ApexClass.Id, ApexClass.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return ApexClass.sObjectType;
	}
}