trigger checkDuplicateGiftBatchNameTrigger on Gift_Batch__c (before insert) {
    Set<String> giftBatchName = new Set<String>();
    for(Gift_Batch__c g : Trigger.New){
        giftBatchName.add(g.Name__c);
    }
    List<Gift_Batch__c> giftBatchRecordList = new GiftBatchSelector().SelectGiftNameByName(giftBatchName);

    if(giftBatchRecordList.size() > 0){
        for(Gift_Batch__c giftBatch : trigger.New){
            for(Gift_Batch__c giftBatchList : giftBatchRecordList){
                if(giftBatch.Name__c == giftBatchList.Name__c){
                    giftBatch.addError('Name already Exist!'); //
                }
            }
        }
    }
}