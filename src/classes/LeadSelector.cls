public with sharing class LeadSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Lead.Id, Lead.Name, Lead.FirstName, Lead.LastName, Lead.OwnerId, Lead.Company, Lead.RecordTypeId };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Lead.sObjectType;
	}
}