global with sharing class YearEndPaymentMissMatchBatchable implements Database.Batchable<sObject> , Database.Stateful{
    Integer numberOfMissMatchPaymentsBefore = -1;
    Integer numberOfMissMatchPaymentsAfter = -1;
    String logFileTitles = 'Payment Id, Error\n';
    String logFileData = '';
    date target_date;
    date target_start;
    date target_end;
    date target_nextYear;

    global Database.QueryLocator start(Database.BatchableContext BC){

        List<App_Settings__c> appSettingsList1 = new AppSettingSelector().SelectNameSendMailAndFirstDateOfTaxYear();
        App_Settings__c appSetting1;
        if(appSettingsList1.size() > 0 && appSettingsList1 != null){
            appSetting1 = appSettingsList1[0];
        }

        if(appSetting1 != null){
            target_date = appSetting1.First_Date_of_Tax_Year__c;
            if(target_date != null){
                target_start = target_date.adddays(-1);
                target_end = target_date.addYears(-1);
                target_nextYear = target_date.addYears(1);
            }
        }

        //VALIDATE # OF RECORDS TO BE FIXED//
        numberOfMissMatchPaymentsBefore = missMatchedPaymentsCount();
        /////////////////////////////////////

        if(target_date == null) {
            return new PaymentSelector().SelectPaymentsByTransactionForCurrentYear(); 
        }
        else 
        {
            return new PaymentSelector().SelectPaymentsByTransactionForTargetYear(target_start, target_end, target_date, target_nextYear); 
        }
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        //VARIABLE DECLARATIONS//
        List<payment__c> currentBatchPayments = scope;
        List<payment__c> thisYearsPayments = new List<payment__c>();
        List<Gift_Detail__c> thisYearsAllocations = new List<Gift_Detail__c>();
        Set<Id> recurringGiftIds = new Set<Id>();
        Map<Id,Gift__c> recurringGiftIdMapThisYearsTransactions = new Map<Id,Gift__c>();
        List<gift__c> thisYearsTransactions;

        payment__c processingPayment;
        /////////////////////////

        //CREATE A SET OF RECURRING GIFTS FROM THE PAYMENTS 2016 TRANSACTION//
        for(payment__c p : currentBatchPayments)
            recurringGiftIds.add(p.Donation__r.Recurring_Donation__c);
        //////////////////////////////////////////////////////////////////////

        //SELECT 2017 TRANSACTIONS FROM THE 2016 TRANSACTIONS RECURRING GIFT//
        if(target_date == null)
        {
        thisYearsTransactions = new GiftSelector().SelectGiftAndRecurringDonationWhereIdInIdsAndCurrentYear(recurringGiftIds);
        }
        //////////////////////////////////////////////////////////////////////
        else
        {
         thisYearsTransactions = new GiftSelector().SelectGiftAndRecurringDonationWhereIdInIdsAndWithinYearRangs(recurringGiftIds, target_date, target_nextYear);
        }

        //MAP 2017 TRANSACTIONS BASED ON THEIR RECURRING GIFT ID//
        for(gift__c g : thisYearsTransactions)
            recurringGiftIdMapThisYearsTransactions.put(g.Recurring_Donation__c,g);
        //////////////////////////////////////////////////////////

        //ATTACH 2017 PAYMENTS TO 2017 TRANSACTIONS//
        for(payment__c p : currentBatchPayments){
            if(recurringGiftIdMapThisYearsTransactions.get(p.Donation__r.Recurring_Donation__c) != null){
                processingPayment  = new payment__c(
                    Id = p.Id,
                    Donation__c = recurringGiftIdMapThisYearsTransactions.get(p.Donation__r.Recurring_Donation__c).Id
                );
                thisYearsPayments.add(processingPayment);
                for(Gift_Detail__c gd : p.Allocations__r){
                    gd.Gift__c = recurringGiftIdMapThisYearsTransactions.get(p.Donation__r.Recurring_Donation__c).Id;
                    thisYearsAllocations.add(gd);
                }
            }else{
                logFileData += p.Id + ', No  2017 transactions found.\n';
            }
        }
        /////////////////////////////////////////////

        //UPDATE 2017 PAYMENTS AND ALLOCATIONS//
        try {
            DMLManager.UpdateSObjects(thisYearsPayments);
            DMLManager.UpdateSObjects(thisYearsAllocations);
        } catch(DmlException e) {

        } catch(Exception e) {

        }
        ////////////////////////////////////////
    }

    global void finish(Database.BatchableContext BC){
        //VALIDATE # OF RECORDS AFTER FIX//
        numberOfMissMatchPaymentsAfter = missMatchedPaymentsCount();
        ///////////////////////////////////

        //EMAILING CAUSEVIEW//
        if(!Test.isRunningTest()){
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'sbala@causeview.com','rcollins@causeview.com'};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Payment Miss Match Job');
            if (logFileData != ''){
                mail.setSubject('Payment Miss Match Run With Errors ' + UserInfo.getOrganizationName());
            }else{
                mail.setSubject('Payment Miss Match Run Without Errors ' + UserInfo.getOrganizationName());
            }
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody('The following attachment is a log of errors that occurred in ' + UserInfo.getOrganizationName() + '\n\nMiss Match Payments Before: ' + numberOfMissMatchPaymentsBefore + '\nMiss Match Payments After: ' + numberOfMissMatchPaymentsAfter);
            mail.setHtmlBody('The following attachment is a log of errors that occurred in ' + UserInfo.getOrganizationName() + '\n\nMiss Match Payments Before: ' + numberOfMissMatchPaymentsBefore + '\nMiss Match Payments After: ' + numberOfMissMatchPaymentsAfter);
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(UserInfo.getOrganizationName() + ' Errors.csv');
            efa.setContentType('text/csv');
            efa.setBody(Blob.valueOf(logFileTitles + logFileData));
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        ///////////////////////

        //CANCEL THE DAILY JOB//
        cancelScheduledJob();
        ////////////////////////

        //STORE THE LOG AS A FILE IF ANY RECORDS FAIL TO UPDATE//
        if(String.isNotBlank(logFileData) == true){
            List<Folder> folder = new FolderSelector().SelectBySpecificNameAndType();
            if (folder.size() > 0)
            {
                Document doc = new Document (Name = UserInfo.getOrganizationName() + ' Payment Miss Match Errors ' + DateTime.now().format('dd/mm/yyyy') + '.csv');
                doc.Description = '';
                doc.FolderId = folder[0].Id;
                doc.Body = Blob.valueOf(logFileData);
                DMLManager.InsertSObject(doc);
            }
        }
        /////////////////////////////////////////////////////////
    }

    private Integer missMatchedPaymentsCount(){
        //RETURN # OF MISS MATCH PAYMENTS//
        if(target_date == null)
        {
          return new PaymentSelector().SelectCountThisYear('Recurring', 'Refunded');
         }
         ///////////////////////////////////

        else
        {
          return new PaymentSelector().SelectCountDateRange('Recurring', 'Refunded', target_start, target_end, target_date, target_nextYear);
        }
    }

    private void cancelScheduledJob(){
        Map<String, String> scheduleJobNamesMap = new Map<String, String>();
        scheduleJobNamesMap = cronJobMethod();
        Set<Id> DeleteJobIds = new Set<Id>();
        if(scheduleJobNamesMap.containskey('Payment Mismatch Job')) {
          DeleteJobIds.add(scheduleJobNamesMap.get('Payment Mismatch Job'));
        }
        List<CronTrigger>  CronTriggerList = new CronTriggerSelector().SelectWhereCronJobDetailIdInIds(DeleteJobIds);
        for(CronTrigger ct:CronTriggerList){
            System.abortJob(ct.id);
        }
    }

    private static Map<String, String> cronJobMethod(){
        Map<String, String> scheduleJobNamesMap = new Map<String, String>();
        for(CronJobDetail scheduleJobNames : new CronJobDetailSelector().SelectIdAndName()){
            scheduleJobNamesMap.put(scheduleJobNames.Name, scheduleJobNames.id);
        }
        return scheduleJobNamesMap;
    }
}