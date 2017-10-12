global with sharing class DMContactRollupScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    //Limit the Batch size to givingpowerSettings__c.Rollup_Batch_Size__c, to avoid the Exception "Aggregate query has too many rows for direct assignment, use FOR loop".
    List<givingpowerSettings__c> gpsList = new GivingPowerSettingsSelector().SelectByIsDeleted(false);
    if (gpsList != null && gpsList.size() > 0) {
      givingpowerSettings__c GPS = gpsList[0];
      if(GPS != null && GPS.Rollup_Batch_Size__c != null && GPS.Rollup_Batch_Size__c > 0) {
          Database.executeBatch(new RollupBatch(), (Integer)GPS.Rollup_Batch_Size__c);
          //Database.executeBatch(new DMContactRollups(), (Integer)GPS.Rollup_Batch_Size__c);
      } else {
          Database.executeBatch(new RollupBatch());   
          //Database.executeBatch(new DMContactRollups());
      }
    }
  }
}