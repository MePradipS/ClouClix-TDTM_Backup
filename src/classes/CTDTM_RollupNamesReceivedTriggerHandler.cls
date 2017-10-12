public class CTDTM_RollupNamesReceivedTriggerHandler extends CTDTM_Runnable 
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
        Set<Id> transIds = new Set<Id>();
        //BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        //String guestId = settings.Unknown_Guest_Id__c;

        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterDelete)  {
            for (Event_Registration__c er : (List<Event_Registration__c>)listOld) {
                if(er.Transaction__c != null){
                    transIds.add(er.Transaction__c);
                }
            }
        }
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUndelete) 
        {
            for (Event_Registration__c er : (List<Event_Registration__c>)listNew) {
                if(er.Transaction__c != null){
                    transIds.add(er.Transaction__c);
                }
            }
        }
        if(transIds.size() > 0){
          if(!system.isFuture() && !system.isBatch())
            EventRegistrationTrigger.RollupNamesReceivedTrigger(transIds);
        }
        return null;
    }
}