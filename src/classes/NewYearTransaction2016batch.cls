global with sharing class NewYearTransaction2016batch implements Database.Batchable<sObject>, Database.stateful {
    String errorLog = ',Error Message,Error Field(s)\n';
    String successLog = 'Transaction Id,Gift Date,Acknowledgement Recipient Email, Conatct Id, Contact Name\n';
    Contact yearEndContact;
    //Date newTransactionDate = Date.valueof(system.today().Year()+'-01-01');
    Date newTransactionDate;
    Integer beforeNumberOfActive2017;
    Integer beforeNumberOfCompleted2016;
    Integer beforeNumberOfActive2016;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<App_Settings__c> appSettingList = new AppSettingSelector().SelectNameSendMailAndFirstDateOfTaxYear();
        App_Settings__c appSetting1;
        if (appSettingList != null && appSettingList.size() > 0) {
            appSetting1 = appSettingList[0];
        }
        appSetting1.Send_Mail_From_Job__c = true;
        String yearEndContactEmail = 'YearEndTest@causeview.com';
        DMLManager.UpdateSObject(appSetting1);

        if (appSetting1.First_Date_of_Tax_Year__c != null)
        {newTransactionDate = appSetting1.First_Date_of_Tax_Year__c;}
        else
        {newTransactionDate = Date.valueof(system.today().Year() + '-01-01');}

        List<Contact> contactList = new ContactSelector().SelectIdByEmail(yearEndContactEmail);
        if (contactList != null && contactList.size() != 0) {
            yearEndContact = contactList[0];
        } else {
            Contact tempYearEndContact = new Contact(
                LastName = 'YearEnd12345',
                Email = yearEndContactEmail
            );

            try {
                DMLManager.InsertSObject(tempYearEndContact);
            } catch (DmlException e) {
            } catch (Exception e) {
            }
            yearEndContact = tempYearEndContact;
        }

        //PRE-RUN VALIDATION QUERIES//
        beforeNumberOfActive2016 = new GiftSelector().SelectActiveCountBetweenYearsAndEnteredActiveStatus(newTransactionDate.addYears(-1), newTransactionDate);
        beforeNumberOfCompleted2016 = new GiftSelector().SelectActiveCountBetweenYearsAndCompleted(newTransactionDate.addYears(-1), newTransactionDate);
        beforeNumberOfActive2017 = new GiftSelector().SelectCountYearCurrent(newTransactionDate);
        //////////////////////////////

        String giftObject = RollupBatch.class.getName().substringBefore('RollupBatch').substringBefore('.');
        if (giftObject != null && giftObject != '') {
            giftObject += '__';
        }
        giftObject += 'Gift__c';

        String fields = 'id,name,Status__c';
        String subFields = '';
        String subWhere = ' where Gift_Date__c != null';

        Map<String, Schema.SObjectType> globaldesc = Schema.getGlobalDescribe();
        Set<String> objectFields = globaldesc.get(giftObject).getDescribe().fields.getMap().keySet();
        subFields = Converter.ConvertListSetToString(objectFields);
        subFields = subFields.remove('\'');

        return new GenericQueryBuilder().getQueryLocatorWithSubQuery('', fields, 'Recurring_Donation__c', subFields, 'Gift__c', 'Orders__r', subWhere);
    }


    global void execute(Database.BatchableContext BC, List<Recurring_Donation__c> scope) {
        List<App_Settings__c> appSettingList = new AppSettingSelector().SelectMailFromJobSetting();
        App_Settings__c appSetting1 = (appSettingList != null && appSettingList.size() > 0) ? appSettingList[0] : null;
        date target_date;
        date target_date1;
        date target_date2;
        Integer targetYear;
        target_date1 = appSetting1.First_Date_of_Tax_Year__c;

        if (target_date1 != null) {
            target_date = target_date1.addDays(-1);
            target_date2 = target_date1.addYears(-1);
        } else {
            targetYear = Date.today().year() - 1;
            target_date = Date.today();
        }

        Map<Id, Recurring_Donation__c> RDmap = new Map<Id, Recurring_Donation__c>();
        if (target_date1 == null) {
            RDmap = new Map<Id, Recurring_Donation__c>(new RecurringDonationSelector().SelectStatusAndTransactionsById(scope, newTransactionDate));
        }
        else {
            RDmap = new Map<Id, Recurring_Donation__c>(new RecurringDonationSelector().SelectStatusAndTransactionsById(scope, target_date1));
        }

        List<Gift__c> modifiedgift = new List<Gift__c>();
        List<Gift__c> insertgift = new List<Gift__c> ();
        List<Gift__c> postInsertModifyGift = new List<Gift__c>();
        List<id> giftidslist = new List<Id>();

        for (Recurring_Donation__c RDlist : scope) {
            if (RDmap.get(RDlist.Id).orders__r.size()  == 0) {
                for (Gift__c mygift : RDlist.orders__r) {

                    if ((target_date1 == null && mygift.Status__c == 'Active'  &&  mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date  && RDlist.Status__c == 'Active') || (target_date1 != null && mygift.Status__c == 'Active'  && mygift.Gift_Date__c > target_date2 && mygift.Gift_Date__c <= target_date  && RDlist.Status__c == 'Active')) {
                        mygift.status__c = 'Completed';
                        Gift__c newg = mygift.clone(false, false, false, false);
                        newg.Gift_Date__c = newTransactionDate;
                        newg.Status__c = 'Active';
                        modifiedgift.add(mygift);
                        Gift__c newgp = new Gift__c(Acknowledgement_Recipient_Email__c = newg.Acknowledgement_Recipient_Email__c);
                        if (newg.Organization__c == null) {
                            newgp.Constituent__c = newg.Constituent__c;
                            newgp.Organization__c = null;
                        } else {
                            newgp.Organization__c = newg.Organization__c;
                            newgp.Constituent__c = null;
                        }
                        postInsertModifyGift.add(newgp);
                        newg.Constituent__c = yearEndContact.Id;
                        newg.Acknowledgement_Recipient_Email__c = yearEndContact.Email;
                        newg.Organization__c = null;
                        insertgift.add(newg);
                        giftidslist.add(mygift.id);

                        //Constituent__c = newg.Constituent__c, Organization__c = newg.Organization__c,
                    } else if ((target_date1 == null && mygift.Status__c == 'Acknowledged'  && mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'Active') || (target_date1 != null && mygift.Status__c == 'Acknowledged'  && mygift.Gift_Date__c > target_date2 && mygift.Gift_Date__c <= target_date && RDlist.Status__c == 'Active')) {
                        //logFileData += RDlist.Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Acknowledged : unchanged '+ '\n' ;
                        Gift__c newg = mygift.clone(false, false, false, false);
                        newg.Gift_Date__c = newTransactionDate;
                        newg.Status__c = 'Active';
                        Gift__c newgp = new Gift__c(Acknowledgement_Recipient_Email__c = newg.Acknowledgement_Recipient_Email__c);
                        if (newg.Organization__c == null) {
                            newgp.Constituent__c = newg.Constituent__c;
                            newgp.Organization__c = null;
                        } else {
                            newgp.Organization__c = newg.Organization__c;
                            newgp.Constituent__c = null;
                        }
                        postInsertModifyGift.add(newgp);
                        newg.Constituent__c = yearEndContact.Id;
                        newg.Acknowledgement_Recipient_Email__c = yearEndContact.Email;
                        newg.Organization__c = null;
                        insertgift.add(newg);
                        giftidslist.add(mygift.id);
                    } else if ( (target_date1 == null && mygift.status__c == 'Payment Received'  &&  mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'Active') || (target_date1 != null && mygift.status__c == 'Payment Received'  &&  mygift.Gift_Date__c > target_date2 && mygift.Gift_Date__c <= target_date && RDlist.Status__c == 'Active')) {
                        //logFileData += RDlist.Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Payment Received : unchanged '+ '\n' ;
                        Gift__c newg = mygift.clone(false, false, false, false);
                        newg.Gift_Date__c = newTransactionDate;
                        newg.Status__c = 'Active';
                        Gift__c newgp = new Gift__c(Acknowledgement_Recipient_Email__c = newg.Acknowledgement_Recipient_Email__c);
                        if (newg.Organization__c == null) {
                            newgp.Constituent__c = newg.Constituent__c;
                            newgp.Organization__c = null;
                        } else {
                            newgp.Organization__c = newg.Organization__c;
                            newgp.Constituent__c = null;
                        }
                        postInsertModifyGift.add(newgp);
                        newg.Constituent__c = yearEndContact.Id;
                        newg.Acknowledgement_Recipient_Email__c = yearEndContact.Email;
                        newg.Organization__c = null;
                        insertgift.add(newg);
                        giftidslist.add(mygift.id);
                    } else if ( (target_date1 == null && mygift.status__c == 'Entered'  &&  mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'Active') || (target_date1 != null && mygift.status__c == 'Entered'  &&  mygift.Gift_Date__c > target_date2 && mygift.Gift_Date__c <= target_date && RDlist.Status__c == 'Active') ) {
                        mygift.status__c = 'Completed';
                        Gift__c newg = mygift.clone(false, false, false, false);
                        newg.Gift_Date__c = newTransactionDate;
                        newg.Status__c = 'Entered';
                        modifiedgift.add(mygift);
                        Gift__c newgp = new Gift__c(Acknowledgement_Recipient_Email__c = newg.Acknowledgement_Recipient_Email__c);
                        if (newg.Organization__c == null) {
                            newgp.Constituent__c = newg.Constituent__c;
                            newgp.Organization__c = null;
                        } else {
                            newgp.Organization__c = newg.Organization__c;
                            newgp.Constituent__c = null;
                        }
                        postInsertModifyGift.add(newgp);
                        newg.Constituent__c = yearEndContact.Id;
                        newg.Acknowledgement_Recipient_Email__c = yearEndContact.Email;
                        newg.Organization__c = null;
                        insertgift.add(newg);
                        giftidslist.add(mygift.id);
                    } else if (((target_date1 == null && mygift.status__c == 'Payment Pending' || mygift.status__c == 'Completed' || mygift.status__c == 'Cancelled')  &&  mygift.Gift_Date__c.year() == Date.today().year() && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'Active') || (target_date1 != null && (mygift.status__c == 'Payment Pending' || mygift.status__c == 'Completed' || mygift.status__c == 'Cancelled')  &&  mygift.Gift_Date__c.year() == Date.today().year() && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'Active')) {
                        //logFileData += RDlist.Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.Gift_Date__c) + ' Transaction ' + mygift.Name  + ' with Status ' + mygift.Status__c  + ' : unchanged '+ '\n' ;
                    } else if ( (target_date1 == null && mygift.Status__c == 'Active'  && mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'On Hold') || (target_date1 != null && mygift.Status__c == 'Active'  && mygift.Gift_Date__c > target_date2 && mygift.Gift_Date__c <= target_date && RDlist.Status__c == 'On Hold') ) {
                        mygift.status__c = 'Completed';
                        Gift__c newg = mygift.clone(false, false, false, false);
                        newg.Gift_Date__c = newTransactionDate;
                        newg.Status__c = 'Active';
                        modifiedgift.add(mygift);
                        Gift__c newgp = new Gift__c(Acknowledgement_Recipient_Email__c = newg.Acknowledgement_Recipient_Email__c);
                        if (newg.Organization__c == null) {
                            newgp.Constituent__c = newg.Constituent__c;
                            newgp.Organization__c = null;
                        } else {
                            newgp.Organization__c = newg.Organization__c;
                            newgp.Constituent__c = null;
                        }
                        postInsertModifyGift.add(newgp);
                        newg.Constituent__c = yearEndContact.Id;
                        newg.Acknowledgement_Recipient_Email__c = yearEndContact.Email;
                        newg.Organization__c = null;
                        insertgift.add(newg);
                        giftidslist.add(mygift.id);
                    } else if ( (target_date1 == null && mygift.Status__c == 'Acknowledged'  && mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'On Hold') || (target_date1 != null && mygift.Status__c == 'Acknowledged'  && mygift.Gift_Date__c > target_date2 && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'On Hold')) {
                        //logFileData += RDlist.Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Acknowledged : unchanged '+ '\n' ;
                        Gift__c newg = mygift.clone(false, false, false, false);
                        newg.Gift_Date__c = newTransactionDate;
                        newg.Status__c = 'Active';
                        Gift__c newgp = new Gift__c(Acknowledgement_Recipient_Email__c = newg.Acknowledgement_Recipient_Email__c);
                        if (newg.Organization__c == null) {
                            newgp.Constituent__c = newg.Constituent__c;
                            newgp.Organization__c = null;
                        } else {
                            newgp.Organization__c = newg.Organization__c;
                            newgp.Constituent__c = null;
                        }
                        postInsertModifyGift.add(newgp);
                        newg.Constituent__c = yearEndContact.Id;
                        newg.Acknowledgement_Recipient_Email__c = yearEndContact.Email;
                        newg.Organization__c = null;
                        insertgift.add(newg);
                        giftidslist.add(mygift.id);
                    } else if ( (target_date1 == null &&  mygift.Status__c == 'Payment Received'  && mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'On Hold') || (target_date1 != null &&  mygift.Status__c == 'Payment Received'  && mygift.Gift_Date__c > target_date2 && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'On Hold')) {
                        //logFileData += RDlist.Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Payment Received : unchanged '+ '\n' ;
                        Gift__c newg = mygift.clone(false, false, false, false);
                        newg.Gift_Date__c = newTransactionDate;
                        newg.Status__c = 'Active';
                        Gift__c newgp = new Gift__c(Acknowledgement_Recipient_Email__c = newg.Acknowledgement_Recipient_Email__c);
                        if (newg.Organization__c == null) {
                            newgp.Constituent__c = newg.Constituent__c;
                            newgp.Organization__c = null;
                        } else {
                            newgp.Organization__c = newg.Organization__c;
                            newgp.Constituent__c = null;
                        }
                        postInsertModifyGift.add(newgp);
                        newg.Constituent__c = yearEndContact.Id;
                        newg.Acknowledgement_Recipient_Email__c = yearEndContact.Email;
                        newg.Organization__c = null;
                        insertgift.add(newg);
                        giftidslist.add(mygift.id);
                    } else if ((target_date1 == null && mygift.status__c == 'Entered'  &&  mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'On Hold') || (target_date1 != null && mygift.status__c == 'Entered'  &&  mygift.Gift_Date__c > target_date2 && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'On Hold')) {
                        //logFileData += RDlist.Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Payment Received : unchanged '+ '\n' ;
                        Gift__c newg = mygift.clone(false, false, false, false);
                        newg.Gift_Date__c = newTransactionDate;
                        Gift__c newgp = new Gift__c(Acknowledgement_Recipient_Email__c = newg.Acknowledgement_Recipient_Email__c);
                        if (newg.Organization__c == null) {
                            newgp.Constituent__c = newg.Constituent__c;
                            newgp.Organization__c = null;
                        } else {
                            newgp.Organization__c = newg.Organization__c;
                            newgp.Constituent__c = null;
                        }
                        postInsertModifyGift.add(newgp);
                        newg.Constituent__c = yearEndContact.Id;
                        newg.Acknowledgement_Recipient_Email__c = yearEndContact.Email;
                        newg.Organization__c = null;
                        insertgift.add(newg);
                        giftidslist.add(mygift.id);
                    } else if ((target_date1 == null && ( mygift.status__c == 'Payment Pending' || mygift.status__c == 'Completed' || mygift.status__c == 'Cancelled')  &&  mygift.Gift_Date__c.year() == targetYear && RDlist.Status__c == 'On Hold') || (target_date1 != null && ( mygift.status__c == 'Payment Pending' || mygift.status__c == 'Completed' || mygift.status__c == 'Cancelled') && RDlist.Status__c == 'On Hold')) {
                        //logFileData += RDlist.Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status ' + mygift.status__c + ' : unchanged '+ '\n' ;
                    } else if ((target_date1 == null && mygift.Status__c == 'Active'  && mygift.Gift_Date__c.year() == targetYear && RDlist.Status__c == 'Cancelled') || (target_date1 != null && mygift.Status__c == 'Active'  && mygift.Gift_Date__c.year() == targetYear && RDlist.Status__c == 'Cancelled')) {
                        mygift.status__c = 'Completed';
                        modifiedgift.add(mygift);
                    } else if ((target_date1 == null && mygift.status__c == 'Entered'  &&  mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'Cancelled') || (target_date1 != null && mygift.status__c == 'Entered'  &&  mygift.Gift_Date__c > target_date2 && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'Cancelled')) {
                        //logFileData += RDlist.Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status Payment Received : unchanged '+ '\n' ;
                        Gift__c newg = mygift.clone(false, false, false, false);
                        newg.Gift_Date__c = newTransactionDate;
                        Gift__c newgp = new Gift__c(Acknowledgement_Recipient_Email__c = newg.Acknowledgement_Recipient_Email__c);
                        if (newg.Organization__c == null) {
                            newgp.Constituent__c = newg.Constituent__c;
                            newgp.Organization__c = null;
                        } else {
                            newgp.Organization__c = newg.Organization__c;
                            newgp.Constituent__c = null;
                        }
                        postInsertModifyGift.add(newgp);
                        newg.Constituent__c = yearEndContact.Id;
                        newg.Acknowledgement_Recipient_Email__c = yearEndContact.Email;
                        newg.Organization__c = null;
                        insertgift.add(newg);
                        giftidslist.add(mygift.id);
                    } else if (((target_date1 == null && mygift.Status__c == 'Acknowledged'  || mygift.Status__c == 'Payment Received'  ||  mygift.status__c == 'Payment Pending' || mygift.status__c == 'Completed' || mygift.status__c == 'Cancelled')  && mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'Cancelled') || (target_date1 != null && (mygift.Status__c == 'Acknowledged'  || mygift.Status__c == 'Payment Received'  ||  mygift.status__c == 'Payment Pending' || mygift.status__c == 'Completed' || mygift.status__c == 'Cancelled')  && mygift.Gift_Date__c.year() == targetYear && mygift.Gift_Date__c < target_date && RDlist.Status__c == 'Cancelled')) {
                        //logFileData += RDlist.Status__c  + ' Recurring Gift  '  +  RDlist.Name  + '  -  ' +  String.valueOf(mygift.Gift_Date__c) + ' Transaction ' + mygift.Name  +'  with Status ' + mygift.status__c  +' : unchanged '+ '\n' ;
                    }
                }
            }
        }

        //LOGGING VARIABLES//
        List<Id> transactionIdList = new List<Id>();
        Gift__c loggingGift;
        /////////////////////

        //INSERTING THE NEW TRANSACTIONS//
        Database.SaveResult[] insertResults = DMLManager.InsertSObjects(insertgift, false);

        for (Integer i = 0; i < insertgift.size(); i++) {
            postInsertModifyGift[i].Id = insertgift[i].Id;
            transactionIdList.add(insertgift[i].Id);
        }

        Database.SaveResult[] insertUpdatesResult = DMLManager.UpdateSObjects(postInsertModifyGift, false);
        //////////////////////////////////

        //RETRIEVING THE INSERTED RECORDS//
        Map<Id, Gift__c> new2017TransactionGifts = new Map<Id, Gift__c>(new GiftSelector().SelectOrganizationConstituentRecurringGiftByIdList(transactionIdList));
        ///////////////////////////////////

        //LOGGING THE TRANSACTIONS//
        for (Database.SaveResult sr : insertUpdatesResult) {
            if (sr.isSuccess() && new2017TransactionGifts.containsKey(sr.getId())) {
                loggingGift = new2017TransactionGifts.get(sr.getId());
                if (loggingGift.Constituent__c == yearEndContact.Id || loggingGift.Acknowledgement_Recipient_Email__c == yearEndContact.Email) {
                    errorLog += 'Gift Not Updated Correctly, ' + 'Transaction ' + loggingGift.Id + ' Still Contains Year End Contact Information' + 'Constituent__c OR Email' + '\n';
                } else {
                    successLog += loggingGift.Id + ',' + loggingGift.Gift_Date__c + ',' + loggingGift.Acknowledgement_Recipient_Email__c + ',' + loggingGift.Constituent__c + ',' + loggingGift.Constituent__r.Name + '\n';
                }
            } else if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    errorLog += '[SALESFORCE ERROR LOG]Error Updating Gift,' + err.getMessage().replace(',', '-') + ',' + err.getMessage().replace(',', '-') + '\n';
                }
            }
        }
        /////////////////////////////////////

        //UPDATING 2016 TRANSACTIONS//
        Database.SaveResult[] updatesResults = DMLManager.UpdateSObjects(modifiedgift, false);
        //////////////////////////////

        //RETRIEVING THE INSERTED RECORDS//
        Map<Id, Gift__c> updated2016TransactionGifts = new Map<Id, Gift__c>(new GiftSelector().SelectOrganizationConstituentRecurringGiftByGiftIdList(modifiedgift));
        ///////////////////////////////////

        //LOGGING THE TRANSACTIONS//
        for (Database.SaveResult sr : updatesResults) {
            if (sr.isSuccess() && updated2016TransactionGifts.containsKey(sr.getId())) {
                loggingGift = updated2016TransactionGifts.get(sr.getId());
                if (loggingGift.Constituent__c == yearEndContact.Id || loggingGift.Acknowledgement_Recipient_Email__c == yearEndContact.Email) {
                    errorLog += 'Gift Not Updated Correctly, ' + 'Transaction ' + loggingGift.Id + ' Still Contains Year End Contact Information' + 'Constituent__c OR Email' + '\n';
                } else {
                    successLog += loggingGift.Id + ',' + loggingGift.Gift_Date__c + ',' + loggingGift.Acknowledgement_Recipient_Email__c + ',' + loggingGift.Constituent__c + ',' + loggingGift.Constituent__r.Name + '\n';
                }
            } else if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    errorLog += '[SALESFORCE ERROR LOG]Error Updating Gift,' + err.getMessage().replace(',', '-') + ',' + err.getMessage().replace(',', '-') + '\n';
                }
            }
        }
        /////////////////////////////////////
    }

    global void finish(Database.BatchableContext BC) {
        //VALIDATION QUERIES//
        Integer afterNumberOfActive2016 = new GiftSelector().SelectActiveCountBetweenYearsAndEnteredActiveStatus(newTransactionDate.addYears(-1), newTransactionDate);
        Integer afterNumberOfCompleted2016 = new GiftSelector().SelectActiveCountBetweenYearsAndCompleted(newTransactionDate.addYears(-1), newTransactionDate);
        Integer afterNumberOfActive2017 = new GiftSelector().SelectCountYearCurrent(newTransactionDate);
        //////////////////////

        //SUCCESS LOG DOCUMENT SAVE//
        if (successLog != 'Success/Fail,Transaction Id,Gift Date,Acknowledgement Recipient Email, Conatct Id, Contact Name\n') {
            DateTime d = Date.Today() ;
            String dateStr =  d.format('dd/mm/yyyy') ;

            Document doc = new Document (Name = 'Year End Job Success Log - ' + dateStr );
            doc.Description = 'A log of the successful records processed by the Year End Job.';
            doc.FolderId = UserInfo.getUserId();
            doc.Body = Blob.valueOf(successLog);
            DMLManager.InsertSObject(doc);
        }
        /////////////////////////////

        //EMAILING CAUSEVIEW//
        if (!Test.isRunningTest()) {
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'sbala@causeview.com', 'rcollins@causeview.com'};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Year End Job');
            if (errorLog != ',Error Message,Error Field(s)\n') {
                mail.setSubject('Year End Run With Errors ' + UserInfo.getOrganizationName());
            } else {
                mail.setSubject('Year End Run Without Errors ' + UserInfo.getOrganizationName());
            }
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody('The following attachment is a log of errors that occurred in ' + UserInfo.getOrganizationName() + '\n\nBefore:\nNumber of Active 2016 Recurring Gift Transactions: ' + beforeNumberOfActive2016 + '\nNumber of Completed 2016 Recurring Gift Transactions: ' + beforeNumberOfCompleted2016 + '\nNumber of Active 2017 Recurring Gift Transactions: ' + beforeNumberOfActive2017 + '\n\nAfter:\nNumber of Active 2016 Recurring Gift Transactions: ' + afterNumberOfActive2016 + '\nNumber of Completed 2016 Recurring Gift Transactions: ' + afterNumberOfCompleted2016 + '\nNumber of Active 2017 Recurring Gift Transactions: ' + afterNumberOfActive2017);
            mail.setHtmlBody('The following attachment is a log of errors that occurred in ' + UserInfo.getOrganizationName() + '\n\nBefore:\nNumber of Active 2016 Recurring Gift Transactions: ' + beforeNumberOfActive2016 + '\nNumber of Completed 2016 Recurring Gift Transactions: ' + beforeNumberOfCompleted2016 + '\nNumber of Active 2017 Recurring Gift Transactions: ' + beforeNumberOfActive2017 + '\n\nAfter:\nNumber of Active 2016 Recurring Gift Transactions: ' + afterNumberOfActive2016 + '\nNumber of Completed 2016 Recurring Gift Transactions: ' + afterNumberOfCompleted2016 + '\nNumber of Active 2017 Recurring Gift Transactions: ' + afterNumberOfActive2017);
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('Error Log.csv');
            efa.setContentType('text/csv');
            efa.setBody(Blob.valueOf(errorLog));
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        ///////////////////////

        Map<String, String> scheduleJobNamesMap = new Map<String, String>();
        scheduleJobNamesMap = cronJobMethod();
        Set<Id> DeleteJobIds = new Set<Id>();
        if (scheduleJobNamesMap.containskey('Year End Job')) {
            DeleteJobIds.add(scheduleJobNamesMap.get('Year End Job'));
        }
        List<CronTrigger>  CronTriggerList = new CronTriggerSelector().SelectWhereCronJobDetailIdInIds(DeleteJobIds);
        for (CronTrigger ct : CronTriggerList) {
            System.abortJob(ct.id);
        }

        List<App_Settings__c> appSettingList = new AppSettingSelector().SelectNameSendMailAndFirstDateOfTaxYear();
        App_Settings__c appSetting2 = (appSettingList != null && appSettingList.size() > 0) ? appSettingList[0] : null;
        appSetting2.Send_Mail_From_Job__c = false;
        DMLManager.UpdateSObject(appSetting2);
    }

    private static Map<String, String> cronJobMethod() {
        Map<String, String> scheduleJobNamesMap = new Map<String, String>();
        for (CronJobDetail scheduleJobNames : new CronJobDetailSelector().SelectIdAndName()) {
            scheduleJobNamesMap.put(scheduleJobNames.Name, scheduleJobNames.id);
        }
        return scheduleJobNamesMap;
    }

    private static Gift__c emailWorkAround() {
        return null;
    }
}