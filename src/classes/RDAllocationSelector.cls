public with sharing class RDAllocationSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			RD_Allocation__c.Id, RD_Allocation__c.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return RD_Allocation__c.sObjectType;
	}

	public List<RD_Allocation__c> SelectPackageByRecurringGiftId(Set<Id> idSet) {
		List<Schema.SObjectField> rdAllocationFieldList = new List<Schema.SObjectField> {
			RD_Allocation__c.Id, RD_Allocation__c.Name, RD_Allocation__c.Recurring_Gift__c, RD_Allocation__c.Fund__c, RD_Allocation__c.Package__c,
			RD_Allocation__c.New_Campaign__c, RD_Allocation__c.Amount__c, RD_Allocation__c.Active__c };
		IsCustomAccessible(rdAllocationFieldList);
		new PackageSelector().IsAccessible();

		String queryString = String.format('select {0}, Package__r.Name from {1} where Recurring_Gift__c in :idSet',
			new List<String> { GetFieldListString(rdAllocationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<RD_Allocation__c> SelectRecurringGiftIdById(Set<Id> idSet) {
		List<Schema.SObjectField> recurringGiftFieldList = new List<Schema.SObjectField> { Recurring_Donation__c.Id };
		new RecurringDonationSelector().IsCustomAccessible(recurringGiftFieldList);
		IsAccessible();

		String queryString = String.format('select Recurring_Gift__r.Id from {0} where Id in :idSet',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public List<RD_Allocation__c> SelectAllocationDetails(Id recurringGiftId) {
		List<Schema.SObjectField> rdAllocationFieldList = new List<Schema.SObjectField> {
			RD_Allocation__c.Amount__c, RD_Allocation__c.Id, RD_Allocation__c.Active__c, RD_Allocation__c.Name };
		IsCustomAccessible(rdAllocationFieldList);

		IsCustomAccessible(new List<Schema.SObjectField> {RD_Allocation__c.Recurring_Gift__c});
		new FundSelector().IsCustomAccessible(new List<Schema.SObjectField> {Fund__c.Name, Fund__c.Fund_Name__c});
		new CampaignSelector().IsCustomAccessible(new List<Schema.SObjectField> {Campaign.Name});

		String queryString = String.format('select {0},New_Campaign__r.Name, Fund__r.Name, Fund__r.Fund_Name__c from {1} where Recurring_Gift__c = :recurringGiftId AND Active__c = TRUE',
			new List<String> {GetFieldListString(rdAllocationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}
}