global with sharing class CCExpiryBatch implements Database.Batchable<sObject>, Database.Stateful {

    global final Date thirty;
    global final Date fifteen;
    global final Date seven;
    global Integer success;
    global Integer total;
    public string query;

    global CCExpiryBatch()
    {
        thirty = Date.today()+30;
        fifteen = Date.today()+15;
        seven = Date.today()+7;
        success = 0;
        total = 0;
    }

    global Database.Querylocator start(Database.BatchableContext BC) {
        String clause = '';
        String fields = '';

        if (!System.Test.isRunningTest())
        {
          fields = 'Id, Constituent__c, Credit_Card_Expiry_Date__c, Status__c, Amount__c, Reference__c, URL_Safe_Key__c';
          clause = 'WHERE Credit_Card_Expiry_Date__c = \'' + thirty + '\' OR Credit_Card_Expiry_Date__c = \'' + fifteen + ' OR Credit_Card_Expiry_Date__c = \'' + seven;
          return new GenericQueryBuilder().getQueryLocator(clause, fields, 'Recurring_Donation__c');
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        CCExpiryUtil.RenewCCs((List<Recurring_Donation__c>)scope);
    }

    global void finish(Database.BatchableContext BC) {}
}