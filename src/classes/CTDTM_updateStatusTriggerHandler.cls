public class CTDTM_updateStatusTriggerHandler extends CTDTM_Runnable 
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
        Set<string> contactIds = new Set<string>(); 
        Set<string> eventIds = new Set<string>();         
        Map<string, CampaignMember> clist = new Map<string, CampaignMember>();
        List<CampaignMember> cmToUpdate = new List<CampaignMember>();
        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterUndelete)  
        {
            for (Event_Registration__c er: (List<Event_Registration__c>)listNew)
            {   
                if (!contactIds.contains(er.Individual__c)) contactIds.add(er.Individual__c);
                if (!eventIds.contains(er.Event__c)) eventIds.add(er.Event__c);
            }
            
            for (CampaignMember cms: new CampaignMemberSelector().SelectCampaignAndContactIdWhereIdInIds(Utilities.ConvertStringSetToIdSet(contactIds), Utilities.ConvertStringSetToIdSet(eventIds)))
            {
                if (!clist.containsKey(cms.ContactId)) clist.put(cms.ContactId, cms);
            }
            
            for (Event_Registration__c er: (List<Event_Registration__c>)listNew)
            {            
                CampaignMember cm = new CampaignMember();
                if (clist.get(er.Individual__c) != null) 
                {            
                    cm = clist.get(er.Individual__c);        
                    cm.Status = 'Responded';
                    cmToUpdate.add(cm);
                }
                else {
                    cm.Status = 'Responded';
                    cm.ContactId = er.Individual__c;
                    cm.CampaignId = er.Event__c;
                    cmToUpdate.add(cm);            
                }
            }
            
            try {
                if (cmToUpdate != null & cmToUpdate.size() > 0) 
                {
                    DMLManager.UpsertSObjects(cmToUpdate);   
                }
            }
            catch(Exception ex){
            }
        }
        
        if (triggerAction == CTDTM_Runnable.Action.AfterDelete ) 
        {
            for (Event_Registration__c er: (List<Event_Registration__c>)listOld)
            {    
            contactIds.add(er.Individual__c);
            eventIds.add(er.Event__c);
            }
            
            for (CampaignMember cms: new CampaignMemberSelector().SelectCampaignAndContactIdWhereIdInIds(Utilities.ConvertStringSetToIdSet(contactIds), Utilities.ConvertStringSetToIdSet(eventIds)))
            {
                clist.put(cms.ContactId, cms);
            }
            
            for (Event_Registration__c er: (List<Event_Registration__c>)listOld){            
                CampaignMember cm = new CampaignMember();
                if (clist.get(er.Individual__c) != null) {            
                    cm = clist.get(er.Individual__c);        
                    cm.Status = 'Sent';
                    cmToUpdate.add(cm);
                }
            }
            
            DMLManager.UpdateSObjects(cmToUpdate);
        }
        return null;
    }
}