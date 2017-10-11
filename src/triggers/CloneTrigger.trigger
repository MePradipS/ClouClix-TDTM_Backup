trigger CloneTrigger on Payment__c (after insert) {
    if (trigger.new.size()>1) return;

    list<Payment__c> payments = new PaymentSelector().SelectPaymentTransactionById(trigger.new[0].Id);
    if (payments==null || payments.size()<=0) return;

    Payment__c newPayment = payments[0];
    Gift__c gift = newPayment.Donation__r;
    if (gift==null || gift.Sys_Clone_Transaction__c==null) return;

    List<Gift__c> gifts = new GiftSelector().SelectAllocationByTransactionId(gift.Sys_Clone_Transaction__c);

    if (gifts==null || gifts.size()<=0) return;

    List<Gift_Detail__c> details = gifts[0].Gift_Allocations__r;
    if (details==null || details.size()<=0) return;

    List<Gift_Detail__c> newOnes = new List<Gift_Detail__c>();
    for(Gift_Detail__c giftDetail : details)
    {
        Gift_Detail__c item = giftDetail.clone();

        item.Gift__c = gift.Id;
        if (newPayment.Amount__c!=gifts[0].Amount__c) {
            //amount is different, use radio
            item.Amount__c = (newPayment.Amount__c * giftDetail.Amount__c) / gifts[0].Amount__c;
        }
        item.Payment__c = trigger.new[0].id;
        newOnes.add(item);
    }

    DMLManager.InsertSObjects(newOnes);
}