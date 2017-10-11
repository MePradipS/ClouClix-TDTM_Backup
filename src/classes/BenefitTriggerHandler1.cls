public class BenefitTriggerHandler1 extends TDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Benefits from trigger new. 
    * @param listOld the list of Benefits from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for EventLevels 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
      if (triggerAction == TDTM_Runnable.Action.BeforeUpdate)
        {
         BenefitHandler.UpdateEventLevels(Trigger.new);                        
        }
        return null;
    }
}