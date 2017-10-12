trigger EventLevel on Event_Level__c (after insert, after update, after delete, after undelete) {
    Set<string> eventLevelIds = new Set<string>();
    if (Trigger.isDelete) {
        for (Event_Level__c el : Trigger.old) {
            eventLevelIds.add(el.Event__c);
        }
    }
    else {
        for (Event_Level__c el : Trigger.new) {
            eventLevelIds.add(el.Event__c);
        }    
    }
    EventLevelHandler.RollupTotals(eventLevelIds);
}