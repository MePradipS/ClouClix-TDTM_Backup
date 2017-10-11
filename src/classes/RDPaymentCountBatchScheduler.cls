global with sharing class RDPaymentCountBatchScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new RDPaymentCountBatch(), 200);  

  }
  
 }