public with sharing class BatchSettingsSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			BatchSettings__c.Id, BatchSettings__c.Name, BatchSettings__c.BatchFormId__c, BatchSettings__c.BatchReportId__c,
			BatchSettings__c.BucketAccountId__c, BatchSettings__c.CurrencyCode__c, BatchSettings__c.GatewayUrl__c,
			BatchSettings__c.RegularGiftRecordTypeId__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return BatchSettings__c.sObjectType;
	}

	public List<SObject> SelectBucketAccountById(String name) {
		List<Schema.SObjectField> customBatchSettingsFieldList = new List<Schema.SObjectField> {
			BatchSettings__c.Id, BatchSettings__c.BucketAccountId__c, BatchSettings__c.Name };
		IsCustomAccessible(customBatchSettingsFieldList);

		String queryString = String.format('select {0} from {1} where Name = :name',
			new List<String> { GetFieldListString(customBatchSettingsFieldList), GetSObjectName() });
        return Database.query(queryString);
    }

	public List<BatchSettings__c> SelectIdWhenDefault() {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Name = \'\'Default\'\'',
			new List<String> { GetFieldListString(), GetSObjectName() });
				return Database.query(queryString);
	}
}