public with sharing class OppControllerExtension2 extends RedirectController {
    public Opportunity SelectedOpp {get; set;}
    public Account theAcc {get; set;}

    public List<PaymentWrapper> theWrappers {get; set;}

    public List<Task> theTasks {get; set;}
    public Decimal totalAmount {get; set;}
    public decimal Index { get; set; }
    public decimal Index2 { get; set; }
    public decimal Index3 { get; set; }
    public decimal gdIndex { get; set; }
    public decimal wrapperIndex { get; set; }
    public boolean isConverted { get; set; }
    public Gift__c trans {get; set;}
    public List<Gift_Detail__c> giftdetaillist { get; set; }
    public String PackageNamespace {
        get {
            if (PackageNamespace == null) {
                String namespace = Utilities.getCurrentNamespace();
                PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
            }
            return PackageNamespace;
         }
         set;
    }
    public Map<String, Schema.SObjectType> getschemaDesc (){return Schema.getGlobalDescribe();}

    public string localeDateFormatVal {get;set;}

    public OppControllerExtension2(ApexPages.StandardController stdController) {
        super(stdController, true);

        LocaleFormattedDateContrl localeFDC = new LocaleFormattedDateContrl();
        localeDateFormatVal = localeFDC.getDateLocale(UserInfo.getLocale());

         this.SelectedOpp = (Opportunity)stdController.getRecord();

         List<Opportunity> opps = new OpportunitySelector().SelectAllFieldsById(new Set<Id> { SelectedOpp.Id });
        if(opps != null && opps.size() != 0)
        { SelectedOpp = opps[0];
        }

        List<Gift__c> theGifts = new GiftSelector().SelectIdByProposal(SelectedOpp.Id);

        isConverted = theGifts.size() > 0;

        if (isConverted)
        {
            trans = theGifts[0];
            SelectedOpp.addError('This Opportunity has already been converted to a transaction');
        }

        if (SelectedOpp.AccountId != null) {
            List<Account> theaAccList = new AccountSelector().SelectIdNameById(new Set<Id> { SelectedOpp.AccountId });
            if (theaAccList != null && theaAccList.size() > 0) {
                theAcc = theaAccList[0];
            }
        }
        Index = 0;
        Index2 = 0;
        Index3 = 0;

        theWrappers = new List<PaymentWrapper>();
        theWrappers.add(new PaymentWrapper(new Payment__c()));
        theTasks = new List<Task>();
        giftdetaillist = new List<Gift_Detail__c>();
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

    public void removePayment()
    {
        integer count = 0;

        Index = Decimal.valueOf(ApexPages.currentPage().getParameters().get('wrapperIndex'));
        integer selectedIndex = Index.intValue();

        for(PaymentWrapper pw : theWrappers)
        {
            count++;
            if (count == selectedIndex )
            { break; }
        }

        if (count != 0) {
            PaymentWrapper selected = theWrappers.remove(count-1);
        }
    }

    public void addPayment()
    {
       theWrappers.add(new PaymentWrapper(new Payment__c()));
    }
    public void removeAllocation()
    {
        integer count = 0;
        integer gdCount = 0;

        gdIndex = Decimal.valueOf(ApexPages.currentPage().getParameters().get('gdIndex'));
        integer gdSelectedIndex = gdIndex.intValue();
        wrapperIndex = Decimal.valueOf(ApexPages.currentPage().getParameters().get('wrapperIndex'));
        integer selectedIndex = wrapperIndex.intValue();
        for(PaymentWrapper pw : theWrappers)
        {
            count++;
            if (count == selectedIndex )
            { break; }
        }
        for (Gift_Detail__c gd : theWrappers[count-1].theGiftDetails)
        {
            gdCount++;
            if (gdCount == gdSelectedIndex )
            {
                break;
            }
        }
        if (count != 0 && gdCount != 0) {
            theWrappers[count-1].theGiftDetails.remove(gdCount-1);
        }
    }
    public void addAllocation()
    {
        Index2 = Decimal.valueOf(ApexPages.currentPage().getParameters().get('gdIndex'));
        integer selectedIndex = Index2.intValue();
        theWrappers[selectedIndex - 1].theGiftDetails.add(new Gift_Detail__c());
    }
    public void removeTask()
    {
        integer count = 0;

        Index3 = Decimal.valueOf(ApexPages.currentPage().getParameters().get('Index3'));
        integer selectedIndex = Index3.intValue();

        for(Task p : theTasks)
        {
            count++;
            if (count == selectedIndex )
            { break; }
        }

        if (count != 0) {
            Task selected = theTasks.remove(count-1);
        }
    }
    public void addTask()
    {
       theTasks.add(new Task(OwnerId = UserInfo.getUserId()));
    }

    public PageReference Submit() {
        Savepoint sp = Database.setSavepoint();
        Double pTotal = 0;
        Double aTotal = 0;
        String BucketAccountId = '';
        String RegGiftRTID = '';
        Gift__c theTrans = new Gift__c();

        OpportunityContactRole cr = new OpportunityContactRole();

            BatchSettings__c settings = BatchSettings__c.getInstance('Default');
            Id rtypes = Id.valueOf(Utilities.getObjectRecordTypeId(Gift__c.SObjectType, 'Gift'));

            if (settings != null) {
                BucketAccountId = settings.BucketAccountId__c;
                 RegGiftRTID = rtypes;
            }

                //If Appeal record is not of type Appeal or Event, Send Error message.
            List<Id> appealIDs = new List<Id>();

            for (PaymentWrapper pw : theWrappers)
            {
                pTotal += pw.thePayment.Amount__c;

                for (Gift_Detail__c gd : pw.theGiftDetails)
                { aTotal += gd.Amount__c; appealIDs.add(gd.New_Campaign__c); }
            }

            Id RTP = Id.valueOf(Utilities.getObjectRecordTypeId(Campaign.SObjectType, 'Campaign'));
            List<Campaign> cmpList = new CampaignSelector().SelectRecordTypeIdByRecordTypeIdAndId(Utilities.ConvertIdListToIdSet(appealIDs), RTP);
            if (cmpList != null && cmpList.size() > 0) {
                theTrans.addError('Appeal: "' + cmpList[0].Name + '" must be of type Appeal or Event.');
                return null;
            }

            //if payments total > opp amount -error
            if (pTotal > SelectedOpp.Amount)
            { theTrans.addError('The sum of all entered payments is greater than the Opportunities Value'); return null; }

            //if allocations total != payment total -error
            if (aTotal != pTotal)
            { theTrans.addError('The sum of all entered Allocations is not equal to the sum of all entered payments');  return null; }

            //In case of Opportunities with no designated Organization, consider the Individual ID.
            if (SelectedOpp.AccountId == null)
            {
                theTrans.Constituent__c = SelectedOpp.Individual__c;
            }
            //In case of Opportunities with designated Organization, consider the Organization ID.
            else
            {
                theTrans.Organization__c = SelectedOpp.AccountId;
            }

            //(In case of Opportunities with no designated Organization)
            //Add selected Opportunity's ContactId to Transaction Constituent__c field, if selected Opportunity's AccountId == null and,
            //     the Transaction's Constituent__c == null.
            if(SelectedOpp.AccountId == null && theTrans.Constituent__c == null) {
                theTrans.Constituent__c = SelectedOpp.Individual__c;
            }

            //create transaction, add payments underneith, add giftdetails underneith, add tasks
            theTrans.Expected_Amount__c = SelectedOpp.Amount;
            theTrans.Gift_Date__c = SelectedOpp.CloseDate;
            theTrans.Status__c = 'In Progress';
            theTrans.Proposal__c = SelectedOpp.Id;
            Id rt = Id.valueOf(Utilities.getObjectRecordTypeId(Gift__c.SObjectType, 'Grant'));
            if (rt == SelectedOpp.RecordTypeId) {
                theTrans.RecordTypeId = rt;
            }
            else {
                theTrans.RecordTypeId = RegGiftRTID;
            }
            try {
                DMLManager.InsertSObject(theTrans);
            }
            catch (Exception ex) {
                if (!IsLightning) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
                    return null;
                }
                convertOppSubmitErrorMsg = ex.getMessage();
                return null;
            }

            rt = Id.valueOf(Utilities.getObjectRecordTypeId(Payment__c.SObjectType, 'Standard'));
            for (PaymentWrapper pw : theWrappers) {
                pw.thePayment.Donation__c = theTrans.Id; pw.thePayment.RecordTypeId = rt;
                for (Gift_Detail__c gd : pw.theGiftDetails){
                    gd.Gift__c = theTrans.Id; gd.Allocation_Date__c = pw.thePayment.Date__c;
                }
            }

            for (Task t : theTasks)
            {
                t.WhatId = theTrans.Id;
                t.WhoId = cr.ContactId;
            }

            List<Payment__c> pToBeInserted = new List<Payment__c>();
            List<Gift_Detail__c> gdToBeInserted = new List<Gift_Detail__c>();
            for (PaymentWrapper pw : theWrappers)
            {
                pToBeInserted.add(pw.thePayment);
                if (pw.isRemind)
                {
                    theTasks.add(new Task(ActivityDate = (pw.thePayment.Date__c - pw.daysBefore), OwnerId = UserInfo.getUserId(), WhatId = theTrans.Id, WhoId = cr.ContactId, Subject = 'Reminder - ' + SelectedOpp.Name + ' follow-up', Description = 'Reminder - ' + SelectedOpp.Name + ' follow-up'));
                }
            }
            DMLManager.InsertSObjects(pToBeInserted);
            for (PaymentWrapper pw : theWrappers)
            {
                for (Gift_Detail__c gd : pw.theGiftDetails)
                {
                    gd.Payment__c = pw.thePayment.Id;
                    gdToBeInserted.add(gd);
                }
            }
            DMLManager.InsertSObjects(gdToBeInserted);
            if (theTasks != null && theTasks.size() > 0) {
                DMLManager.InsertSObjects(theTasks);
            }

            SelectedOpp.StageName = 'Converted to Transaction';
            DMLManager.UpdateSObject(SelectedOpp);

            PageReference pr = new ApexPages.StandardController(theTrans).view();
            pr.setRedirect(true);

            return pr;
    }

    public string convertOppSubmitErrorMsg {get;set;}
    public PageReference Submit2() {
        convertOppSubmitErrorMsg = '';

        Savepoint sp = Database.setSavepoint();
        Double pTotal = 0;
        Double aTotal = 0;
        String BucketAccountId = '';
        String RegGiftRTID = '';
        Gift__c theTrans = new Gift__c();
        OpportunityContactRole cr = new OpportunityContactRole();

        //try
        //{
            BatchSettings__c settings = BatchSettings__c.getInstance('Default');
            Id rtypes = Id.valueOf(Utilities.getObjectRecordTypeId(Gift__c.SObjectType, 'Gift'));

            if (settings != null) {
                BucketAccountId = settings.BucketAccountId__c;
                //RegGiftRTID = settings.RegularGiftRecordTypeId__c;
                 RegGiftRTID = rtypes;
            }

                //If Appeal record is not of type Appeal or Event, Send Error message.
            List<Id> appealIDs = new List<Id>();

            for (PaymentWrapper pw : theWrappers)
            {
                pTotal += pw.thePayment.Amount__c;

                for (Gift_Detail__c gd : pw.theGiftDetails)
                { aTotal += gd.Amount__c; appealIDs.add(gd.New_Campaign__c); }
            }

            Id RTP = Id.valueOf(Utilities.getObjectRecordTypeId(Campaign.SObjectType, 'Campaign'));
            List<Campaign> cmpList = new CampaignSelector().SelectRecordTypeIdByRecordTypeIdAndId(Utilities.ConvertIdListToIdSet(appealIDs), RTP);
            if (cmpList != null && cmpList.size() > 0) {
                theTrans.addError('Appeal: "' + cmpList[0].Name + '" must be of type Appeal or Event.');
                return null;
            }

            //if payments total > opp amount -error
            if (pTotal > SelectedOpp.Amount)
            {
                convertOppSubmitErrorMsg = 'The sum of all entered payments is greater than the Opportunities Value';
                return null;
            }

            //if allocations total != payment total -error
            if (aTotal != pTotal)
            {
                convertOppSubmitErrorMsg = 'The sum of all entered Allocations is not equal to the sum of all entered payments';
                return null;
            }

            //In case of Opportunities with no designated Organization, consider the Individual ID.
            if (SelectedOpp.AccountId == null)
            {
                theTrans.Constituent__c = SelectedOpp.Individual__c;
            }
            //In case of Opportunities with designated Organization, consider the Organization ID.
            else
            {
                theTrans.Organization__c = SelectedOpp.AccountId;
            }

            //(In case of Opportunities with no designated Organization)
            //Add selected Opportunity's ContactId to Transaction Constituent__c field, if selected Opportunity's AccountId == null and,
            //     the Transaction's Constituent__c == null.
            if(SelectedOpp.AccountId == null && theTrans.Constituent__c == null) {
                theTrans.Constituent__c = SelectedOpp.Individual__c;
            }

            //create transaction, add payments underneith, add giftdetails underneith, add tasks
            theTrans.Expected_Amount__c = SelectedOpp.Amount;
            theTrans.Gift_Date__c = SelectedOpp.CloseDate;
            theTrans.Status__c = 'In Progress';
            theTrans.Proposal__c = SelectedOpp.Id;
            Id rt = Id.valueOf(Utilities.getObjectRecordTypeId(Gift__c.SObjectType, 'Grant'));
            // below caused an error since the query returns 2 records and value is not being assigned to a list
            if (rt == SelectedOpp.RecordTypeId) {
                theTrans.RecordTypeId = rt;
            }
            else {
                theTrans.RecordTypeId = RegGiftRTID;
            }
            try {
                DMLManager.InsertSObject(theTrans);
            }
            catch
            (Exception ex) {
                if (!IsLightning) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
                    return null;
                }
                convertOppSubmitErrorMsg = ex.getMessage();
                return null;
            }

            rt = Id.valueOf(Utilities.getObjectRecordTypeId(Payment__c.SObjectType, 'Standard'));
            for (PaymentWrapper pw : theWrappers)
            {
                pw.thePayment.Donation__c = theTrans.Id; pw.thePayment.RecordTypeId = rt;
                for (Gift_Detail__c gd : pw.theGiftDetails)
                { gd.Gift__c = theTrans.Id; gd.Allocation_Date__c = pw.thePayment.Date__c; }
            }

            for (Task t : theTasks)
            {
                t.WhatId = theTrans.Id;
                t.WhoId = cr.ContactId;
            }

            List<Payment__c> pToBeInserted = new List<Payment__c>();
            List<Gift_Detail__c> gdToBeInserted = new List<Gift_Detail__c>();
            for (PaymentWrapper pw : theWrappers)
            {
                pToBeInserted.add(pw.thePayment);
                if (pw.isRemind)
                {
                    theTasks.add(new Task(ActivityDate = (pw.thePayment.Date__c - pw.daysBefore), OwnerId = UserInfo.getUserId(), WhatId = theTrans.Id, WhoId = cr.ContactId, Subject = 'Reminder - ' + SelectedOpp.Name + ' follow-up', Description = 'Reminder - ' + SelectedOpp.Name + ' follow-up'));
                }
            }
            DMLManager.InsertSObjects(pToBeInserted);
            for (PaymentWrapper pw : theWrappers)
            {
                for (Gift_Detail__c gd : pw.theGiftDetails)
                {
                    gd.Payment__c = pw.thePayment.Id;
                    gdToBeInserted.add(gd);
                }
            }
            DMLManager.InsertSObjects(gdToBeInserted);
            DMLManager.InsertSObjects(theTasks);

            SelectedOpp.StageName = 'Converted to Transaction';
            DMLManager.UpdateSObject(SelectedOpp);

            PageReference pr = new ApexPages.StandardController(theTrans).view();
            pr.setRedirect(true);

            return pr;
    }

    public PageReference goToTrans() {
        PageReference pr = new ApexPages.StandardController(trans).view();
        pr.setRedirect(true);

        return pr;
    }

    public void nilMethod() { }

    //** Used to feed Javascript to Dynamicly populate fund when an Appeal is selected ** //
    public class BatchAllocationSetting {
        public string LetterId { get; set; }
        public string LetterName { get; set; }

        public string FundId { get; set; }
        public string FundName { get; set; }

        public BatchAllocationSetting() { }
        public BatchAllocationSetting(string l, string f)
        {
            LetterId = l;
            FundId = f;
        }
    }

    @RemoteAction
    public static BatchAllocationSetting GetAppealDefaults(string appealId) {
        List<Campaign> camps = new CampaignSelector().SelectLetterAndFundById(new Set<Id> { appealId });
        if (camps!=null && camps.size()>0) {
            BatchAllocationSetting setting = new BatchAllocationSetting(camps[0].Letter__c, camps[0].Fund__c);
            if (camps[0].Letter__c!=null)
                setting.LetterName = camps[0].Letter__r.Name;
            if (camps[0].Fund__c!=null)
                setting.FundName = camps[0].Fund__r.Name;
            return setting;
        }
        else
            return new BatchAllocationSetting();
    }
}