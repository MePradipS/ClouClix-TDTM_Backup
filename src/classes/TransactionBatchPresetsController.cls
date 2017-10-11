public with sharing class TransactionBatchPresetsController extends RedirectController {

  public GiftBatchWrapper wrapper { get; set; }
  public String TrsactionName { get; set; }

  public TransactionBatchPresetsController() {
    super(true);
     TrsactionName = 'Gift';
     initPage();
     //schemaDesc = Schema.getGlobalDescribe();
  }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

  private void initPage()
  {
     wrapper = new GiftBatchWrapper();
     wrapper.loadDefaults();

     String recordTypeId = '';

     List<BatchSettings__c> settingList = new BatchSettingsSelector().SelectIdWhenDefault();
     if (settingList != null && settingList.size()>0)
          recordTypeId  = settingList[0].RegularGiftRecordTypeId__c;
     if (recordTypeId != null && recordTypeId != '')
     {
        List<RecordType> rts = new RecordTypeSelector().SelectRecordByRecordId(recordTypeId);
        if (rts!=null && rts.size()>0)
          TrsactionName = rts[0].Name;
     }

  }

  public void clear() {
     wrapper.clearDefaults();
     wrapper = new GiftBatchWrapper();
     wrapper.loadDefaults();
  }

  public void save()
  {
     if ((wrapper.presets.giftSubject.isHidden || wrapper.presets.giftSubject.readOnly) && (wrapper.noteSubject==null || wrapper.noteSubject==''))
     {
        if ( !wrapper.presets.giftNotes.isHidden || (wrapper.noteSubject!=null && wrapper.noteSubject!=''))
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid state: Note subject default value is required if you are not hidding Note Content or setting a default value for it.'));
             return;
        }
     }


     if ( wrapper.presets.giftSubject.readOnly && !wrapper.presets.giftNotes.readOnly && !wrapper.presets.giftNotes.isHidden && (wrapper.noteSubject==null || wrapper.noteSubject==''))
     {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid state: Note subject default value is required if you are not hidding Note Content.'));
        return;
     }

     if ( (wrapper.presets.receiptType.readOnly || wrapper.presets.receiptType.isHidden) && (wrapper.gift.Receipt_Type__c==null || wrapper.gift.Receipt_Type__c==''))
     {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid state: Receipt Type requires a default value.'));
        return;
     }

     if ( (wrapper.presets.paymentType.readOnly || wrapper.presets.paymentType.isHidden) &&  (wrapper.payment.Payment_Type__c==null||wrapper.payment.Payment_Type__c==''))
     {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid state: payment Type requires a default value.'));
        return;
     }

     wrapper.saveDefaults();

     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your presets are saved.'));
  }


  static testMethod void testMe() {

        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();

        cnt.wrapper.presets.giftSubject.readOnly = true;
        cnt.wrapper.noteSubject = '';
        cnt.save();

        cnt.wrapper.noteSubject = 'jkjkjl';

        cnt.wrapper.presets.receiptType.readOnly = true;
        cnt.wrapper.gift.Receipt_Type__c = '';
        cnt.save();

        cnt.wrapper.gift.Receipt_Type__c = 'xvxczvz';

        cnt.wrapper.presets.paymentType.readOnly = true;
        cnt.wrapper.payment.Payment_Type__c = '';
        cnt.save();

        cnt.wrapper.gift.Receipt_Type__c = 'On time only';
        cnt.wrapper.payment.Payment_Type__c = 'Credit Card';
        cnt.save();

        cnt.clear();
    }

   // contact region .....
    public  List<String>  getConstituentRegion()
    {

        List<String> regionoptions=new List<String>();

         Schema.DescribeFieldResult  region=Contact.fields.Region__c.getDescribe();
        List<Schema.PicklistEntry>  regionpval = region.getPicklistValues();

        for(Schema.PicklistEntry pval : regionpval)
             regionoptions.add(String.valueOf(pval.getLabel()));


        return regionoptions;
    }
    // contact traid status ......
    public  List<String>  getConstituentTraidStatus()
    {

        List<String> traidstatsoptions=new List<String>();

         Schema.DescribeFieldResult  tstatus=Contact.fields.Trade_Status__c.getDescribe();
        List<Schema.PicklistEntry>  tstatuspval = tstatus.getPicklistValues();

        for(Schema.PicklistEntry pval : tstatuspval)
             traidstatsoptions.add(String.valueOf(pval.getLabel()));


        return traidstatsoptions;
    }

    // Account region .....
    public  List<String>  getAccountRegion()
    {

        List<String> regionoptions=new List<String>();

         Schema.DescribeFieldResult  region=Account.fields.Region__c.getDescribe();
        List<Schema.PicklistEntry>  regionpval = region.getPicklistValues();

        for(Schema.PicklistEntry pval : regionpval)
             regionoptions.add(String.valueOf(pval.getLabel()));


        return regionoptions;
    }





    // Account type .....
    public  List<String>  getAccountType()
    {

        List<String> acctypeoptions=new List<String>();

         Schema.DescribeFieldResult  atype=Account.fields.Type.getDescribe();
        List<Schema.PicklistEntry>  atypepval = atype.getPicklistValues();

        for(Schema.PicklistEntry pval : atypepval)
             acctypeoptions.add(String.valueOf(pval.getLabel()));


        return acctypeoptions;
    }

     // Account traid status ......
    public  List<String>  getAccountTraidStatus()
    {

        List<String> traidstatsoptions=new List<String>();

         Schema.DescribeFieldResult  tstatus=Account.fields.Trade_Status__c.getDescribe();
        List<Schema.PicklistEntry>  tstatuspval = tstatus.getPicklistValues();

        for(Schema.PicklistEntry pval : tstatuspval)
             traidstatsoptions.add(String.valueOf(pval.getLabel()));


        return traidstatsoptions;
    }
    // Reccring donaition......
    public  List<String>  getReccuringDonation()
    {

        List<String> rdonationoptions=new List<String>();

         Schema.DescribeFieldResult rfrequency=Recurring_Donation__c.fields.Frequency__c.getDescribe();
        List<Schema.PicklistEntry>  freqpval = rfrequency.getPicklistValues();

        for(Schema.PicklistEntry pval : freqpval)
             rdonationoptions.add(String.valueOf(pval.getLabel()));


        return rdonationoptions;
    }

    // Gift chennal......
    public  List<String>  getGiftChannal()
    {

        List<String> gchanneloptions=new List<String>();

         Schema.DescribeFieldResult gchannel=Gift__c.fields.Channel__c.getDescribe();
        List<Schema.PicklistEntry>  chanpval = gchannel.getPicklistValues();

        for(Schema.PicklistEntry pval : chanpval)
             gchanneloptions.add(String.valueOf(pval.getLabel()));


        return gchanneloptions;
    }
    // Gift Type......
    public  List<String>  getGiftType()
    {

        List<String> gtypeoptions=new List<String>();

         Schema.DescribeFieldResult gtype=Gift__c.fields.Gift_Type__c.getDescribe();
        List<Schema.PicklistEntry>  typepval = gtype.getPicklistValues();

        for(Schema.PicklistEntry pval : typepval)
             gtypeoptions.add(String.valueOf(pval.getLabel()));


        return gtypeoptions;
    }
    // Gift Recipt Type......
    public  List<String>  getGiftReciptType()
    {

        List<String> reciptoptions=new List<String>();

         Schema.DescribeFieldResult grecptype=Gift__c.fields.Receipt_Type__c.getDescribe();
        List<Schema.PicklistEntry>  rtypepval = grecptype.getPicklistValues();

        for(Schema.PicklistEntry pval : rtypepval)
             reciptoptions.add(String.valueOf(pval.getLabel()));


        return reciptoptions;
    }



     // Payment  Type......
    public  List<String>  getPaymentType()
    {

        List<String> ptypeoptions=new List<String>();

         Schema.DescribeFieldResult ptype=Payment__c.fields.Payment_Type__c.getDescribe();
        List<Schema.PicklistEntry>  ptypepval = ptype.getPicklistValues();

        for(Schema.PicklistEntry pval : ptypepval)
             ptypeoptions.add(String.valueOf(pval.getLabel()));


        return ptypeoptions;
    }

     // Payment Credit card  Type......
    public  List<String>  getCreditCardType()
    {

        List<String> ptypeoptions=new List<String>();

         Schema.DescribeFieldResult ptype=Payment__c.fields.Credit_Card_Type__c.getDescribe();
        List<Schema.PicklistEntry>  ptypepval = ptype.getPicklistValues();

        for(Schema.PicklistEntry pval : ptypepval)
             ptypeoptions.add(String.valueOf(pval.getLabel()));


        return ptypeoptions;
    }

     // constituent code......
    public  List<String>  getConstituentCodes()
    {

        List<String> concodeoptions=new List<String>();

         Schema.DescribeFieldResult conscode=Contact.fields.Constituent_Codes__c.getDescribe();
        List<Schema.PicklistEntry>  concodepval = conscode.getPicklistValues();

        for(Schema.PicklistEntry pval : concodepval)
             concodeoptions.add(String.valueOf(pval.getLabel()));


        return concodeoptions;
    }

     // Solicit_Codes ......
    public  List<String>  getSolicitCodes()
    {

        List<String> solicodeoptions=new List<String>();

         Schema.DescribeFieldResult solicode=Contact.fields.Solicit_Codes__c.getDescribe();
        List<Schema.PicklistEntry>  solicodepval = solicode.getPicklistValues();

        for(Schema.PicklistEntry pval : solicodepval)
             solicodeoptions.add(String.valueOf(pval.getLabel()));


        return solicodeoptions;
    }

     // Account code......
    public  List<String>  getAccConstituCodes()
    {

        List<String> concodeoptions=new List<String>();

         Schema.DescribeFieldResult conscode=Account.fields.Constituent_Codes__c.getDescribe();
        List<Schema.PicklistEntry>  concodepval = conscode.getPicklistValues();

        for(Schema.PicklistEntry pval : concodepval)
             concodeoptions.add(String.valueOf(pval.getLabel()));


        return concodeoptions;
    }

     // Solicit_Codes ......
    public  List<String>  getAccSolicitCodes()
    {

        List<String> solicodeoptions=new List<String>();

         Schema.DescribeFieldResult solicode=Account.fields.Solicit_Codes__c.getDescribe();
        List<Schema.PicklistEntry>  solicodepval = solicode.getPicklistValues();

        for(Schema.PicklistEntry pval : solicodepval)
             solicodeoptions.add(String.valueOf(pval.getLabel()));


        return solicodeoptions;
    }



}