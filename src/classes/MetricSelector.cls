public with sharing class MetricSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Metric__c.Id, Metric__c.Name, Metric__c.Report_Date__c, Metric__c.CreatedDate };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Metric__c.sObjectType;
	}

	public List<Metric__c> SelectByCreatedDateGteDate(Date currentDate) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where CreatedDate >= :currentDate',
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Metric__c> SelectIdByReportDate(Date reportDate) {
		List<Schema.SObjectField> metricFieldList = new List<Schema.SObjectField> { Metric__c.Id, Metric__c.Report_Date__c };
		IsCustomAccessible(metricFieldList);

		String queryString = String.format('select {0} from {1} where Report_Date__c = :reportDate limit 1 all rows',
			new List<String> { GetFieldListString(metricFieldList), GetSObjectName() });
        return Database.query(queryString);
	}
}