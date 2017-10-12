public class CTDTM_updateActiveGiftTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of RecurringGifts from trigger new. 
    * @param listOld the list of RecurringGifts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for RecurringGifts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
            set<Id> triggerOldMapId = new set<Id>();
            for(Recurring_Donation__c objRecurr : (List<Recurring_Donation__c>)listOld)
            {
                triggerOldMapId.add(objRecurr.Id);
            }
            List <Gift__c> activeGifts = new List<Gift__c>();
            if (triggerAction == CTDTM_Runnable.Action.AfterDelete)
            {
                activeGifts = new GiftSelector().SelectRecurringDonationAmountById(triggerOldMapId);
            }
            if (triggerAction == CTDTM_Runnable.Action.AfterUpdate)
            {
                activeGifts = new GiftSelector().SelectRecurringDonationAmountByIdForUpdate(triggerOldMapId);
            }
            for (Gift__c g : activeGifts)
            {
                g.Expected_Amount__c = g.Recurring_Donation__r.Amount__c;
            }

            if (activeGifts != null && activeGifts.size() > 0) 
            {
                DMLManager.UpdateSObjects(activeGifts); 
                
            }
            return null;
        
    }   
    
}