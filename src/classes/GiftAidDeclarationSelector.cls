public with sharing class GiftAidDeclarationSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Gift_Aid_Declaration__c.Id, Gift_Aid_Declaration__c.Donor__c, Gift_Aid_Declaration__c.Name, Gift_Aid_Declaration__c.isActive__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Gift_Aid_Declaration__c.sObjectType;
	}

	public List<Gift_Aid_Declaration__c> SelectGADsById(List<sObject> contactSet){
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift_Aid_Declaration__c.Id, Gift_Aid_Declaration__c.Donor__c, Gift_Aid_Declaration__c.isActive__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Donor__c IN :contactSet',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
				return Database.query(queryString);
	}
}