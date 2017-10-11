global with sharing class CampaignRollupScheduler implements Schedulable {
  global void execute(SchedulableContext SC) {
    
    Database.executeBatch(new CampaignRollupBatch(), 200);  
    
      /*  datetime nextScheduleTime = Datetime.now().addMinutes(10);
      string minute = string.valueof(nextScheduleTime.minute());
      string second = string.valueof(nextScheduleTime.second ());
      string cronvalue = second+' '+minute+' * * * ?' ;
     
      AppealRollupScheduler3 CR = new AppealRollupScheduler3();
      system.schedule('CampaignRollup Job '+ nextScheduleTime.format('hh:mm'), cronvalue , CR);

      system.abortJob(sc.getTriggerId()); */
 
  }
   /* global static void scheduleMe1() {
        
        String sch = Datetime.now().addMinutes(10).format('s m H d M ? yyyy');
        AppealRollupScheduler3 CR1 = new AppealRollupScheduler3();
        System.schedule('CampaignRollup Job', sch, CR1);
        } */
}