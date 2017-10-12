public class CTDTM_EventLevelTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of EventLevels from trigger new. 
    * @param listOld the list of EventLevels from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for EventLevels 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        Set<string> eventLevelIds = new Set<string>();
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterUndelete) 
        {
            for (Event_Level__c el : (List<Event_Level__c>)listNew) {
                eventLevelIds.add(el.Event__c);
            }
        }
        if (triggerAction == CTDTM_Runnable.Action.AfterDelete ) 
        {
            for (Event_Level__c el : (List<Event_Level__c>)listOld) {
                eventLevelIds.add(el.Event__c);
            }
            
        }
        if(eventLevelIds.size()>0)
            EventLevelHandler.RollupTotals(eventLevelIds);
        
        return null;
    }
}