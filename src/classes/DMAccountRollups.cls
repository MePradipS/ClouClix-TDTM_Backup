global with sharing class DMAccountRollups implements Database.Batchable<sObject> {

  public string query;

  global DMAccountRollups() {
    query = 'Select Id,RecordTypeId From Account LIMIT 1';
  }

  global Database.Querylocator start(Database.BatchableContext BC) {

    if (!System.Test.isRunningTest()) {
        return new GenericQueryBuilder().getQueryLocator('', 'Id,RecordTypeId', 'Account');
    }
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    Set<Id> itemIds = new Set<Id>();
    Set<Id> hhIds = new Set<Id>();
    RecordType rec;
    List<RecordType> recordTypeList = new RecordTypeSelector().SelectByNameAndLimit(new List<String> { 'Household' }, 1);
    if (recordTypeList != null && recordTypeList.size() > 0) {
      rec = recordTypeList[0];
      for (sObject c : scope)
      {
        if (!itemIds.contains(c.Id)) {
          itemIds.add(c.Id);
        }
        if (rec.id==(Id)c.get('RecordTypeId')) {
            hhIds.add(c.id);
        }
      }

      RollupHelper.RecalculateTotalGivingForOrg(itemIds);
      RollupHelper.RecalculateGiftDatesForOrg(itemIds);
      RollupHelper.RecalculateTotalHouseholdGiving(hhIds);
    }
  }

  global void finish(Database.BatchableContext BC) { }
}