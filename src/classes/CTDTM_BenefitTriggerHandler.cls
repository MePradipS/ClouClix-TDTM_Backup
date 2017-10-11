public class CTDTM_BenefitTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Benefits from trigger new. 
    * @param listOld the list of Benefits from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for EventLevels 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            BenefitHandler.UpdateEventLevels((list<Benefit__c>)listNew);                        
        }
        return null;
    }
}