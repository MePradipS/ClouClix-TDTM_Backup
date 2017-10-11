global with sharing class RollupIndividualBatch implements Database.Batchable<sObject> {
  global Database.Querylocator start(Database.BatchableContext BC)
  {
        return new GenericQueryBuilder().getQueryLocator('', 'id', 'Gift__c');
  }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        DMLManager.UpdateSObjects(scope);
    }

    global void finish(Database.BatchableContext BC) {  }

}