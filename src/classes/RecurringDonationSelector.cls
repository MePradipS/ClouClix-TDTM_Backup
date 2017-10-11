public with sharing class RecurringDonationSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Frequency__c, Recurring_Donation__c.of_Payments__c, Recurring_Donation__c.Start_Date__c,
			Recurring_Donation__c.Constituent__c, Recurring_Donation__c.Credit_Card_Expiry_Date__c, Recurring_Donation__c.Status__c,
			Recurring_Donation__c.Amount__c, Recurring_Donation__c.Reference__c, Recurring_Donation__c.URL_Safe_Key__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Recurring_Donation__c.sObjectType;
	}

	public List<Recurring_Donation__c> SelectIdNameReferenceTypeById(String recurringGiftId) {
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Name, Recurring_Donation__c.Reference__c, Recurring_Donation__c.Type__c };
		IsCustomAccessible(customRecurringDonationFieldList);
		new ContactSelector().IsCustomAccessible(new List<Schema.SObjectField> { Contact.Id });

		String queryString = String.format('select {0}, Constituent__r.Id from {1} where Id = :recurringGiftId',
			new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Recurring_Donation__c> SelectIdNameReferenceTypeById(Set<Id> idSet) {
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> { Recurring_Donation__c.Id, Recurring_Donation__c.Name };
		IsCustomAccessible(customRecurringDonationFieldList);
		new RDAllocationSelector().IsAccessible();

		String queryString = String.format('select {0}, (select Name from Recurring_Gift_Allocations__r) from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectActiveNumberOfConstituents(Date startDate, String status) {
		return SelectActiveNumberOfConstituentsByStartDateStatusAndAmount(startDate, status, null);
	}

	public AggregateResult[] SelectActiveNumberOfConstituentsByStartDateStatusAndAmount(Date startDate, String status, Decimal amount) {
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Contact.Id };
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Start_Date__c, Recurring_Donation__c.Status__c, Recurring_Donation__c.Amount__c };
		IsCustomAccessible(customRecurringDonationFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);

		String amountQuery = (amount == null) ? '' : (' and Amount__c > ' + amount);
		String queryString = String.format('select COUNT_DISTINCT(Constituent__r.Id)donorCount from {0} where Start_Date__c <= :startDate and Status__c = :status {1}',
			new List<String> { GetSObjectName(), amountQuery });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectActiveNumberOfConstituentsWithinMonth(Date currentMonthStartDate, Date nextMonthStartDate, String status) {
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Contact.Id };
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Start_Date__c, Recurring_Donation__c.Status__c };
		IsCustomAccessible(customRecurringDonationFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);

		String queryString = String.format('select COUNT_DISTINCT(Constituent__r.Id)donorCount from {0} where (Start_Date__c >= :currentMonthStartDate AND Start_Date__c < :nextMonthStartDate) and Status__c = :status',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectTotalAmountByStartDate(Date startDate, String status) {
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Start_Date__c, Recurring_Donation__c.Status__c, Recurring_Donation__c.Amount__c };
		IsCustomAccessible(customRecurringDonationFieldList);

		String queryString = String.format('select COUNT_DISTINCT(Amount__c)sum from {0} where Start_Date__c <= :startDate and Status__c = :status',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectTotalAmountWithinMonth(Date currentMonthStartDate, Date nextMonthStartDate, String status) {
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Start_Date__c, Recurring_Donation__c.Status__c, Recurring_Donation__c.Amount__c };
		IsCustomAccessible(customRecurringDonationFieldList);

		String queryString = String.format('select COUNT_DISTINCT(Amount__c)sum from {0} where (Start_Date__c >= :currentMonthStartDate AND Start_Date__c < :nextMonthStartDate) and Status__c = :status',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Recurring_Donation__c> SelectIdAndRecurringGiftAllocations(Set<Id> idSet) {
		List<Schema.SObjectField> rdAllocationFieldList = new List<Schema.SObjectField> {
			RD_Allocation__c.Id, RD_Allocation__c.Name, RD_Allocation__c.Recurring_Gift__c, RD_Allocation__c.Active__c,
			RD_Allocation__c.Campaign__c, RD_Allocation__c.Fund__c, RD_Allocation__c.Amount__c, RD_Allocation__c.New_Campaign__c,
			RD_Allocation__c.Custom_Allocation_Text__c, RD_Allocation__c.Package__c };
		List<Schema.SObjectField> recurringDonationFieldList = new List<Schema.SObjectField> { Recurring_Donation__c.Id };

		IsCustomAccessible(recurringDonationFieldList);
		new RDAllocationSelector().IsCustomAccessible(rdAllocationFieldList);

		String rdAllocationQuery = '(Select Id, Name, Recurring_Gift__c, Active__c, Campaign__c, Fund__c, Amount__c, New_Campaign__c, Custom_Allocation_Text__c, Package__c From Recurring_Gift_Allocations__r WHERE Active__c = true)';
		String queryString = String.format('select {0}, {1} from {2} where Id in :idSet',
			new List<String> { GetFieldListString(recurringDonationFieldList), rdAllocationQuery, GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Recurring_Donation__c> SelectActiveDonationById(Set<Id> RdIds) {
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.id, Recurring_Donation__c.Name, Recurring_Donation__c.Status__c, Recurring_Donation__c.Frequency__c, Recurring_Donation__c.New_Payment_Start_Date__c,
			Recurring_Donation__c.Next_Payment_Date__c , Recurring_Donation__c.Schedule_Date__c, Recurring_Donation__c.Start_Date__c};
		IsCustomAccessible(customRecurringDonationFieldList);

		String queryString = String.format('SELECT {0} FROM {1} where Id IN :RdIds and Status__c =\'\'Active\'\'',
			new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Recurring_Donation__c> SelectStatusAndTransactionsById(List<Recurring_Donation__c> recurringDonations, Date giftDate) {
		List<Schema.SObjectField> transactionFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Name, Gift__c.Status__c, Gift__c.Gift_Date__c };
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.id, Recurring_Donation__c.name, Recurring_Donation__c.Status__c };
		IsCustomAccessible(customRecurringDonationFieldList);
		new GiftSelector().IsCustomAccessible(transactionFieldList);

		String queryString = String.format('select {0}, (select id, name,  Status__c, Gift_Date__c from Orders__r WHERE Gift_Date__c >= :giftDate) from {1} where Id in :recurringDonations',
			new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Recurring_Donation__c> SelectPaymentGatewayAndFrequencyAndContactsByRecurringDonationId(Set<Id> idSet) {
		List<Schema.SObjectField> giftFieldList = new List<Schema.SObjectField> {
			Gift__c.Id, Gift__c.Name, Gift__c.Gateway__c, Gift__c.Createddate };
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> {
			Contact.FirstName, Contact.LastName, Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState,
			Contact.MailingStreet, Contact.Email, Contact.Phone };
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Name, Recurring_Donation__c.sysMergeAmountPaymentGateway__c,
			Recurring_Donation__c.Frequency__c, Recurring_Donation__c.Constituent__c };

		IsCustomAccessible(customRecurringDonationFieldList);
		new GiftSelector().IsCustomAccessible(giftFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);

		String contactQueryString = 'Constituent__r.FirstName, Constituent__r.LastName, Constituent__r.MailingCity, Constituent__r.MailingCountry, Constituent__r.MailingPostalCode, Constituent__r.MailingState, Constituent__r.MailingStreet, Constituent__r.Email, Constituent__r.Phone';
		String queryString = String.format('select {0}, {1}, (Select Id, Name, Gateway__c from Orders__r order by Createddate Desc Limit 1) from {2} where Id in :idSet',
			new List<String> { GetFieldListString(customRecurringDonationFieldList), contactQueryString, GetSObjectName() });
		return Database.query(queryString);
	}

	public List<Recurring_Donation__c> SelectFrequencyAndStatusById(Set<Id> idSet) {
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Frequency__c, Recurring_Donation__c.Status__c };
		IsCustomAccessible(customRecurringDonationFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
		return Database.query(queryString);
	}

	public List<Recurring_Donation__c> SelectRecurringGiftWhereIdInIds(Set<Id> idSet) {
        List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {Recurring_Donation__c.Id, Recurring_Donation__c.Approved_Payments__c,
        	Recurring_Donation__c.Consecutive_Declined_Payments__c, Recurring_Donation__c.Declined_Payments__c };
        IsCustomAccessible(customRecurringDonationFieldList);

        new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> { Gift__c.Status__c, Gift__c.Recurring_Donation__c });
        String queryString = String.format('select {0}, (select Status__c,Recurring_Donation__c  from Orders__r ) from {1} where Id IN :idSet FOR UPDATE',
            new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
                return Database.query(queryString);
    }

    public List<Recurring_Donation__c> SelectAllocationOfRecurringGiftWhereIdInIds(Set<Id> idSet) {
        List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {Recurring_Donation__c.Id };
        IsCustomAccessible(customRecurringDonationFieldList);

        new RDAllocationSelector().IsCustomAccessible(new List<Schema.SObjectField> { RD_Allocation__c.Id, RD_Allocation__c.Name, RD_Allocation__c.Recurring_Gift__c, RD_Allocation__c.Active__c,
        	RD_Allocation__c.Campaign__c, RD_Allocation__c.Fund__c, RD_Allocation__c.Amount__c, RD_Allocation__c.New_Campaign__c, RD_Allocation__c.Custom_Allocation_Text__c, RD_Allocation__c.Package__c });
        String queryString = String.format('Select {0}, (Select Id, Name, Recurring_Gift__c, Active__c, Campaign__c, Fund__c, Amount__c, New_Campaign__c, Custom_Allocation_Text__c, Package__c From Recurring_Gift_Allocations__r WHERE Active__c=true) From {1} WHERE Id IN :idSet',
            new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
                return Database.query(queryString);
    }

	public Database.QueryLocator LocateRecurringDonationGiftInfo() {
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {Recurring_Donation__c.Id};
		IsCustomAccessible(customRecurringDonationFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField> {Gift__c.Gift_Date__c, Gift__c.Gift_Type__c, Gift__c.Reference__c, Gift__c.Status__c, Gift__c.Constituent__c, Gift__c.Organization__c});

		String queryString = String.format('select {0}, (SELECT Gift_Date__c, Gift_Type__c, Reference__c, Status__c, Constituent__c, Organization__c from Orders__r) from {1}',
			new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
		return Database.getQueryLocator(queryString);
	}

	public List<Recurring_Donation__c> SelectDonationByRecurringId(id recurringGiftId) {
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Reference__c, Recurring_Donation__c.Type__c, Recurring_Donation__c.Sort_Code__c, Recurring_Donation__c.Account__c,
			Recurring_Donation__c.Status__c, Recurring_Donation__c.Start_Date__c, Recurring_Donation__c.End_Date__c, Recurring_Donation__c.Amount__c, Recurring_Donation__c.Schedule_Date__c,
			Recurring_Donation__c.Credit_Card_Expiry_Date__c, Recurring_Donation__c.Credit_Card_Type__c, Recurring_Donation__c.Credit_Card__c, Recurring_Donation__c.Frequency__c, Recurring_Donation__c.Cancellation_Reason__c,
			Recurring_Donation__c.Next_Payment_Date__c, Recurring_Donation__c.New_Payment_Start_Date__c, Recurring_Donation__c.Branch_Num__c, Recurring_Donation__c.Declined_Payments__c, Recurring_Donation__c.Id, Recurring_Donation__c.Name };
		IsCustomAccessible(customRecurringDonationFieldList);

		new ContactSelector().IsCustomAccessible(new List<Schema.SObjectField> {Contact.Id});

		String queryString = String.format('select {0}, Constituent__r.Id from {1} where id = :recurringGiftId',
			new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<AggregateResult> SelectByActiveRecordAndContactId(Set<Id> Contactsetids){
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Constituent__c,Recurring_Donation__c.Status__c };
		IsCustomAccessible(customRecurringDonationFieldList);

			String soql = String.format('SELECT Constituent__c con FROM {0} WHERE Constituent__c IN :Contactsetids AND Status__c = \'\'Active\'\' GROUP BY Constituent__c',
				new List<String> { GetSObjectName() });
					return Database.query(soql);
	}

	public List<Recurring_Donation__c> SelectEncryptedKey(id recurringGiftId) {
		List<Schema.SObjectField> customRecurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Id, Recurring_Donation__c.Name, Recurring_Donation__c.Name_on_Card__c, Recurring_Donation__c.Reference__c, 
			Recurring_Donation__c.Type__c, Recurring_Donation__c.Status__c, Recurring_Donation__c.Encrypted_Key__c };
		IsCustomAccessible(customRecurringDonationFieldList);

		String queryString = String.format('select {0} from {1} where id = :recurringGiftId',
			new List<String> { GetFieldListString(customRecurringDonationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}
}