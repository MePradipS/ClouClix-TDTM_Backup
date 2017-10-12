public with sharing class GoalSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Goal__c.id, Goal__c.Name, Goal__c.Overall_Goal__c, Goal__c.Fiscal_Year__c, Goal__c.Q1_Goal__c, Goal__c.Active__c,
			Goal__c.Q2_Goal__c, Goal__c.Notes__c, Goal__c.Q3_Goal__c, Goal__c.Q4_Goal__c, Goal__c.Campaign_Appeal__c};
	}

	public override Schema.SObjectType GetSObjectType() {
		return Goal__c.sObjectType;
	}

	public List<Goal__c> SelectGoalByCampignId(Id campaignId) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} WHERE Campaign_Appeal__c = :campaignId limit 1',
			new List<String> { GetFieldListString(), GetSObjectName() });
				return Database.query(queryString);
		}
}