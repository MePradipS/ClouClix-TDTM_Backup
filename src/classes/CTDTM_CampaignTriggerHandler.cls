public class CTDTM_CampaignTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.BeforeInsert || triggerAction == CTDTM_Runnable.Action.BeforeUpdate) 
        {
            List<RecordType> rt = new RecordTypeSelector().SelectRecordsByNameNamespacePrefixAndName(Utilities.getCurrentNamespace(), 'Campaign');

            Set<String> CIDs = new Set<String>();
            Map<String, String> cmp_to_par_rt = new Map<String, String>();

            for (Campaign c : (List<Campaign>)listNew)
            {
                CIDs.add(c.ParentId);
            }

            for (Campaign c : new CampaignSelector().SelectIdById(Utilities.ConvertStringSetToIdSet(CIDs)))
            {
                cmp_to_par_rt.put(c.Id, c.RecordTypeId);
            }

            if (rt.size() > 0)
            {
                for (Campaign c : (List<Campaign>)listNew)
                {
                    if (cmp_to_par_rt.get(c.ParentId) == rt[0].Id)
                    { c.ParentAppeal__c = True; }

                    if (cmp_to_par_rt.get(c.ParentId) != rt[0].Id)
                    { c.ParentAppeal__c = False; }
                }
            }
        }
        return null;
    }
}