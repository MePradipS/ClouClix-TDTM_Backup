trigger BucketAccount on Contact (before insert, before update) {       
    /*BatchSettings__c setting = BatchSettings__c.getInstance('Default');
    for (Contact c : Trigger.new)    
    {
        if (c.AccountId == null && setting != null)
        { c.AccountId = setting.BucketAccountId__c; }
    }*/
}