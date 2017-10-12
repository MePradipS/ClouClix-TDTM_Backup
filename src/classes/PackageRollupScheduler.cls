global with sharing class PackageRollupScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new PackageRollupBatch(), 40);   
  }
   
}