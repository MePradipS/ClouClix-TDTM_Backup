global with sharing class ConsolidatedReceiptBatch implements Database.Batchable<sObject> {

    global Database.Querylocator start(Database.BatchableContext BC)
    {
        return new ContactSelector().queryContactIdNameByIdStatusAndDate();
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        RollupHelper.executeConsolidatedReceiptBatch(scope);
    }

    global void finish(Database.BatchableContext BC) { }
}