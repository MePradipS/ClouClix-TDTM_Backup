trigger FormIDs on Campaign (before insert, before update) {
    // -------------------------------------------------------------------------------------------
    // This trigger code has been commented to reduce the probability of getting the Percent of Apex
    // Used limit. 
    // -------------------------------------------------------------------------------------------
    //    Date                Author                 Description
    // -------------------------------------------------------------------------------------------
    // 11-Oct-2017        Pradip Shukla          Initial Version
    // --------------------------------------------------------------------------------------------
    /*FormSettings__c fs = FormSettings__c.getValues('Default');
    
    if (fs != null)
    {
        for (Campaign c : Trigger.new)
        {
            c.Sys_FormIDs__c = fs.Donation__c + ':' + fs.Contact__c + ':' + fs.RSVP__c + ':' + fs.RSVP_Free__c + ':' + fs.RSVP_Free_Public__c;
        }
    }*/
}