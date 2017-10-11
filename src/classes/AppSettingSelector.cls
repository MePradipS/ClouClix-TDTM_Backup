public with sharing class AppSettingSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			App_Settings__c.Enable_Enhanced_Batch_Interface__c, App_Settings__c.Enable_Enhanced_Fund_Accounting__c,
			App_Settings__c.Enable_Pledge_Installment_Model__c, App_Settings__c.Use_Workflows_for_Sending_Receipts__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return App_Settings__c.sObjectType;
	}

	public List<App_Settings__c> SelectEnableEnhancedBatchInterface() {
		List<Schema.SObjectField> appSettingFieldList = new List<Schema.SObjectField> { App_Settings__c.Enable_Enhanced_Batch_Interface__c };
		IsCustomAccessible(appSettingFieldList);

		String queryString = String.format('select {0} from {1}', new List<String> { GetFieldListString(appSettingFieldList), GetSObjectName() });
        return Database.query(queryString);
    }
	
    public List<App_Settings__c> SelectMailFromJobSetting() {
		List<Schema.SObjectField> appSettingFieldList = new List<Schema.SObjectField> { App_Settings__c.id, App_Settings__c.Name, App_Settings__c.Send_Mail_From_Job__c, App_Settings__c.First_Date_of_Tax_Year__c };
		IsCustomAccessible(appSettingFieldList);

		String queryString = String.format('select {0} from {1} limit 1', new List<String> { GetFieldListString(appSettingFieldList), GetSObjectName() });
        return Database.query(queryString);
    }

    public List<App_Settings__c> SelectNameSendMailAndFirstDateOfTaxYear() {
		List<Schema.SObjectField> appSettingFieldList = new List<Schema.SObjectField> { App_Settings__c.Id, App_Settings__c.Name, App_Settings__c.Send_Mail_From_Job__c,
			App_Settings__c.First_Date_of_Tax_Year__c };
		IsCustomAccessible(appSettingFieldList);

		String queryString = String.format('select {0} from {1} limit 1',
			new List<String> { GetFieldListString(appSettingFieldList), GetSObjectName() });
        return Database.query(queryString);
    }

    public List<App_Settings__c> SelectGiftAidEnable() {
		List<Schema.SObjectField> appSettingFieldList = new List<Schema.SObjectField> { App_Settings__c.Gift_Aid_Enable__c };
		IsCustomAccessible(appSettingFieldList);

		String queryString = String.format('SELECT {0} FROM {1} LIMIT 1',
			new List<String> { GetFieldListString(appSettingFieldList), GetSObjectName() });
        return Database.query(queryString);
    }
}