trigger updateAllocationGAEligibleField on Fund__c (after update, after delete) {
    new TriggerHandler()
        .bind(TriggerHandler.Evt.afterupdate, new FundAfterUpdateHandler())
        .bind(TriggerHandler.Evt.afterdelete, new FundAfterDeleteHandler())
        .manage();
    //Just a comment to flag git
}