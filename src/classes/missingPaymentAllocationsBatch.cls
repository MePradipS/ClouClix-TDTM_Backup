/*--------------------------- ROLLUPBATCH----------------------------
|  Class MissingPaymentAllocationsBatch
|
|  Purpose: Queries all payments with missing allocations and fix them
|   if the Recurring Gift has an allocation. Will output all record in list.
|
|  Last Modified Date: 21/11/2016
|
|   TODO:
|    [] over-allocation?
|    [] build csv in hierarchy... line 1 = recurring gift, line 2 = transaction, line 2 = payments/allocation if created, new line /n
|    [] allow clients to select fields to output?
|    []
 *-------------------------------------------------------------------*/
global with sharing class missingPaymentAllocationsBatch implements Database.Batchable<sObject>, Database.stateful{
    public Set <Id> paymentIds = new Set <Id>();
    String ErrorLog = 'ERRORS\n';
    String FixedLog = 'FIXED PAYMENTS, Transaction, Payment, Allocation, Campaign, Fund\n';
    String CreateAllocation = 'ALLOCATIONS, Campaign, New Campaign, Fund, Amount, Transaction, Payment\n';
    String RGMissingAllocationLog = 'RECURRING GIFTS MISSING ALLOCATION, Recurring Gift Id, Recurring Gift Name\n';
    public Integer batchCounter = 0;
    public Integer paymentCounter = 0;
    public boolean runAuto = true;
    public boolean commitFix = false;
    global String query = ''; 
    global MissingPaymentAllocationsBatch () {}
    global MissingPaymentAllocationsBatch (Id updatePayment) {
        this.runAuto = false;
        this.paymentIds.add(updatePayment);
    }

    global MissingPaymentAllocationsBatch (Set<Id> paymentIds) {
        this.runAuto = false;
        this.paymentIds.addAll(paymentIds);
    }

    global MissingPaymentAllocationsBatch (String fixType) {
        if (fixType == 'Auto') {
            this.runAuto = true;
        }
        if (fixType == 'Commit') {
            this.commitFix = true;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return chooseClause();
    }

    public Database.QueryLocator chooseClause() {
        Database.QueryLocator q;
        if(runAuto) {
            q = new PaymentSelector().SelectGiftWhenNotInPayment();
        }else if (!paymentIds.isEmpty()){
            q = new PaymentSelector().SelectGiftByPaymentId(paymentIds);
        }
        return q;
    }

    global void execute(Database.BatchableContext BC, List<Payment__c> PaymentsMissingAllocation){
        try {
            Set<Id> paymentIds = new Set<Id>();
            for(Payment__c payment:PaymentsMissingAllocation){
                paymentIds.add(payment.Id);
            }
            Set < String > inputs = new Set < String > ();
            map < id, Payment__c > toUpdatePayment = new map < id, Payment__c > ();

            Map < String, String > paymentMap = new Map < String, String > ();
            List < string > RD_Ids = new List < String > ();
            Receipt__c theReceipt = null;
            List < Receipt__c > toInsertReceipt = new List < Receipt__c > ();
            Set < String > recurringPIds = new Set < String > ();

            List < Payment__c > ps1 = new PaymentSelector().SelectGiftAndRecurringGiftByIdAndGiftType(paymentIds);
            for (Payment__c p: ps1) {
                p.Credit_Card_Number__c = p.Donation__r.Recurring_Donation__r.Credit_Card__c;
                p.Credit_Card_Type__c = p.Donation__r.Recurring_Donation__r.Credit_Card_Type__c;
                p.Account_Number__c = p.Donation__r.Recurring_Donation__r.Account__c;
                p.Routing_Branch_Number__c = p.Donation__r.Recurring_Donation__r.Branch_Num__c;
                p.Transit_Number__c = p.Donation__r.Recurring_Donation__r.Institution_Num__c;
                p.Bank_Name__c = p.Donation__r.Recurring_Donation__r.Bank_Name__c;
                toUpdatePayment.put(p.id, p);
                // UpdatesPaymentIds.add(p.id);
                inputs.add(p.Id + ':' + p.Donation__r.Recurring_Donation__c);
                paymentMap.put(p.Id, p.Donation__r.Recurring_Donation__c);
                if (!isEmptyOrNull(p.Donation__r.Recurring_Donation__c)) {
                    RD_Ids.add(p.Donation__r.Recurring_Donation__c);
                }
            }

            Map < Id, Recurring_Donation__c > RDsMap = new map < Id, Recurring_Donation__c > (new RecurringDonationSelector().SelectIdAndRecurringGiftAllocations(Utilities.ConvertStringListToIdSet(RD_Ids)));

            //target list
            List < Gift_Detail__c > itemsToBeInserted = new List < Gift_Detail__c > ();
            Map < Id, Receipt__c > giftDetailMap = new Map < Id, Receipt__c > ();
            decimal rdAmount = 0;
            integer cnt = 0;
            App_Settings__c appSetting = App_Settings__c.getInstance();
            for (Payment__c p: Ps1) {
                if (giftDetailMap.get(p.id) != null) {
                    p.receipt__c = giftDetailMap.get(p.id).id;
                    toUpdatePayment.put(p.id, p);
                }
                //If the Payment record already contains allocation, do not create allocations.
                //Bug Fix : Process Payment - recurring gifts creates 2 allocations.
                if (p.Donation__R.Gift_Type__c == 'Recurring' && p.Allocations__r != null && p.Allocations__r.size() > 0) {
                    continue;
                }

                cnt++;
                string RD_Id = paymentMap.get(p.Id);

                Recurring_Donation__c RD = RDsMap.get(RD_Id); // (Recurring_Donation__c)findItem('Id',RD_Id, RDs);
                if (RD == null || RD.Recurring_Gift_Allocations__r == null || RD.Recurring_Gift_Allocations__r.size() <= 0)
                    continue;
                for (RD_Allocation__c allocation: RD.Recurring_Gift_Allocations__r) {
                    Gift_Detail__c gd = new Gift_Detail__c();
                    gd.Allocation_Date__c = p.Date__c;
                    if (p.Amount__c < 0) { gd.Amount__c = (0 - allocation.Amount__c); } else { gd.Amount__c = allocation.Amount__c; }
                    rdAmount = allocation.Amount__c;
                    gd.New_Campaign__c = allocation.New_Campaign__c;
                    gd.Campaign__c = allocation.Campaign__c;
                    gd.Fund__c = allocation.Fund__c;
                    gd.Custom_Allocation_Text__c = allocation.Custom_Allocation_Text__c;
                    gd.Gift__c = p.Donation__c;
                    gd.Payment__c = p.Id;
                    gd.Package__c = allocation.Package__c;

                    itemsToBeInserted.add(gd);
                }

            }

            if (itemsToBeInserted != null && itemsToBeInserted.size() > 0 && rdAmount != -8967){
                DMLManager.InsertSObjects(itemsToBeInserted);
                for(Gift_Detail__c ia: itemsToBeInserted){
                    //Transaction, Payment, Allocation, Campaign, Fund
                    FixedLog += ',' + ia.Gift__c + ',' + ia.Payment__c + ',' + ia.Id + ',' + ia.New_Campaign__c  + ',' + ia.Fund__c  + '\n';
                }
            }

            if (toUpdatePayment.values().size() != null && toUpdatePayment.values().size() > 0) {
                List<Payment__c> toUpdatePaymentList = new List<Payment__c>();
                toUpdatePaymentList = toUpdatePayment.values();
                DMLManager.UpdateSObjects(toUpdatePaymentList);
            }

        } catch (Exception e) {
            ErrorLog += 'Exception' + ',' + e + '\n';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            string emailAddress = 'ayhap@causeview.com';
            String[] toAddresses = new String[] { emailAddress };
            mail.setToAddresses(toAddresses);
            mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public static Boolean IsEmptyOrNull(string value) {
      return (value==null || value=='');
    }

    global void finish(Database.BatchableContext BC){
        // todo: output allocation id
        FixedLog += ',' + 'Total Allocations Created: ' + paymentCounter + '\n';
        FixedLog += ',' + 'Total Batches: ' + batchCounter + '\n';
        Document doc = new Document (Name = 'MissingPaymentAllocationsBatch CreateFile - '+DateTime.now().format() + '.csv');
        doc.Description = '';
        doc.FolderId = UserInfo.getUserId();
        doc.Body = Blob.valueOf(FixedLog);
        DMLManager.InsertSObject(doc);

        Document errorDoc = new Document (Name = 'MissingPaymentAllocationsBatch ErrorFile - '+DateTime.now().format() + '.csv');
        errorDoc.Description = '';
        errorDoc.FolderId = UserInfo.getUserId();
        errorDoc.Body = Blob.valueOf(ErrorLog);
        DMLManager.InsertSObject(errorDoc);
    }
}