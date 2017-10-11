public with sharing class ReceiptSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Receipt__c.Id, Receipt__c.Name, Receipt__c.Notes__c, Receipt__c.Gift__c, Receipt__c.Amount_Not_Eligible__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Receipt__c.sObjectType;
	}

	public List<Receipt__c> SelectIdWhereGiftInReceiptReadyGifts(Set<Id> idSet) {
		List<Schema.SObjectField> receiptFieldList = new List<Schema.SObjectField> { Receipt__c.Id };
		IsCustomAccessible(receiptFieldList);
		IsCustomAccessible(new List<Schema.SObjectField>{Receipt__c.Gift__c});

		String queryString = String.format('select {0} from {1} where Gift__c in :idSet for update',
			new List<String> { GetFieldListString(receiptFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Receipt__c> SelectReceiptTypeById(Set<Id> idSet) {
		List<Schema.SObjectField> receiptFieldList = new List<Schema.SObjectField> { Receipt__c.Id, Receipt__c.Receipt_Type__c };
		IsCustomAccessible(receiptFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet limit 1',
			new List<String> { GetFieldListString(receiptFieldList), GetSObjectName() });
        return Database.query(queryString);
	}


	public Receipt__c SelecRecieptById(String id) {
        List<Schema.SObjectField> receiptFieldList = new List<Schema.SObjectField> {Receipt__c.Status__c, Receipt__c.Date_Issued__c, Receipt__c.Constituent__c, Receipt__c.Id, Receipt__c.Receipt_Email_Address__c,
        	Receipt__c.Print_Date__c, Receipt__c.Email_Subject__c, Receipt__c.Receipt_Type__c};
        IsCustomAccessible(receiptFieldList);
        
        new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.RecordTypeId });
        String queryString = String.format('SELECT {0}, Gift__r.RecordTypeId FROM {1} WHERE Id = :id',
            new List<String> { GetFieldListString(receiptFieldList), GetSObjectName() });
                return Database.query(queryString);
    }


    public List<Receipt__c> SelectTransactionRecieptWhereIdInIds(Set<id> ReceiptIds) {
        List<Schema.SObjectField> receiptFieldList = new List<Schema.SObjectField> {Receipt__c.Status__c, Receipt__c.Constituent__c, Receipt__c.Id, Receipt__c.Gift__c,
        	Receipt__c.Auto_Email_Receipt__c, Receipt__c.Receipt_Type__c};
        IsCustomAccessible(receiptFieldList);
        
        new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Recurring_Donation__c });
        String queryString = String.format('Select Id, Status__c, Gift__r.Amount__c, Gift__r.Recurring_Donation__c, Gift__c, Constituent__c, Auto_Email_Receipt__c, Receipt_Type__c From Receipt__c g WHERE Id IN :ReceiptIds FOR UPDATE',
            new List<String> { GetFieldListString(receiptFieldList), GetSObjectName() });
                return Database.query(queryString);
    }

	public List<Receipt__c> UpdateReceiptOnTrigger(Set<Id> keySet) {
		List<Schema.SObjectField> receiptFieldList = new List<Schema.SObjectField> {
			Receipt__c.Id, Receipt__c.Introduction_Text_Block_Rich_Text__c , Receipt__c.Custom_Rich_Text_3__c, Receipt__c.Custom_Rich_Text_2__c, Receipt__c.Custom_Rich_Text_1__c, Receipt__c.Email_Subject__c,
			Receipt__c.Body_Text_Block_Rich_Text__c, Receipt__c.Signature_Rich_Text__c , Receipt__c.Gift__c };
		IsCustomAccessible(receiptFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{ Gift__c.Id, Gift__c.Letter__c });
		new LetterSelector().IsCustomAccessible(new List<Schema.SObjectField>{ Letter__c.Introduction_Text_Block_Rich_Text__c, Letter__c.Custom_Rich_Text_1__c,
			Letter__c.Custom_Rich_Text_2__c, Letter__c.Custom_Rich_Text_3__c, Letter__c.Email_Subject__c, Letter__c.Text_Block__c, Letter__c.Signature_Rich_Text__c});

		String queryString = String.format('select {0}, Gift__r.Id, Gift__r.Letter__r.Introduction_Text_Block_Rich_Text__c, Gift__r.Letter__r.Custom_Rich_Text_1__c, Gift__r.Letter__r.Custom_Rich_Text_2__c, Gift__r.Letter__r.Custom_Rich_Text_3__c, Gift__r.Letter__r.Email_Subject__c, Gift__r.Letter__r.Text_Block__c, Gift__r.Letter__r.Signature_Rich_Text__c from {1} where Receipt__c.Gift__c in :keySet FOR UPDATE',
			new List<String> { GetFieldListString(receiptFieldList), GetSObjectName() });
				return Database.query(queryString);
	}
}