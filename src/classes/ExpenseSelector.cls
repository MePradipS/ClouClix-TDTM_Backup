public with sharing class ExpenseSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Expense__c.Id, Expense__c.Amount__c, Expense__c.New_Campaign__c, Expense__c.Date__c, Expense__c.Description__c, 
			Expense__c.Expense_Type__c, Expense__c.Gift__c, Expense__c.Source__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Expense__c.sObjectType;
	}
}