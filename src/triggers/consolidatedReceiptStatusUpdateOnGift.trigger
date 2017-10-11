/*
* @author Nitin Khunal
* @date 20/10/2014
* @Trigger to update Transaction Status when consolidated receipt is created
* @description Trigger to update Transaction Status to "Acknowledged" when consolidated receipt is created and has a status of "Issued".
*/
trigger consolidatedReceiptStatusUpdateOnGift on Receipt__c (after insert) {
    set<Id> giftIds = new Set<Id>();
    set<Id> giftIdsForPayUpdate = new Set<Id>();
    List<Gift__c> giftListToUpdate = new List<Gift__c>();
    map<string, list<Receipt__c>> giftToReceipt = new map<string, list<Receipt__c>>();
    for(Receipt__c r : Trigger.New){
        if(r.Receipt_Type__c == 'Consolidated' && r.Status__c == 'Issued'){
            giftIds.add(r.Gift__c);
        }
        giftIdsForPayUpdate.add(r.Gift__c);
        if (giftToReceipt.containsKey(r.Gift__c)){
            giftToReceipt.get(r.Gift__c).add(r);
        }else{
            list<Receipt__c> tempRecList= new list<Receipt__c>();
            tempRecList.add(r);
            giftToReceipt.put(r.Gift__c, tempRecList);
        }
    }
    if(giftIds.size() > 0){
        Map<Id, Gift__c> gift_Record_Map = new Map<Id, Gift__c>(new GiftSelector().SelectStatusById(giftIds));
        for(Receipt__c r : Trigger.New){
            if(gift_Record_Map.get(r.Gift__c) != null){
                Gift__c gift = gift_Record_Map.get(r.Gift__c);
                gift.Status__c = 'Acknowledged';
                giftListToUpdate.add(gift);
            }
        }
        if(giftListToUpdate.size() > 0) {
            DMLManager.UpdateSObjects(giftListToUpdate);
        }
    }

    //shridhar- user story :-'The trigger to create the Receipt lookup on the Payment record does not work with the form submission;
    //this code is to just populate reciept in payment when gift is created by form submission


    list<payment__c> paymentsToBeUpdated = new list<payment__c>();
    if(giftIdsForPayUpdate.size()>0){
        paymentsToBeUpdated = new PaymentSelector().SelectReciptByReciptId(giftIdsForPayUpdate);
    }
    if(paymentsToBeUpdated.size()>0){
            for(payment__c p :paymentsToBeUpdated){
                for(Receipt__c r : giftToReceipt.get(p.Donation__c)){
                    if(p.Amount__c == r.Receipt_Amount__c && p.Receipt__c ==null && r.Receipt_Type__c !='Void'){
                        p.Receipt__c = r.id;
                    }
                }
            }
            DMLManager.UpdateSObjects(paymentsToBeUpdated);
        }
}