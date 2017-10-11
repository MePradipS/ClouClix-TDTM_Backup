public with sharing class EventLevelSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Event_Level__c.Id, Event_Level__c.Ticket_Count__c, Event_Level__c.Event__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Event_Level__c.sObjectType;
	}

	public List<Event_Level__c> SelectQualitySoldById(Set<Id> idSet) {
		List<Schema.SObjectField> allocationsFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Quantity__c };
		List<Schema.SObjectField> eventLevelFieldList = new List<Schema.SObjectField> {
			Event_Level__c.Id, Event_Level__c.Name, Event_Level__c.Quantity_Sold__c, Event_Level__c.Quantity_Remaining__c };
		IsCustomAccessible(eventLevelFieldList);
		new AllocationSelector().IsCustomAccessible(allocationsFieldList);

		String queryString = String.format('select {0}, (SELECT {1} FROM Allocations__r) from {2} where Id in :idSet for update',
			new List<String> { GetFieldListString(eventLevelFieldList), GetFieldListString(allocationsFieldList), GetSObjectName() });
        return Database.query(queryString);
	}
}