trigger updateActiveGiftAmount on Recurring_Donation__c (after update, after delete) {
    List <Gift__c> activeGifts = new List<Gift__c>();
    if(Trigger.isDelete)
        activeGifts = new GiftSelector().SelectRecurringDonationAmountById(Trigger.oldMap.keyset());
    else
        activeGifts = new GiftSelector().SelectRecurringDonationAmountByIdForUpdate(Trigger.oldMap.keyset());
    for (Gift__c g : activeGifts)
    {
        g.Expected_Amount__c = g.Recurring_Donation__r.Amount__c;
    }

    if (activeGifts != null && activeGifts.size() > 0) {
        DMLManager.UpdateSObjects(activeGifts);
    }
}