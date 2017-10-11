public class AccountTriggerHandler2 extends TDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) 
        {
            OrgContactHandler.PreventBucketDelete(listOld);
        } 
        if (triggerAction == TDTM_Runnable.Action.AfterDelete)   
        {
            OrgRelationships.deleteEmptyRelationships();
        }    
        return null;
    }
}