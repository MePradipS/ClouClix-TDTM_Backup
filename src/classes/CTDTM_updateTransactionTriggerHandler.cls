public class CTDTM_updateTransactionTriggerHandler extends CTDTM_Runnable 
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
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            set<Id> rdIds = new set<Id>();
            for (Recurring_Donation__c rd : (List<Recurring_Donation__c>)listNew)
            {
                if (rd.Status__c == 'Cancelled')
                    rdIds.add(rd.id);
            }
            if(rdIds.size() > 0)
            {
                List<Gift__c> gifts = new GiftSelector().SelectGiftStatusWhereDonationInIDs(rdIds);
                for (Gift__c gift : gifts)
                {
                    gift.Status__c = 'Payment Received';
                } 

                if (gifts != null && gifts.size() > 0)
                    DMLManager.UpdateSObjects(gifts);
            }
        }
        return null;
    }
}