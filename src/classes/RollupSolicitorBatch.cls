global with sharing class RollupSolicitorBatch implements Database.Batchable<sObject> {

    global DateTime previousRunTime;
	global RollupSolicitorBatch(DateTime lastRun) {
		previousRunTime = lastRun;
	}
	global Database.Querylocator start(Database.BatchableContext BC) {
	    if (previousRunTime==null)
	    	previousRunTime = DateTime.now().addHours(-24);

        String clause = 'WHERE Id IN (Select Primary_Solicitor__c FROM Gift__c WHERE Primary_Solicitor__c!=null AND Gift_Date__c !=null AND LastModifiedDate > '+ previousRunTime  +')';
        String fields = 'Id';

		return new GenericQueryBuilder().getQueryLocator(clause, fields, 'Contact');
	}
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Map<ID, Contact> scopeMap = new Map<ID, Contact>((List<Contact>)scope);
		RollupHelper.RecalculateTotalGiving(scopeMap.keySet());
	}
	global void finish(Database.BatchableContext BC) {
	}

}