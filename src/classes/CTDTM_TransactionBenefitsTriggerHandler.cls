public class CTDTM_TransactionBenefitsTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of TransactionBenefits from trigger new. 
    * @param listOld the list of TransactionBenefits from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for TransactionBenefits 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterDelete) 
        {
            TransactionBenefitHandler.RollupTotals((List<Transaction_Benefit__c>)listOld);
        }
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterUndelete) 
        {    
            TransactionBenefitHandler.RollupTotals((List<Transaction_Benefit__c>)listNew);
        }           
        return null;
    }
}