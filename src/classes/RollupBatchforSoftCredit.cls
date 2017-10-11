global with sharing class RollupBatchforSoftCredit implements Database.Batchable<sObject>, Database.Stateful {

    global string query;
    global DateTime previousRunTime;
    global set<String> cid = new set<String>();
    Map<Id, List<Solicitor__c>> softCreditMap = new Map<Id, List<Solicitor__c>>();
    global List<Contact> contactRec = new List<Contact>();
    Set<Id> conId = new Set<Id>();
    global Map<Id, List<Gift__c>> giftMap = new Map<Id, List<Gift__c>>();
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {

        for(Solicitor__c g : (List<Solicitor__c>)scope){
            if(!softCreditMap.containsKey(g.Solicitor__c)){
                softCreditMap.put(g.Solicitor__c, new List<Solicitor__c>());
            }
            softCreditMap.get(g.Solicitor__c).add(g);
        }

    }
    // Reschedule the job for an hour from now
    global void finish(Database.BatchableContext BC)
    {
    }
}