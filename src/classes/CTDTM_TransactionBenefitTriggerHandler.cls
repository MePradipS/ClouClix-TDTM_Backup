public class CTDTM_TransactionBenefitTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of TransactionBenefits from trigger new. 
    * @param listOld the list of TransactionBenefits from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for EventLevels 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
      if (triggerAction == CTDTM_Runnable.Action.AfterDelete) 
         {
           TransactionBenefitHandler.RollupTotals(listOld);
         }
     else 
        {    
           TransactionBenefitHandler.RollupTotals(listNew);
        }
        return null;
    }
}