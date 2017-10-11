global with sharing class RDPaymentCountBatch implements Database.Batchable<sObject> {

  public string query;
  global Database.Querylocator start(Database.BatchableContext BC)
  {
    String whereClause = 'WHERE LastModifiedDate = yesterday ALL ROWS';
    String fields = 'Donation__c,StatusComment__c,Status__c,Id';

    return new GenericQueryBuilder().getQueryLocator(whereClause, fields, 'Payment__c');
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope)
  {
     Map<ID, Payment__c> scopeMap = new Map<ID, Payment__c>((List<Payment__c>)scope);
     Map<Id, Payment__c> map_GiftId_Payment = new Map<Id,Payment__c>();
     for(Payment__c payment : scopeMap.values())
     {
        if((payment.Status__c == 'Approved' || payment.Status__c == 'Declined') && !map_GiftId_Payment.containsKey(payment.Donation__c))
        {
            map_GiftId_Payment.put(payment.Donation__c,payment);
        }
     }
     recurringGiftFieldUpdateTriggerclass.recurringGiftFieldUpdate(map_GiftId_Payment.keySet());
  }

  global void finish(Database.BatchableContext BC)
  {
  }
}