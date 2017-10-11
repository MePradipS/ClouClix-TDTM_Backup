trigger updateTransactionStatus on Recurring_Donation__c (after insert, after update) {
    set<Id> rdIds = new set<Id>();
    for (Recurring_Donation__c rd : trigger.new)
    {
        if (rd.Status__c == 'Cancelled')
        {
            rdIds.add(rd.id);
        }
    }
    if(rdIds.size() > 0){
        List<Gift__c> gifts = new GiftSelector().SelectGiftStatusWhereDonationInIDs(rdIds);
        for (Gift__c gift : gifts)
        {
            gift.Status__c = 'Payment Received';
        } 

        if (gifts != null && gifts.size() > 0) {
            DMLManager.UpdateSObjects(gifts);
        }
    }
    
}