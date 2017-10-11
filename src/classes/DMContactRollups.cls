global with sharing class DMContactRollups implements Database.Batchable<sObject> {

  public string query;

  global DMContactRollups ()
  { query = 'Select Id From Contact LIMIT 1';  }

  global Database.Querylocator start(Database.BatchableContext BC)
  {
    if (!System.Test.isRunningTest())
    {
      return new GenericQueryBuilder().getQueryLocator('', 'Id', 'Contact');
    }
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
    Set<Id> cIds = new Set<Id>();
    for (sObject c : scope)
    {
    	if (!cIds.contains(c.Id)) cIds.add(c.Id);
    }
    RollupHelper.RecalculateTotalGiving(cIds);
    RollupHelper.RecalculateGiftDates(cIds);
  }

  global void finish(Database.BatchableContext BC) {
  }
}