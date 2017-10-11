public with sharing class OpportunitySelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Opportunity.Id, Opportunity.Name, Opportunity.RecordTypeId };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Opportunity.sObjectType;
	}

	public List<Opportunity> SelectAllFieldsById(Set<Id> idSet) {
		List<Schema.SObjectField> opportunityFieldList = new List<Schema.SObjectField> {
			Opportunity.Id, Opportunity.AccountId, Opportunity.RecordTypeId, Opportunity.Amount,
			Opportunity.CloseDate, Opportunity.CreatedDate, Opportunity.Description, Opportunity.ExpectedRevenue, Opportunity.ForecastCategory,
			Opportunity.CVADeliveryInstallationStatus__c, Opportunity.HasOpportunityLineItem, Opportunity.IsClosed, Opportunity.IsDeleted,
			Opportunity.IsPrivate, Opportunity.IsWon, Opportunity.LastActivityDate, Opportunity.LeadSource, Opportunity.Name, Opportunity.NextStep,
			Opportunity.Probability, Opportunity.StageName, Opportunity.SystemModstamp, Opportunity.TotalOpportunityQuantity, Opportunity.Type,
			Opportunity.Individual__c };
		IsCustomAccessible(opportunityFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(opportunityFieldList), GetSObjectName() });
        return Database.query(queryString);
	}
}