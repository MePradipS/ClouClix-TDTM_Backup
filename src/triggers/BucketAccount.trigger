trigger BucketAccount on Contact (before insert, before update) {  
    // -------------------------------------------------------------------------------------------
    // This trigger code has been commented to reduce the probability of getting the Percent of Apex
    // Used limit. 
    // -------------------------------------------------------------------------------------------
    //    Date                Author                 Description
    // -------------------------------------------------------------------------------------------
    // 11-Oct-2017        Pradip Shukla          Initial Version
    // --------------------------------------------------------------------------------------------     
    /*BatchSettings__c setting = BatchSettings__c.getInstance('Default');
    for (Contact c : Trigger.new)    
    {
        if (c.AccountId == null && setting != null)
        { c.AccountId = setting.BucketAccountId__c; }
    }*/
}