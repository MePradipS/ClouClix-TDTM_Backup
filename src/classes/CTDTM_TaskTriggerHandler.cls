public class CTDTM_TaskTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Tasks from trigger new. 
    * @param listOld the list of Tasks from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Tasks 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
          Set<Id> individualIds = new Set<Id>();
          BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
          if(settings.Data_Migration_Mode__c) 
              return null;
          
            if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUndelete)
            {
                for(Task t : (List<Task>)listNew) 
                {
                    if (t.WhoId!=null && ((string)t.WhoId).startsWith('003') && !individualIds.contains(t.WhoId))
                        individualIds.add(t.WhoId);
                }
            }
            else if (triggerAction == CTDTM_Runnable.Action.AfterUpdate)
            {
                integer i = 0;
                for(Task t : (List<Task>)listNew)
                {
                    if (t.WhoId!=null && ((string)t.WhoId).startsWith('003') && !individualIds.contains(t.WhoId))
                       individualIds.add(t.WhoId);
                    if (t.WhoId==null && listOld[i].get('WhoId')!=null) 
                    {
                       string oldWhoId = String.valueOf(listOld[i].get('WhoId'));
                        if (!individualIds.contains(oldWhoId) && oldWhoId.startsWith('003'))
                            individualIds.add(oldWhoId);
                    }
                    i++;
                }
            }
            else if(triggerAction == CTDTM_Runnable.Action.AfterDelete)
            {
                for(Task t : (List<Task>)listOld)
                {
                    if (t.WhoId!=null && ((string)t.WhoId).startsWith('003') && !individualIds.contains(t.WhoId))
                        individualIds.add(t.WhoId);
                }
            }
            if (individualIds.size()<=0) 
              return null;

            AggregateResult[] results = new TaskSelector().SelectTaskByIds(individualIds);
            if (results==null || results.size()<=0) 
              return null;
            List<Contact> itemsToUpdate = new List<Contact>();
            Map<string,string> trackedTaskTypes = new Map<string,string>();
            trackedTaskTypes.put('Phone Call','Steward_Phone_Calls__c');
            trackedTaskTypes.put('Call','Steward_Phone_Calls__c');
            trackedTaskTypes.put('Personal Letter','Steward_Acknowledgement_Letter__c');
            trackedTaskTypes.put('Automated Email','Steward_Emails__c');
            trackedTaskTypes.put('Email','Steward_Emails__c');
            trackedTaskTypes.put('Personal Email','Steward_Personal_Emails__c');
            trackedTaskTypes.put('Face to Face Meeting','Steward_Face_to_Face_Meetings__c');
            trackedTaskTypes.put('Meeting','Steward_Face_to_Face_Meetings__c');

            for(string contactId : individualIds) 
            {
                boolean isFound = false;
                Contact c = new Contact(Id=contactId);

                for(AggregateResult result : results)
                {
                    if (result.get('WhoId') == contactId && trackedTaskTypes.containsKey((string)result.get('Type'))) 
                    {
                        c.put(trackedTaskTypes.get((string)result.get('Type')), result.get('cnt'));
                        isFound = true;
                    }
                }
                if (isFound) 
                    itemsToUpdate.add(c);
            }

            if (itemsToUpdate.size()>0) 
                update itemsToUpdate;     
        return null;
    }
        
}