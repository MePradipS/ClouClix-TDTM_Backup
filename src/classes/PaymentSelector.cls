public with sharing class PaymentSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Account_Number__c, Payment__c.Account_Type__c, Payment__c.Amount__c, Payment__c.Bank_Name__c,
			Payment__c.Cheque_Num__c, Payment__c.Credit_Card_Type__c, Payment__c.Payment_Type__c, Payment__c.Routing_Branch_Number__c,
			Payment__c.Status__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Payment__c.sObjectType;
	}

	public List<Payment__c> SelectRecoveredPaymentByDonationId(String donationContactId, String recordTypeId) {
		List<Schema.SObjectField> transactionFieldList = new List<Schema.SObjectField> {
			Gift__c.Name, Gift__c.Gift_Type__c, Gift__c.Gift_Date__c, Gift__c.Constituent__c, Gift__c.Organization__c,
			Gift__c.Receipt_Type__c };
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Date__c, Payment__c.Amount__c, Payment__c.Payment_Type__c, Payment__c.Status__c,
			Payment__c.Receipt__c, Payment__c.RecordTypeId, Payment__c.Payment_Refunded__c };
		IsCustomAccessible(customPaymentFieldList);
		IsRelatedSObjectAccessible(new GiftSelector().GetSObjectType(), transactionFieldList);

		String transactionFieldListString = 'Donation__r.Name, Donation__r.Gift_Type__c, Donation__r.Gift_Date__c, Donation__r.Constituent__c, Donation__r.Organization__c, Donation__r.Receipt_Type__c';
		String queryString = String.format('select {0}, {1}, (Select Id From Payments__r) from {2} where (Donation__r.Constituent__c = :donationContactId or Donation__r.Organization__c = :donationContactId) and Receipt__c = null and RecordTypeId != :recordTypeId and Status__c = \'\'Approved\'\' and Donation__r.Receipt_Type__c != \'\'No Receipt\'\' and Payment_Refunded__c = null limit 1000',
			new List<String> { GetFieldListString(customPaymentFieldList), transactionFieldListString, GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectRecoveredPaymentByDonationId(String donationId) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Recovered_Payment__c, Payment__c.Donation__c };
		IsCustomAccessible(customPaymentFieldList);

		String queryString = String.format('select {0} from {1} where Donation__c = :donationId and (Recovered_Payment__c != null and Recovered_Payment__c != \'\'\'\')',
			new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentByMostRecentTransaction(String transactionId, Set<Id> recoveredPaymentIds, String status) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Amount__c, Payment__c.Date__c, Payment__c.Payment_Type__c, Payment__c.Donation__c,
			Payment__c.Status__c, Payment__c.CC_Reference__c, Payment__c.Recovered_Payment__c };
		IsCustomAccessible(customPaymentFieldList);

		String queryString = String.format('select {0} from {1} where Donation__c = :transactionId and Id not in :recoveredPaymentIds and Status__c = :status and Amount__c > 0 and CC_Reference__c <> \'\'\'\' and (Recovered_Payment__c = null OR Recovered_Payment__c = \'\'\'\') limit 5',
			new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentCCInfoById(Set<Id> idSet) {
		List<Schema.SObjectField> transactionFieldList = new List<Schema.SObjectField> { Gift__c.Recurring_Donation__c };
		List<Schema.SObjectField> recurringDonationFieldList = new List<Schema.SObjectField> { Recurring_Donation__c.Type__c };
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.CC_Reference__c, Payment__c.External_Payment_ID__c, Payment__c.Donation__c, Payment__c.Amount__c,
            Payment__c.Status__c, Payment__c.Date__c, Payment__c.CC_Transaction_Date__c, Payment__c.Recovered_Payment__c, Payment__c.CC_Invoice_Number__c,
			Payment__c.Authorization__c, Payment__c.Payment_Type__c };
		IsCustomAccessible(customPaymentFieldList);
		IsRelatedSObjectAccessible(new GiftSelector().GetSObjectType(), transactionFieldList);
		IsRelatedSObjectAccessible(new RecurringDonationSelector().GetSObjectType(), recurringDonationFieldList);

		String queryString = String.format('select {0}, Donation__r.Recurring_Donation__r.Type__c from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectPotentiallyFraudulent(Boolean isPotentiallyFraudulent) {
		List<Schema.SObjectField> giftFieldList = new List<Schema.SObjectField> {
			Gift__c.Constituent__c, Gift__c.Organization__c, Gift__c.Recurring_Donation__c };
		List<Schema.SObjectField> allocationsFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Name, Gift_Detail__c.Posted_to_Finance__c };
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Amount__c, Payment__c.Gift_Aid_Declaration__c, Payment__c.Donation__c,
			Payment__c.Status__c, Payment__c.Payment_Type__c, Payment__c.Date__c, Payment__c.iATS_Potentially_Fraudulent_Payment__c };
		IsCustomAccessible(customPaymentFieldList);
		new GiftSelector().IsCustomAccessible(giftFieldList);
		new AllocationSelector().IsCustomAccessible(allocationsFieldList);

		String queryString = String.format('select {0}, Donation__r.Constituent__c, Donation__r.Organization__c, Donation__r.Recurring_Donation__c, (select name, Posted_to_Finance__c from Allocations__r) from {1} where iATS_Potentially_Fraudulent_Payment__c = :isPotentiallyFraudulent',
			new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectInstallmentsAndAllocationsById(Set<Id> idSet) {
		List<Schema.SObjectField> allocationFieldList = new List<Schema.SObjectField> { Gift_Detail__c.Name };
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name };
		IsCustomAccessible(customPaymentFieldList);
		new InstallmentFulfillmentSelector().IsAccessible();
		new AllocationSelector().IsCustomAccessible(allocationFieldList);

		String queryString = String.format('select {0}, (select Name from Installment_Fulfillments__r), (select Name from Payments__r), (select Name from Allocations__r) from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectAllPaymentAndContactInfoById(Set<Id> idSet) {
		List<Schema.SObjectField> giftAidDeclarationFieldList = new List<Schema.SObjectField> { Gift_Aid_Declaration__c.Donor__c };
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> {
			Contact.Title, Contact.Salutation, Contact.FirstName, Contact.LastName, Contact.MailingStreet, Contact.MailingPostalCode };
		List<Schema.SObjectField> giftFieldList = new List<Schema.SObjectField> { Gift__c.Constituent__c };
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Claim_Reference_Number__c, Payment__c.Constituent__c, Payment__c.Gift_Aid_Claim_Status__c,
			Payment__c.Gift_Aid_Declaration__c, Payment__c.Date__c, Payment__c.Gift_Aid_Amount__c, Payment__c.Gift_Aid_Claim_Date__c,
			Payment__c.Gift_Aid_Received_Date__c };
		IsCustomAccessible(customPaymentFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);
		new GiftAidDeclarationSelector().IsCustomAccessible(giftAidDeclarationFieldList);
		new GiftSelector().IsCustomAccessible(giftFieldList);

		String queryString = String.format('select {0}, Gift_Aid_Declaration__r.Donor__r.Title, Gift_Aid_Declaration__r.Donor__r.Salutation, Donation__r.Constituent__r.FirstName, Donation__r.Constituent__r.LastName, Donation__r.Constituent__r.MailingStreet, Donation__r.Constituent__r.MailingPostalCode from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectGiftAidAndContactInfoById(Set<Id> idSet) {
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Contact.FirstName, Contact.LastName };
		List<Schema.SObjectField> giftFieldList = new List<Schema.SObjectField> { Gift__c.Constituent__c };
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Claim_Reference_Number__c, Payment__c.Gift_Aid_Claim_Status__c,
			Payment__c.Gift_Aid_Declaration__c, Payment__c.Gift_Aid_Amount__c, Payment__c.Gift_Aid_Received_Date__c,
			Payment__c.Gift_Aid_Rejected_Date__c, Payment__c.Donation__c };
		IsCustomAccessible(customPaymentFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);
		new GiftSelector().IsCustomAccessible(giftFieldList);

		String queryString = String.format('select {0}, Donation__r.Constituent__r.FirstName, Donation__r.Constituent__r.LastName from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectReciptByReciptId(Set<Id> giftIdsForPayUpdate){
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Receipt__c, Payment__c.Amount__c, Payment__c.Donation__c };

		IsCustomAccessible(customPaymentFieldList);

		String queryString = String.format('select {0} from {1} where Donation__c IN :giftIdsForPayUpdate',
			new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public AggregateResult[] SelectActiveDonorsByPayment(Date lastYear, Date currentDate) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Amount__c, Payment__c.Date__c };
		IsCustomAccessible(customPaymentFieldList);

		String queryString = String.format('select SUM(Amount__c)sum from {0} where Amount__c > 0 and (Date__c >= :lastYear and Date__c <= :currentDate)',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectGiftAndRecurringGiftByIdAndGiftType(Set<Id> idSet) {
		List<Schema.SObjectField> allocationsFieldList = new List<Schema.SObjectField> { Gift_Detail__c.Id };
		List<Schema.SObjectField> recurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Credit_Card__c, Recurring_Donation__c.Credit_Card_Type__c, Recurring_Donation__c.Account__c,
			Recurring_Donation__c.Branch_Num__c, Recurring_Donation__c.Institution_Num__c, Recurring_Donation__c.Bank_Name__c  };
		List<Schema.SObjectField> giftFieldList = new List<Schema.SObjectField> {
			Gift__c.Organization__c, Gift__c.Constituent__c, Gift__c.Gift_Type__c, Gift__c.RecordTypeId, Gift__c.Recurring_Donation__c };
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Amount__c, Payment__c.Receipt__c, Payment__c.Date__c, Payment__c.Donation__c,
			Payment__c.Credit_Card_Number__c, Payment__c.Credit_Card_Type__c, Payment__c.Account_Number__c,
			Payment__c.Routing_Branch_Number__c, Payment__c.Transit_Number__c, Payment__c.Bank_Name__c };
		IsCustomAccessible(customPaymentFieldList);
		new AllocationSelector().IsCustomAccessible(allocationsFieldList);
		new RecurringDonationSelector().IsCustomAccessible(recurringDonationFieldList);
		new GiftSelector().IsCustomAccessible(giftFieldList);

		String giftQuery = 'Donation__r.Organization__c, Donation__r.Constituent__c, p.Donation__r.Gift_Type__c, p.Donation__r.RecordTypeId, Donation__r.Recurring_Donation__c';
		String recurringDonationQuery = 'Donation__r.Recurring_Donation__r.Credit_Card__c, Donation__r.Recurring_Donation__r.Credit_Card_Type__c, Donation__r.Recurring_Donation__r.Account__c, Donation__r.Recurring_Donation__r.Branch_Num__c, Donation__r.Recurring_Donation__r.Institution_Num__c, Donation__r.Recurring_Donation__r.Bank_Name__c';
		String queryString = String.format('select {0}, {1}, {2}, (Select Id From Allocations__r) from {3} where Id in :idSet and Amount__c != 0 and (Donation__r.Gift_Type__c = \'\'Recurring\'\' or Donation__r.Gift_Type__c = \'\'Sponsorship\'\') for update',
			new List<String> { GetFieldListString(customPaymentFieldList), giftQuery, recurringDonationQuery, GetSObjectName() });
        return Database.query(queryString);
	}

	public Payment__c SelectPaymentWhereIdIsPaymentId(String newPaymentId){
		List<Schema.SObjectField> paymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Donation__c };

		IsCustomAccessible(paymentFieldList);

		String queryString = String.format('select {0} from {1} where Id = :newPaymentId',
			new List<String> { GetFieldListString(paymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentByCCReference(String ccReferenceId) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
		Payment__c.Id, Payment__c.Status__c, Payment__c.CC_Reference__c, Payment__c.StatusComment__c, Payment__c.Donation__c };
		IsCustomAccessible(customPaymentFieldList);

		String queryString = String.format('select {0} from {1} where CC_Reference__c = :ccReferenceId',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectRelatedGiftById(Set<Id> rgId) {
		List<Schema.SObjectField> allocationsFieldList = new List<Schema.SObjectField> { Gift_Detail__c.Gift__c };
		List<Schema.SObjectField> transactionFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Name, Gift__c.Gift_Date__c, Gift__c.Recurring_Donation__c, Gift__c.Status__c, Gift__c.Gift_Type__c,
			Gift__c.Constituent__c, Gift__c.Organization__c, Gift__c.Reference__c };
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Date__c, Payment__c.Donation__c };
		IsCustomAccessible(customPaymentFieldList);
		new AllocationSelector().IsCustomAccessible(allocationsFieldList);
		new GiftSelector().IsCustomAccessible(transactionFieldList);

		String transactionQuery = 'Donation__r.Name, Donation__r.Gift_Date__c, Donation__r.Recurring_Donation__c, Donation__r.Status__c, Donation__r.Gift_Type__c, Donation__r.Constituent__c, Donation__r.Organization__c, Donation__r.Reference__c';
		String queryString = String.format('select {0}, {1}, (select Gift__c from Allocations__r) from {2} where Donation__r.Recurring_Donation__c != null and Donation__r.Gift_Date__c = LAST_YEAR and Date__c = THIS_YEAR and Donation__r.Recurring_Donation__c in :rgId',
		new List<String> { GetFieldListString(customPaymentFieldList), transactionQuery, GetSObjectName() });
			return Database.query(queryString);
	}

	public Database.QueryLocator SelectGiftByPaymentId(Set<Id> paymentIds) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
		Payment__c.Id, Payment__c.Name, Payment__c.Amount__c, Payment__c.Status__c, Payment__c.Description__c, Payment__c.Donation__c};
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Recurring_Donation__c });

		String queryString = String.format('select {0}, Donation__r.Recurring_Donation__c from {1} WHERE ID IN :paymentIds',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.getQueryLocator(queryString);
	}

	public Database.QueryLocator SelectGiftWhenNotInPayment() {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
		Payment__c.Id, Payment__c.Name, Payment__c.Amount__c, Payment__c.Status__c, Payment__c.Description__c, Payment__c.Donation__c, Payment__c.Date__c};
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Recurring_Donation__c, Gift__c.Gift_Type__c });
		new AllocationSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift_Detail__c.Payment__c });

		String queryString = String.format('select {0}, Donation__r.Recurring_Donation__c from {1} WHERE ID NOT IN (SELECT Payment__c FROM Gift_Detail__c) AND Donation__r.Gift_Type__c = \'\'Recurring\'\' AND Status__c = \'\'Approved\'\' AND Amount__c >0 AND Date__c >= 2013-01-01',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.getQueryLocator(queryString);
	}

	public List<Payment__c> SelectNewestGiftsByTransId(Set<Id> transctionsIds) {
		List<Schema.SObjectField> giftFieldList = new List<Schema.SObjectField> { Gift__c.Recurring_Donation__c, Gift__c.Status__c };
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {Payment__c.Status__c, Payment__c.Amount__c, Payment__c.Donation__c, Payment__c.CreatedDate, Payment__c.Date__c};
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(giftFieldList);

		String queryString = String.format('select {0}, Donation__r.Recurring_Donation__c, Donation__r.Status__c from {1} where Donation__c IN :transctionsIds order by Date__c DESC, CreatedDate DESC',
			new List<String> { GetFieldListString(customPaymentFieldList) ,GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Payment__c> SelectInstallmentFulfillmentById(Set<Id> paymentIds) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {Payment__c.Id, Payment__c.Payment_Type__c, Payment__c.Payment_Refunded__c, Payment__c.Status__c, Payment__c.Date__c, Payment__c.RecordTypeId};
		IsCustomAccessible(customPaymentFieldList);
		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> { RecordType.Name });
		new InstallmentFulfillmentSelector().IsCustomAccessible(new List<Schema.SObjectField> { Installment_Fulfillment__c.Id });

		String queryString = String.format('SELECT {0}, RecordType.Name, (select Id from Installment_Fulfillments__r) from {1} where Id IN :paymentIds',
			new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public Integer SelectCountThisYear(String giftType, String status){
		isAccessible();

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{Gift__c.Gift_Date__c, Gift__c.Gift_Type__c, Gift__c.Recurring_Donation__c});

		String soql = 'SELECT count() FROM payment__c WHERE Donation__r.Gift_Date__c = LAST_YEAR AND Donation__r.Gift_Type__c = :giftType AND Date__c = THIS_YEAR AND Donation__r.Recurring_Donation__c != null AND Status__c != :status AND Amount__c > 0';
		return Database.countQuery(soql);
	}

	public Integer SelectCountDateRange(String giftType, String status, Date startDate, Date endDate, Date targetDate, Date targetNextYear){
		isAccessible();

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{Gift__c.Gift_Date__c, Gift__c.Gift_Type__c, Gift__c.Recurring_Donation__c});

		String soql = 'SELECT count() FROM payment__c WHERE Donation__r.Gift_Date__c > :endDate   AND Donation__r.Gift_Date__c <= :startDate AND  Donation__r.Gift_Type__c = :giftType AND Date__c > :targetDate AND Date__c < :targetNextYear AND Donation__r.Recurring_Donation__c != null AND Status__c != :status AND Amount__c > 0';
		return Database.countQuery(soql);
	}

	public List<Payment__c> SelectPaymentInfoForRollUpBatchMulti(Set<Id> contactIds, Set<String> recordTypesToRollup) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name , Payment__c.Amount__c, Payment__c.Date__c , Payment__c.Status__c};
		IsCustomAccessible(customPaymentFieldList);

		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> { RecordType.Name });
		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.RecordTypeId, Gift__c.Constituent__c });

		String queryString = String.format('SELECT Id, Name, convertCurrency(Amount__c), Date__c, Status__c, Donation__r.Constituent__c, Donation__r.RecordTypeId, Donation__r.RecordType.Name FROM {0} where Donation__r.Constituent__c IN :contactIds AND Status__c  = \'\'Approved\'\' AND Donation__r.RecordTypeId IN :recordTypesToRollup AND  Amount__c > 0 ORDER BY Date__c DESC, CreatedDate DESC',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentInfoForRollUpBatchMultiByIdSets(Set<Id> accountIds, Set<String> recordIds) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Amount__c, Payment__c.Date__c, Payment__c.Status__c};
		IsCustomAccessible(customPaymentFieldList);

		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> { RecordType.Name });
		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Organization__c, Gift__c.RecordTypeId });

		String queryString = String.format('select Id, Name , convertCurrency(Amount__c), Date__c , Donation__r.RecordType.Name, Donation__r.Organization__c ,Donation__r.RecordTypeId, Status__c  from Payment__c where Donation__r.Organization__c IN :accountIds AND  Status__c = \'\'Approved\'\' AND Donation__r.RecordTypeId IN :recordIds ORDER BY Date__c DESC, CreatedDate DESC',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentInfoForRollUpBatchByIdSets(Set<Id> accountIds, Set<String> recordIds) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Amount__c, Payment__c.Date__c, Payment__c.Status__c};
		IsCustomAccessible(customPaymentFieldList);

		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> { RecordType.Name });
		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Organization__c, Gift__c.RecordTypeId });

		String queryString = String.format('select Id, Name, Amount__c, Date__c , Donation__r.RecordType.Name, Donation__r.Organization__c ,Donation__r.RecordTypeId, Status__c  from Payment__c where Donation__r.Organization__c IN :accountIds AND  Status__c = \'\'Approved\'\' AND Donation__r.RecordTypeId IN :recordIds ORDER BY Date__c DESC, CreatedDate DESC',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentInfoForRollUpBatch(Set<Id> contactIds, Set<String> recordTypesToRollup) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name , Payment__c.Amount__c, Payment__c.Date__c , Payment__c.Status__c};
		IsCustomAccessible(customPaymentFieldList);

		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> { RecordType.Name });
		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Constituent__c , Gift__c.RecordTypeId });

		String queryString = String.format('SELECT Id, Name, Amount__c, Date__c, Status__c, Donation__r.Constituent__c, Donation__r.RecordTypeId, Donation__r.RecordType.Name FROM {0} where Donation__r.Constituent__c IN :contactIds AND Status__c  = \'\'Approved\'\' AND Donation__r.RecordTypeId IN :recordTypesToRollup AND  Amount__c > 0 ORDER BY Date__c DESC, CreatedDate DESC',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}

	public List<AggregateResult> SelectMinAndMaxGiftDateByContactIds(Set<Id> contactIds, List<String> recordTypesToRollup, Id recordTypeId) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Date__c, Payment__c.Status__c, Payment__c.Amount__c};
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{Gift__c.Constituent__c, Gift__c.RecordTypeId});

		String queryString = String.format('SELECT MIN(Date__c) minpaymentdate,  MAX(Date__c) maxpaymentDate ,Donation__r.Constituent__c con, Status__c  FROM payment__c  where Donation__r.Constituent__c IN :contactIds AND (Donation__r.RecordTypeId IN :recordTypesToRollup OR Donation__r.RecordTypeId = :recordTypeId) AND Status__c = \'\'Approved\'\' AND  Amount__c > 0 GROUP BY Donation__r.Constituent__c, Status__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectMinAndMaxGiftDateByOrgIds(Set<Id> orgIds, List<String> recordTypesToRollup) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Date__c, Payment__c.Status__c, Payment__c.Amount__c};
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{Gift__c.Organization__c, Gift__c.RecordTypeId});

		String queryString = String.format('SELECT MIN(Date__c) minpaymentdate, MAX(Date__c) maxpaymentDate ,Donation__r.Organization__c con , Status__c  FROM payment__c  where Donation__r.Organization__c IN :orgIds AND Donation__r.RecordTypeId IN :recordTypesToRollup AND Status__c = \'\'Approved\'\' GROUP BY Donation__r.Organization__c, Status__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public Database.QueryLocator SelectDataTablesQueryFields(String queryString) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id,
			Payment__c.Name,
			Payment__c.Claim_Reference_Number__c,
			Payment__c.Constituent__c,
			Payment__c.Gift_Aid_Claim_Status__c,
			Payment__c.Gift_Aid_Declaration__c,
			Payment__c.Date__c,
			Payment__c.Gift_Aid_Amount__c,
			Payment__c.Gift_Aid_Claim_Date__c,
			Payment__c.Gift_Aid_Received_Date__c,
			Payment__c.Gift_Aid_Rejected_Date__c,
			Payment__c.Status__c
			};
		IsCustomAccessible(customPaymentFieldList);
		new GiftAidDeclarationSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift_Aid_Declaration__c.Name, Gift_Aid_Declaration__c.IsActive__c, Gift_Aid_Declaration__c.Donor__c });
		new ContactSelector().IsCustomAccessible(new List<Schema.SObjectField> { Contact.Title, Contact.Salutation, Contact.FirstName, Contact.LastName, Contact.MailingStreet, Contact.MailingPostalCode });
		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Constituent__c });

		return Database.getQueryLocator(queryString);
	}

	public List<Payment__c> SelectPaymentByStatusAndDonation(String status, String donationId) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
		Payment__c.Id, Payment__c.Name, Payment__c.Amount__c, Payment__c.Donation__c, Payment__c.Status__c };
		IsCustomAccessible(customPaymentFieldList);

		String queryString = String.format('Select {0} From {1} Where Status__c = :status AND Donation__c = :donationId ',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectRefundedPaymentByPaymentId(Set<Id> refundPaymentIds) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
		Payment__c.Id, Payment__c.Amount__c, Payment__c.Payment_Refunded__c };
		IsCustomAccessible(customPaymentFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id IN :refundPaymentIds',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentsByDoationOrderByDate(Set<Id> transctionsIds) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Status__c, Payment__c.Amount__c, Payment__c.Date__c,
				Payment__c.Donation__c, Payment__c.CreatedDate };
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Recurring_Donation__c, Gift__c.Status__c});

		String queryString = String.format('select {0}, Donation__r.Recurring_Donation__c,Donation__r.Status__c from {1} where Donation__c IN :transctionsIds order by Date__c DESC, CreatedDate DESC',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public Database.QueryLocator SelectPaymentsByTransactionForCurrentYear() {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Amount__c, Payment__c.Date__c,
				Payment__c.Donation__c, Payment__c.Status__c };
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Recurring_Donation__c, Gift__c.Gift_Date__c, Gift__c.Gift_Type__c});
		new AllocationSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift_Detail__c.Gift__c});
		new RecurringDonationSelector().IsCustomAccessible(new List<Schema.SObjectField> {Recurring_Donation__c.Id});

		String queryString = String.format('SELECT {0}, Donation__r.Recurring_Donation__c, Donation__r.Recurring_Donation__r.Id, (select Gift__c from Allocations__r) FROM {1} WHERE Donation__r.Gift_Date__c = LAST_YEAR AND Donation__r.Gift_Type__c = \'\'Recurring\'\' AND Date__c = THIS_YEAR AND Donation__r.Recurring_Donation__c != null AND Status__c != \'\'Refunded\'\' AND Amount__c > 0',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.getQueryLocator(queryString);
	}

	public Database.QueryLocator SelectPaymentsByTransactionForTargetYear(Date targetStart, Date targetEnd, Date targetDate, Date targetNext) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Amount__c, Payment__c.Date__c,
				Payment__c.Donation__c, Payment__c.Status__c };
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Recurring_Donation__c, Gift__c.Gift_Date__c, Gift__c.Gift_Type__c});
		new AllocationSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift_Detail__c.Gift__c});
		new RecurringDonationSelector().IsCustomAccessible(new List<Schema.SObjectField> {Recurring_Donation__c.Id});

		String queryString = String.format('SELECT {0}, Donation__r.Recurring_Donation__c, Donation__r.Recurring_Donation__r.Id, (select Gift__c from Allocations__r) FROM {1} WHERE Donation__r.Gift_Date__c >: targetEnd AND Donation__r.Gift_Date__c <= :targetStart AND Donation__r.Gift_Type__c = \'\'Recurring\'\' AND Date__c >: targetDate AND Date__c < :targetNext AND Donation__r.Recurring_Donation__c != null AND Status__c != \'\'Refunded\'\' AND Amount__c > 0',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.getQueryLocator(queryString);
	}

	public List<Payment__c> SelectPaymentsByTypeAndId(Set<Id> paymentIds) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Amount__c, Payment__c.Date__c, Payment__c.Receipt__c,
				Payment__c.Donation__c, Payment__c.Credit_Card_Number__c, Payment__c.Credit_Card_Type__c, Payment__c.Account_Number__c, Payment__c.Routing_Branch_Number__c, Payment__c.Transit_Number__c,
				Payment__c.Bank_Name__c };
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Organization__c, Gift__c.Constituent__c, Gift__c.Gift_Type__c, Gift__c.RecordTypeId, Gift__c.Recurring_Donation__c});
		new AllocationSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift_Detail__c.Id});
		new RecurringDonationSelector().IsCustomAccessible(new List<Schema.SObjectField> {Recurring_Donation__c.Id, Recurring_Donation__c.Credit_Card__c, Recurring_Donation__c.Credit_Card_Type__c, Recurring_Donation__c.Account__c, Recurring_Donation__c.Branch_Num__c, Recurring_Donation__c.Institution_Num__c, Recurring_Donation__c.Bank_Name__c});

		String transactionQuery = 'Donation__R.Organization__c, Donation__R.Constituent__c, Donation__r.Gift_Type__c, Donation__r.RecordTypeId, Donation__r.Recurring_Donation__c';
		String recurringDonationQuery = 'Donation__r.Recurring_Donation__r.Credit_Card__c, Donation__r.Recurring_Donation__r.Credit_Card_Type__c, Donation__r.Recurring_Donation__r.Account__c, Donation__r.Recurring_Donation__r.Branch_Num__c, Donation__r.Recurring_Donation__r.Institution_Num__c, Donation__r.Recurring_Donation__r.Bank_Name__c';
		String queryString = String.format('select {0}, {1}, {2}, (Select Id From Allocations__r) From {3} WHERE id IN :paymentIds AND Amount__c!=0 AND (Donation__r.Gift_Type__c=\'\'Recurring\'\' OR Donation__r.Gift_Type__c=\'\'Sponsorship\'\')  FOR UPDATE',
		new List<String> { GetFieldListString(customPaymentFieldList), transactionQuery, recurringDonationQuery, GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectConsolidateReportForPaymentByStatusAndId(Set<Id> giftIds) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Receipt__c, Payment__c.Date__c, Payment__c.Donation__c, Payment__c.Status__c };
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Consolidated_Rcpt__c });

		String queryString = String.format('Select {0}, Donation__r.Consolidated_Rcpt__c From {1} Where Status__c = \'\'Approved\'\' AND Donation__c In :giftIds FOR UPDATE',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectAllocationForPaymentById(Set<Id> giftIds) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Amount__c, Payment__c.Payment_Refunded__c };
		IsCustomAccessible(customPaymentFieldList);

		new AllocationSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.Gift__c, Gift_Detail__c.Tribute__c, Gift_Detail__c.Product__c,
			Gift_Detail__c.New_Campaign__c, Gift_Detail__c.Fund__c, Gift_Detail__c.Payment__c, Gift_Detail__c.Amount__c, Gift_Detail__c.Quantity__c, Gift_Detail__c.Event_Level__c });

		String queryString = String.format('SELECT {0}, (SELECT Allocation_Date__c, Gift__c, Tribute__c, Product__c, New_Campaign__c, Fund__c, Payment__c, Amount__c,Quantity__c, Event_Level__c FROM Allocations__r) FROM {1} WHERE Id IN :giftIds',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public AggregateResult[] CalculatePaymentDatesByIds(Set<Id> orgIds, Set<Id> recordTypeIdsforRollup) {
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Status__c, Payment__c.Date__c };
		IsCustomAccessible(contactFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Organization__c, Gift__c.RecordTypeId });

		String queryString = String.format('SELECT MIN(Date__c) minpaymentdate,  MAX(Date__c) maxpaymentDate ,Donation__r.Organization__c , Status__c  FROM {0}  where Donation__r.Organization__c IN :orgIds AND Donation__r.RecordTypeId IN :recordTypeIdsforRollup AND Status__c = \'\'Approved\'\' GROUP BY Donation__r.Organization__c, Status__c ',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentWithCurrencyByAccountAndRecordIds(Set<Id> accountIds, Set<Id> recordIds){
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Name, Payment__c.Amount__c,
			Payment__c.CreatedDate, Payment__c.Status__c, Payment__c.Date__c  };
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Organization__c, Gift__c.RecordTypeId });
		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> {RecordType.Name });

		String queryString = String.format('select {0}, convertCurrency(Amount__c), Donation__r.RecordType.Name, Donation__r.Organization__c ,Donation__r.RecordTypeId, from {1} where Donation__r.Organization__c IN : accountIds AND  Status__c = \'\'Approved\'\' AND Donation__r.RecordTypeId IN : recordIds ORDER BY Date__c DESC, CreatedDate DESC',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentByAccountAndRecordIds(Set<Id> accountIds, Set<Id> recordIds){
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Name, Payment__c.Amount__c,
			Payment__c.CreatedDate, Payment__c.Status__c, Payment__c.Date__c  };
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Organization__c, Gift__c.RecordTypeId });
		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> {RecordType.Name });

		String queryString = String.format('select {0}, Donation__r.RecordType.Name, Donation__r.Organization__c ,Donation__r.RecordTypeId from {1} where Donation__r.Organization__c IN : accountIds AND Status__c = \'\'Approved\'\' AND Donation__r.RecordTypeId IN : recordIds ORDER BY Date__c DESC, CreatedDate DESC',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentTransactionById(String setId){
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Donation__c, Payment__c.Amount__c  };
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Sys_Clone_Transaction__c, Gift__c.Amount__c });

		String queryString = String.format('Select Id, Amount__c, Donation__r.Sys_Clone_Transaction__c, Donation__r.Amount__c, Donation__c From Payment__c c where Id=:setId',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectNameByPaymentId(String paymentId){
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Name  };
		IsCustomAccessible(customPaymentFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Name });

		String queryString = String.format('Select Id, Donation__r.Name, Name FROM {0} where Id = :paymentId LIMIT 1',
		new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectRefundedPaymentInfo(String refundPaymentId) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
		Payment__c.Id, Payment__c.Name, Payment__c.Amount__c, Payment__c.Refund_Reason__c, Payment__c.Refund_Comments__c, Payment__c.Payment_Type__c, 
		Payment__c.Status__c, Payment__c.Donation__c };
		IsCustomAccessible(customPaymentFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id = :refundPaymentId',
		new List<String> { GetFieldListString(customPaymentFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Payment__c> SelectPaymentByRefundId(String refundPaymentId) {
		List<Schema.SObjectField> customPaymentFieldList = new List<Schema.SObjectField> {
		Payment__c.Id, Payment__c.Amount__c, Payment__c.Payment_Refunded__c, Payment__c.Status__c };
		IsCustomAccessible(customPaymentFieldList);

		String queryString = String.format('SELECT Id, Amount__c FROM {0} WHERE Payment_Refunded__c = :refundPaymentId AND Status__c = \'\'Refunded\'\'',
		new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}
}