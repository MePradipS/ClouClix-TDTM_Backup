trigger RollupTotals on Expense__c (after delete, after insert, after undelete, 
after update) {
    
    Set<String> AppealIDs = new Set<String>();
    
    if (Trigger.isDelete)
    {
         for(Expense__c ex : trigger.old) 
         {
             if (!RollupHelper.isEmptyOrNull(ex.New_Campaign__c) && !AppealIDs.contains(ex.New_Campaign__c))
             AppealIDs.add(ex.New_Campaign__c);     
         }
    }
    else
    {
         for(Expense__c ex : trigger.new) 
         {
             if (!RollupHelper.isEmptyOrNull(ex.New_Campaign__c) && !AppealIDs.contains(ex.New_Campaign__c))
             AppealIDs.add(ex.New_Campaign__c);     
         }
    }
    
    if (AppealIDs.size()>0)
    { 
        AppealUtil.RollupExpenses(AppealIDs);
    }
}