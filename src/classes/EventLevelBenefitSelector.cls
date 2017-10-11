public with sharing class EventLevelBenefitSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Event_Level_Benefit__c.Id, Event_Level_Benefit__c.Benefit__c, Event_Level_Benefit__c.Event_Level__c, Event_Level_Benefit__c.Quantity__c };
	}          

	public override Schema.SObjectType GetSObjectType() {
		return Event_Level_Benefit__c.sObjectType;
	}

	public List<Event_Level_Benefit__c> SelectByEventLevel(List<String> eventLevelList) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Event_Level__c in :eventLevelList', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }
}