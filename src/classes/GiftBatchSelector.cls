public with sharing class GiftBatchSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Gift_Batch__c.Id, Gift_Batch__c.CreatedById, Gift_Batch__c.Batch_Status__c, Gift_Batch__c.Template_Name__c,
			Gift_Batch__c.Total_Gift__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Gift_Batch__c.sObjectType;
	}

	public List<Gift_Batch__c> SelectAllById(Set<Id> idSet) {
		List<Schema.SObjectField> giftBatchFieldList = new List<Schema.SObjectField> {
			Gift_Batch__c.Id, Gift_Batch__c.Total_Gift__c, Gift_Batch__c.Total_Gift_Amount__c, Gift_Batch__c.Shareplan__c,
			Gift_Batch__c.Shareplan_Gifts__c, Gift_Batch__c.OwnerId, Gift_Batch__c.Other__c, Gift_Batch__c.Other_Gifts__c,
			Gift_Batch__c.Open_Date__c, Gift_Batch__c.Name__c, Gift_Batch__c.Name, Gift_Batch__c.LastModifiedDate,
			Gift_Batch__c.LastModifiedById, Gift_Batch__c.Direct_Deposit__c, Gift_Batch__c.Direct_Deposit_Gifts__c, Gift_Batch__c.Description__c,
			Gift_Batch__c.Credit_Card__c, Gift_Batch__c.Credit_Card_Gifts__c, Gift_Batch__c.CreatedDate, Gift_Batch__c.CreatedById,
			Gift_Batch__c.Close_Date__c, Gift_Batch__c.Cheque__c, Gift_Batch__c.Cheque_Gifts__c, Gift_Batch__c.Cash__c,
			Gift_Batch__c.Cash_Gifts__c, Gift_Batch__c.Template_Name__c };
		IsCustomAccessible(giftBatchFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(giftBatchFieldList), GetSObjectName() });
        return Database.query(queryString);
    }

		public List<Gift_Batch__c> SelectByKeySet(Set<Id> keySet){
			List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift_Batch__c.Id, Gift_Batch__c.Template_Name__c};
			IsCustomAccessible(customGiftFieldList);

			String queryString = String.format('Select {0} From {1} Where Id IN :keySet',
				new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
			return Database.query(queryString);
		}

		public List<Gift_Batch__c> SelectGiftNameByName(Set<String> giftBatchName){
			List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift_Batch__c.Name__c};
			IsCustomAccessible(customGiftFieldList);

			String queryString = String.format('Select {0} From {1} Where Name__c = :giftBatchName',
				new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
			return Database.query(queryString);
		}
}