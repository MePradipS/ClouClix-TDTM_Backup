global with sharing class MetricsSchedule implements Schedulable {
        
    public static final String SCHEDULE = '0 0 1 * * ? *';
    public static final Date DEFAULT_DATE = Date.Today().addDays(-1);
    
    global static String scheduleIt() {
        MetricsSchedule metricsJob = new MetricsSchedule();
        return System.schedule('Daily Causeview Metrics', schedule, metricsJob);
    }
    
    global void execute(SchedulableContext sc) {           
        MetricsCore.CalculateForDate(DEFAULT_DATE);
    }
}