global with sharing class NewYearTransactionScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      
      //activate this year gifts that were created last year
      List<Gift__c> thisYearGifts = new GiftSelector().SelectGiftAndRecurringDonationThisYear();
      
      //recreate last year recurring gifts for this year:
      NewYearTransactionsBatch giftBatch = new NewYearTransactionsBatch();
      Database.executeBatch(giftBatch);
      
   }
}