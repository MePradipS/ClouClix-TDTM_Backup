public with sharing class AsyncApexJobSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			AsyncApexJob.Id, AsyncApexJob.Status, AsyncApexJob.TotalJobItems, AsyncApexJob.JobItemsProcessed, AsyncApexJob.NumberOfErrors };
	}

	public override Schema.SObjectType GetSObjectType() {
		return AsyncApexJob.sObjectType;
	}

	public List<AsyncApexJob> SelectByApexClassIdOrderByCreatedDate(String name) {
		ApexClassSelector apexClassSelector = new ApexClassSelector();
		IsAccessible();
		apexClassSelector.IsAccessible();

		List<ApexClass> apexClassList = apexClassSelector.SelectSObjectsByName(name);
		String queryString = String.format('select {0} from {1} where ApexClassId in :apexClassList order by CreatedDate desc limit 1',
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<AsyncApexJob> SelectByApexClassIdAndStatusOrderByCreatedDate(String name, List<String> statusList) {
		ApexClassSelector apexClassSelector = new ApexClassSelector();
		IsAccessible();
		apexClassSelector.IsAccessible();

		String statusClause = '';
		for (String status : statusList) {
			statusClause += 'and Status != \'' + status + '\' ';
		}
		List<ApexClass> apexClassList = apexClassSelector.SelectSObjectsByName(name);
		String queryString = String.format('select {0} from {1} where ApexClassId in :apexClassList {2} order by CreatedDate desc limit 2',
			new List<String> { GetFieldListString(), GetSObjectName(), statusClause });
        return Database.query(queryString);
	}

	public List<AsyncApexJob> SelectStatusByTodayAndMethodName(String methodName) {
		List<Schema.SObjectField> customAsyncApexJobFieldList = new List<Schema.SObjectField> {
			AsyncApexJob.Id, AsyncApexJob.Status, AsyncApexJob.CreatedDate, AsyncApexJob.MethodName, AsyncApexJob.CreatedById };
		IsCustomAccessible(customAsyncApexJobFieldList);

		String info = UserInfo.getUserId();

		String queryString = String.format('select {0} from {1} where CreatedDate = today and MethodName = :methodName and CreatedById = :info order by CreatedDate desc nulls last limit 1',
			new List<String> { GetFieldListString(customAsyncApexJobFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public Integer SelectJobCountByCreatedDate(Datetime currentDate) {
		List<Schema.SObjectField> customAsyncApexJobFieldList = new List<Schema.SObjectField> { AsyncApexJob.Id, AsyncApexJob.CreatedDate };
		IsCustomAccessible(customAsyncApexJobFieldList);

		String queryString = String.format('select count() from {0} where CreatedDate >= :currentDate',
			new List<String> { GetSObjectName() });
        return Database.countQuery(queryString);
	}

	public List<AsyncApexJob> SelectByApexClassName(List<String> apexClassNames) {
    	List<Schema.SObjectField> customAsyncApexJobFieldList = new List<Schema.SObjectField> {
			AsyncApexJob.ApexClassId, AsyncApexJob.CompletedDate, AsyncApexJob.Id, AsyncApexJob.JobItemsProcessed, AsyncApexJob.JobType,
			AsyncApexJob.LastProcessed, AsyncApexJob.NumberOfErrors, AsyncApexJob.Status, AsyncApexJob.TotalJobItems, AsyncApexJob.CreatedDate };
    	IsCustomAccessible(customAsyncApexJobFieldList);
    	new ApexClassSelector().IsAccessible();

    	String nameClause = '';
    	for (String name : apexClassNames) {
      		nameClause = (String.isEmpty(nameClause)) ? ' where ApexClass.Name = \'' + name + '\'' : (nameClause + ' or ApexClass.Name = \'' + name + '\'');
		}
    	String queryString = String.format('select {0}, ApexClass.Name from {1} {2} order by CreatedDate desc',
			new List<String> { GetFieldListString(customAsyncApexJobFieldList), GetSObjectName(), nameClause });
        return Database.query(queryString);
  }

	public List<AsyncApexJob> SelectCompletedDateByCompletedJob() {
		List<Schema.SObjectField> customAsyncApexJobFieldList = new List<Schema.SObjectField> { AsyncApexJob.CompletedDate, AsyncApexJob.ApexClassId, AsyncApexJob.Status, AsyncApexJob.NumberOfErrors, AsyncApexJob.CreatedDate};
		IsCustomAccessible(customAsyncApexJobFieldList);

		new ApexClassSelector().IsCustomAccessible(new List<Schema.SObjectField> {ApexClass.Id, ApexClass.Name});

		String queryString = String.format('select CompletedDate from {0} where ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = \'\'RollupBatch\'\') AND (Status = \'\'Completed\'\' AND numberOfErrors = 0) ORDER BY CreatedDate DESC LIMIT 1',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}

	public List<AsyncApexJob> SelectCreatedDateByLastJob() {
		List<Schema.SObjectField> customAsyncApexJobFieldList = new List<Schema.SObjectField> { AsyncApexJob.CreatedDate, AsyncApexJob.ApexClassId, AsyncApexJob.Status };
		IsCustomAccessible(customAsyncApexJobFieldList);

		new ApexClassSelector().IsCustomAccessible(new List<Schema.SObjectField> {ApexClass.Id, ApexClass.Name});

		String queryString = String.format('select CreatedDate from {0} where ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = \'\'RollupBatch\'\') AND (Status != \'\'Queued\'\' OR Status != \'\'Processing\'\' OR Status != \'\'Preparing\'\' OR Status != \'\'Holding\'\') ORDER BY CreatedDate ASC LIMIT 1',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}

	public Integer SelectCountOfJobsByDate(Datetime dateObj) {
		List<Schema.SObjectField> customAsyncApexJobFieldList = new List<Schema.SObjectField> { AsyncApexJob.CreatedDate };
		IsCustomAccessible(customAsyncApexJobFieldList);

		String queryString = String.format('select count() from {0} WHERE CreatedDate >= :dateObj',
			new List<String> { GetSObjectName() });
				return Database.countQuery(queryString);
	}

	public List<AsyncApexJob> SelectJobByJobId(Id jobId) {
		List<Schema.SObjectField> customAsyncApexJobFieldList = new List<Schema.SObjectField> {
			AsyncApexJob.Id, AsyncApexJob.Status, AsyncApexJob.NumberOfErrors, AsyncApexJob.JobItemsProcessed, AsyncApexJob.TotalJobItems };
		IsCustomAccessible(customAsyncApexJobFieldList);

		new UserSelector().IsCustomAccessible(new List<Schema.SObjectField> {User.Email});

		String queryString = String.format('Select {0},CreatedBy.Email FROM {1} WHERE Id =:jobId',
			new List<String> { GetFieldListString(customAsyncApexJobFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<AsyncApexJob> SelectTodaysJobByUserId(Id jobId) {
		List<Schema.SObjectField> customAsyncApexJobFieldList = new List<Schema.SObjectField> {
			AsyncApexJob.Id, AsyncApexJob.Status, AsyncApexJob.CreatedDate, AsyncApexJob.MethodName, AsyncApexJob.CreatedById };
		IsCustomAccessible(customAsyncApexJobFieldList);

		String queryString = String.format('SELECT id, Status FROM {0} WHERE CreatedDate = today AND MethodName = \'RollupBatch\' AND CreatedById = :jobId ORDER BY CreatedDate DESC NULLS LAST LIMIT 1',
			new List<String> { GetSObjectName() });
				return Database.query(queryString);
	}

	public List<AsyncApexJob> SelectJobByIdAndMethodName(String methodName, String createdById) {
		List<Schema.SObjectField> customAsyncApexJobFieldList = new List<Schema.SObjectField> {
			AsyncApexJob.Id, AsyncApexJob.Status, AsyncApexJob.CreatedDate, AsyncApexJob.MethodName, AsyncApexJob.CreatedById };
		IsCustomAccessible(customAsyncApexJobFieldList);

		String queryString = String.format('SELECT id, Status FROM {0} WHERE CreatedDate = today AND MethodName = :methodName AND CreatedById = :createdById ORDER BY CreatedDate DESC NULLS LAST LIMIT 1', 
			new List<String> { GetSObjectName() });
        return Database.query(queryString);
	}
}