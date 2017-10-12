public class CTDTM_RDHeirachyUpdatesTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of RecurringGiftAllocations from trigger new. 
    * @param listOld the list of RecurringGiftAllocations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for RecurringGiftAllocations 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if(triggerAction == CTDTM_Runnable.Action.BeforeInsert || triggerAction == CTDTM_Runnable.Action.BeforeUpdate)
        {
            List<RecordType> rts = new RecordTypeSelector().SelectRecordBySObjectAndNamespace('Campaign', Utilities.getCurrentNamespace());
            Set<String> GDIDs = new Set<String>();
            Map<String, Id> rt_map = new Map<String, Id>();

            for (RecordType rt : rts)
            {
                rt_map.put(rt.Name, rt.Id);
            }

            for (RD_Allocation__c gd : (List<RD_Allocation__c>)listNew)
            {
                GDIDs.add(gd.New_Campaign__c);
            }

            if (GDIDs.size() > 0)
            {
                Map<Id, Campaign> camp_map = new Map<Id, Campaign>(new CampaignSelector().SelectParentIds(GDIDs));

                for (RD_Allocation__c gd : (List<RD_Allocation__c>)listNew)
                {
                    if (camp_map.get(gd.New_Campaign__c) != null)
                    {
                        if (camp_map.get(gd.New_Campaign__c).Parent.RecordTypeId == rt_map.get('Campaign'))
                        {
                            gd.Campaign__c = camp_map.get(gd.New_Campaign__c).ParentId;
                        }
                        if (camp_map.get(gd.New_Campaign__c).Parent.RecordTypeId == rt_map.get('Appeal'))
                        {
                            gd.Campaign__c = camp_map.get(gd.New_Campaign__c).Parent.ParentId;
                            gd.Parent_Appeal__c = camp_map.get(gd.New_Campaign__c).ParentId;
                        }
                    }
                }
            }
        }
        return null;
    }
}