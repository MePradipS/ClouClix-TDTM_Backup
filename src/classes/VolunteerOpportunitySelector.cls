public with sharing class VolunteerOpportunitySelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {};
	}

	public override Schema.SObjectType GetSObjectType() {
		return Volunteer_Opportunity__c.sObjectType;
	}
}