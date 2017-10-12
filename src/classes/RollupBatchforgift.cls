global with sharing class RollupBatchforgift implements Database.Batchable<sObject>, Database.Stateful {

    global string query;
    global set<String> cid1 = new set<String>();
    Map<Id, List<Gift__c>> gift = new Map<Id, List<Gift__c>>();
    global List<Contact> con = new List<Contact>();
    Set<Id> conId = new Set<Id>();
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        for(Gift__c g : (List<Gift__c>)scope){
            if(!gift.containsKey(g.Constituent__c)){
                gift.put(g.Constituent__c, new List<Gift__c>());
            }
            gift.get(g.Constituent__c).add(g);
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        RollupBatchforSoftCredit r = new RollupBatchforSoftCredit();
        r.cid.addAll(cid1);
        r.contactRec.addAll(con);
        r.giftMap.putAll(gift);
        r.query = new SolicitorSelector().SelectById(r.cid);//'Select Id, Amount__c, Solicitor__c, Gift_Date__c, Gift_Status__c From Solicitor__c where Solicitor__c IN: cid';
        Database.executeBatch(r);
    }
}