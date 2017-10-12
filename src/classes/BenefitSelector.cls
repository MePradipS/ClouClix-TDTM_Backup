public with sharing class BenefitSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Benefit__c.Id };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Benefit__c.sObjectType;
	}

	public List<SObject> SelectBenefitAndEventLevelBenefitByIdForUpdate(Set<Id> idSet) {
		EventLevelBenefitSelector eventLevelBenefitSelector = new EventLevelBenefitSelector();
		EventLevelBenefitSelector.IsAccessible();
		IsAccessible();

		String queryString = String.format('select {0}, (select {1} from Event_Level_Benefits__r) from {2} where Id in :idSet for update', 
			new List<String> { GetFieldListString(), EventLevelBenefitSelector.GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }
}