public with sharing class CronJobDetailSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			CronJobDetail.Id, CronJobDetail.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return CronJobDetail.sObjectType;
	}

	public List<CronJobDetail> SelectIdAndName() {
		IsAccessible();
		
		String queryString = String.format('select {0} from {1}', 
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}
}