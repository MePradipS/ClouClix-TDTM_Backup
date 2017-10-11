public with sharing class GivingPowerSettingsSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			givingpowerSettings__c.Name, givingpowerSettings__c.DupeConsolidatedReceiptPDFDocId__c, givingpowerSettings__c.ConsolidatedReceiptPDFDocId__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return givingpowerSettings__c.sObjectType;
	}

	public List<givingpowerSettings__c> SelectReceiptsByName(String name) {
		List<Schema.SObjectField> customGPSettingFieldList = new List<Schema.SObjectField> {
			givingpowerSettings__c.Name, givingpowerSettings__c.ReceiptEmailDocId__c, givingpowerSettings__c.ReceiptPDFDocId__c,
			givingpowerSettings__c.DupeAttachTemplateId__c };
		IsCustomAccessible(customGPSettingFieldList);

		String queryString = String.format('select {0} from {1} where Name = :name',
			new List<String> { GetFieldListString(customGPSettingFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<givingpowerSettings__c> SelectByIsDeleted(Boolean isDeleted) {
		List<Schema.SObjectField> customGPSettingFieldList = new List<Schema.SObjectField> {
			givingpowerSettings__c.Id, givingpowerSettings__c.Rollup_Batch_Size__c, givingpowerSettings__c.IsDeleted };
		IsCustomAccessible(customGPSettingFieldList);

		String queryString = String.format('select {0} from {1} where IsDeleted = :isDeleted',
			new List<String> { GetFieldListString(customGPSettingFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<givingpowerSettings__c> SelectTemplateIdAndEmailIdByName(String name) {
		List<Schema.SObjectField> customGPSettingFieldList = new List<Schema.SObjectField> {
			givingpowerSettings__c.Id, givingpowerSettings__c.New_Lead_Template_Id__c, givingpowerSettings__c.Org_Wide_Email_ID__c,
			givingpowerSettings__c.Name };
		IsCustomAccessible(customGPSettingFieldList);

		String queryString = String.format('select {0} from {1} where Name = :name',
			new List<String> { GetFieldListString(customGPSettingFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<givingpowerSettings__c> SelectReceiptPDFsByName(String name) {
		List<Schema.SObjectField> customGPSettingFieldList = new List<Schema.SObjectField> {
			givingpowerSettings__c.Id, givingpowerSettings__c.DupeAttachTemplateId__c, givingpowerSettings__c.ReceiptPDFDocId__c,
			givingpowerSettings__c.DupeConsolidatedReceiptPDFDocId__c, givingpowerSettings__c.ConsolidatedReceiptPDFDocId__c, givingpowerSettings__c.Name };
		IsCustomAccessible(customGPSettingFieldList);

		String queryString = String.format('select {0} from {1} where Name = :name',
			new List<String> { GetFieldListString(customGPSettingFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<givingpowerSettings__c> SelectDocumentsByName(String name) {
		List<Schema.SObjectField> customGPSettingFieldList = new List<Schema.SObjectField> {
			givingpowerSettings__c.Id, givingpowerSettings__c.DupeDocumentTemplateId__c, givingpowerSettings__c.ReceiptEmailDocId__c,
			givingpowerSettings__c.Name };
		IsCustomAccessible(customGPSettingFieldList);

		String queryString = String.format('select {0} from {1} where Name = :name',
			new List<String> { GetFieldListString(customGPSettingFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public givingpowerSettings__c SelectSettingsByName(String name) {
		List<Schema.SObjectField> customGPSettingFieldList = new List<Schema.SObjectField> { givingpowerSettings__c.ReceiptPDFDocId__c };
		IsCustomAccessible(customGPSettingFieldList);
		IsCustomAccessible(new List<Schema.SObjectField> { givingpowerSettings__c.Name });

		String queryString = String.format('select {0} from {1} where Name = :name',
			new List<String> { GetFieldListString(customGPSettingFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<givingpowerSettings__c> SelectTemplateByName(String name) {
		List<Schema.SObjectField> customGPSettingFieldList = new List<Schema.SObjectField> {
			givingpowerSettings__c.ConsolidatedReceiptEmailTemplateId__c, givingpowerSettings__c.Event_Registration_Email_Template_ID__c, givingpowerSettings__c.Dupe_Event_Registration_Template_ID__c,
			givingpowerSettings__c.DupeConsolidatedReceiptEmailTempId__c, givingpowerSettings__c.DupeEmailTemplateId__c, givingpowerSettings__c.Org_Wide_Email_ID__c, givingpowerSettings__c.EmailTemplateId__c };
		IsCustomAccessible(customGPSettingFieldList);
		IsCustomAccessible(new List<Schema.SObjectField> { givingpowerSettings__c.Name });

		String queryString = String.format('select {0} from {1} where Name = :name',
			new List<String> { GetFieldListString(customGPSettingFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<givingpowerSettings__c> SelectRecurringBatchSize() {
		List<Schema.SObjectField> customGPSettingFieldList = new List<Schema.SObjectField> { givingpowerSettings__c.Recurring_Batch_Size__c, givingpowerSettings__c.Rollup_Batch_Size__c };
		IsCustomAccessible(customGPSettingFieldList);

		String queryString = String.format('select {0} from {1} where Name = \'\'settings\'\'',
			new List<String> { GetFieldListString(customGPSettingFieldList), GetSObjectName() });
		return Database.query(queryString);
	}
}