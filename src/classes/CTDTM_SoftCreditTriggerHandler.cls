public class CTDTM_SoftCreditTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of SoftCredits from trigger new. 
    * @param listOld the list of SoftCredits from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for SoftCredits 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        Set<Id> contactIds = new Set<Id>();
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUndelete || triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            for(Solicitor__c item : (List<Solicitor__c>)listNew)
            {
                if (!contactIds.contains(item.Solicitor__c) && !RollupHelper.IsEmptyOrNull(item.Solicitor__c))
                    contactIds.add(item.Solicitor__c);
            }
        }
        else if (triggerAction == CTDTM_Runnable.Action.AfterDelete)
        {
            for(Solicitor__c item : (List<Solicitor__c>)listOld)
            {
                if (!contactIds.contains(item.Solicitor__c) && !RollupHelper.IsEmptyOrNull(item.Solicitor__c))
                    contactIds.add(item.Solicitor__c);
            }
        }
        
        if (contactIds.size()>0)
            RollupHelper.RecalculateTotalGiving(contactIds);    
        
        return null;
    }
        
}