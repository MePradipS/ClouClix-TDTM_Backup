global with sharing class RecurringScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {

        RollupHelper.CreateTodayRecurringBatch();

        decimal batchSize = 5;
        List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectRecurringBatchSize();
        if (settingsRecords != null && settingsRecords.size()>0) {
            batchSize = settingsRecords[0].Recurring_Batch_Size__c;
        }
        if (batchSize==null)
          batchSize=5;

        RecurringProcessor runningProc = new RecurringProcessor();
        Database.executeBatch(runningProc, batchSize.intValue());
    }

}