public with sharing class EventRegistrationSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Event_Registration__c.Id, Event_Registration__c.Registration_Date__c, Event_Registration__c.Status__c, Event_Registration__c.Event__c,
			Event_Registration__c.Individual__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Event_Registration__c.sObjectType;
	}

	public List<Event_Registration__c> LastTransactionByGiftIdForUpdate(Set<Id> giftId){
		List<Schema.SObjectField> eventRegistrationFieldList = new List<Schema.SObjectField> {
			Event_Registration__c.Id , Event_Registration__c.sysLastTransactionUpdate__c, Event_Registration__c.Transaction__c };

		IsCustomAccessible(eventRegistrationFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Transaction__c IN :giftId FOR UPDATE',
			new List<String> { GetFieldListString(eventRegistrationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Event_Registration__c> SelectLastTransactionByGiftId(Set<Id> giftId){
		List<Schema.SObjectField> eventRegistrationFieldList = new List<Schema.SObjectField> {
			Event_Registration__c.Id , Event_Registration__c.sysLastTransactionUpdate__c, Event_Registration__c.Transaction__c };

		IsCustomAccessible(eventRegistrationFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Transaction__c IN :giftId',
			new List<String> { GetFieldListString(eventRegistrationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public Database.QueryLocator SelectLastTransactionStringByGiftId(Set<Id> giftId){
		List<Schema.SObjectField> eventRegistrationFieldList = new List<Schema.SObjectField> {
			Event_Registration__c.Id , Event_Registration__c.sysLastTransactionUpdate__c, Event_Registration__c.Transaction__c };

		IsCustomAccessible(eventRegistrationFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Transaction__c IN :giftId',
			new List<String> { GetFieldListString(eventRegistrationFieldList), GetSObjectName() });
				return Database.getQueryLocator(queryString);
	}
}