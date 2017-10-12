trigger RollupTotalGivingSolicits on Solicitor__c (after delete, after insert, after undelete, 
after update) {
    
    Set<Id> contactIds = new Set<Id>();
    
    if (trigger.isInsert || trigger.isUnDelete || trigger.isUpdate)
    {
        for(Solicitor__c item : trigger.new)
          if (!contactIds.contains(item.Solicitor__c) && !RollupHelper.IsEmptyOrNull(item.Solicitor__c))
             contactIds.add(item.Solicitor__c);
    }
    else if (trigger.isDelete)
    {
        for(Solicitor__c item : trigger.old)
          if (!contactIds.contains(item.Solicitor__c) && !RollupHelper.IsEmptyOrNull(item.Solicitor__c))
             contactIds.add(item.Solicitor__c);
    }
    
    if (contactIds.size()>0)
      RollupHelper.RecalculateTotalGiving(contactIds);
      
}