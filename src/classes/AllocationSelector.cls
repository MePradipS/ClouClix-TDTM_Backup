// API Name: Gift_Detail__cSelector
public with sharing class AllocationSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.Amount__c, Gift_Detail__c.Approved_Amount__c,
			Gift_Detail__c.Campaign__c, Gift_Detail__c.Custom_Allocation_Text__c, Gift_Detail__c.Event_Level__c,
			Gift_Detail__c.Fund__c, Gift_Detail__c.Gift__c, Gift_Detail__c.GL_Auto_Debit_Account__c,
			Gift_Detail__c.GL_Auto_Credit_Account__c, Gift_Detail__c.New_Campaign__c, Gift_Detail__c.Package__c,
			Gift_Detail__c.Parent_Appeal__c, Gift_Detail__c.Payment__c, Gift_Detail__c.Product__c, Gift_Detail__c.Quantity__c,
			Gift_Detail__c.Tribute__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Gift_Detail__c.sObjectType;
	}

	public List<Gift_Detail__c> SelectByNewCampaign(Set<Id> idSet) {
		List<Schema.SObjectField> relatedFieldsList = new List<Schema.SObjectField> { Gift__c.Recurring_Donation__c, Gift__c.Gift_Type__c };
		List<String> relatedFieldsStringList = new List<String> { 'Gift__r.Recurring_Donation__c', 'Gift__r.Gift_Type__c' };
		List<Schema.SObjectField> customSObjectFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Gift__c, Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.Approved_Amount__c, Gift_Detail__c.New_Campaign__c };
		IsCustomAccessible(customSObjectFieldList);
		IsRelatedSObjectAccessible(new GiftSelector().GetSObjectType(), relatedFieldsList);

		String queryString = String.format('select {0},{1} from {2} where New_Campaign__c in :idSet for update',
			new List<String> { GetFieldListString(customSObjectFieldList), GetRelatedFieldListString(relatedFieldsStringList), GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectSumAmountAndMonthByIdAndCurrentYearByCampaignId(String campaignId) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Amount__c, Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.Campaign__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select SUM(Amount__c) total, CALENDAR_MONTH(Allocation_Date__c) month from {0} where Campaign__c = :campaignId and Allocation_Date__c = THIS_YEAR group by CALENDAR_MONTH(Allocation_Date__c) order by CALENDAR_MONTH(Allocation_Date__c)',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectSumAmountAndMonthByIdAndCurrentYearByNewCampaignId(String campaignId) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Amount__c, Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.Campaign__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select SUM(Amount__c) total, CALENDAR_MONTH(Allocation_Date__c) month from {0} where New_Campaign__c = :campaignId and Allocation_Date__c = THIS_YEAR group by CALENDAR_MONTH(Allocation_Date__c) order by CALENDAR_MONTH(Allocation_Date__c)',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectSumAmountAndDonorSegmentationByCampaignId(String campaignId) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Amount__c, Gift_Detail__c.Campaign__c, Gift_Detail__c.Gift__c };
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Gift__c.Constituent__c };
		List<Schema.SObjectField> customContactFieldList = new List<Schema.SObjectField> { Contact.Sys_Donor_Segmentation__c };
		IsCustomAccessible(customAllocationFieldList);
		IsRelatedSObjectAccessible(new GiftSelector().GetSObjectType(), customGiftFieldList);
		IsRelatedSObjectAccessible(new ContactSelector().GetSObjectType(), customContactFieldList);

		String queryString = String.format('select SUM(Amount__c) total, Gift__r.Constituent__r.Sys_Donor_Segmentation__c level from Gift_Detail__c where Campaign__c = :campaignId group by Gift__r.Constituent__r.Sys_Donor_Segmentation__c order by Gift__r.Constituent__r.Sys_Donor_Segmentation__c',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectSumAmountAndFundByConstituent(String contactId) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Amount__c, Gift_Detail__c.Fund__c, Gift_Detail__c.Constituent__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select SUM(Amount__c) total, Fund__c from {0} where Gift__r.Constituent__c = :contactId group by Fund__c',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectIdAndFundByConstituent(String contactId) {
		List<Schema.SObjectField> fundFieldList = new List<Schema.SObjectField> { Fund__c.Fund_Name__c };
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Fund__c, Gift_Detail__c.Constituent__c };
		IsCustomAccessible(customAllocationFieldList);
		new FundSelector().IsCustomAccessible(fundFieldList);

		String queryString = String.format('select Id, Fund__c, Fund__r.Fund_Name__c from {0} where Gift__r.Constituent__c = :contactId',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public AggregateResult[] SelectMaxFundAndAmountByPayments(List<Payment__c> paymentList) {
		List<Schema.SObjectField> fundFieldList = new List<Schema.SObjectField> { Fund__c.Fund_Name__c };
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Amount__c, Gift_Detail__c.Fund__c, Gift_Detail__c.Payment__c };
		IsCustomAccessible(customAllocationFieldList);
		new FundSelector().IsCustomAccessible(fundFieldList);

		String queryString = String.format('select max(Fund__r.Fund_Name__c) fundName, sum(Amount__c) totalFundAmount from {0} where Payment__c in :paymentList group by Fund__c limit 100',
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectApprovedAmountAndPaymentByFund(Set<Id> idSet) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Approved_Amount__c, Gift_Detail__c.Payment__c, Gift_Detail__c.Fund__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select {0} from {1} where Fund__c in :idSet',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectNameAndPaymentByPaymentId(String paymentId) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Name, Gift_Detail__c.Payment__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select {0} from {1} where Payment__c =:paymentId',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectMatchingGiftsByGiftId(String giftId) {
		List<Schema.SObjectField> campaignFieldList = new List<Schema.SObjectField> { Campaign.Name };
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Name, Gift_Detail__c.Tribute__c, Gift_Detail__c.Product__c, Gift_Detail__c.Fund__c,
			Gift_Detail__c.Fund_Name__c, Gift_Detail__c.Approved_Amount__c, Gift_Detail__c.Amount__c, Gift_Detail__c.Parent_Appeal__c,
			Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.New_Campaign__c, Gift_Detail__c.Campaign__c };
		IsCustomAccessible(customAllocationFieldList);
		new CampaignSelector().IsCustomAccessible(campaignFieldList);

		String queryString = String.format('select {0}, New_Campaign__r.Name from {1} where Gift__c = :giftId',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectGiftByRecurringDonationMonth(Date startOfMonth, Date startOfNextMonth) {
		return SelectGiftByRecurringDonationMonthAndStatus(startOfMonth, startOfNextMonth, null);
	}

	public List<Gift_Detail__c> SelectGiftByRecurringDonationMonthAndStatus(Date startOfMonth, Date startOfNextMonth, String status) {
		List<Schema.SObjectField> allocationFieldList = new List<Schema.SObjectField> { Gift_Detail__c.Id, Gift_Detail__c.Gift__c };
		List<Schema.SObjectField> giftFieldList = new List<Schema.SObjectField> { Gift__c.Constituent__c, Gift__c.Recurring_Donation__c };
		List<Schema.SObjectField> contactFieldList = new List<Schema.SObjectField> { Contact.Date_of_First_Gift__c, Contact.Id };
		List<Schema.SObjectField> recurringDonationFieldList = new List<Schema.SObjectField> {
			Recurring_Donation__c.Start_Date__c, Recurring_Donation__c.Status__c, Recurring_Donation__c.Amount__c };
		IsCustomAccessible(allocationFieldList);
		new GiftSelector().IsCustomAccessible(giftFieldList);
		new ContactSelector().IsCustomAccessible(contactFieldList);
		new RecurringDonationSelector().IsCustomAccessible(recurringDonationFieldList);

		String statusQuery = (status == null) ? '' : ' and Gift__r.Recurring_Donation__r.Status__c = \'' + status + '\'';
		String giftQuery = 'Gift__r.Constituent__r.Date_of_First_Gift__c, Gift__r.Recurring_Donation__r.Start_Date__c, Gift__r.Constituent__r.Id';
		String queryString = String.format('select {0} from {1} where (Gift__r.Recurring_Donation__r.Start_Date__c >= :startOfMonth and Gift__r.Recurring_Donation__r.Start_Date__c < :startOfNextMonth) {2}',
			new List<String> { giftQuery, GetSObjectName(), statusQuery });
        return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectGiftByTriggerSet(Set<Id> idSet){
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Approved_Amount__c, Gift_Detail__c.Payment__c, Gift_Detail__c.Amount__c };

		IsCustomAccessible(new List<Schema.SObjectField>{Gift_Detail__c.Exclude_From_Gift_Aid__c, Gift_Detail__c.Is_Donor_GA_Eligible__c, Gift_Detail__c.Is_Fund_GA_Eligible__c});
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Payment__c IN :idSet AND Exclude_From_Gift_Aid__c = FALSE AND Is_Donor_GA_Eligible__c = TRUE AND Is_Fund_GA_Eligible__c = TRUE',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectIdByPaymentId(list<String> paymentIds){
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {Gift_Detail__c.Id};

		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('SELECT {0} FROM {1} where Payment__c in :paymentIds',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectGiftDetailsWherePaymentInPaymentIds(set<id> paymentIds) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Gift__c, Gift_Detail__c.Payment__c, Gift_Detail__c.Fund__c, Gift_Detail__c.GL_Auto_Credit_Account__c, Gift_Detail__c.GL_Auto_Debit_Account__c,
			Gift_Detail__c.Posted_to_Finance__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select {0} from {1} where Payment__c IN: paymentIds FOR UPDATE',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectGiftDetailsWhereIdEqualsAllocationId(String newAllocationId) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Id, Gift_Detail__c.Gift__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select {0} from {1} where Id = :newAllocationId',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public Gift_Detail__c SelectPostedToFinanceWhereIdIsId(id setid) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> { Gift_Detail__c.Id, Gift_Detail__c.Posted_to_Finance__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select {0} from {1} where id = :setid',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectIdByCampaignIdForUpdate(String CampId){
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {Gift_Detail__c.Id, Gift_Detail__c.New_Campaign__c};

		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE New_Campaign__c = :CampId FOR UPDATE',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectRelatedConstituentAndNameById(Set<id> contactIds) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> { Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.Amount__c };
		IsCustomAccessible(customAllocationFieldList);

		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{ Gift__c.Constituent__c });
		new CampaignSelector().IsCustomAccessible(new List<Schema.SObjectField>{ Campaign.Name });

		String queryString = String.format('select Gift__r.Constituent__c, New_Campaign__r.Name from {0} where Gift__r.Constituent__c IN :contactIds ORDER BY Gift__r.Constituent__c ASC, Allocation_Date__c ASC, Amount__c ASC',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectAllocationRecordsByDate(Date fromDate, Date toDate, String orderByField, String extraFields) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Gift_Detail__c.Name, Gift_Detail__c.Constituent__c, Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.Amount__c,
			Gift_Detail__c.Approved_Amount__c, Gift_Detail__c.Accounting_Code__c, Gift_Detail__c.GL_Auto_Credit_Account__c, Gift_Detail__c.GL_Auto_Debit_Account__c};
		IsCustomAccessible(customAllocationFieldList);

		IsCustomAccessible(new List<Schema.SObjectField>{
			Gift_Detail__c.Posted_to_Finance__c, Gift_Detail__c.Parent_Appeal__c, Gift_Detail__c.Gift_Type__c, Gift_Detail__c.Event_Level__c,
			Gift_Detail__c.Fund__c, Gift_Detail__c.Payment__c, Gift_Detail__c.Is_Payment_GA_Eligible__c });

		new FundSelector().IsCustomAccessible(new List<Schema.SObjectField>{ Fund__c.Fund_Code__c, Fund__c.Fund_Name__c });
		new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{ Gift__c.Gift_Date__c });
		new PaymentSelector().IsCustomAccessible(new List<Schema.SObjectField>{ Payment__c.Status__c });

		String queryString = String.format('SELECT {0}, Fund__r.Fund_Code__c, Gift__r.Gift_Date__c, Payment__r.Status__c, Fund__r.Fund_Name__c' + extraFields + ' FROM {1} WHERE Posted_to_Finance__c = null AND Approved_Amount__c > 0 AND Allocation_Date__c >= :fromDate and Allocation_Date__c <= :toDate Order By '+ orderByField +' NULLS LAST',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Gift_Detail__c> SelectPostedToFinanceWhereIdInId(Set<id> setid) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> { Gift_Detail__c.Id, Gift_Detail__c.Posted_to_Finance__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select {0} from {1} where id IN :setid',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Gift_Detail__c> ExportControllerQuery(String giftDetailFields, String giftFields) {
		SObjectType schemaType = Schema.getGlobalDescribe().get('Gift_Detail__c');
		SObjectType subSchemaType = Schema.getGlobalDescribe().get('Gift__c');

		Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
		Map<String, SObjectField> subFields = subSchemaType.getDescribe().fields.getMap();

		List<String> accessibleFields = QueryIsAccessible('Gift_Detail__c', fields, giftDetailFields, false, '');
		List<String> accessibleSubFields = QueryIsAccessible('Gift__c', subFields, giftFields, true, 'Gift__r.');

		String queryString = 'SELECT ' + String.join(accessibleFields, ',') + ', ' + String.join(accessibleSubFields, ',') + ' from Gift_Detail__c where Gift__r.Exported__c = false';
				return Database.query(queryString);
	}

	public List<String> QueryIsAccessible(String sObjectType, Map<String, SObjectField> fields, String commaDelimitedFields, Boolean applyPrefix, String prefix)
	{
			List<String> accessibleFields = new List<String>();

			for (String field : commaDelimitedFields.split(',')){
				if (fields.get(field).getDescribe().isAccessible())
				{
					if(applyPrefix == true){
						accessibleFields.add(prefix+field.trim());
					}else{
						accessibleFields.add(field.trim());
					}
				}else{
					NoAccessException cannotAccess = new NoAccessException();
					cannotAccess.SetMessage('Cannot Access ' + field + ' in object ' + sObjectType);
					throw cannotAccess;
				}
			}
			return accessibleFields;
	}
}