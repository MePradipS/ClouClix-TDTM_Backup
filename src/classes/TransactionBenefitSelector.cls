public with sharing class TransactionBenefitSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Transaction_Benefit__c.Id, Transaction_Benefit__c.Allocation__c };
	}          

	public override Schema.SObjectType GetSObjectType() {
		return Transaction_Benefit__c.sObjectType;
	}

	public List<Transaction_Benefit__c> SelectByEventLevel(Set<Id> idSet) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Allocation__c in :idSet', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }
}