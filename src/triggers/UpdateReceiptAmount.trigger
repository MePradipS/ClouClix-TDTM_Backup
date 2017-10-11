/*Recalculate and update the associated Receipt Amount if,
    1. Payment Amount is updated,
    2. A payment is removed from a consolidated receipt and,
    3. A payment is added to a consolidated receipt.
*/
trigger UpdateReceiptAmount on Payment__c (after update, after insert) {
    Set<Id> receiptIds = new Set<Id>();

        //List all the Receipt Ids from the Updated Payment records (If a payment is updated or added to consolidated receipt).
    for (Payment__c payment : Trigger.new) {
        if(payment.Receipt__c != null) {
            receiptIds.add(payment.Receipt__c);
        }
    }

        //List all the Receipt Ids from the Payment records to be Updated (If a payment is removed from consolidated receipt).
    if(Trigger.isUpdate) {
        for (Payment__c payment : Trigger.old) {
            if(payment.Receipt__c != null) {
                receiptIds.add(payment.Receipt__c);
            }
        }
    }
}