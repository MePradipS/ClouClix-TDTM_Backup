global with sharing class RollupScheduler implements Schedulable {
	global void execute(SchedulableContext SC) {
		//when was thr 
		CronTrigger ct = new CronTriggerSelector().SelectCronTriggerDetails(SC.getTriggerId());
		   
		//read custom settings
		decimal batchSize = 10;
		List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectRecurringBatchSize();
        if (settingsRecords != null && settingsRecords.size()>0 && settingsRecords[0].Rollup_Batch_Size__c!=null) {
        	batchSize = settingsRecords[0].Rollup_Batch_Size__c;
        }

		Datetime PreviousFireTime = ct.PreviousFireTime;
		if (ct.PreviousFireTime==null || ct.PreviousFireTime>=DateTime.now().addMinutes(-5))
			PreviousFireTime = DateTime.now().addHours(-24);

		Database.executeBatch(new RollupBatch(PreviousFireTime), batchSize.intValue());
		Database.executeBatch(new RollupSolicitorBatch(PreviousFireTime), batchSize.intValue());
	}

}