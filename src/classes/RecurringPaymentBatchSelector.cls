public with sharing class RecurringPaymentBatchSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Recurring_Payment_Batch__c.Id, Recurring_Payment_Batch__c.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Recurring_Payment_Batch__c.sObjectType;
	}

	public List<Recurring_Payment_Batch__c> SelectRecurringPaymentBatch(String type) {
		List<Schema.SObjectField> recurringPaymentBatchFieldList = new List<Schema.SObjectField> { Recurring_Payment_Batch__c.Id, Recurring_Payment_Batch__c.Name,
			Recurring_Payment_Batch__c.Process_Date__c, Recurring_Payment_Batch__c.Payment_Type__c };
		IsCustomAccessible(recurringPaymentBatchFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Process_Date__c = Today AND Payment_Type__c = :type', 
			new List<String> { GetFieldListString(recurringPaymentBatchFieldList), GetSObjectName() });
        return Database.query(queryString);
	}
}