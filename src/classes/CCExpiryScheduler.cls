global with sharing class CCExpiryScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CCExpiryBatch(), 5);
    }    
        
}