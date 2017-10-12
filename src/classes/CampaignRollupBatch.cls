global with sharing class CampaignRollupBatch implements Database.Batchable<sObject> {

  public string query;
  public string camp_rtid;

  global CampaignRollupBatch() {
        List<RecordType> rts = new RecordTypeSelector().SelectRecordBySObjectTypeNameAndNamespacePrefix(Utilities.getCurrentNamespace());
        if (rts.size() > 0)
        {
            camp_rtid = rts[0].Id;
        }
  }

  global Database.Querylocator start(Database.BatchableContext BC)
  {
    String clause = '';
    String fields = '';

    if (!System.Test.isRunningTest())
    {
      fields = 'Id';
      clause = 'WHERE RecordTypeId = \'' + camp_rtid + '\'';
    }
    return new GenericQueryBuilder().getQueryLocator(clause, fields, 'Campaign');
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
    Map<ID, Campaign> scopeMap = new Map<ID, Campaign>((List<Campaign>)scope);
    AppealUtil.RollupCampaigns(scopeMap.keySet());
  }

  global void finish(Database.BatchableContext BC)
  {
  }
}