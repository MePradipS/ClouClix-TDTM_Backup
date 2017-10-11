global with sharing class AppealUtilRollBatch implements Database.Batchable<sObject> {
  public Database.Querylocator queryResult;
  public string camp_rtid;

    global AppealUtilRollBatch()
    {
        List<RecordType> rts = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectType('Campaign', 'Campaign', Utilities.getCurrentNamespace());
        if (rts.size() > 0)
        {
            camp_rtid = rts[0].Id;
        }
    }

  global Database.Querylocator start(Database.BatchableContext BC)
  {
    if (!System.Test.isRunningTest())
    { 
      queryResult =  new CampaignSelector().SelectCampaignIdByRecordTypeId(camp_rtid); 
    }         
    return queryResult;
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
    Map<ID, Campaign> scopeMap = new Map<ID, Campaign>((List<Campaign>)scope);

    AppealUtil.RollupAppeals(scopeMap.keySet());
  }

  global void finish(Database.BatchableContext BC)
  {
  }
}