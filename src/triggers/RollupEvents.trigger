trigger RollupEvents on Event_Registration__c (after insert, after update, after delete, after undelete) {
        Set<String> ContactIDs = new Set<String>();

        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)
        {
            for (Event_Registration__c er : Trigger.new)
            {
                ContactIDs.add(er.Individual__c);
            }
        }

        if (Trigger.isDelete)
        {
            for (Event_Registration__c er : Trigger.old)
            {
                ContactIDs.add(er.Individual__c);
            }
        }

        if(ContactIDs.size() > 0){
        	if(!system.isFuture() && !system.isBatch())
            EventRegistrationTrigger.RollupNamesReceivedTrigger(ContactIDs);
        }
}