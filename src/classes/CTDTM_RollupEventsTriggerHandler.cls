public class CTDTM_RollupEventsTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of EventRegistrations from trigger new. 
    * @param listOld the list of EventRegistrations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for EventRegistrations 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        Set<String> ContactIDs = new Set<String>();
        
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterUndelete) 
        {
            for (Event_Registration__c er : (List<Event_Registration__c>)listNew)
            {
                ContactIDs.add(er.Individual__c);
            }
        }

        if (triggerAction == CTDTM_Runnable.Action.AfterDelete)
        {
            for (Event_Registration__c er : (List<Event_Registration__c>)listOld)
            {
                ContactIDs.add(er.Individual__c);
            }
        }

        if(ContactIDs.size() > 0){
          if(!system.isFuture() && !system.isBatch())
            EventRegistrationTrigger.RollupNamesReceivedTrigger(ContactIDs);
        }
        return null;
    }
}