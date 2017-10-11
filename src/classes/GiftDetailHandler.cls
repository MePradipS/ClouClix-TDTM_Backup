public class GiftDetailHandler {
    public static void RollupTotals(List<Gift_Detail__c> records) {
        Set<Id> giftIds = new Set<Id>();
        Set<Id> eventLevelIds = new Set<Id>();
        for (Gift_Detail__c gd : records) {
            giftIds.add(gd.Gift__c);
        }

        for (Gift_Detail__c gd : records) {
            eventLevelIds.add(gd.Event_Level__c);
        }

        List<Gift__c> gifts = new GiftSelector().SelectTotalAttendeesById(giftIds);
        for (Gift__c g : gifts) {
            Decimal total = 0;
            for (Gift_Detail__c  gd : g.Gift_Allocations__r) {
                total = total + gd.Number_of_Attendees__c;
            }
            g.Total_Attendees_Purchased__c = total;
        }

        DMLManager.UpdateSObjects(gifts);

        Map<id, sObject> giftdetailmap = Trigger.NewMap;

        List<Event_Level__c> event_levels = new EventLevelSelector().SelectQualitySoldById(eventLevelIds);

        for (Gift_Detail__c g : records) {
            if (g.Event_Level__c != null) {
                for (Event_Level__c e : event_levels) {
                    if (e.Id == g.Event_Level__c) {
                        if (e.Quantity_Remaining__c < g.Quantity__c) {
                            giftdetailmap.get(g.Id).AddError('Quantity for ' + e.Name + ' is greater than Available Quantity');
                        }
                    }
                }
            }
        }

        for (Event_Level__c g : event_levels) {
            Decimal total = 0;
            for (Gift_Detail__c  gd : g.Allocations__r) {
                total = total + gd.Quantity__c;
            }
            g.Quantity_Sold__c = total;
        }

        if (event_levels != null && event_levels.size() > 0) {
            DMLManager.UpdateSObjects(event_levels);
        }
    }

    public static void ManageTransactionBenefitsInsert(List<Gift_Detail__c> records) {
        Map<Gift_Detail__c, string> eventLevelToCreate = new Map<Gift_Detail__c, string>();
        List<Transaction_Benefit__c> benefitsToInsert = new List<Transaction_Benefit__c>();
        for (Gift_Detail__c gd : records) {
            eventLevelToCreate.put(gd, gd.Event_Level__c);
        }

        benefitsToInsert = EventBenefitHelper.CreateTransactionBenefits(eventLevelToCreate);
        if (benefitsToInsert.size() > 0) {
            DMLManager.InsertSObjects(benefitsToInsert);
        }
    }

    public static void ManageTransactionBenefitsUpdate(List<Gift_Detail__c> new_records, List<Gift_Detail__c> old_records) {
        Map<Gift_Detail__c, string> eventLevelToCreate = new Map<Gift_Detail__c, string>();
        Set<string> eventLevelToDelete = new Set<string>();
        List<Transaction_Benefit__c> benefitsToInsert = new List<Transaction_Benefit__c>();
        List<Transaction_Benefit__c> benefitsToDelete = new List<Transaction_Benefit__c>();

        for (Integer i = 0; i < new_records.size(); i++) {
            if (new_records[i].Event_Level__c != old_records[i].Event_Level__c) {
                if (new_records[i].Event_Level__c != null) { eventLevelToCreate.put(new_records[i], new_records[i].Event_Level__c); }
                if (old_records[i].Event_Level__c != null) { eventLevelToDelete.add(new_records[i].Id); }
            }
        }

        benefitsToInsert = EventBenefitHelper.CreateTransactionBenefits(eventLevelToCreate);
        benefitsToDelete = EventBenefitHelper.DeleteTransactionBenefits(eventLevelToDelete);
        if (benefitsToInsert.size() > 0) {
            DMLManager.InsertSObjects(benefitsToInsert);
        }

        if (benefitsToDelete.size() > 0) {
            if (Transaction_Benefit__c.sObjectType.getDescribe().isDeletable()) {
                DMLManager.DeleteSObjects(benefitsToDelete);
            }
        }
    }

    public static void ManageTransactionBenefitsDelete(List<Gift_Detail__c> records) {
        List<Transaction_Benefit__c> benefitsToDelete = new List<Transaction_Benefit__c>();
        Set<string> eventLevelToDelete = new Set<string>();

        for (Gift_Detail__c gd : records) {
            if (gd.Event_Level__c != null) {
                eventLevelToDelete.add(gd.Id);
            }
        }

        benefitsToDelete = EventBenefitHelper.DeleteTransactionBenefits(eventLevelToDelete);
        if (benefitsToDelete.size() > 0) {
            if (Transaction_Benefit__c.sObjectType.getDescribe().isDeletable()) {
                DMLManager.DeleteSObjects(benefitsToDelete);
            }
        }
    }
}