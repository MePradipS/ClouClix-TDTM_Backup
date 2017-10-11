/*Payment Reassign Script batch class
Check all Payments belonging to Transactions that are linked to Recurring Gifts
Verify the Payment year matches with the Transaction year
If the years do not match, then reassign the Payment and Allocations to the correct Transaction
Payment in 2013 is linked to Transaction in 2013
Payment in 2014 is linked to Transaction in 2014
This only applies to Transactions with Recurring Gift lookup populated.
This batch class maps all the payments with transactions according to year for a recurring gift.
*/
global with sharing class paymentUpdateBatchable implements Database.Batchable<sObject>, Database.stateful {
    String logFileData = '';
    //In start method querying all the recurring gifts
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return new RecurringDonationSelector().LocateRecurringDonationGiftInfo();
    }
    //In execute method, performing operations over reurring gifts fetched in start method
    global void execute(Database.BatchableContext BC, List<Recurring_Donation__c> scope) {


        Map<Id, Map<Integer, List<Gift__c>>> recurringGiftMap = new Map<Id, Map<Integer, List<Gift__c>>>();
        set<Id> rgId = new set<Id>();
        List<Gift_Detail__c> updateAllocationList = new List<Gift_Detail__c>();
        Set<Gift_Detail__c> updateAllocationSet = new Set<Gift_Detail__c>();
        List<Gift_Detail__c> updateAllocationList2 = new List<Gift_Detail__c>();
        List<Gift__c> giftInsert = new List<Gift__c>();
        //Adding reurring gift ids fetched in start method in Set of Id type
        for (Recurring_Donation__c rg : scope) {
            rgId.add(rg.Id);
        }
        List<Payment__c> paymentRecord = new List<Payment__c>();
        Set<Payment__c> paymentRecordSet = new Set<Payment__c>();
        List<Payment__c> paymentRecordToUpdate = new List<Payment__c>();
        //Query all the payments of whose "Donation__r.Recurring_Donation__c" id in rgId set
        paymentRecord = new PaymentSelector().SelectRelatedGiftById(rgId);

        //Putting values to "recurringGiftMap" Map
        for (Recurring_Donation__c recurringGift : scope) {  //for loop for recurring gifts fetched in start Method
            if (!recurringGiftMap.containsKey(recurringGift.Id)) {  //checking recurringGiftMap already contains "recurringGift.Id" or not
                recurringGiftMap.put(recurringGift.id, new Map<Integer, List<Gift__c>>()); // if recurringGiftMap not contains the "recurringGift.id", then put it into recurringGiftMap
            }
            for (Gift__c gift : recurringGift.Orders__r) {  //for loop for child gifts of recurring gift
                if (!recurringGiftMap.get(recurringGift.id).containsKey(gift.Gift_Date__c.year())) {  //checking recurring gift map contains year at keyvalue on inner map
                    recurringGiftMap.get(recurringGift.id).put(gift.Gift_Date__c.year(), new List<Gift__c>());    //if recurringGiftMap not contains the year, then put it into recurringGiftMap
                }
                recurringGiftMap.get(recurringGift.id).get(gift.Gift_Date__c.year()).add(gift);    //adding List of gift records according to recurring gift id and year of transaction
            }
        }
        for (Payment__c payment : paymentRecord) {


            if (recurringGiftMap.get(payment.Donation__r.Recurring_Donation__c).get(payment.Date__c.year()) == null ) {  //checking for a recurring gift, in inner map for keyvalue "year" it not contains gift record
                logFileData += 'Payment ' + payment.Name + ' could not  find a 2017 transaction' + '\n';
            }
        }

        //mapping payment to transaction according to year
        for (Payment__c payment : paymentRecord) {
            if (recurringGiftMap.get(payment.Donation__r.Recurring_Donation__c).get(payment.Date__c.year()) != null ) {
                if (payment.Date__c.year() != payment.Donation__r.Gift_Date__c.year()) {
                    for (Gift__c gift : recurringGiftMap.get(payment.Donation__r.Recurring_Donation__c).get(payment.Date__c.year())) {  //fetching gift for recurring gift and for year of payment from recurringGiftMap

                        if (gift != null) {

                            logFileData += payment.Date__c.year() + ' Payment ' + payment.Name + ' associated with ' + payment.Donation__r.Gift_Date__c.year() + ' Transaction ' + payment.Donation__r.Id + ' changed to ' + payment.Date__c.year() + ' Payment ' + payment.Name + ' associated with ' + gift.Gift_Date__c.year() + ' Transaction ' + gift.Id + '\n';
                            payment.Donation__c = gift.id;    //updating the gift id on payment record
                            paymentRecordToUpdate.add(payment);
                            if (payment.Allocations__r.size() > 0) {
                                for (Gift_Detail__c allocation : payment.Allocations__r) {
                                    allocation.Gift__c = gift.id;    //updating the gift id on allocation record
                                    updateAllocationList.add(allocation);
                                }
                            }
                        } else {
                            logFileData += 'Payment ' + payment.Name + ' could not  find a 2017 transaction' + '\n';
                        }
                    }
                }
            }
        }
        try {
            if (paymentRecordToUpdate.size() > 0) {
                paymentRecordSet.addAll(paymentRecordToUpdate);
                paymentRecordToUpdate.clear();
                paymentRecordToUpdate.addAll(paymentRecordSet);
                DMLManager.UpdateSObjects(paymentRecordToUpdate);
            }
            if (updateAllocationList.size() > 0) {
                updateAllocationSet.addAll(updateAllocationList);
                updateAllocationList2.addAll(updateAllocationSet);
                DMLManager.UpdateSObjects(updateAllocationList2);
            }
        } catch (DmlException e) {

        }
    }
    global void finish(Database.BatchableContext BC) {
        if (String.isNotBlank(logFileData) == true) {
            List<Folder> folder = new FolderSelector().SelectBySpecificNameAndType();
            if (folder.size() > 0) {
                Document doc = new Document (Name = 'Payment Log' + DateTime.now().format() + '.txt');
                doc.Description = '';
                doc.FolderId = folder[0].Id;
                doc.Body = Blob.valueOf(logFileData);
                DMLManager.InsertSObject(doc);
            }
        }
    }
}