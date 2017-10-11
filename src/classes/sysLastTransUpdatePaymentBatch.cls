global with sharing class sysLastTransUpdatePaymentBatch implements Database.Batchable<sObject>{

    Set<Id> setGiftIds = new Set<Id>();
    global sysLastTransUpdatePaymentBatch(Set<Id> giftIds){
        setGiftIds = giftIds;
    }

    global Database.queryLocator start(Database.BatchableContext BC){
        return new EventRegistrationSelector().SelectLastTransactionStringByGiftId(setGiftIds);
    }

    global void execute(Database.BatchableContext BC, List<Event_Registration__c> eventRegList){
        if(eventRegList.size() > 0) {
            for(Event_Registration__c eventReg: eventRegList)
            {
               eventReg.sysLastTransactionUpdate__c = system.today();
            }
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}