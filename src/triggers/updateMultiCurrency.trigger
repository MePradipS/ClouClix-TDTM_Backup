trigger updateMultiCurrency on Receipt__c (before insert) {
    RollupHelper.updateCurrency(trigger.new);
}