public class CTDTM_AffiliatedOrgaTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of AffiliatedOrganizations from trigger new. 
    * @param listOld the list of AffiliatedOrganizations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for AffiliatedOrganizations 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.BeforeInsert)
        {
            OrgRelationships process = new OrgRelationships(listNew,listOld,0);
        }
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert)
        {
            OrgRelationships process = new OrgRelationships(listNew,listOld, 3);
        }
        if (triggerAction == CTDTM_Runnable.Action.BeforeUpdate)
        {
            OrgRelationships process = new OrgRelationships(listNew,listOld, 1);
        }
        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            OrgRelationships process = new OrgRelationships(listNew,listOld, 4);
        }
        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            OrgRelationships process = new OrgRelationships(listNew,listOld, 4);
        }
        if (triggerAction == CTDTM_Runnable.Action.AfterDelete)
        {
            OrgRelationships process = new OrgRelationships(listOld, null, 5);
        }   
        return null;
    }
        
}