/*
This trigger updates the information for Receipt that has been Void. In this trigger we are updating the Receipt Status to Void,
Receipt Custom Amount with Receipt Amount and removing the payment records relationship with receipt record.
*/
trigger voidDetailUpdateOnReceiptTrigger on Receipt__c (before insert, before update) {
    set<Id> receiptIds = new set<Id>();
    Map<String, String> rtypes_Map = new Map<String, String>();
    List <RecordType> rtypeList = new RecordTypeSelector().SelectBySObjectAndName('Receipt__c', 'Void');
    for(RecordType recType : rtypeList){
        rtypes_Map.put(recType.Name, recType.Id);
    }
    for(Receipt__c r : Trigger.new){
        if(r.RecordTypeId == rtypes_Map.get('Void')){
            r.Status__c = 'Void';
            r.Amount_Receipted__c = r.Receipt_Amount__c;
            receiptIds.add(r.id);
        }
    }

    List<Payment__c> paymentRecords = new PaymentSelector().SelectReciptByReciptId(receiptIds);
    if(paymentRecords.size() > 0){
        for(Payment__c p : paymentRecords){
            p.Receipt__c = null;
        }
        DMLManager.UpdateSObjects(paymentRecords);
    }
}