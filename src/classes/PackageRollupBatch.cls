global with sharing class PackageRollupBatch implements Database.Batchable<sObject> {

  public string query;
  public string camp_rtid;

  global PackageRollupBatch()
  {
       List<RecordType> rts = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectType('Campaign', 'Campaign', Utilities.getCurrentNamespace());
       if (rts.size() > 0)
       {
          camp_rtid = rts[0].Id;
       }
  }

  global Database.Querylocator start(Database.BatchableContext BC)
  {
    Database.Querylocator locatedQuery = null;
    if (!System.Test.isRunningTest())
    { locatedQuery = new CampaignSelector().LocateCampignByREcordTypeId(camp_rtid); }

    return locatedQuery;
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
    Map<ID, Campaign> scopeMap = new Map<ID, Campaign>((List<Campaign>)scope);

    AppealUtil.RollupPackages(scopeMap.keySet());
  }

  global void finish(Database.BatchableContext BC)
  {
  }
}