public with sharing class MatchingControllerExtension {
// Security issue resolve.
    public Gift__c theGift { get; set; }
    public Gift__c origGift { get; set; }
    public Payment__c thePayment { get; set; }
    public Receipt__c theReceipt { get; set; }
    public string pType { get; set; }
    public string ccExpM { get; set; }
    public string ccExpY { get; set; }
    public string ccCVV { get; set; }
    public List<Gift_Detail__c> theGiftDetails { get; set; }
    public boolean createReceipt { get; set; }
    public boolean isMatched { get; set; }
	private String namespacePrefix = Utilities.getCurrentNamespace();
    private String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');

    public MatchingControllerExtension(ApexPages.StandardController controller) {
        List<Gift__c> giftList = new GiftSelector().SelectExpectedAmountById(new Set<Id> { controller.getId() });
        if (giftList != null && giftList.size() > 0) {
            origGift = giftList[0];
            theGift = giftList[0].clone(false, true, false, false);
        }
        String giftObject = namespaceFieldPrefix + 'Gift__c';
        RecordType rt;
        List<RecordType> rtList = new RecordTypeSelector().SelectBySObjectAndName(giftObject, 'Matching Gift');
        if (rtList != null && rtList.size() > 0) {
            rt = rtList[0];
        }
         theGift.RecordTypeId = rt.Id;
         theGift.Gift_Date__c = Date.Today();
         theGift.Constituent__c = null;
         theGift.Organization__c = null;
         thePayment = new Payment__c();
         thePayment.Payment_Type__c = '';
         theGiftDetails = new List<Gift_Detail__c>();
         for (Gift_Detail__c gd : new AllocationSelector().SelectMatchingGiftsByGiftId(origGift.Id))
         {
             Gift_Detail__c nGD = new Gift_Detail__c();
             nGD = gd.clone(false, true, false, false);
             nGD.Allocation_Date__c = Date.Today();
             theGiftDetails.add(nGD);
         }
         theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued');
        List<Gift__c> theGifts = new GiftSelector().SelectIdByMatchedGift(origGift.Id);

        isMatched = theGifts.size() > 0;

        if (isMatched)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This Transaction has previously been Matched'));
        }
    }

    public List<SelectOption> getPTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-- None --', '-- None --'));
        options.add(new SelectOption('Credit Card', 'Credit Card'));
        options.add(new SelectOption('Credit Card - Offline', 'Credit Card - Offline'));
        options.add(new SelectOption('Check', 'Check'));
        options.add(new SelectOption('Cash', 'Cash'));
        options.add(new SelectOption('Stock', 'Stock'));
        options.add(new SelectOption('Other', 'Other'));
        return options;
    }

    public List<SelectOption> getMonths() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', 'Jan'));
        options.add(new SelectOption('2', 'Feb'));
        options.add(new SelectOption('3', 'Mar'));
        options.add(new SelectOption('4', 'Apr'));
        options.add(new SelectOption('5', 'May'));
        options.add(new SelectOption('6', 'Jun'));
        options.add(new SelectOption('7', 'Jul'));
        options.add(new SelectOption('8', 'Aug'));
        options.add(new SelectOption('9', 'Sept'));
        options.add(new SelectOption('10', 'Oct'));
        options.add(new SelectOption('11', 'Nov'));
        options.add(new SelectOption('12', 'Dec'));
        return options;
    }

    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        for (Integer i = 0; i < 5; i++)
        {
            options.add(new SelectOption(String.valueOf(Date.Today().Year()+i), String.valueOf(Date.Today().Year()+i)));
        }
        return options;
    }

    public PageReference Submit() {
        if(pType == '-- None --'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Select Payment Type'));
            return null;
        }
        Savepoint sp = Database.setSavepoint();
        theGift.Matched_Gift__c = origGift.Id;
        theGift.Status__c = 'Entered';
        DMLManager.InsertSObject(theGift);
        thePayment.Donation__c = theGift.Id;
        thePayment.Amount__c = theGift.Expected_Amount__c;
        thePayment.Status__c = 'Approved';
        thePayment.Payment_Type__c = pType;
        DMLManager.InsertSObject(thePayment);
        for (Gift_Detail__c gd : theGiftDetails)
        {
            gd.Payment__c = thePayment.Id;
            gd.Gift__c = theGift.Id;
        }
        DMLManager.InsertSObjects(theGiftDetails);
        if (createReceipt)
        {
            theReceipt.Gift__c = theGift.Id;
            DMLManager.InsertSObject(theReceipt);
        }

        Solicitor__c softCredit = new Solicitor__c(Solicitor__c = origGift.Constituent__c, Gift__c = theGift.Id);
        DMLManager.InsertSObject(softCredit);

        PageReference pr = new ApexPages.StandardController(theGift).view();
        pr.setRedirect(true);

        return pr;
    }
}