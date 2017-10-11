public class BenefitHandler {
    public static void UpdateEventLevels(List<Benefit__c> records) {
        Set<Id> benefitIds = new Set<Id>();
        for (Benefit__c b : records) {
            benefitIds.add(b.Id);
        }
        List<Benefit__c> benefits = new BenefitSelector().SelectBenefitAndEventLevelBenefitByIdForUpdate(benefitIds);
        List<Event_Level_Benefit__c> elb = new List<Event_Level_Benefit__c>();
        for (Benefit__c b : benefits ) {
            if (b.Event_Level_Benefits__r.size() > 0) {
                elb.addAll(b.Event_Level_Benefits__r);  
            }
        }

        if (elb != null && elb.size() > 0) {
            DMLManager.UpdateSObjects(elb);
        }
    }
}