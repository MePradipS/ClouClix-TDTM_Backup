public class CTDTM_RollupOppStatusTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
* @param listNew the list of Contacts from trigger new. 
* @param listOld the list of Contacts from trigger old. 
* @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
* @param objResult the describe for Contacts 
* @return dmlWrapper.  always null.
********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
                                   CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        Set<String> oppIds = new Set<String>();
        
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            for (Volunteer_Role__c vp : (List<Volunteer_Role__c>)listNew)
            {
                oppIds.add(vp.Volunteer_Opportunity__c);
            }
        }
        if (triggerAction == CTDTM_Runnable.Action.AfterDelete)
        {
            for (Volunteer_Role__c vp : (List<Volunteer_Role__c>)listOld)
            {
                oppIds.add(vp.Volunteer_Opportunity__c);
            }    
        }
        if(oppIds.size() > 0)
            VolunteerUtil.RecalculateOpportunityStatus(oppIds);
        
        return null;
    }
}