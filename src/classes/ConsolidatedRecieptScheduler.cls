global with sharing class ConsolidatedRecieptScheduler implements Schedulable {
	global void execute(SchedulableContext SC) {
	  	ConsolidatedReceiptBatch createReceipts = new ConsolidatedReceiptBatch();
 	    Database.executeBatch(createReceipts, 500);
	}
}