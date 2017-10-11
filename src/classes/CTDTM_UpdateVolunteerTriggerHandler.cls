public class CTDTM_UpdateVolunteerTriggerHandler extends CTDTM_Runnable 
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
         if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            VolunteerUtil.updateVolunteerProfile((list<Volunteer_Application__c>)listNew);
        }
        return null;
    }
}