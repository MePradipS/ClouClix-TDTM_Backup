public class CTDTM_updateFundTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Allocations from trigger new. 
    * @param listOld the list of Allocations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Allocations 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.BeforeInsert || triggerAction == CTDTM_Runnable.Action.BeforeUpdate) 
        {
            Set<Id> appealIds = new Set<Id>();
            integer i = 0;
            for(Gift_Detail__c giftDetail : (List<Gift_Detail__c>)listNew)
            {
                if(giftDetail.Fund__c == null && giftDetail.New_Campaign__c <> null)
                {
                    if(triggerAction == CTDTM_Runnable.Action.BeforeInsert)
                        appealIds.add(giftDetail.New_Campaign__c);
                    else if(triggerAction == CTDTM_Runnable.Action.BeforeUpdate && giftDetail.New_Campaign__c <> listOld[i].get('New_Campaign__c'))
                        appealIds.add(giftDetail.New_Campaign__c);
                }
                i++;
            }   
        
            if(appealIds.size() > 0)
            {
                Map<Id, Campaign> appealFund= new Map<Id, Campaign>(new CampaignSelector().SelectIdandFundById(appealIds));
                
                for(Gift_Detail__c giftDetail : (List<Gift_Detail__c>)listNew)
                {
                    if(appealFund.get(giftDetail.New_Campaign__c) != null)
                        giftDetail.Fund__c = appealFund.get(giftDetail.New_Campaign__c).Fund__c;
                }
            }
        }
        return null;
    }
}