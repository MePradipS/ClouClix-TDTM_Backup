public with sharing class InstallmentFulfillmentSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Installment_Fulfillment__c.Id, Installment_Fulfillment__c.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Installment_Fulfillment__c.sObjectType;
	}

	public List<Installment_Fulfillment__c> SelectIdAndPaymentWherePaymentInPaymentIds(Set<Id> paymentIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Installment_Fulfillment__c.Id, Installment_Fulfillment__c.Payment__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Payment__c In : paymentIds',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
    }
}