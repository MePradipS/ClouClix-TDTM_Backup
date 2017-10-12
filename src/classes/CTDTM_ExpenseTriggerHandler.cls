public class CTDTM_ExpenseTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Expenses from trigger new. 
    * @param listOld the list of Expenses from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Expenses 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        Set<String> AppealIDs = new Set<String>();
    
        if (triggerAction == CTDTM_Runnable.Action.AfterDelete ) 
        {
             for(Expense__c ex : (List<Expense__c>)listOld) 
             {
                 if (!RollupHelper.isEmptyOrNull(ex.New_Campaign__c) && !AppealIDs.contains(ex.New_Campaign__c))
                 AppealIDs.add(ex.New_Campaign__c);     
             }
        }
         if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterUndelete) 
         {
              for(Expense__c ex : (List<Expense__c>)listNew) 
             {
                 if (!RollupHelper.isEmptyOrNull(ex.New_Campaign__c) && !AppealIDs.contains(ex.New_Campaign__c))
                 AppealIDs.add(ex.New_Campaign__c);     
             }
         }
            
        
        if (AppealIDs.size()>0)
        { 
            AppealUtil.RollupExpenses(AppealIDs);
        }   
        return null;
    }
}