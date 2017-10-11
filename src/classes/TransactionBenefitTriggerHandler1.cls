public class TransactionBenefitTriggerHandler1 extends TDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of TransactionBenefits from trigger new. 
    * @param listOld the list of TransactionBenefits from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for EventLevels 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
      if (triggerAction == TDTM_Runnable.Action.AfterDelete) 
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