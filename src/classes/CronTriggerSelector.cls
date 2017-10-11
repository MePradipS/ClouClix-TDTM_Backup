public with sharing class CronTriggerSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			CronTrigger.Id, CronTrigger.CronExpression, CronTrigger.TimesTriggered, CronTrigger.NextFireTime };
	}

	public override Schema.SObjectType GetSObjectType() {
		return CronTrigger.sObjectType;
	}

	public List<CronTrigger> SelectExtendedCronTriggers() {
		List<Schema.SObjectField> customCronTriggerFieldList = new List<Schema.SObjectField> {
			CronTrigger.Id, CronTrigger.EndTime, CronTrigger.CronJobDetailId, CronTrigger.NextFireTime, CronTrigger.PreviousFireTime,
			CronTrigger.StartTime, CronTrigger.State, CronTrigger.TimesTriggered, CronTrigger.TimeZoneSidKey };
		IsCustomAccessible(customCronTriggerFieldList);
		new CronJobDetailSelector().IsAccessible();

		String queryString = String.format('select {0}, CronJobDetail.Name from {1}',
			new List<String> { GetFieldListString(customCronTriggerFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<CronTrigger> SelectWhereCronJobDetailIdInIds(Set<Id> DeleteJobIds) {
		List<Schema.SObjectField> customCronTriggerFieldList = new List<Schema.SObjectField> { CronTrigger.Id, CronTrigger.CronJobDetailId };
		IsCustomAccessible(customCronTriggerFieldList);

		String queryString = String.format('SELECT {0} FROM {1} where CronJobDetailId IN :DeleteJobIds',
			new List<String> { GetFieldListString(customCronTriggerFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}

	public CronTrigger SelectCronTriggerDetails(Id cronId) {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { CronTrigger.TimesTriggered, CronTrigger.State, CronTrigger.StartTime, 
		   CronTrigger.PreviousFireTime, CronTrigger.NextFireTime, CronTrigger.Id, CronTrigger.EndTime, CronTrigger.CronExpression };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT {0} FROM {1} where Id = :cronId',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}
}