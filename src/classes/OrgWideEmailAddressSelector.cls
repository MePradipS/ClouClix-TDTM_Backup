public with sharing class OrgWideEmailAddressSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			OrgWideEmailAddress.Id, OrgWideEmailAddress.Address };
	}

	public override Schema.SObjectType GetSObjectType() {
		return OrgWideEmailAddress.sObjectType;
	}
}