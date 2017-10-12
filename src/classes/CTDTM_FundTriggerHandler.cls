public class CTDTM_FundTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Funds from trigger new. 
    * @param listOld the list of Funds from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Funds 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterDelete) 
        {
            new TriggerHandler()
            .bind(TriggerHandler.Evt.afterupdate, new FundAfterUpdateHandler())
            .bind(TriggerHandler.Evt.afterdelete, new FundAfterDeleteHandler())
            .manage();
        //Just a comment to flag git
        }
        
        return null;
    }
}