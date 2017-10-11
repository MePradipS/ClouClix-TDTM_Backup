public class CTDTM_VolunteerHourTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
* @param listNew the list of Volunteer_Hours__c from trigger new. 
* @param listOld the list of Volunteer_Hours__c from trigger old. 
* @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
* @param objResult the describe for Volunteer_Hours__c 
* @return dmlWrapper.  always null.
******************************************************************************************************* */
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
                                   CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        Set<String> HourIDs = new Set<String>();
        if (triggerAction == CTDTM_Runnable.Action.AfterDelete)
        {
             for(Volunteer_Hours__c vh: (List<Volunteer_Hours__c>)listOld) 
             {
                 if (!VolunteerUtil.isEmptyOrNull(vh.Id) && !HourIDs.contains(vh.Id))
                 HourIDs.add(vh.Id);     
             }
        }
        if(triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUndelete)
        {
             for(Volunteer_Hours__c vh : (List<Volunteer_Hours__c>)listNew) 
             {
                 if (!VolunteerUtil.isEmptyOrNull(vh.Id) && !HourIDs.contains(vh.Id))
                 HourIDs.add(vh.Id);     
             }
        }
        if (HourIDs.size()>0)
        { 
            VolunteerUtil.RollupHours(HourIDs);
        }
        return null;
    }
}