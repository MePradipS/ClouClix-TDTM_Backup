global with sharing class MetricsBatchable implements Database.Batchable<Metric__c> {

    global List<Metric__c> start(Database.BatchableContext context) {
              
        // default and maximum date range is 3 years
        Date currentDate = Date.Today().addYears(-3);		
		List<Organization> org = new OrganizationSelector().SelectCreatedDate();
		
		if (org != null && org.size() > 0) {
			if (org[0].CreatedDate < currentDate) {
				currentDate = Date.newInstance(org[0].CreatedDate.year(), org[0].CreatedDate.month(), org[0].CreatedDate.day());
			}
		}

        List<Metric__c> existingMetrics = new MetricSelector().SelectByCreatedDateGteDate(currentDate);
        Map<Date, Metric__c> metricsMap = new Map<Date, Metric__c>();

        if (existingMetrics != null && existingMetrics.size() > 0) {
            for (Metric__c metric : existingMetrics) {
                metricsMap.put(metric.Report_Date__c, metric);
            }
        }

        List<Metric__c> metricsToRun = new List<Metric__c>();

        Integer numberOfDays = currentDate.daysBetween(Date.Today());

        for (Integer i = 0; i < numberOfDays; i++) {
            
            if (metricsMap.containsKey(currentDate)) {
                metricsToRun.add(metricsMap.get(currentDate));  
            } else {
                Metric__c metric = new Metric__c();
                metric.Report_Date__c = currentDate;

                metricsToRun.add(metric);  
            }
            
            currentDate = currentDate.addDays(1);
        }

        DMLManager.UpsertSObjects(metricsToRun);
        return metricsToRun;
    }

    global void execute(Database.BatchableContext context, List<Metric__c> scope) {
        MetricsCore.CalculateForDate(scope[0].Report_Date__c);
    }
    
    global void finish(Database.BatchableContext context) {
    }
}