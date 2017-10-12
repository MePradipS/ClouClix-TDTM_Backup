trigger UnknownRegistrations on Gift__c (after insert, after update, after delete, after undelete) {
        // -------------------------------------------------------------------------------------------
        // This trigger code has been commented to reduce the probability of getting the Percent of Apex
        // Used limit. 
        // -------------------------------------------------------------------------------------------
        //    Date                Author                 Description
        // -------------------------------------------------------------------------------------------
        // 11-Oct-2017        Pradip Shukla          Initial Version
        // --------------------------------------------------------------------------------------------
/*    Set<Gift__c> giftIds = new Set<Gift__c>();
    if (Trigger.isUpdate) {
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            if (Trigger.new[i].Attendee_Names_Pending__c != 0 && Trigger.new[i].Attendee_Names_Pending__c != Trigger.old[i].Attendee_Names_Pending__c) {
                giftIds.add(Trigger.new[i]);
            }
        }
    }
    if (Trigger.isDelete) {
        for (Gift__c g : Trigger.old) {
            if (g.Attendee_Names_Pending__c != 0) {
                giftIds.add(g);
            }
        }
    }
    if (Trigger.isInsert || Trigger.isUndelete) {
        for (Gift__c g : Trigger.new) {
            if (g.Attendee_Names_Pending__c != 0) {
                giftIds.add(g);
            }
        }
    }
    
    RollupHelper.GuestRegistrations(giftIds);*/

}