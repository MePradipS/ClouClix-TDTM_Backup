public with sharing class BatchTemplateSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Batch_Template__c.Id, Batch_Template__c.Name, Batch_Template__c.AccountFieldsXml__c, Batch_Template__c.ContactFieldXml__c,
			Batch_Template__c.EventRegistrationsFieldsXml__c, Batch_Template__c.GiftDetailFieldsXml__c, Batch_Template__c.PaymentFieldsXml__c,
			Batch_Template__c.ReceiptFieldsXml__c, Batch_Template__c.RecurringGiftFieldsXml__c, Batch_Template__c.TransactionFieldsXml__c,
			Batch_Template__c.Transaction_Type__c, Batch_Template__c.Type__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Batch_Template__c.sObjectType;
	}

	public List<Batch_Template__c> SelectIdNameTypeOrderByName() {
		List<Schema.SObjectField> customSObjectFieldList = new List<Schema.SObjectField> { Batch_Template__c.Id, Batch_Template__c.Name, Batch_Template__c.Type__c };
		IsCustomAccessible(customSObjectFieldList);

		String queryString = String.format('select {0} from {1} order by Name',
			new List<String> { GetFieldListString(customSObjectFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Batch_Template__c> SelectIdNameByPersonalOrGlobalCreatedId(String userId) {
		List<Schema.SObjectField> customSObjectFieldList = new List<Schema.SObjectField> { Batch_Template__c.Id, Batch_Template__c.Name, Batch_Template__c.Type__c };
		IsCustomAccessible(customSObjectFieldList);
		IsCustomAccessible(new List<Schema.SObjectField> { Batch_Template__c.CreatedById});

		String personalType = 'Personal';
		String globalType = 'Global';
		String queryString = String.format('select {0} from {1} where Type__c = :personalType or (Type__c = :globalType and CreatedById = :userId) order by Name limit 100',
			new List<String> { GetFieldListString(customSObjectFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Batch_Template__c> SelectIdNameById(Set<Id> idSet) {
		List<Schema.SObjectField> customSObjectFieldList = new List<Schema.SObjectField> { Batch_Template__c.Id, Batch_Template__c.Name };
		IsCustomAccessible(customSObjectFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customSObjectFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Batch_Template__c> SelectAllById(Set<Id> idSet) {
		List<Schema.SObjectField> customSObjectFieldList = new List<Schema.SObjectField> {
			Batch_Template__c.AccountFieldsXml__c,Batch_Template__c.ContactFieldXml__c,Batch_Template__c.EventRegistrationsFieldsXml__c,
    	Batch_Template__c.GiftDetailFieldsXml__c,Batch_Template__c.PaymentFieldsXml__c,Batch_Template__c.ReceiptFieldsXml__c,
			Batch_Template__c.RecurringGiftFieldsXml__c,Batch_Template__c.TransactionFieldsXml__c,Batch_Template__c.Type__c,
			Batch_Template__c.Id,Batch_Template__c.Name,Batch_Template__c.RecordTypeId,Batch_Template__c.Transaction_Type__c};
		IsCustomAccessible(customSObjectFieldList);

		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> {RecordType.Name});

		String queryString = String.format('select {0} from {1} Where RecordType.Name = \'\'Parent\'\' And Id IN :idSet',
			new List<String> { GetFieldListString(customSObjectFieldList), GetSObjectName() });
        return Database.query(queryString);
		}

	public List<Batch_Template__c> SelectByTypeRecordTypeOrderByName(String type, String recordTypeId) {
		IsAccessible();
		return SelectByTypeRecordTypeCreatedByOrderByName(type, recordTypeId, null);
	}

	public List<Batch_Template__c> SelectByTypeRecordTypeCreatedByOrderByName(String type, String recordTypeId, String userId) {
		List<Schema.SObjectField> customSObjectFieldList = new List<Schema.SObjectField> {
			Batch_Template__c.Id, Batch_Template__c.CreatedById, Batch_Template__c.Name, Batch_Template__c.RecordTypeId, Batch_Template__c.Type__c };
		IsCustomAccessible(customSObjectFieldList);

		String whereClause = String.isEmpty(userId) ? 'where Type__c = :type and RecordTypeId = :recordTypeId' : 'where Type__c = :type and RecordTypeId = :recordTypeId and CreatedById = :userId';
		String queryString = String.format('select {0} from {1} {2} order by Name',
			new List<String> { GetFieldListString(customSObjectFieldList), GetSObjectName(), whereClause });
        return Database.query(queryString);
	}

	public List<Batch_Template__c> SelectBatchTemplateAndRecordTypeNameById(Set<Id> idSet) {
		new RecordTypeSelector().IsAccessible();
		IsAccessible();

		String queryString = String.format('select {0}, RecordType.Name from {1} where Id in :idSet', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Batch_Template__c> SelectBatchTemplateByNameAndId(Set<String> batchTemplateName, Id rtype){
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Batch_Template__c.Name, Batch_Template__c.RecordTypeId};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where name = :batchTemplateName AND RecordTypeId = :rtype',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
				return Database.query(queryString);
	}
}