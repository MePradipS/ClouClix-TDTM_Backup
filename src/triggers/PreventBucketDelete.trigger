trigger PreventBucketDelete on Account (before delete, before update) {
    // -------------------------------------------------------------------------------------------
    // This trigger code has been commented to reduce the probability of getting the Percent of Apex
    // Used limit. 
    // -------------------------------------------------------------------------------------------
    //    Date                Author                 Description
    // -------------------------------------------------------------------------------------------
    // 11-Oct-2017        Pradip Shukla          Initial Version
    // --------------------------------------------------------------------------------------------
    /*BatchSettings__c settingList = BatchSettings__c.getInstance('Default');
    
    if (Trigger.isDelete)
    {
        for (Account a : Trigger.old)
        {
            if (a.Id == settingList.BucketAccountId__c && settingList.LockBucketAccount__c == True)
            { a.addError('Cannot delete the Individual Bucket Account!'); }
        }
    }
    if (Trigger.isUpdate)
    {
        List<Account> aOld = Trigger.old;
        List<Account> aNew = Trigger.new;
        
        for (Integer i = 0; i < Trigger.new.size(); i++)
        {
            if (aNew[i].Id == settingList.BucketAccountId__c && settingList.LockBucketAccount__c == True && (aNew[i].Name != aOld[i].Name))
            { aNew[i].addError('Cannot modify the Individual Bucket Account!'); }
        }
    }*/
}