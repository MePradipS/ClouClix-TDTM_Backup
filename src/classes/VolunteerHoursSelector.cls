public with sharing class VolunteerHoursSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> { Volunteer_Hours__c.Id, Volunteer_Hours__c.Volunteer__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Volunteer_Hours__c.sObjectType;
	}

	public List<Volunteer_Hours__c> SelectVolunteerById(Set<String> idSet) {
		IsCustomAccessible(GetSObjectFieldList());

		new ContactSelector().IsCustomAccessible(new List<Schema.SObjectField> {Contact.AccountId});

		String queryString = String.format('select Id, Volunteer__c, Volunteer__r.AccountId from {0} where Id in :idSet',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}
}