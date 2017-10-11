public with sharing class GiftSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Name, Gift__c.Amount__c, Gift__c.Batch_Status__c, Gift__c.Constituent__c, Gift__c.Constituent_Name__c, Gift__c.CreatedDate,
			Gift__c.Expected_Amount__c, Gift__c.Gift_Type__c, Gift__c.Organization__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Gift__c.sObjectType;
	}

	public List<Gift__c> SelectIdByOrganization(String organizationId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Organization__c = :organizationId',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectIdByProposal(String proposalId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Proposal__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Proposal__c = :proposalId',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift__c> SelectStatusById(Set<id> giftIds){
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Status__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id IN :giftIds',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift__c> SelectIdByConstituent(String constituentId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Constituent__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Constituent__c = :constituentId',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectAmountAndYearByConstituentAndPastFourYears(String contactId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Constituent__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select SUM(Amount__c) total, CALENDAR_YEAR(Gift_Date__c) year from {0} where Constituent__c = :contactId and (Gift_Date__c = LAST_N_YEARS:4 OR Gift_Date__c = THIS_YEAR) group by CALENDAR_YEAR(Gift_Date__c) order by CALENDAR_YEAR(Gift_Date__c)',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectAmountAndYearByOrganizationAndPastFourYears(String contactId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select SUM(Amount__c) total, CALENDAR_YEAR(Gift_Date__c) year from {0} where Organization__c = :contactId and (Gift_Date__c = LAST_N_YEARS:4 OR Gift_Date__c = THIS_YEAR) group by CALENDAR_YEAR(Gift_Date__c) order by CALENDAR_YEAR(Gift_Date__c)',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectExpectedAmountById(Set<Id> idSet) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Expected_Amount__c, Gift__c.Constituent__c, Gift__c.Gift_Date__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectIdByRecurringDonationAndStatus(String recurringGiftId, String status) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Recurring_Donation__c, Gift__c.Status__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Recurring_Donation__c = :recurringGiftId and Status__c = :status order by Gift_Date__c desc limit 1',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectIdByRecurringDonation(String recurringGiftId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Gift_Date__c, Gift__c.Status__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Recurring_Donation__c = :recurringGiftId order by Gift_Date__c desc limit 1',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift__c> SelectWithCreatedDateNotNull() {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where CreatedDate != null', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftConstituentOrganizationRecurringDonationById(Set<Id> idSet) {
		List<String> constituentRelatedFieldsStringList = new List<String> {
			'Constituent__r.MailingStreet', 'Constituent__r.MailingCity', 'Constituent__r.MailingState', 'Constituent__r.MailingCountry',
			'Constituent__r.MailingPostalCode', 'Constituent__r.Email', 'Constituent__r.Phone', 'Constituent__r.FirstName', 'Constituent__r.LastName' };
		List<String> organizationRelatedFieldsStringList = new List<String> {
			'Organization__r.BillingStreet', 'Organization__r.BillingCity', 'Organization__r.BillingState', 'Organization__r.BillingCountry',
			'Organization__r.BillingPostalCode', 'Organization__r.Email__c', 'Organization__r.Phone', 'Organization__r.Name' };
		List<String> recurringDonationRelatedFieldsStringList = new List<String> {
			'Recurring_Donation__r.Start_Date__c', 'Recurring_Donation__r.of_Payments__c', 'Recurring_Donation__r.Frequency__c' };
		PaymentSelector paymentSelector = new PaymentSelector();

		IsAccessible();
		paymentSelector.IsAccessible();
		new RecurringDonationSelector().IsAccessible();
		new AccountSelector().IsAccessible();
		new ContactSelector().IsAccessible();

		String queryString = String.format('select {0}, {1}, {2}, {3}, (select {4} from {5}) from {6} where Id in :idSet',
			new List<String> { GetFieldListString(), GetRelatedFieldListString(constituentRelatedFieldsStringList),
				GetRelatedFieldListString(organizationRelatedFieldsStringList), GetRelatedFieldListString(recurringDonationRelatedFieldsStringList),
				paymentSelector.GetFieldListString(), 'Recurring_Payments__r', GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectReferenceByStatusAndReference(String status, String referenceId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Reference__c, Gift__c.Status__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Status__c = :status and Reference__c = :referenceId',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectEventById(Set<Id> idSet) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Name, Gift__c.Event_Id__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectAttendeesById(String guestId, Set<Id> idSet) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Attendee_Names_Received__c };
		IsCustomAccessible(customGiftFieldList);
		new EventRegistrationSelector().IsCustomAccessible(new List<Schema.SObjectField> {Event_Registration__c.Id, Event_Registration__c.Individual__c});

		String queryString = String.format('select {0}, (select Id from Event_Registrations__r where Individual__c != :guestId) from {1} where Id in :idSet for update',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectRecurringById(Set<Id> idSet) {
		List<Schema.SObjectField> paymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Name };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Name, Gift__c.Recurring_Donation__c, Gift__c.Constituent__c, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);
		new PaymentSelector().IsCustomAccessible(paymentFieldList);

		String queryString = String.format('select {0}, (select Name from Recurring_Payments__r) from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectAllRecurringInfoById(Set<Id> idSet) {
		List<Schema.SObjectField> paymentFieldList = new List<Schema.SObjectField> { Payment__c.Name };
		List<Schema.SObjectField> allocationFieldList = new List<Schema.SObjectField> { Gift_Detail__c.Name };
		List<Schema.SObjectField> solicitorsFieldList = new List<Schema.SObjectField> { Solicitor__c.Name };
		List<Schema.SObjectField> receiptsFieldList = new List<Schema.SObjectField> { Receipt__c.Name };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Name, Gift__c.Recurring_Donation__c, Gift__c.Constituent__c, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);
		new PaymentSelector().IsCustomAccessible(paymentFieldList);
		new AllocationSelector().IsCustomAccessible(allocationFieldList);
		new SolicitorSelector().IsCustomAccessible(solicitorsFieldList);
		new ReceiptSelector().IsCustomAccessible(receiptsFieldList);

		String queryString = String.format('select {0}, (select Name from Recurring_Payments__r), (select Name from Gift_Allocations__r), (select Name from Soft_Credits__r), (select Name from Receipts__r) from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectConstituentNameByConstituentId(Set<Id> idSet) {
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Contact.Name };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Constituent__c };
		IsCustomAccessible(customGiftFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);

		String queryString = String.format('select {0}, Constituent__r.Name from {1} where Constituent__c in :idSet',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectOrganizationNameByOrganizationId(Set<Id> idSet) {
		List<Schema.SObjectField> accountFieldList = new List<Schema.SObjectField> { Account.Name };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);
		new AccountSelector().IsCustomAccessible(accountFieldList);

		String queryString = String.format('select {0}, Organization__r.Name from {1} where Organization__c in :idSet',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectOrganizationNameAndConstituentNameById(Set<Id> idSet) {
		List<Schema.SObjectField> accountFieldList = new List<Schema.SObjectField> { Account.Name };
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Contact.Name };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Constituent__c, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);
		new AccountSelector().IsCustomAccessible(accountFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);

		String queryString = String.format('select {0}, Constituent__r.Name, Organization__r.Name from {1} where Organization__c in :idSet',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectOrganizationConstituentRecurringGiftByIdList(List<Id> idList) {
		List<Schema.SObjectField> accountFieldList = new List<Schema.SObjectField> { Account.Name };
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Contact.Name };
		List<Schema.SObjectField> recurringGiftFieldList = new List<Schema.SObjectField> { Recurring_Donation__c.Name, Recurring_Donation__c.Status__c };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.name, Gift__c.Gift_Type__c, Gift__c.Status__c, Gift__c.Gift_Date__c, Gift__c.Acknowledgement_Recipient_Email__c, Gift__c.Constituent__c, Gift__c.Organization__c, Gift__c.Recurring_Donation__c };
		IsCustomAccessible(customGiftFieldList);
		new AccountSelector().IsCustomAccessible(accountFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);
		new RecurringDonationSelector().IsCustomAccessible(recurringGiftFieldList);

		String queryString = String.format('select {0}, Constituent__r.Name, Organization__r.Name, Recurring_Donation__r.Name, Recurring_Donation__r.Status__c from {1} where id = :idList',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectOrganizationConstituentRecurringGiftByGiftIdList(List<Gift__c> idList) {
		List<Schema.SObjectField> accountFieldList = new List<Schema.SObjectField> { Account.Name };
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Contact.Name };
		List<Schema.SObjectField> recurringGiftFieldList = new List<Schema.SObjectField> { Recurring_Donation__c.Name, Recurring_Donation__c.Status__c };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.name, Gift__c.Gift_Type__c, Gift__c.Status__c, Gift__c.Gift_Date__c, Gift__c.Acknowledgement_Recipient_Email__c, Gift__c.Constituent__c, Gift__c.Organization__c, Gift__c.Recurring_Donation__c };
		IsCustomAccessible(customGiftFieldList);
		new AccountSelector().IsCustomAccessible(accountFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);
		new RecurringDonationSelector().IsCustomAccessible(recurringGiftFieldList);

		String queryString = String.format('select {0}, Constituent__r.Name, Organization__r.Name, Recurring_Donation__r.Name, Recurring_Donation__r.Status__c from {1} where id = :idList',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectByConstituentIdAndGiftType(Set<Id> idSet, String giftType) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Constituent__c, Gift__c.Next_Payment_Due__c, Gift__c.Per_payment_amount__c, Gift__c.Outstanding_Amount__c,
			Gift__c.No_of_Outstanding_Payments__c, Gift__c.Expected_Amount__c, Gift__c.Amount__c, Gift__c.Gift_Date__c,
			Gift__c.Gift_Type__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Constituent__c in :idSet and Gift_Type__c = :giftType and No_of_Outstanding_Payments__c > 0 order by CreatedDate desc',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectTotalAttendeesById(Set<Id> idSet) {
		List<Schema.SObjectField> allocationsFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Number_of_Attendees__c };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Total_Attendees_Purchased__c };
		IsCustomAccessible(customGiftFieldList);
		new AllocationSelector().IsCustomAccessible(allocationsFieldList);

		String queryString = String.format('select {0}, (select Id, Number_of_Attendees__c from Gift_Allocations__r) from {1} where Id in :idSet for update',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectIdByMatchedGift(String matchedGiftId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Matched_Gift__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Matched_Gift__c = :matchedGiftId',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectAccountContactRecurringDonationAndAllocationByGiftBatchId(String giftBatchId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Package_Name__c, Gift__c.Name, Gift__c.Receipt_Type__c, Gift__c.Batch_Status__c,
			Gift__c.Gift_Type__c, Gift__c.Gift_Date__c, Gift__c.Foundation_Credit__c, Gift__c.Constituent__c, Gift__c.Recurring_Donation__c,
			Gift__c.Receipt_Later__c, Gift__c.Channel__c, Gift__c.Amount__c, Gift__c.Organization__c, Gift__c.Anonymous__c,
			Gift__c.Reference__c, Gift__c.Letter__c, Gift__c.Primary_Solicitor__c, Gift__c.Internal_Solicitor__c, Gift__c.Expected_Amount__c };
		IsCustomAccessible(customGiftFieldList);
		CheckAccountContactRecurringDonationAndAllocation();
		String accountQuery = GetFullAccountQuery();
		String contactQuery = GetFullContactQuery();
		String recurringDonationQuery = GetFullRecurringDonationQuery();

		String queryString = String.format('select {0}, RecordType.Name, {1}, {2}, {3}, (Select Id, Notes__c, Name, Gift__c, Amount_Not_Eligible__c from Receipts__r), (Select Id, Name, Date__c, Status__c, Amount__c, Payment_Type__c, Donation__c, CC_Transaction_Date__c, Cheque_Num__c, Cheque_Date__c, Date_Deposited__c, Credit_Card_Type__c, StatusComment__c from Recurring_Payments__r), (Select Id, Title, ParentId, Body from Notes), (Select Id, Package__c, Amount__c, Package__r.Name, New_Campaign__c, Product__c, Tribute__c, Fund__c, Description__c, Gift__c from Gift_Allocations__r) from {4} where GiftBatch__c = :giftBatchId',
			new List<String> { GetFieldListString(customGiftFieldList), accountQuery, contactQuery, recurringDonationQuery, GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectAccountContactRecurringDonationAndAllocationById(Set<Id> idSet) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Package_Name__c, Gift__c.Name, Gift__c.Receipt_Type__c, Gift__c.Batch_Status__c,
			Gift__c.Gift_Type__c, Gift__c.Gift_Date__c, Gift__c.Foundation_Credit__c, Gift__c.Constituent__c, Gift__c.Recurring_Donation__c,
			Gift__c.Receipt_Later__c, Gift__c.Channel__c, Gift__c.Amount__c, Gift__c.Organization__c, Gift__c.Anonymous__c,
			Gift__c.Reference__c, Gift__c.Letter__c, Gift__c.Primary_Solicitor__c, Gift__c.Internal_Solicitor__c, Gift__c.Expected_Amount__c };
		IsCustomAccessible(customGiftFieldList);
		CheckAccountContactRecurringDonationAndAllocation();
		String accountQuery = GetFullAccountQuery();
		String contactQuery = GetFullContactQuery();
		String recurringDonationQuery = GetFullRecurringDonationQuery();

		String queryString = String.format('select {0}, RecordType.Name, {1}, {2}, {3}, (Select Id, Notes__c, Name, Gift__c, Amount_Not_Eligible__c from Receipts__r), (Select Id, Name, Date__c, Status__c, Amount__c, Payment_Type__c, Donation__c, CC_Transaction_Date__c, Cheque_Num__c, Cheque_Date__c, Date_Deposited__c, Credit_Card_Type__c, StatusComment__c from Recurring_Payments__r), (Select Id, Title, ParentId, Body from Notes), (Select Id, Package__c, Amount__c, Package__r.Name, New_Campaign__c, Product__c, Tribute__c, Fund__c, Description__c, Gift__c from Gift_Allocations__r) from {4} where Id in :idSet',
			new List<String> { GetFieldListString(customGiftFieldList), accountQuery, contactQuery, recurringDonationQuery, GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftTypeAndRecordWithDateWhereIdInIds(Set<Id> giftIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Gift_Type__c,
			Gift__c.RecordTypeId, Gift__c.Gift_Date__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Id IN: giftIds',
		new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftTypeAndRecordWhereIdInIds(Set<Id> giftIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Gift_Type__c,
		Gift__c.RecordTypeId };
		  String queryString = String.format('select {0} from {1} where Id IN: giftIds',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
		return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftAndLetterWhereIdInIds(Set<Id> giftId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Letter__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id In :giftId FOR UPDATE',
		new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
		return Database.query(queryString);
	}

		public List<Gift__c> SelectGiftAndRecordTypeId(Set<Id> orgIds) {
			List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
				Gift__c.Id, Gift__c.Amount__c, Gift__c.Status__c, Gift__c.Gift_Date__c, Gift__c.RecordTypeId, Gift__c.Organization__c};
			IsCustomAccessible(customGiftFieldList);
			CheckAccountContactRecurringDonationAndAllocation();

			String queryString = String.format('select {0}, RecordType.Name from {1} where Organization__c IN :orgIds ORDER BY Gift_Date__c DESC, CreatedDate DESC',
				new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
					return Database.query(queryString);
		}

		public List<Gift__c> SelectGiftByFoundationCredit(Set<Id> accountIds) {
			List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
				Gift__c.Id, Gift__c.Amount__c, Gift__c.Status__c, Gift__c.Gift_Date__c, Gift__c.Foundation_Credit__c};
			IsCustomAccessible(customGiftFieldList);
			CheckAccountContactRecurringDonationAndAllocation();

			String queryString = String.format('select {0} from {1} where Foundation_Credit__c IN :accountIds',
				new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
					return Database.query(queryString);
		}

		public List<Gift__c> SelectGiftByFoundationCreditAndConvert(Set<Id> accountIds) {
			List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
				Gift__c.Id, Gift__c.Amount__c, Gift__c.Status__c, Gift__c.Gift_Date__c, Gift__c.Foundation_Credit__c};
			IsCustomAccessible(customGiftFieldList);
			CheckAccountContactRecurringDonationAndAllocation();

			String queryString = String.format('select Id, convertCurrency(Amount__c), Status__c,Gift_Date__c, Foundation_Credit__c from {0} where Foundation_Credit__c IN :accountIds',
				new List<String> { GetSObjectName() });
					return Database.query(queryString);
		}

	private void CheckAccountContactRecurringDonationAndAllocation() {
		List<Schema.SObjectField> accountFieldList = new List<Schema.SObjectField> {
			Account.Id, Account.Solicit_Codes__c, Account.Constituent_Codes__c, Account.Trade_Status__c, Account.Organization_ID__c,
			Account.Type, Account.Region__c, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState,
			Account.BillingCity, Account.BillingStreet, Account.Name, Account.Phone, Account.Fax, Account.Website, Account.Email__c };
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> {
			Contact.Id, Contact.Middle_Name__c, Contact.Trade_Status__c, Contact.Constituent_ID__c, Contact.Solicit_Codes__c, Contact.Primary_Salutation__c,
			Contact.Name, Contact.Salutation, Contact.FirstName, Contact.LastName, Contact.MailingCountry, Contact.MailingPostalCode,
			Contact.MailingState, Contact.MailingCity, Contact.MailingStreet, Contact.Region__c, Contact.Email, Contact.Phone, Contact.Primary_Addressee__c,
			Contact.Constituent_Codes__c, Contact.AccountId, Contact.Household__c };
		List<Schema.SObjectField> recurringGiftFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Organization__c, Recurring_Donation__c.Start_Date__c, Recurring_Donation__c.Frequency__c,
			Recurring_Donation__c.Type__c, Recurring_Donation__c.CreatedDate, Recurring_Donation__c.Constituent__c, Recurring_Donation__c.End_Date__c,
			Recurring_Donation__c.Bank_Name__c, Recurring_Donation__c.Bank_City__c, Recurring_Donation__c.Amount__c, Recurring_Donation__c.Branch_Num__c,
			Recurring_Donation__c.Institution_Num__c, Recurring_Donation__c.Encrypted_Key__c, Recurring_Donation__c.Account__c, Recurring_Donation__c.Credit_Card_Expiry_Date__c,
			Recurring_Donation__c.Credit_Card__c, Recurring_Donation__c.Credit_Card_Type__c, Recurring_Donation__c.of_Payments__c };
		List<Schema.SObjectField> paymentFieldList = new List<Schema.SObjectField> {
			Payment__c.Id, Payment__c.Name, Payment__c.Date__c, Payment__c.Status__c, Payment__c.Amount__c, Payment__c.Payment_Type__c, Payment__c.Donation__c,
			Payment__c.CC_Transaction_Date__c, Payment__c.Cheque_Num__c, Payment__c.Cheque_Date__c, Payment__c.Date_Deposited__c, Payment__c.Credit_Card_Type__c,
			Payment__c.StatusComment__c };
		List<Schema.SObjectField> allocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Package__c, Gift_Detail__c.Amount__c, Gift_Detail__c.New_Campaign__c, Gift_Detail__c.Product__c,
			Gift_Detail__c.Tribute__c, Gift_Detail__c.Fund__c, Gift_Detail__c.Description__c,
			Gift_Detail__c.Gift__c, Gift_Detail__c.Package__c };
		List<Schema.SObjectField> packageFieldList = new List<Schema.SObjectField> { Package__c.Name };
		new RecordTypeSelector().IsAccessible();
		new AccountSelector().IsCustomAccessible(accountFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);
		new RecurringDonationSelector().IsCustomAccessible(recurringGiftFieldList);
		new PaymentSelector().IsCustomAccessible(paymentFieldList);
		new ReceiptSelector().IsAccessible();
		new AllocationSelector().IsCustomAccessible(allocationFieldList);
		new PackageSelector().IsAccessible();
	}

	private String GetFullAccountQuery() {
		String accountQuery = 'Organization__r.Organization_ID__c, Organization__r.Solicit_Codes__c, Organization__r.Constituent_Codes__c, Organization__r.Trade_Status__c,';
		accountQuery += 'Organization__r.Id, Organization__r.Type, Organization__r.Region__c, Organization__r.BillingCountry, Organization__r.BillingPostalCode,';
		accountQuery += 'Organization__r.BillingState, Organization__r.BillingCity, Organization__r.BillingStreet, Organization__r.Name, Organization__r.Phone,';
		accountQuery += 'Organization__r.Fax, Organization__r.Website, Organization__r.Email__c';
		return accountQuery;
	}

	private String GetFullContactQuery() {
		String contactQuery = 'Constituent__r.Id, Constituent__r.Middle_Name__c, Constituent__r.Trade_Status__c, Constituent__r.Constituent_ID__c,';
		contactQuery += 'Constituent__r.Solicit_Codes__c, Constituent__r.Primary_Salutation__c, Constituent__r.Name, Constituent__r.Salutation, Constituent__r.FirstName,';
		contactQuery += 'Constituent__r.LastName, Constituent__r.MailingCountry, Constituent__r.MailingPostalCode, Constituent__r.MailingState, Constituent__r.MailingCity,';
        contactQuery += 'Constituent__r.MailingStreet, Constituent__r.Region__c, Constituent__r.Email, Constituent__r.Phone, Constituent__r.Primary_Addressee__c,';
		contactQuery += 'Constituent__r.Constituent_Codes__c, Constituent__r.AccountId, Constituent__r.Household__c';
		return contactQuery;
	}

	private String GetFullRecurringDonationQuery() {
		String recurringDonationQuery = 'Recurring_Donation__r.Id, Recurring_Donation__r.Organization__c, Recurring_Donation__r.Start_Date__c,';
		recurringDonationQuery += 'Recurring_Donation__r.Frequency__c, Recurring_Donation__r.Type__c, Recurring_Donation__r.CreatedDate,';
		recurringDonationQuery += 'Recurring_Donation__r.Constituent__c, Recurring_Donation__r.End_Date__c, Recurring_Donation__r.Bank_Name__c,';
		recurringDonationQuery += 'Recurring_Donation__r.Bank_City__c, Recurring_Donation__r.Amount__c, Recurring_Donation__r.Branch_Num__c,';
		recurringDonationQuery += 'Recurring_Donation__r.Institution_Num__c, Recurring_Donation__r.Encrypted_Key__c, Recurring_Donation__r.Account__c,';
		recurringDonationQuery += 'Recurring_Donation__r.Credit_Card_Expiry_Date__c, Recurring_Donation__r.Credit_Card__c, Recurring_Donation__r.Credit_Card_Type__c,';
		recurringDonationQuery += 'Recurring_Donation__r.of_Payments__c';
		return recurringDonationQuery;
	}

	public Integer SelectActiveCountBetweenYearsAndEnteredActiveStatus(Date lowerDate, Date upperDate) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Gift_Type__c, Gift__c.Gift_Date__c, Gift__c.Status__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select count() from {0} where Gift_Type__c = \'\'Recurring\'\' AND Gift_Date__c >= :lowerDate and Gift_Date__c < :upperDate AND (Status__c = \'\'Entered\'\' OR Status__c = \'\'Active\'\')',
			new List<String> { GetSObjectName() });
        return Database.countQuery(queryString);
	}

	public Integer SelectActiveCountBetweenYearsAndCompleted(Date lowerDate, Date upperDate) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Gift_Type__c, Gift__c.Gift_Date__c, Gift__c.Status__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select count() from {0} where Gift_Type__c = \'\'Recurring\'\' AND Gift_Date__c >= :lowerDate AND Gift_Date__c < :upperDate AND (Status__c = \'\'Completed\'\')',
			new List<String> { GetSObjectName() });
        return Database.countQuery(queryString);
	}

	public Integer SelectCountYearCurrent(Date transactionDate) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Gift_Type__c, Gift__c.Gift_Date__c, Gift__c.Status__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select count() from {0} where Gift_Type__c = \'\'Recurring\'\' AND Gift_Date__c = :transactionDate AND (Status__c = \'\'Active\'\')',
			new List<String> { GetSObjectName() });
        return Database.countQuery(queryString);
	}

	public List<Gift__c> SelectGiftStatusWhereDonationInIDs(Set<Id> rdIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Status__c };
		IsCustomAccessible(customGiftFieldList);
		IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Recurring_Donation__c });

		String queryString = String.format('select {0} from {1} where Recurring_Donation__c IN :rdIds FOR UPDATE',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftAndRecurringDonationWhereIdInIdsAndCurrentYear(Set<Id> recurringGiftIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Recurring_Donation__c };
		IsCustomAccessible(customGiftFieldList);
		IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Gift_Date__c });

		String queryString = String.format('SELECT {0} FROM {1} WHERE Recurring_Donation__c IN :recurringGiftIds AND Gift_Date__c = THIS_YEAR',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}

	public List<Gift__c> UpdateEventById(Set<Id> giftId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Event_Id__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id IN :giftId FOR UPDATE',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift__c> SelectOrganizationAndConstituentWhereIdInIds(List<Id> giftIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Constituent__c, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('Select {0} From {1} Where Id IN :giftIds',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftAndRecurringDonationWhereIdInIdsAndWithinYearRangs(Set<Id> recurringGiftIds, Date TargetDate, Date TargetNextYear) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Recurring_Donation__c };
		IsCustomAccessible(customGiftFieldList);
		IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Gift_Date__c });

		String queryString = String.format('SELECT {0} FROM {1} WHERE Recurring_Donation__c IN :recurringGiftIds and Gift_Date__c > :TargetDate AND Gift_Date__c < :TargetNextYear',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftAndRecurringDonationThisYear() {
		List<Schema.SObjectField> recurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Start_Date__c, Recurring_Donation__c.Status__c };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Recurring_Donation__c, Gift__c.Status__c, Gift__c.Gift_Date__c };
		IsCustomAccessible(customGiftFieldList);
		new RecurringDonationSelector().IsCustomAccessible(recurringDonationFieldList);

		String queryString = String.format('select {0} from {1} where Gift_Date__c = THIS_YEAR and Status__c != \'\'Active\'\' and Recurring_Donation__c in (select id from Recurring_Donation__c where Start_Date__c = THIS_YEAR AND Status__c = \'\'Active\'\')',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}

	public List<Gift__c> SelectGatewayById(Set<Id> idSet) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Gateway__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}

	public List<Gift__c> SelectGatewayByRecurringGiftId(Set<Id> idSet) {
		return SelectGatewayByRecurringGiftIdAndLimit(idSet, null);
	}

	public List<Gift__c> SelectGatewayByRecurringGiftIdAndLimit(Set<Id> idSet, Integer recordLimit) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Gateway__c, Gift__c.Recurring_Donation__c, Gift__c.CreatedDate };
		IsCustomAccessible(customGiftFieldList);

		String limitString = recordLimit != null ? 'limit ' + recordLimit : '';
		String queryString = String.format('select {0} from {1} where Recurring_Donation__c in :idSet order by CreatedDate Desc {2}',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName(), limitString });
	    return Database.query(queryString);
	}

	public AggregateResult[] SelectMaxMinAvgByOrganizationAndRecordType(set<Id> orgIds, string recordId, Set<Id> recordIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Organization__c, Gift__c.RecordTypeId };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT AVG(Amount__c) avgGiftAmt, MAX(Amount__c) maxGiftAmt, MIN(Gift_Date__c) minGiftDate, MAX(Gift_Date__c) maxGiftDate, Organization__c org FROM {0} WHERE Organization__c IN :orgIds AND Gift_Date__c != null AND (RecordTypeId = :recordId OR RecordTypeId In :recordIds) GROUP BY Organization__c',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectSumLastYearByOrganizationAndRecordType(set<Id> orgIds, string recordId, Set<Id> recordIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Organization__c, Gift__c.RecordTypeId };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT SUM(Amount__c) total, Organization__c org FROM {0} WHERE Organization__c IN :orgIds AND Gift_Date__c = LAST_YEAR AND (RecordTypeId = :recordId OR RecordTypeId In :recordIds) GROUP BY Organization__c',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectSumLastTwoYearsByOrganizationAndRecordType(set<Id> orgIds, Date dateStart, Date dateEnd, string recordId, Set<Id> recordIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Organization__c, Gift__c.RecordTypeId };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT SUM(Amount__c) total, Organization__c org FROM {0} WHERE Organization__c IN :orgIds AND Gift_Date__c >= :dateStart AND Gift_Date__c <= :dateEnd AND (RecordTypeId = :recordId OR RecordTypeId In :recordIds) GROUP BY Organization__c',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectMaxMinAvgByConstituentAndRecordType(set<Id> contactIds, string recordId, Set<Id> recordIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Constituent__c, Gift__c.RecordTypeId };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT AVG(Amount__c) avgGiftAmt, MAX(Amount__c) maxGiftAmt, MIN(Gift_Date__c) minGiftDate, MAX(Gift_Date__c) maxGiftDate, Constituent__c con FROM {0} WHERE Constituent__c IN :contactIds AND Gift_Date__c != null AND (RecordTypeId = :recordId OR RecordTypeId In :recordIds) GROUP BY Constituent__c',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectSumLastYearByConstituentAndRecordType(set<Id> contactIds, string recordId, Set<Id> recordIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Constituent__c, Gift__c.RecordTypeId };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT SUM(Amount__c) total, Constituent__c con FROM {0} WHERE Constituent__c IN :contactIds AND Gift_Date__c = LAST_YEAR AND (RecordTypeId = :recordId OR RecordTypeId In :recordIds) GROUP BY Constituent__c',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectSumLastTwoYearsByConstituentAndRecordType(set<Id> contactIds, Date dateStart, Date dateEnd, string recordId, Set<Id> recordIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Constituent__c, Gift__c.RecordTypeId };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT SUM(Amount__c) total, Constituent__c con FROM {0} WHERE Constituent__c IN :contactIds AND Gift_Date__c >= :dateStart AND Gift_Date__c <= :dateEnd AND (RecordTypeId = :recordId OR RecordTypeId In :recordIds) GROUP BY Constituent__c',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectGatewayByRecurringDonationId(String recurringDonationId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Gateway__c, Gift__c.Recurring_Donation__c, Gift__c.CreatedDate };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('Select {0} From {1} where Recurring_Donation__c = :recurringDonationId order by CreatedDate Desc',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift__c> SelectDonationStatusWhereIdInIdsAndDonationNotNull(Set<Id> transactionIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Recurring_Donation__c, Gift__c.Status__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select {0} from {1} where Id IN: transactionIds AND Recurring_Donation__c != null',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}


	public Database.QueryLocator SelectGiftIdByPaymentIdAndStatus() {
        List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Id};
        IsCustomAccessible(customGiftFieldList);

        new ReceiptSelector().IsCustomAccessible(new List<Schema.SObjectField> { Receipt__c.Id, Receipt__c.Status__c });
        new PaymentSelector().IsCustomAccessible(new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Donation__c, Payment__c.Status__c, Payment__c.Receipt__c });
        String queryString = String.format('Select {0}, (Select Id, Receipt__c, Status__c From Recurring_Payments__r Where Receipt__c = null AND Status__c = \'\'Approved\'\'), (Select Id From Receipts__r Where Status__c != \'\'Void\'\') From {1} Where Id IN (Select Donation__c From Payment__c Where Receipt__c = null AND Status__c = \'\'Approved\'\')',

            new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
                return Database.getQueryLocator(queryString);
    }

    public List<Gift__c> SelectGuestRegistrationWhereIdInIds(Set<Gift__c> giftIds) {
        List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Id, Gift__c.Attendee_Names_Pending__c, Gift__c.Constituent__c};
        IsCustomAccessible(customGiftFieldList);

        new EventRegistrationSelector().IsCustomAccessible(new List<Schema.SObjectField> { Event_Registration__c.Id, Event_Registration__c.Registration_Date__c, Event_Registration__c.Event__c, Event_Registration__c.Transaction__c, Event_Registration__c.Individual__c });
        String queryString = String.format('SELECT {0}, (SELECT Id, Registration_Date__c, Event__c, Transaction__c FROM Event_Registrations__r WHERE Individual__c != \'\'\'\') FROM {1} WHERE Id IN :giftIds',

            new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
                return Database.query(queryString);
    }

    public List<Gift__c> SelectRecurringGiftPaymentsById(Set<Id> giftIds) {
        List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Id, Gift__c.Credit_Card_Number__c, Gift__c.Credit_Card_Type__c};
        IsCustomAccessible(customGiftFieldList);

        new PaymentSelector().IsCustomAccessible(new List<Schema.SObjectField> { Payment__c.Credit_Card_Number__c, Payment__c.Credit_Card_Type__c, Payment__c.Donation__c, Payment__c.Payment_Type__c, Payment__c.CreatedDate });

        String recurringPaymentsQuery = 'SELECT Credit_Card_Number__c, Credit_Card_Type__c, Donation__c  FROM Recurring_Payments__r  WHERE Payment_Type__c = \'Credit Card\' ORDER BY CreatedDate DESC NULLS Last Limit 1';
        String queryString = String.format('SELECT  {0}, ({1}) FROM {2} WHERE ID IN :giftIds FOR UPDATE',

            new List<String> { GetFieldListString(customGiftFieldList), recurringPaymentsQuery, GetSObjectName() });
                return Database.query(queryString);
    }

    public List<Gift__c> SelectRecurringDonationAmountById(Set<Id> idSet) {
        List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Id, Gift__c.Expected_Amount__c, Gift__c.Status__c, Gift__c.Recurring_Donation__c};
        IsCustomAccessible(customGiftFieldList);

        new RecurringDonationSelector().IsCustomAccessible(new List<Schema.SObjectField> { Recurring_Donation__c.Amount__c });

        String queryString = String.format('SELECT {0}, Recurring_Donation__r.Amount__c FROM {1} WHERE Recurring_Donation__c IN :idSet AND Status__c = \'\'Active\'\'',

            new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
                return Database.query(queryString);
    }

    public List<Gift__c> SelectRecurringDonationAmountByIdForUpdate(Set<Id> idSet) {
        List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Id, Gift__c.Expected_Amount__c, Gift__c.Status__c, Gift__c.Recurring_Donation__c};
        IsCustomAccessible(customGiftFieldList);

        new RecurringDonationSelector().IsCustomAccessible(new List<Schema.SObjectField> { Recurring_Donation__c.Amount__c });

        String queryString = String.format('SELECT {0}, Recurring_Donation__r.Amount__c FROM {1} WHERE Recurring_Donation__c IN :idSet AND Status__c = \'\'Active\'\' FOR UPDATE',

            new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
    }

    public List<Gift__c> SelectAllocationByTransactionId(String setId) {
        List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Id, Gift__c.Amount__c };
        IsCustomAccessible(customGiftFieldList);

        new AllocationSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift_Detail__c.Name, Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.Amount__c, Gift_Detail__c.Appeal_Name__c,
        	Gift_Detail__c.Approved_Amount__c, Gift_Detail__c.Campaign__c, Gift_Detail__c.Constituent__c, Gift_Detail__c.Description__c, Gift_Detail__c.Fund_Name__c, Gift_Detail__c.Fund__c, Gift_Detail__c.Gift__c,
        	Gift_Detail__c.Organization__c, Gift_Detail__c.Payment__c, Gift_Detail__c.Percent_Allocation__c, Gift_Detail__c.Product__c, Gift_Detail__c.Tribute__c, Gift_Detail__c.Gift_Type__c,
        	Gift_Detail__c.New_Campaign__c, Gift_Detail__c.Parent_Appeal__c, Gift_Detail__c.Custom_Allocation_Text__c, Gift_Detail__c.Posted_to_Finance__c, Gift_Detail__c.Package__c, Gift_Detail__c.GL_Code__c,
        	Gift_Detail__c.GL_Debit_Account__c, Gift_Detail__c.GL_Credit_Account__c });

        String allocationQuery = 'Select Name, Allocation_Date__c, Amount__c, Appeal_Name__c, Approved_Amount__c, Campaign__c, Constituent__c, Description__c, Fund_Name__c, Fund__c, Gift__c, Organization__c, Payment__c, Percent_Allocation__c, Product__c, Tribute__c, Gift_Type__c, New_Campaign__c, Parent_Appeal__c, Custom_Allocation_Text__c, Posted_to_Finance__c, Package__c, GL_Code__c, GL_Debit_Account__c, GL_Credit_Account__c From Gift_Allocations__r';
        String queryString = String.format('Select {0}, ({1}) From {2} where Id = :setId',

            new List<String> { GetFieldListString(customGiftFieldList), allocationQuery, GetSObjectName() });
                return Database.query(queryString);
    }

	public List<Gift__c> SelectByAccountIdAndConvert(Set<Id> idSet) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id, Gift__c.Amount__c, Gift__c.Status__c, Gift__c.Gift_Date__c, Gift__c.RecordTypeId, RecordType.Name, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select Id, convertCurrency(Amount__c), Status__c, Gift_Date__c, RecordTypeId, RecordType.Name, Organization__c from {0} where Organization__c in :idSet ORDER BY Gift_Date__c DESC, CreatedDate DESC',
			new List<String> { GetSObjectName() });
	    return Database.query(queryString);
	}

	public List<AggregateResult> SelectAccountPaymentSummary(Set<Id> orgIds, List<string> recordTypeIdsforRollup, Id rId, string bucketAccount) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select AVG(Amount__c)avgGiftAmt, MAX(Amount__c)maxGiftAmt, MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Organization__c org from {0} where Organization__c IN :orgIds AND Gift_Date__c != null  AND  (RecordTypeId In :recordTypeIdsforRollup OR RecordTypeId = :rId) AND Organization__c <> :bucketAccount GROUP BY Organization__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectGiftDateSummary(Set<Id> orgIds, string bucketAccount) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Gift_Date__c, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Organization__c org from {0} where Organization__c IN :orgIds AND Gift_Date__c != null AND Organization__c <> :bucketAccount GROUP BY Organization__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectPaymentTotal(Set<Id> orgIds, Id rId, List<string> recordTypeIdsforRollup, string bucketAccount) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select SUM(Amount__c) total, Organization__c org from {0} where Organization__c IN :orgIds AND Gift_Date__c = LAST_YEAR AND  (RecordTypeId = :rId OR RecordTypeId In :recordTypeIdsforRollup) AND Organization__c <> :bucketAccount GROUP BY Organization__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectPaymentTotalWithDateRange(Set<Id> orgIds, Id rId, List<string> recordTypeIdsforRollup, string bucketAccount, date dateStart, date dateEnd) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Organization__c };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select SUM(Amount__c) total, Organization__c org from {0} where Organization__c IN :orgIds AND Gift_Date__c >= :dateStart AND Gift_Date__c <= :dateEnd AND (RecordTypeId = :rId OR RecordTypeId In :recordTypeIdsforRollup) AND Organization__c <> :bucketAccount GROUP BY Organization__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public Database.Querylocator LocateGiftAndPayments() {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Id };
		IsCustomAccessible(customGiftFieldList);

		new PaymentSelector().IsCustomAccessible(new List<Schema.SObjectField> { Payment__c.Id, Payment__c.Receipt__c, Payment__c.Status__c, Payment__c.Donation__c });
		new ReceiptSelector().IsCustomAccessible(new List<Schema.SObjectField> { Receipt__c.Id, Receipt__c.Status__c });

		String subQuery1 = '(Select Id, Receipt__c, Status__c From Recurring_Payments__r Where Receipt__c = null AND Status__c = \'Approved\')';
		String subQuery2 = '(Select Id From Receipts__r Where Status__c != \'Void\')';
		String whereSubQuery = '(Select Donation__c From Payment__c Where Receipt__c = null AND Status__c = \'Approved\')';

		String queryString = String.format('select {0}, {1}, {2} from {3} Where Id IN {4}',
			new List<String> { GetFieldListString(customGiftFieldList), subQuery1, subQuery2, GetSObjectName(), whereSubQuery });
			return Database.getQueryLocator(queryString);
	}

	public Database.Querylocator LocateGiftDetails() {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Channel__c, Gift__c.Constituent__c, Gift__c.Gift_Date__c, Gift__c.Gift_Type__c, Gift__c.Last_Payment_Date__c, Gift__c.Recurring_Donation__c, Gift__c.Reference__c };
		IsCustomAccessible(customGiftFieldList);

		new RecurringDonationSelector().IsCustomAccessible(new List<Schema.SObjectField> {  Recurring_Donation__c.Reference__c, Recurring_Donation__c.Constituent__c });

		String queryString = String.format('select {0}, Recurring_Donation__r.Reference__c, Recurring_Donation__r.Constituent__c from {1} WHERE Gift_Date__c = LAST_YEAR AND Gift_Type__c = \'Recurring\'',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
			return Database.getQueryLocator(queryString);
	}

	public Database.Querylocator LocateActiveRecurringGift() {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Id, Gift__c.Gift_Type__c};
		IsCustomAccessible(customGiftFieldList);
		IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Status__c});

		new RecurringDonationSelector().IsCustomAccessible(new List<Schema.SObjectField> {  Recurring_Donation__c.Reference__c, Recurring_Donation__c.Amount__c, Recurring_Donation__c.Type__c, Recurring_Donation__c.Next_Payment_Date__c });

		String queryString = String.format('select {0}, Recurring_Donation__r.Reference__c, Recurring_Donation__r.Amount__c from {1} WHERE Gift_Type__c =\'Recurring\' AND Status__c=\'Active\' AND Recurring_Donation__r.Type__c = \'Credit Card\' AND Recurring_Donation__r.Next_Payment_Date__c = TODAY',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
			return Database.getQueryLocator(queryString);
	}

	public List<AggregateResult> SelectConstituentByLastTimeRun(Datetime lastTimeRun, Set<Id> alreadyUpdatedContacts) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Constituent__c, Gift__c.LastModifiedDate, Gift__c.IsDeleted, Gift__c.SystemModStamp};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('select Constituent__c from {0} WHERE (LastModifiedDate > :lastTimeRun OR (IsDeleted = True AND SystemModStamp > :lastTimeRun)) AND Constituent__c NOT IN :alreadyUpdatedContacts GROUP BY Constituent__c LIMIT 1000 ALL ROWS',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectConstituentById(Set<Id> contactsetids, List<String> recordTypesToRollup, Id recordTypeId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Constituent__c, Gift__c.Gift_Date__c, Gift__c.IsDeleted, Gift__c.RecordTypeId};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT Constituent__c con FROM {0} WHERE Constituent__c IN :contactsetids AND Gift_Date__c != null AND IsDeleted = true AND (RecordTypeId In :recordTypesToRollup OR RecordTypeId=\':recordTypeId\') GROUP BY Constituent__c ALL ROWS',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Gift__c> SelectLetterByGiftId(Set<Id> giftId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Id};
		IsCustomAccessible(customGiftFieldList);

		List<Schema.SObjectField> customLetterFieldList = new List<Schema.SObjectField> {Letter__c.Introduction_Text_Block_Rich_Text__c, Letter__c.Text_Block__c, Letter__c.Email_Subject__c, Letter__c.Signature_Rich_Text__c, Letter__c.Custom_Rich_Text_1__c, Letter__c.Custom_Rich_Text_2__c, Letter__c.Custom_Rich_Text_3__c };
		new LetterSelector().IsCustomAccessible(customLetterFieldList);

		String queryString = String.format('Select {0}, Letter__r.Introduction_Text_Block_Rich_Text__c, Letter__r.Text_Block__c, Letter__r.Email_Subject__c, Letter__r.Signature_Rich_Text__c, Letter__r.Custom_Rich_Text_1__c, Letter__r.Custom_Rich_Text_2__c, Letter__r.Custom_Rich_Text_3__c FROM {1} WHERE Id in :giftId',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftSummaryByContactId(Id contactId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Name, Gift__c.Constituent__c , Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Gift_Type__c, Gift__c.Expected_Amount__c, Gift__c.CreatedDate};
		IsCustomAccessible(customGiftFieldList);

		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> { RecordType.Name });
		new ContactSelector().IsCustomAccessible(new List<Schema.SObjectField> { Contact.Name });
		new AllocationSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift_Detail__c.Approved_Amount__c, Gift_Detail__c.New_Campaign__c });
		new CampaignSelector().IsCustomAccessible(new List<Schema.SObjectField> { Campaign.Name });

		String queryString = String.format('SELECT {0}, RecordType.Name, Constituent__r.Name, (SELECT Approved_Amount__c, New_Campaign__c, New_Campaign__r.Name FROM Gift_Allocations__r ORDER BY Approved_Amount__c DESC NULLS LAST, New_Campaign__r.Name) from Gift__c where Constituent__c =:contactId and Amount__c > 0 order by CreatedDate DESC limit 5',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftAndCampaignInfoByContactId(Id contactId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Name, Gift__c.Organization__c, Gift__c.Amount__c, Gift__c.Gift_Date__c, Gift__c.Gift_Type__c, Gift__c.Expected_Amount__c, Gift__c.CreatedDate};
		IsCustomAccessible(customGiftFieldList);

		new AccountSelector().IsCustomAccessible(new List<Schema.SObjectField> { Account.Name });
		new AllocationSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift_Detail__c.Approved_Amount__c, Gift_Detail__c.New_Campaign__c });


		String queryString = String.format('SELECT {0}, Organization__r.Name, (SELECT Approved_Amount__c, New_Campaign__c, New_Campaign__r.Name FROM Gift_Allocations__r ORDER BY Approved_Amount__c DESC NULLS LAST, New_Campaign__r.Name) from {1} where Organization__c = \':contactId\' and Amount__c > 0 order by CreatedDate DESC  limit 5',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftInfoAndConvert(Set<Id> contactIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Amount__c, Gift__c.Total_Gift_Amount__c, Gift__c.Status__c, Gift__c.HouseholdId__c, Gift__c.Gift_Date__c, Gift__c.RecordTypeId, Gift__c.Constituent__c, Gift__c.Primary_Solicitor__c, Gift__c.CreatedDate};
		IsCustomAccessible(customGiftFieldList);

		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> { RecordType.Name });

		String queryString = String.format('Select Id, convertCurrency(Amount__c), convertCurrency(Total_Gift_Amount__c), Status__c,HouseholdId__c, Gift_Date__c, RecordType.Name, RecordTypeId,Constituent__c,Primary_Solicitor__c From {0} where Constituent__c IN :contactIds AND Amount__c > 0 ORDER BY Gift_Date__c DESC,CreatedDate DESC',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<Gift__c> SelectGiftInfoNoConvert(Set<Id> contactIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Amount__c, Gift__c.Total_Gift_Amount__c, Gift__c.Status__c, Gift__c.HouseholdId__c, Gift__c.Gift_Date__c, Gift__c.RecordTypeId, Gift__c.Constituent__c, Gift__c.Primary_Solicitor__c, Gift__c.CreatedDate};
		IsCustomAccessible(customGiftFieldList);

		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> { RecordType.Name });

		String queryString = String.format('Select Id,HouseholdId__c, Amount__c, Total_Gift_Amount__c, Status__c, Gift_Date__c,RecordType.Name, RecordTypeId, Constituent__c,Primary_Solicitor__c From Gift__c where Constituent__c IN :contactIds AND Amount__c > 0 ORDER BY Gift_Date__c DESC,CreatedDate DESC',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectTotalGiftAmount(Set<Id> contactIds, List<String> recordTypesToRollup, String transactionRecordTypeId, Date last2_year_start, Date last2_year_end) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Total_Gift_Amount__c, Gift__c.Constituent__c, Gift__c.Gift_Date__c, Gift__c.Amount__c, Gift__c.RecordTypeId};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT SUM(Total_Gift_Amount__c) total, Constituent__c con FROM {0} WHERE Constituent__c IN :contactIds AND Gift_Date__c >= :last2_year_start AND Gift_Date__c <= :last2_year_end AND Amount__c > 0  AND (RecordTypeId = :transactionRecordTypeId OR RecordTypeId In :recordTypesToRollup ) GROUP BY Constituent__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectTotalGiftAmountSOQLDate(Set<Id> contactIds, List<String> recordTypesToRollup, String transactionRecordTypeId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Total_Gift_Amount__c, Gift__c.Constituent__c, Gift__c.Gift_Date__c, Gift__c.Amount__c, Gift__c.RecordTypeId};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT SUM(Total_Gift_Amount__c) total, Constituent__c con FROM {0} WHERE Constituent__c IN :contactIds AND Gift_Date__c <= LAST_YEAR AND Amount__c > 0  AND (RecordTypeId =\':transactionRecordTypeId\' OR RecordTypeId In :recordTypesToRollup ) GROUP BY Constituent__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectMaxGiftAmount(Set<Id> contactIds, List<String> recordTypesToRollup, String transactionRecordTypeId, Date thisYearStart, Date thisYearEnd) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Total_Gift_Amount__c, Gift__c.Constituent__c, Gift__c.Gift_Date__c, Gift__c.Amount__c, Gift__c.RecordTypeId};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT MAX(Total_Gift_Amount__c) largestGift, Constituent__c con FROM {0} WHERE Constituent__c IN :contactIds AND Gift_Date__c >= :thisYearStart AND Gift_Date__c <= :thisYearEnd AND Amount__c > 0  AND (RecordTypeId = :transactionRecordTypeId OR RecordTypeId In :recordTypesToRollup ) GROUP BY Constituent__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectGiftAmountSummary(Set<Id> contactIds, List<String> recordTypesToRollup, Id recordTypeId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {Gift__c.Total_Gift_Amount__c, Gift__c.Constituent__c, Gift__c.Gift_Date__c, Gift__c.Amount__c, Gift__c.RecordTypeId};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT AVG(Total_Gift_Amount__c)avgGiftAmt, MAX(Total_Gift_Amount__c)maxGiftAmt, MIN(Gift_Date__c) minGiftDate,  MAX(Gift_Date__c) maxGiftDate, Constituent__c con FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c != null AND Amount__c > 0  AND (RecordTypeId In :recordTypesToRollup OR RecordTypeId =\':recordTypeId\') GROUP BY Constituent__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public List<AggregateResult> SelectMinAndMaxGiftDate(Set<Id> contactIds) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Constituent__c, Gift__c.Gift_Date__c, Gift__c.Amount__c};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT MIN(Gift_Date__c) minGiftDate, MAX(Gift_Date__c) maxGiftDate, Constituent__c con FROM Gift__c WHERE Constituent__c IN :contactIds AND Gift_Date__c != null AND Amount__c > 0 GROUP BY Constituent__c',
			new List<String> { GetSObjectName() });
			return Database.query(queryString);
	}

	public String QueyrStringForRollUpConsecutive(Set<String> cid1) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Amount__c, Gift__c.Status__c, Gift__c.Gift_Date__c, Gift__c.Constituent__c, Gift__c.RecordTypeId};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('Select {0} From {1} where Constituent__c IN :cid1 ORDER BY Gift_Date__c DESC',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
			return queryString;
	}
}