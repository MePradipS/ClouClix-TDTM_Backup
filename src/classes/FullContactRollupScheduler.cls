global with sharing class FullContactRollupScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		try { 
			system.abortJob(sc.getTriggerId()); 
		} catch (exception e) {
			
		}
		Database.executeBatch(new RollupBatch('Full'),200);
	}
}