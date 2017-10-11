//When creating a new receipt from within a Transaction record, populate Constituent and Organization fields of the receipt.

trigger UpdateConstituentAndOrganizationLookups on Receipt__c (before Insert, before Update) {
    List<Id> giftIds = new List<Id>();

    for(Integer i = 0; i < Trigger.new.size(); i++) {
        if(Trigger.new[i].Gift__c != null && (Trigger.new[i].Constituent__c == null && Trigger.new[i].Organization__c == null)) {
            giftIds.add(Trigger.new[i].Gift__c);
        }
    }

    if(giftIds.size() > 0) {
        Map<Id, Gift__c> gifts = new Map<Id, Gift__c>(new GiftSelector().SelectOrganizationAndConstituentWhereIdInIds(giftIds));
        for(Integer i = 0; i < Trigger.new.size(); i++) {
            if(Trigger.new[i].Gift__c != null && (Trigger.new[i].Constituent__c == null && Trigger.new[i].Organization__c == null)) {
                Trigger.new[i].Constituent__c = gifts.get(Trigger.new[i].Gift__c).Constituent__c;
                Trigger.new[i].Organization__c = gifts.get(Trigger.new[i].Gift__c).Organization__c;
            }
        }
    }
}