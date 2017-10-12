public with sharing class GiftBatchWrapper {

    public boolean isIndividualGift { get; set; }
    public boolean isRecurring {get; set;}

    //identifier
    public String id { get; set; }
    public Account account { get; set; }
    public Contact constituent { get; set; }
    public Gift__c gift { get; set; }
    public Recurring_Donation__c recurringDonation { get; set; }
    public List<Gift_Detail__c> giftDetails { get; set; }
    public List<RD_Allocation__c> rdGiftDetails { get; set; }
    public Payment__c payment { get; set; }
    public Receipt__c receipt { get; set; }
    public Note giftNote { get; set; }
    public String noteSubject { get; set; }

    public string rstartdate{get;set;}  //Added on 14-04-2017
    public string gtransactiondate{get;set;}  //Added on 14-04-2017
    public string pdate{get;set;}  //Added on 14-04-2017

    public string pcheckdate{get;set;}  //Added on 14-04-2017
    public string pdepositeddate{get;set;}  //Added on 14-04-2017
    public string paymentdate{get;set;}  //Added on 14-04-2017

    public String lookupintersoli { get; set; }  //added on 13-04-2017
    public String lookuplatter { get; set; }  //added on 13-04-2017
    public String lookuptribute { get; set; }  //added on 13-04-2017
    public String lookupprod { get; set; }  //added on 13-04-2017
    public String lookupfund { get; set; }  //added on 13-04-2017
    public String lookupncomp { get; set; }  //added on 13-04-2017

    public String noteBody { get; set; }
    public Gift_Detail__c giftDetail { get; set; }
    public RD_Allocation__c rdGiftDetail { get; set; }

    // CC Info for CC Batch entries
    public String CCNumber {get; set;}
    public String CCName { get; set;}
    public String expirationDate { get; set; }
    public String Cvv { get; set; }
    public String cardholderFirstName { get; set; }
    public String cardholderLastName { get; set; }
    public boolean isNewRecord { get; set; }

    //presets related data
    public GiftBatchPresets presets { get; set; }
    public User user { get; set; }

    private static String NamespacePrefix = Utilities.getCurrentNamespace();
    private static String NamespaceField = NamespacePrefix + (String.isEmpty(NamespacePrefix) ? '' : '__');
    private static string NamespaceGift = NamespaceField + 'Gift__c';

    public string SaveTitle {
        get
        {
            string retVal = 'Save';
            try
            {
                if (gift != null && payment != null && gift.Batch_Status__c == 'Failed' && payment.Payment_Type__c == 'Credit Card')
                    retVal = 'Resubmit';

            }
            catch (Exception ex)
            {
            }
            return retVal;
        }
   }

   public string SaveAndNewTitle {
        get
        {
            string retVal = 'Save & New';
            try {
                if (gift != null && payment != null && gift.Batch_Status__c == 'Failed' && payment.Payment_Type__c == 'Credit Card')
                    retVal = 'Resubmit & New';
            }
            catch (Exception ex) { }
            return retVal;
        }
   }

   public GiftBatchWrapper() {

       isIndividualGift = true;
       isRecurring = false;
       account = new Account();
       constituent = new Contact();
       gift = CreateGiftInstance();

       recurringDonation = new Recurring_Donation__c();
       giftDetails = new List<Gift_Detail__c>();
       giftDetail = new Gift_Detail__c();
       rdGiftDetails = new List<RD_Allocation__c>();
       rdGiftDetail = new RD_Allocation__c();
       payment = new Payment__c();
       giftNote = new Note();
       receipt = new Receipt__c();
       noteSubject = '';
       noteBody = '';
       Cvv = '';
       isNewRecord = false;
       id =  'NotSavedYet-' + DateTime.now().format('hmmss');
   }

   public void loadDefaults() {
      if (presets==null) {
          if (user == null)
            user = GiftBatchPresets.GetPresetsData();
          presets = new GiftBatchPresets(user);
      }
      presets.load(this);
   }

   public void clearDefaults() {
      if (presets != null)
       presets.ClearDefaults();
   }

   public void saveDefaults() {
      if (presets != null)
        presets.save(this);
   }

   public String getUniqueId() {
      if (gift == null) return '';

      string retVal = '';
      string giftNumber = gift.Name;
      if (giftNumber == null || giftNumber == '')
      {
          //refresh gift
          Gift__c g = loadGiftRecord(gift.Id);
          if (g != null) {
           gift = g;
           giftNumber = g.Name;
          }
          else
           return retVal;
      }

      retVal = giftNumber + '-' + DateTime.now().format('hmmss');

      return retVal;
   }

   public static String getBukectAccountId() {
      string retval = '';
      List<BatchSettings__c> settings = new BatchSettingsSelector().SelectBucketAccountById('Default');

      if (settings != null && settings.size() > 0)
         retval = settings[0].BucketAccountId__c;

      return retval;
   }

   public Gift_Detail__c CreateGiftDetailInstance() {
      Gift_Detail__c gd = new Gift_Detail__c();
      gd.Amount__c = giftDetail.Amount__c;
      gd.New_Campaign__c = giftDetail.New_Campaign__c;
      gd.Product__c = giftDetail.Product__c;
      gd.Tribute__c = giftDetail.Tribute__c;
      gd.Package__c = giftDetail.Package__c;
      gd.Fund__c = giftDetail.Fund__c;
      gd.Description__c = giftDetail.Description__c;
      return gd;
   }

   public RD_Allocation__c CreateRDGiftDetailInstance() {
      RD_Allocation__c gd = new RD_Allocation__c();
      gd.Amount__c = giftDetail.Amount__c;
      gd.New_Campaign__c = giftDetail.New_Campaign__c;
      gd.Package__c = giftDetail.Package__c;
      gd.Fund__c = giftDetail.Fund__c;
      return gd;
   }

   public static Gift__c CreateGiftInstance() {
      Gift__c g = new Gift__c();
      g.Batch_Status__c = 'Pending';
      return g;
   }

   public static List<GiftBatchWrapper> GetBatchData(string giftBatchId, User presetsData)
   {
      List<GiftBatchWrapper> wrappers = new List<GiftBatchWrapper>();

      List<Gift__c> gifts = new GiftSelector().SelectAccountContactRecurringDonationAndAllocationByGiftBatchId(giftBatchId);

      User user = GiftBatchPresets.GetPresetsData();
      if (gifts != null && gifts.size()>0)
      {
          List<String> listOfIds = new List<String>();
          for(Gift__c g : gifts)
          {
             if (g.Recurring_Donation__c != null) listOfIds.add(g.Recurring_Donation__c);
          }

          List<RD_Allocation__c> rdAllocations = new List<RD_Allocation__c>();

          if(listOfIds.isEmpty() == false){
            rdAllocations = new RDAllocationSelector().SelectPackageByRecurringGiftId(Utilities.ConvertStringListToIdSet(listOfIds));
          }

          for(Gift__c g : gifts)
          {
             List<RD_Allocation__c> rds = new List<RD_Allocation__c>();
             for(RD_Allocation__c rd : rdAllocations)
               if (g.Recurring_Donation__c==rd.Recurring_Gift__c)
                 rds.add(rd);

            wrappers.add(GetInstance(g, rds, user));
          }
      }
      return wrappers;
   }

   private static GiftBatchWrapper GetInstance(Gift__c gift, List<RD_Allocation__c> rdAllocation)
   {
       User user = GiftBatchPresets.GetPresetsData();
       return GetInstance(gift, rdAllocation, user);
   }

    private static GiftBatchWrapper GetInstance(Gift__c gift,List<RD_Allocation__c> rdAllocation, User presetsData)
    {
        if (gift == null)
          return null;

        GiftBatchWrapper wrapper = new GiftBatchWrapper();
        wrapper.gift = gift;
        wrapper.isIndividualGift = (gift.Constituent__r != null);
        wrapper.giftDetails = gift.Gift_Allocations__r.size() > 0 ? gift.Gift_Allocations__r : new List<Gift_Detail__c>();
        wrapper.rdGiftDetails = rdAllocation != null ? rdAllocation : new List<RD_Allocation__c>();
        wrapper.constituent = gift.Constituent__r==null? new Contact() : gift.Constituent__r;
        wrapper.account = gift.Organization__r==null? new Account() : gift.Organization__r;
        wrapper.payment = gift.Recurring_Payments__r.size() > 0 ? gift.Recurring_Payments__r[0] : new Payment__c();
        wrapper.recurringDonation = gift.recurring_Donation__r == null? new Recurring_Donation__c() : gift.recurring_Donation__r;
        wrapper.expirationDate = wrapper.recurringDonation != null? formatExpirationDate(wrapper.recurringDonation.Credit_Card_Expiry_Date__c) : '';
        wrapper.receipt = gift.Receipts__r.size() > 0 ? gift.Receipts__r[0] : new Receipt__c();
        wrapper.giftNote = gift.Notes.size() > 0 ? gift.Notes[0] : new Note();
        if (gift.Notes.size() > 0)
        {
            wrapper.noteSubject = gift.Notes[0].Title;
            wrapper.noteBody = gift.Notes[0].Body;
        }

        wrapper.isRecurring = (wrapper.recurringDonation != null && wrapper.recurringDonation.Frequency__c != null);

        if (wrapper.giftDetails.size()<=0)
          wrapper.giftDetails.add(wrapper.CreateGiftDetailInstance());

         if (wrapper.rdGiftDetails.size()<=0)
            wrapper.rdGiftDetails.add(wrapper.CreateRDGiftDetailInstance());

        return wrapper;
    }

   public static GiftBatchWrapper CreateInstance(string giftId)
   {
        GiftBatchWrapper newGift = new GiftBatchWrapper();

        Gift__c gift = loadGiftRecord(giftId);

        if (gift != null)
        {
            List<RD_Allocation__c> rdAllocation = null;
            if (gift.Recurring_Donation__c != null)
            {
                rdAllocation = new RDAllocationSelector().SelectPackageByRecurringGiftId(new Set<Id> { gift.Recurring_Donation__c });
            }

            newGift  = GetInstance(gift, rdAllocation);
        }
        else
        {
            newGift.user = GiftBatchPresets.GetPresetsData();
            newGift.loadDefaults();
        }

        return newGift;
    }

    public static GiftBatchWrapper refreshInstance(GiftBatchWrapper original) {
        if (original == null || original.gift == null || original.gift.Id == null)
          return original;

        GiftBatchWrapper wrapper = CreateInstance(original.gift.Id);
        wrapper.CCName = original.CCName;
        wrapper.CCNumber = original.CCNumber;
        wrapper.Cvv = original.Cvv;
        wrapper.expirationDate = original.expirationDate;
        wrapper.isIndividualGift = original.isIndividualGift;
        wrapper.isRecurring = original.isRecurring;
        wrapper.cardholderFirstName = original.cardholderFirstName;
        wrapper.cardholderLastName = original.cardholderLastName;

        if (original.receipt.Gift__c != null && wrapper.receipt.Gift__c==null)
          wrapper.receipt = original.receipt;

        return wrapper;
    }
    private static Gift__c loadGiftRecord(string giftId)
    {
       List<Gift__c> gifts = new List<Gift__c>();

       gifts = new GiftSelector().SelectAccountContactRecurringDonationAndAllocationById(new Set<Id> { giftId });

       if (gifts != null && gifts.size() > 0)
          return gifts[0];
       else
          return null;

    }

    public static string formatExpirationDate(Date expiryDate)
    {
        if (expiryDate==null)
          return '';

        string month = expiryDate.month().format();
        if (month.length()==1)
          month = '0'+month;
        string year = expiryDate.year().format();

        return month+year.substring(3,5);
    }

    static testMethod void testMe()
    {
        BatchSettings__c bs = testCustomSettings();
        String recordTypeId = Utilities.getObjectRecordTypeId(Gift__c.SObjectType, 'Gift');

        GiftBatchWrapper gw = new GiftBatchWrapper();
        string value = gw.SaveTitle;
        value = gw.SaveAndNewTitle;
        gw.gift.Batch_Status__c = 'Failed';
        value = gw.SaveTitle;
        value = gw.SaveAndNewTitle;

        gw = new GiftBatchWrapper();
        gw.user = new User();
        gw.loadDefaults();
        gw.clearDefaults();
        gw.saveDefaults();
        value = gw.getUniqueId();
        GiftBatchWrapper.getBukectAccountId();
        System.assertEquals(bs.BucketAccountId__c, GiftBatchWrapper.getBukectAccountId());
        GiftBatchWrapper.CreateGiftInstance();
        System.assertEquals(String.valueOf('Pending'), String.valueOf(GiftBatchWrapper.CreateGiftInstance().Batch_Status__c));

        GiftBatchWrapper.refreshInstance(gw);
        Account a = new Account(Name = 'sss');
        DMLManager.InsertSObject(a);

        Gift__c g = new Gift__c();
        g.Organization__c = a.Id;
        g.RecordTypeId = recordTypeId;
        DMLManager.InsertSObject(g);
        gw.gift = g;
        GiftBatchWrapper.refreshInstance(gw);
        GiftBatchWrapper.CreateInstance(g.Id);

        Batch_Template__c bt123 = new Batch_Template__c();
        bt123.name = 'abc';
        DMLManager.InsertSObject(bt123);

        Gift_Batch__c gb2 = new Gift_Batch__c();
        gb2.Name__c = 'test977';
        gb2.Template_Name__c = bt123.id;
        DMLManager.InsertSObject(gb2);

        User user = new User();
        GiftBatchWrapper.GetBatchData(gb2.Id, user);
        for(GiftBatchWrapper gbw : GiftBatchWrapper.GetBatchData(gb2.Id, user)){
            System.assertEquals(g, gbw.gift);
        }

    }

   public static testMethod BatchSettings__c testCustomSettings()
   {
        List<aNums__c> setlist = new aNumsSelector().SelectSObjects();
        if (setlist .size() == 0) {
            aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
            DMLManager.InsertSObject(cs1);
        }
       Account a2 = new Account(Name = 'Ind');
       DMLManager.InsertSObject(a2);
       List<RecordType> rts = new RecordTypeSelector().SelectBySObjectNameAndIsActive(NamespaceGift, 'Gift', true);
        String recTypeId = '';
        if (rts!=null&&rts.size()>0)
          recTypeId = rts[0].Id;

        List<BatchSettings__c> bsettings = new BatchSettingsSelector().SelectSObjectsByName('Default');
        if (bsettings!=null && bsettings.size()>0)
          return bsettings[0];
        else
        {

            BatchSettings__c b = new BatchSettings__c();
            b.RegularGiftRecordTypeId__c = recTypeId;
            b.BatchFormID__c = 'asdasdsadasd';
            b.Name='Default';
            b.BatchReportId__c = 'sdfsdfsdfdsfd';
            b.BucketAccountId__c = a2.Id;
            b.CurrencyCode__c = 'CAD';
            b.GatewayUrl__c = 'https://www.givingpower.com/service.asmx';

            DMLManager.InsertSObject(b);
            return b;
        }
   }

}