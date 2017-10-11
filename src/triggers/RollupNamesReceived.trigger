trigger RollupNamesReceived on Event_Registration__c (after insert, after update, after delete, after undelete) {
    //if(system.isBatch()!=true){

        Set<Id> transIds = new Set<Id>();
        //BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        //String guestId = settings.Unknown_Guest_Id__c;

        if (Trigger.IsDelete || Trigger.IsUpdate ) {
            for (Event_Registration__c er : Trigger.old) {
                if(er.Transaction__c != null){
                    transIds.add(er.Transaction__c);
                }
            }
        }
        else {
            for (Event_Registration__c er : Trigger.new) {
                if(er.Transaction__c != null){
                    transIds.add(er.Transaction__c);
                }
            }
        }
        if(transIds.size() > 0){
        	if(!system.isFuture() && !system.isBatch())
            EventRegistrationTrigger.RollupNamesReceivedTrigger(transIds);
        }

}