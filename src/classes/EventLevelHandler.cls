public class EventLevelHandler {
    public static void RollupTotals(Set<string> eventLevelIds) {
        Set<Id> eventIds = Utilities.ConvertStringSetToIdSet(eventLevelIds);
        List<Campaign> camps = new CampaignSelector().SelectTicketsById(eventIds);
        for (Campaign c : camps) {
            Decimal total = 0;
            for (Event_Level__c el : c.Tickets__r) {
                total = total + el.Ticket_Count__c;            
            }
            c.Number_Of_Tickets_Planned__c = total;
        }
        DMLManager.UpdateSObjects(camps);
    }
}