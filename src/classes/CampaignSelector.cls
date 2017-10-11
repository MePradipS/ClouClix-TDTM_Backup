public with sharing class CampaignSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Campaign.Id, Campaign.Name, Campaign.ParentId, Campaign.ActualCost,
			Campaign.Gift_Amount__c, Campaign.Gift_Count__c, Campaign.Gifts_for_Current_Fiscal__c,
			Campaign.Gifts_for_Current_Quarter__c, Campaign.One_Time_Gift_Count__c, Campaign.Overall_Gift_Amount__c,
			Campaign.Overall_Gift_Count__c, Campaign.Overall_Gifts_for_Current_Fiscal__c,
			Campaign.Overall_Gifts_for_Current_Quarter__c, Campaign.Overall_One_Time_Gift_Count__c,
			Campaign.Overall_Recurring_Gift_Count__c, Campaign.Recurring_Gift_Count__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Campaign.sObjectType;
	}

	private void IsParentAccessible() {
		IsAccessible();
	}

	public List<Campaign> SelectIdAndRecordTypeNameById(Set<Id> idSet) {
		new RecordTypeSelector().IsAccessible();
		IsAccessible();

		List<Schema.SObjectField> customSObjectFieldList = new List<Schema.SObjectField> { Campaign.Id };
		String queryString = String.format('select {0}, RecordType.Name from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customSObjectFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectByParentId(Set<Id> idSet) {
		IsParentAccessible();

		String queryString = String.format('select {0}, c.Parent.ParentId from {1} c where c.ParentId in :idSet',
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectByParentOrParentId(Set<Id> idSet) {
		IsParentAccessible();

		String queryString = String.format('select {0}, c.Parent.ParentId from {1} c where c.ParentId in :idSet or c.Parent.ParentId in :idSet',
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectParentIds(Set<String> GDIDs){
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.ParentId };
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('SELECT {0}, Parent.ParentId, Parent.RecordTypeId, Parent.Parent.RecordTypeId FROM {1} WHERE Id IN :GDIDs',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Campaign> SelectFundAndLetterWhereIdInIds(Set<Id> idSet){
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {Campaign.Id, Campaign.Letter__c};
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('SELECT {0}, Campaign.Parent.ParentId, Campaign.Parent.RecordTypeId, Campaign.Parent.Parent.RecordTypeId from {1} WHERE Id In :idSet',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Campaign> SelectFundByNamespace(String endClause, String nameSpace){
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {Campaign.Id, Campaign.Name, Campaign.Fund__c, Campaign.IsActive, Campaign.RecordTypeId};
		IsCustomAccessible(customCampaignFieldList);

		new FundSelector().IsCustomAccessible(new List<Schema.SObjectField> {Fund__c.Name, Fund__c.Fund_Name__c});
		new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField> {RecordType.SobjectType, RecordType.Name, RecordType.Id, RecordType.NamespacePrefix});

		String queryString = String.format('SELECT {0},Fund__r.Name, Fund__r.Fund_Name__c from {1} WHERE RecordTypeId IN (SELECT Id FROM RecordType WHERE SobjectType = \'\'Campaign\'\' AND (Name = \'\'Appeal\'\' OR Name = \'\'Event\'\') AND NamespacePrefix =: nameSpace) AND IsActive = true ' + endClause,
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public Database.Querylocator LocateCampignByREcordTypeId(String camp_rtid){
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {Campaign.Id};
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('SELECT {0} from {1} WHERE Campaign.Parent.Parent.RecordTypeId = :camp_rtid',
			new List<String> { GetFieldListString(), GetSObjectName() });
				return Database.getQueryLocator(queryString);
	}

	public List<Campaign> SelectIdById(Set<Id> appealId){
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.RecordTypeId};
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id IN :appealId',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Campaign> SelectCampaignAndExpensesById(Set<Id> idSet) {
		ExpenseSelector expenseSelector = new ExpenseSelector();
		expenseSelector.IsAccessible();

		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> { Campaign.Id, Campaign.ActualCost };
		IsCustomAccessible(customCampaignFieldList);

		String relatedExpense = PackageNamespace + 'Expenses__r';
		String queryString = String.format('select {0}, (select {1} from {2}) from {3} c where Id in :idSet for update',
			new List<String> { GetFieldListString(customCampaignFieldList), expenseSelector.GetFieldListString(), relatedExpense, GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectCampaignAndFundById(Set<Id> idSet) {
		new FundSelector().IsAccessible();

		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> { Campaign.Id, Campaign.Fund__c };
		IsCustomAccessible(customCampaignFieldList);

		String relatedFund = PackageNamespace + 'Fund__r';
		String queryString = String.format('select {0}, {1}.Name from {2} where Id in :idSet',
			new List<String> { GetFieldListString(customCampaignFieldList), relatedFund, GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectCampaignFundAndLetterById(List<RecordType> rts) {
		new FundSelector().IsAccessible();
		new LetterSelector().IsAccessible();

		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Name,Campaign.IsActive,Campaign.ParentId,Campaign.RecordTypeId,Campaign.Type, Campaign.Fund__c, Campaign.Letter__c, Campaign.Status };
		IsCustomAccessible(customCampaignFieldList);

		String relatedFund = PackageNamespace + 'Fund__r';
		String relatedLetter = PackageNamespace + 'Letter__r';
		String queryString = String.format('select {0}, {1}.Name, {2}.Name from {3} where RecordTypeId in :rts LIMIT 25',
			new List<String> { GetFieldListString(customCampaignFieldList), relatedFund, relatedLetter, GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Campaign> SelectCampaignFundAndLetterBySearch(List<RecordType> rts, String searchString) {
		new FundSelector().IsAccessible();
		new LetterSelector().IsAccessible();

		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Name,Campaign.IsActive,Campaign.ParentId,Campaign.RecordTypeId,Campaign.Type, Campaign.Fund__c, Campaign.Letter__c, Campaign.Status };
		IsCustomAccessible(customCampaignFieldList);

		String relatedFund = PackageNamespace + 'Fund__r';
		String relatedLetter = PackageNamespace + 'Letter__r';
		String queryString = String.format('select {0}, {1}.Name, {2}.Name from {3} where RecordTypeId in :rts AND Name LIKE \'\'%'+searchString+'%\'\' LIMIT 25',
			new List<String> { GetFieldListString(customCampaignFieldList), relatedFund, relatedLetter, GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Campaign> SelectIdNameById(Set<Id> idSet) {
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> { Campaign.Id, Campaign.Name };
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectIdNameFundLetterRecordTypeIdById(Set<Id> idSet) {
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.Name, Campaign.Fund__c, Campaign.Letter__c, Campaign.RecordTypeId };
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectIdNameLetterAutoEmailAndURLsById(Set<Id> idSet) {
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.Name, Campaign.Letter__c, Campaign.Actionpage_Auto_Email_Acknowledgement__c,
			Campaign.Failure_URL__c, Campaign.Success_URL__c };
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectIdNameEventById(Set<Id> idSet) {
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.Name, Campaign.Paid_Event__c, Campaign.Event_Fee_Formated__c };
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectTicketsById(Set<Id> idSet) {
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.Number_of_Tickets_Planned__c };
		IsCustomAccessible(customCampaignFieldList);
		new EventLevelSelector().IsAccessible();

		String queryString = String.format('select {0}, (select Ticket_Count__c from Tickets__r) from {1} where Id in :idSet for update',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectRecordTypeIdById(Set<Id> idSet) {
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.RecordTypeId, Campaign.Name };
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectRecordTypeIdByRecordTypeIdAndId(Set<Id> idSet, String rTypeId) {
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.RecordTypeId, Campaign.Name };
		IsCustomAccessible(customCampaignFieldList);

		String queryString = String.format('select {0} from {1} where RecordTypeId = :rTypeId and Id in :idSet',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectLetterAndFundById(Set<Id> idSet) {
		List<Schema.SObjectField> fundFieldList = new List<Schema.SObjectField> { Fund__c.Name };
		List<Schema.SObjectField> letterFieldList = new List<Schema.SObjectField> { Letter__c.Name };
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.Fund__c, Campaign.Name, Campaign.Letter__c };

		IsCustomAccessible(customCampaignFieldList);
		new FundSelector().IsCustomAccessible(fundFieldList);
		new LetterSelector().IsCustomAccessible(letterFieldList);

		String queryString = String.format('select {0}, Letter__r.Name, Fund__r.Name from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectCampaingMembersById(Set<Id> idSet) {
		List<Schema.SObjectField> campaignMemberFieldList = new List<Schema.SObjectField> {
			CampaignMember.RSVP__c, CampaignMember.Form_URL__c, CampaignMember.Status, CampaignMember.LeadId, CampaignMember.LastModifiedDate,
			CampaignMember.ContactId, CampaignMember.CampaignId, CampaignMember.HasResponded, CampaignMember.FirstRespondedDate,
			CampaignMember.CreatedDate, CampaignMember.CreatedById };
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.IsActive, Campaign.Name, Campaign.StartDate, Campaign.EndDate, Campaign.Description };
		IsCustomAccessible(customCampaignFieldList);
		new CampaignMemberSelector().IsCustomAccessible(campaignMemberFieldList);

		String campaignMemberQuery = '(Select RSVP__c, Form_URL__c, Status, LeadId, LastModifiedDate, LastModifiedById, HasResponded, FirstRespondedDate, CreatedDate, CreatedById, ContactId, CampaignId FROM CampaignMembers)';
		String queryString = String.format('select {0}, {1} from {2} where Id in :idSet limit 1',
			new List<String> { GetFieldListString(customCampaignFieldList), campaignMemberQuery, GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectIdandFundById(Set<Id> appealIds) {
		List<Schema.SObjectField> customAllocationFieldList = new List<Schema.SObjectField> {
			Campaign.Id, Campaign.Fund__c };
		IsCustomAccessible(customAllocationFieldList);

		String queryString = String.format('select {0} from {1} where Id in :appealIds',
			new List<String> { GetFieldListString(customAllocationFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Campaign> SelectRecordTypeIdByStringId(Set<Id> idSet) {
    List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
      Campaign.Id, Campaign.RecordTypeId };
    IsCustomAccessible(customCampaignFieldList);

    String queryString = String.format('select {0} from {1} where Id in :idSet',
      new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.query(queryString);
  }

	public List<Campaign> SelectCampaignByAccountId(Id contactId) {
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.id, Campaign.Name, Campaign.Organization_or_Group__c,Campaign.CreatedDate };
		IsCustomAccessible(customCampaignFieldList);

		new AccountSelector().IsCustomAccessible(new List<Schema.SObjectField>{Account.Name});

		String queryString = String.format('SELECT {0}, Organization_or_Group__r.name from {1} where Organization_or_Group__c = \':contactId\' order by CreatedDate DESC limit 5',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Campaign> SelectCampaignContactInfoByPrimaryId(Id contactId) {
		List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {
			Campaign.id, Campaign.Name, Campaign.Event_Primary_Contact__c, Campaign.Status, Campaign.Event_End_Time__c, Campaign.Event_Start_Time__c, Campaign.CreatedDate };
		IsCustomAccessible(customCampaignFieldList);

		new ContactSelector().IsCustomAccessible(new List<Schema.SObjectField>{Contact.Name});

		String queryString = String.format('SELECT {0}, Event_Primary_Contact__r.name from {1} where Event_Primary_Contact__c = \':contactId\' order by CreatedDate DESC limit 5',
			new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<sObject> SelectCampaignAndRelatedFund(String recordName, String searchKey)
	{
		new CampaignSelector().isCustomAccessible(new List<Schema.SObjectField>{Campaign.Id,Campaign.Name});
		new FundSelector().isCustomAccessible(new List<Schema.SObjectField>{Fund__c.Name,Fund__c.id});
		new RecordTypeSelector().isCustomAccessible(new List<Schema.SObjectField>{RecordType.Name});

		String soql = 'SELECT Id,Name,Fund__r.Name, Fund__r.id FROM Campaign WHERE RecordType.Name = \''+recordName+'\' AND Name LIKE \''+searchKey+'%\' LIMIT 10';
		return Database.query(soql);
	}
	
  public Database.QueryLocator SelectCampaignIdByRecordTypeId(String campId) {
    List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> { Campaign.Id, Campaign.RecordTypeId };
    IsCustomAccessible(customCampaignFieldList);

    String queryString = String.format('Select {0} From {1} WHERE Parent.RecordTypeId = :campId',
      new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() });
        return Database.getQueryLocator(queryString);
  }
}