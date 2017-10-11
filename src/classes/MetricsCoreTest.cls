@isTest
public class MetricsCoreTest {
    public static testMethod void testMetricsCore() {
        Date yesterday = Date.Today().addDays(-1);
        MetricsCore.CalculateForDate(yesterday);
    }
    
    public static testMethod void testMetricsSchedule() {
    	String scheduleId = MetricsSchedule.scheduleIt();
    }
}