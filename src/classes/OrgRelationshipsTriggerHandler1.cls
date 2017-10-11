public class OrgRelationshipsTriggerHandler1 extends TDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of AffiliatedOrganizations from trigger new. 
    * @param listOld the list of AffiliatedOrganizations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Contacts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == TDTM_Runnable.Action.BeforeInsert)
        {
            OrgRelationships process = new OrgRelationships(listNew, listOld, 0);
        }
        if (triggerAction == TDTM_Runnable.Action.AfterInsert) 
        {
            OrgRelationships process = new OrgRelationships(listNew, listOld, 3);
        }
        if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) 
        {
            OrgRelationships process = new OrgRelationships(listNew, listOld, 1);
        }
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) 
        {
            OrgRelationships process = new OrgRelationships(listNew, listOld, 4);
        }
        /*if (triggerAction == TDTM_Runnable.Action.AfterUpdate) 
        {
            OrgRelationships process = new OrgRelationships(listNew, listOld, 4);
        }*/
        if (triggerAction == TDTM_Runnable.Action.AfterDelete) 
        {
            OrgRelationships process = new OrgRelationships(listOld, null, 5);
        }   

        return null;
    }
}