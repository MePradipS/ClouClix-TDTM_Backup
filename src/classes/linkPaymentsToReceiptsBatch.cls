global with sharing class linkPaymentsToReceiptsBatch implements Database.Batchable<sObject> {
    global Database.Querylocator start(Database.BatchableContext BC) {
        return new GiftSelector().SelectGiftIdByPaymentIdAndStatus();
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Payment__c> paymentsToUpdate = new List<Payment__c>();
        for(sObject each : scope) {
            Gift__c gift = (Gift__c)each;

            if(gift.Receipts__r != null && gift.Receipts__r.size() > 0 && gift.Recurring_Payments__r.size() > 0) {
                for(Payment__c payment : gift.Recurring_Payments__r){
                    payment.Receipt__c = gift.Receipts__r[0].Id;
                    paymentsToUpdate.add(payment);
                }
            }
        }
        if(paymentsToUpdate.size() > 0) {
            DMLManager.UpdateSObjects(paymentsToUpdate);
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}