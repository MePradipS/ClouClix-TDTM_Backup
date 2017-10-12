global with sharing class NewYearTransactionsBatch implements Database.Batchable<sObject> {
  global Database.Querylocator start(Database.BatchableContext BC)
  {
        return new GiftSelector().LocateGiftDetails();
  }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        //RollupHelper.executeNewYearTransactionsBatch(scope);
    }

    global void finish(Database.BatchableContext BC) {  }

}