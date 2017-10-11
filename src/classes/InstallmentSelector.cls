public with sharing class InstallmentSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Installment__c.Id };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Installment__c.sObjectType;
	}

	public List<Installment__c> SelectInstallmentById(Boolean isMultiCurrency, Set<Id> giftIds) {
		List<Schema.SObjectField> customInstallmentFields;

		if(isMultiCurrency == true){
			customInstallmentFields = new List<Schema.SObjectField> {
				Installment__c.Id, Installment__c.Pledge__c, Installment__c.Account_Contact__c, Installment__c.Name, Installment__c.Inst_No__c, Installment__c.Installment_Date__c,
				Installment__c.Installment_Amount__c, Installment__c.Installment_Balance__c, Installment__c.Status__c, Installment__c.Amount_Fulfilled_To_Date__c };
		}else{
			customInstallmentFields = new List<Schema.SObjectField> {Installment__c.Id, Installment__c.Installment_Balance__c};
		}

		new AllocationSelector().IsCustomAccessible(new List<schema.SObjectField>{
			Gift_Detail__c.Amount__c, Gift_Detail__c.Campaign__c, Gift_Detail__c.New_Campaign__c, Gift_Detail__c.Gift__c, Gift_Detail__c.Fund__c, Gift_Detail__c.GL_Auto_Credit_Account__c,
			Gift_Detail__c.GL_Auto_Debit_Account__c, Gift_Detail__c.Payment__c});
		new GiftSelector().IsCustomAccessible(new List<schema.SObjectField>{Gift__c.Organization__c, Gift__c.Constituent__c});
		IsCustomAccessible(customInstallmentFields);

		String queryString = String.format('SELECT {0},Pledge__r.Organization__c, Pledge__r.Constituent__c, (select Amount__c, Campaign__c, New_Campaign__c, Gift__c, Fund__c, GL_Auto_Credit_Account__c, GL_Auto_Debit_Account__c, Payment__c from Allocations__r) FROM {1} where Pledge__c IN :giftIds AND Installment_Balance__c > 0',
			new List<String> { GetFieldListString(customInstallmentFields), GetSObjectName() });
				return Database.query(queryString);
		}
}