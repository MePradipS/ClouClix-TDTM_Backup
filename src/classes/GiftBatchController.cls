public with sharing class GiftBatchController {

  public static String CvNamespace {
        get {
            if (CvNamespace == null) {
                SetNamespace();
            }
            return CvNamespace;
        }
        set;
    }

  public string pledgeId { get; set; }
  public boolean hasPledge { get; set; }
  public integer WizardStep { get; set; }
  public Gift_Batch__c SelectedBatch { get; set; }
  public string SelectedBatchName { get; set; }
  public BatchReconciliation Recon { get; set; }

  // package Search
  public string PackageSearchText { get; set; }
  public List<String> thePackages {get; set;}

  // appeal Search
  public string AppealSearchText { get; set; }
  public string SelectedAppealId { get; set; }

  // constituent Search
  public string ContactSearchText { get; set; }
  public string SelectedContactId { get; set; }

  // account search
  public string AccountSearchText { get; set; }
  public string SelectedAccountId { get; set; }

  // session view state data
  public GiftBatchWrapper curr_wrapper { get; set; }
  public List<GiftBatchWrapper> giftItems { get; set; }
  public List<GiftBatchWrapper> giftItemsForGiftDetail { get; set; }

  // selected gift
  public String selectedGiftId { get; set; }

  public boolean hasItems { get { return (giftItems != null && giftItems.size() > 0); } }
  public String userLocale { get { return UserInfo.getLocale(); } }
  public Boolean isSubmitEnabled { get; set; }
  public BatchSettings__c BatchSettings { get; set; }
  public boolean isGiftTypeVisible { get; set; }

  public boolean isTesting { get; set; }

  //used for removing gift detail items
  public decimal GiftDetailIndex { get; set; }
  public decimal RDGiftDetailIndex { get; set; }

  private String bucketAccountId = '';
  public boolean isBatchClosed {
    get
    {
      if (SelectedBatch.Close_Date__c != null)
        return true;
      else
        return false;
    }
  }

  //-------------------------------------------------------------------------------------------------------------------------
  public string selectedBatchId {
    get {
      string Val = SelectedBatch.id;
      if (Val != null && Val != '')
        Val = Val.substring(0, Val.length() - 3);
      return Val;
    }
  }

  //-------------------------------------------------------------------------------------------------------------------------
  public class internalException extends Exception { }
  public string FundKeyPrefix { get; set; }
  //-------------------------------------------------------------------------------------------------------------------------
  //If App_Settings__c.Enable_Enhanced_Batch_Interface__c = TRUE then launch NEW interface
  public boolean launchNewInterface { get; set; }

  //-------------------------------------------------------------------------------------------------------------------------
  public GiftBatchController(ApexPages.StandardController stdController) {
    SetNamespace();

    Schema.DescribeSObjectResult fund = Fund__c.sObjectType.getDescribe();
    FundKeyPrefix = fund.getKeyPrefix();

    isTesting = false;
    WizardStep = 1;
    isSubmitEnabled = false;
    this.SelectedBatch = (Gift_Batch__c)stdController.getRecord();
    refreshBatchData(SelectedBatch.Id);
    curr_wrapper = new GiftBatchWrapper();
    //presets
    curr_wrapper.user = GiftBatchPresets.GetPresetsData();
    curr_wrapper.loadDefaults();

    this.bucketAccountId = GiftBatchWrapper.getBukectAccountId();
    this.Recon = new BatchReconciliation();
    isGiftTypeVisible = true;
    GiftDetailIndex = 0;
    RDGiftDetailIndex = 0;
    giftItems = GiftBatchWrapper.GetBatchData(SelectedBatch.Id, curr_wrapper.user);
    updateReconciliation();
    //loading the settings
    List<BatchSettings__c> settingList = new BatchSettingsSelector().SelectSObjectsByName('Default');
    if (settingList != null && settingList.size() > 0)
      BatchSettings = settingList[0];
    progress = 0;
    thePackages = new List<String>();
    List<Package__c> packageList = new PackageSelector().SelectSObjectsByLimit(10000);
    for (Package__c p : packageList) {
      thePackages.add(p.Name);
    }
    maxItemPerBatch = 8;

    launchNewInterface = false;
    List<App_Settings__c> appSetList = new AppSettingSelector().SelectEnableEnhancedBatchInterface();
    if (appSetList != null && appSetList.size() > 0) {
      App_Settings__c appSet = appSetList[0];
      if (appSet != null) {
        launchNewInterface = (appSet.Enable_Enhanced_Batch_Interface__c && SelectedBatch.Template_Name__c != null);
      }
    }
  }
  //-------------------------------------------------------------------------------------------------------------------------
  private void refreshBatchData(string batchId) {
    List<Gift_Batch__c> batches = new GiftBatchSelector().SelectAllById(new Set<Id> { batchId });
    if (batches != null && batches.size() > 0) SelectedBatch = batches[0];
  }
  //-------------------------------------------------------------------------------------------------------------------------
  public void editBatch() {
    WizardStep = 3;
  }
  //-------------------------------------------------------------------------------------------------------------------------
  public void saveBatch() {
    try {
      DMLManager.UpdateSObject(SelectedBatch);
    } catch (Exception ex) {
      ApexPages.addMessages(ex);
      return;
    }

    refreshBatchData(SelectedBatch.Id);

    WizardStep = 1;
  }

  //-------------------------------------------------------------------------------------------------------------
  // used by the radio button to select gift type
  public void nilMethod() { }

  //-------------------------------------------------------------------------------------------------------------
  //Navigate to New Batch Item Interface
  public PageReference newBatchItemInterface() {
    PageReference pageRef = new PageReference('/apex/' + CvNamespace + 'BatchProcessingInterface?batchId=' + SelectedBatch.id);
    pageRef.setRedirect(true);
    return pageRef;
  }


  //-------------------------------------------------------------------------------------------------------------
  public void newGift() {
    curr_wrapper = new GiftBatchWrapper();
    curr_wrapper.user = GiftBatchPresets.GetPresetsData();
    curr_wrapper.loadDefaults();
    curr_wrapper.giftDetails.add(curr_wrapper.CreateGiftDetailInstance());
    curr_wrapper.rdGiftDetails.add(curr_wrapper.CreateRDGiftDetailInstance());
    WizardStep = 2;
    isGiftTypeVisible = true;
    ContactSearchText = '';
    AccountSearchText = '';
    SelectedContactId = '';
    SelectedAccountId = '';
  }

  //-------------------------------------------------------------------------------------------------------------
  public void FindContact() {
    List<Contact> Contacts = new ContactSelector().SelectAllConstituentInfoByConstituentId(new Set<String> { ContactSearchText });

    if (Contacts != null && Contacts.size() > 0) {
      curr_wrapper.constituent = contacts[0];
      hasPledge = CheckPledges(contacts[0].id);
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Constituent is found.'));
      curr_wrapper.cardholderFirstName = curr_wrapper.constituent.FirstName;
      curr_wrapper.cardholderLastName = curr_wrapper.constituent.LastName;
    } else {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Constituent is NOT found.'));
      ContactSearchText = '';
      curr_wrapper.constituent = new Contact();
    }
  }

  public List<Gift__c> outstanding_pledges { get; set; }

  public boolean CheckPledges(string contactId) {
    boolean retVal = false;
    outstanding_pledges = new GiftSelector().SelectByConstituentIdAndGiftType(new Set<Id> { contactId }, 'Pledge');
    if (outstanding_pledges.size() > 0) {
      retVal = true;
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Constituent has outstanding pledges.'));
    }
    return retVal;
  }
  //-------------------------------------------------------------------------------------------------------------
  public void FindAccount() {
    List<Account> accounts = new AccountSelector().SelectByOrganizationId(new Set<String> { AccountSearchText });

    if (accounts != null && accounts.size() > 0) {
      curr_wrapper.account = accounts[0];
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Organization is found.'));
    } else {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Organization is NOT found.'));
      AccountSearchText = '';
      curr_wrapper.account = new Account();
    }
  }

  //-------------------------------------------------------------------------------------------------------------
  public void updateReconciliation() {
    if (this.giftItems == null || this.giftItems.size() <= 0)
      return;

    Recon = new BatchReconciliation();

    for (GiftBatchWrapper wrapper : giftItems) {

      if (wrapper.gift == null || wrapper.payment == null)
        continue;
      Recon.totalCount++;
      string paymentType = wrapper.payment.Payment_Type__c;
      Decimal paymentAmount = (wrapper.gift.Expected_Amount__c == null) ? 0 : wrapper.gift.Expected_Amount__c;

      if (wrapper.isRecurring) {
        Recon.sharePlanCount += 1;
        Recon.ShareplanTotal += paymentAmount;
      } else {

        if (paymentType == 'Cash')
          Recon.cashTotal += paymentAmount;
        else if (paymentType == 'Credit Card') {
          Recon.creditCardTotal += paymentAmount;
          if (wrapper.gift.Batch_Status__c == 'Committed' || wrapper.gift.Batch_Status__c == 'Receipted')
            Recon.ccApprovedCount += 1;
          else if (wrapper.gift.Batch_Status__c == 'Failed')
            Recon.ccDeclinedCount += 1;
        } else if (paymentType == 'Check')
          Recon.chequeTotal += paymentAmount;
        else
          Recon.OtherTotal += paymentAmount;

        if (paymentType != 'PAD')
          Recon.grandTotal += paymentAmount;
      }

      if (paymentType == 'Credit Card'
          && wrapper.gift.Batch_Status__c == 'Pending'
          && (!wrapper.isRecurring || (wrapper.isRecurring && wrapper.recurringDonation.Start_Date__c == Date.today())) ) {

        Recon.ccPendingCount += 1;
        Recon.creditCardTotalPending += paymentAmount;

      }

    }
  }
  //-------------------------------------------------------------------------------------------------------------
  public void populateAmount() {

    if (curr_wrapper.giftDetails.size() > 0) {
      curr_wrapper.giftDetails[0].Amount__c = curr_wrapper.gift.Expected_Amount__c;
    }
    if (curr_wrapper.rdGiftDetails.size() > 0) {
      curr_wrapper.rdGiftDetails[0].Amount__c = curr_wrapper.gift.Expected_Amount__c;
    }
  }

  public void populateDate() {
    curr_wrapper.payment.Date__c = curr_wrapper.gift.Gift_Date__c;
    curr_wrapper.payment.Date_Deposited__c = curr_wrapper.gift.Gift_Date__c;
    curr_wrapper.payment.Cheque_Date__c = curr_wrapper.gift.Gift_Date__c;
  }

  public void cancel() {
    WizardStep = 1;
    hasPledge = false;
    // reload the gift
    curr_wrapper = GiftBatchWrapper.refreshInstance(curr_wrapper);
  }
  //-------------------------------------------------------------------------------------------------------------
  public boolean validateExpirationDate(string expDate) {

    string errorMessage = 'Invalid Expiration date. The correct format is: mmyy ';
    string errorExpired = 'Invalid Expiration date. ';
    if (expDate.length() != 4) {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMessage));
      return false;
    } else {
      string monthStr = expDate.substring(0, 2);
      string yearStr = expDate.substring(2, 4);

      integer monthValue = tryParseToInt(monthStr);
      if (monthValue == 0 || monthValue > 12) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMessage));
        return false;
      }

      integer yearValue = tryParseToInt('20' + yearStr);
      date curDate = date.today();
      if (yearValue == 0 || yearValue < curDate.year()) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMessage));
        return false;
      } else if (yearValue == curDate.year() && monthValue < curDate.month()) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorExpired));
        return false;
      }
    }

    return true;
  }
  //-------------------------------------------------------------------------------------------------------------
  public integer tryParseToInt(String txt) {
    integer result = 0;
    try {
      result = integer.valueOf(txt);
    } catch (Exception ex) {
    }

    return result;
  }
  private void pickPackage(GiftBatchWrapper curr_wrapper) {

    if (!curr_wrapper.presets.giftDetailPackage.isHidden) {
      if (curr_wrapper.gift.Package_Name__c != '') {
        List<Package__c> theP = new PackageSelector().SelectSObjectsByName(curr_wrapper.gift.Package_Name__c);
        if (theP.size() > 0 && theP != null) {
          curr_wrapper.giftDetail.Package__c = theP[0].Id;
        } else {
          if (curr_wrapper.giftDetail.New_Campaign__c != null) {
            Package__c p = new Package__c(Name = curr_wrapper.gift.Package_Name__c, Appeal__c = curr_wrapper.giftDetail.New_Campaign__c);
            DMLManager.InsertSObject(p);
            curr_wrapper.giftDetail.Package__c = p.id;
          } else {
            Package__c p = new Package__c(Name = curr_wrapper.gift.Package_Name__c, Appeal__c = curr_wrapper.giftDetails[0].New_Campaign__c);
            if (p.Appeal__c != null) {
              DMLManager.InsertSObject(p);
              curr_wrapper.giftDetail.Package__c = p.id;
            }
          }
        }
      }
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------
  private boolean saveWrapper() {
    //>> Validation
    hasPledge = false;
    // if the NoteSubject is not provided and NoteBody is.
    if ((curr_wrapper.noteBody != null && curr_wrapper.noteBody != '')
        && (curr_wrapper.noteSubject == null || curr_wrapper.noteSubject == '')) {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'In order to leaves notes, you need to enter the "Subject" as well.'));
      return false;
    }

    //is recurring?
    if (curr_wrapper.recurringDonation != null
        && !GivingpowerUtility.IsEmptyOrNull(curr_wrapper.recurringDonation.Frequency__c)) {
      if (curr_wrapper.recurringDonation.of_Payments__c == 0) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Number of payments cannot be zero for a recurring transaction.'));
        return false;
      }

      if (curr_wrapper.recurringDonation.of_Payments__c == 0) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Number of payments cannot be zero for a recurring transaction.'));
        return false;
      }

      if (curr_wrapper.recurringDonation.start_Date__c == null) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'When defining Frequency of a recurring transaction. You require to specfiy the "Start Date"'));
        return false;
      }

      if (!GivingpowerUtility.IsEmptyOrNull(curr_wrapper.giftDetail.Product__c)) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Cannot add products as a recurring donation'));
        return false;
      }

      curr_wrapper.isRecurring = true;
    } else
      curr_wrapper.isRecurring = false;

    // is PAD or recurring?
    if ((curr_wrapper.payment.Payment_Type__c == 'PAD' || curr_wrapper.gift.Gift_Type__c == 'Recurring')
        && curr_wrapper.isIndividualGift
        && (curr_wrapper.recurringDonation == null || curr_wrapper.recurringDonation.Frequency__c == null)) {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Recurring gift type requires the Recurring Section to be filled out.'));
      return false;
    }

    // credit card validations:
    if (curr_wrapper.payment.Payment_Type__c == 'Credit Card') {
      if (GivingpowerUtility.IsEmptyOrNull(curr_wrapper.CCNumber)) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Credit Card Number is required.'));
        return false;
      }
      if (GivingpowerUtility.IsEmptyOrNull(curr_wrapper.expirationDate)) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Expiration date is required.'));
        return false;
      }
      if (!validateExpirationDate(curr_wrapper.expirationDate)) return false;

      //validate CC;
      curr_wrapper.recurringDonation.Credit_Card__c = RollupHelper.maskCardNumber(curr_wrapper.CCNumber);
      curr_wrapper.payment.Credit_Card_Number__c = RollupHelper.maskCardNumber(curr_wrapper.CCNumber);
      curr_wrapper.recurringDonation.Name_on_Card__c = curr_wrapper.cardholderFirstName + ' ' + curr_wrapper.cardholderLastName;
    }

    //check sum: total gift details
    Decimal totalGD = 0;
    Decimal totalAmount = curr_wrapper.isRecurring ? curr_wrapper.recurringDonation.Amount__c : curr_wrapper.payment.Amount__c;

    //If Appeal record is not of type Appeal or Event, Send Error message.
    List<Id> appealIDs = new List<Id>();
    if (!curr_wrapper.isRecurring) {
      /// gift details
      if (curr_wrapper.giftDetails != null && curr_wrapper.giftDetails.size() > 1) {
        for (Gift_Detail__c gdetail : curr_wrapper.giftDetails) {
          totalGD += gdetail.Amount__c;
          appealIDs.add(gdetail.New_Campaign__c);
          //appealIDs.add(gdetail.Campaign__c);
        }
      } else {
        totalGD = curr_wrapper.giftDetails[0].Amount__c;
        appealIDs.add(curr_wrapper.giftDetails[0].New_Campaign__c);
      }
    } else {
      //rd allocations
      if (curr_wrapper.rdGiftDetails != null && curr_wrapper.rdGiftDetails.size() > 1) {
        for (RD_Allocation__c gdetail : curr_wrapper.rdGiftDetails) {
          totalGD += gdetail.Amount__c;
          appealIDs.add(gdetail.New_Campaign__c);
        }
      } else {
        totalGD = curr_wrapper.rdGiftDetails[0].Amount__c;
        appealIDs.add(curr_wrapper.rdGiftDetails[0].New_Campaign__c);
      }
    }

    List<RecordType> RT = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectType('Campaign', 'Campaign', Utilities.getCurrentNamespace());
    if (RT.size() > 0) {
      List<Campaign> cmpList = new CampaignSelector().SelectRecordTypeIdByRecordTypeIdAndId(Utilities.ConvertIdListToIdSet(appealIDs), RT[0].Id);
      if (cmpList != null && cmpList.size() > 0) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Appeal: "' + cmpList[0].Name + '" must be of type Appeal or Event.'));
        return false;
      }
    }


    if (totalGD != totalAmount) {

      if (!curr_wrapper.isRecurring)
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                             'The sum of Gift Details amounts is not equal to Gift amount value. Please review the Gift Details amounts.'));

      else
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                             'The sum of Recurring Donation Allocation amounts is not equal to Gift amount value. Please review the Recurring Donation Allocation amounts.'));

      return false;
    }

    Savepoint sp = Database.setSavepoint();
    if (curr_wrapper.gift != null) {
      pickPackage(curr_wrapper);
    }

    //identify if it's update mode.
    boolean isUpdate = (curr_wrapper.gift != null && curr_wrapper.gift.Id != null);

    try {
      //>> account or contact
      if (!curr_wrapper.isIndividualGift) {
        curr_wrapper.isNewRecord = (curr_wrapper.account.Id == null);
        DMLManager.UpsertSObject(curr_wrapper.account);
        curr_wrapper.gift.Organization__c = curr_wrapper.account.Id;
      }

      if (curr_wrapper.constituent.Id != null || !GivingpowerUtility.IsEmptyOrNull(curr_wrapper.constituent.LastName)) {
        if (curr_wrapper.constituent.AccountId == null) {
          if (!curr_wrapper.isIndividualGift)
            curr_wrapper.constituent.AccountId = curr_wrapper.account.Id;
          else
            curr_wrapper.constituent.AccountId = this.bucketAccountId;
        }

        curr_wrapper.isNewRecord = (curr_wrapper.constituent.Id == null);
        DMLManager.UpsertSObject(curr_wrapper.constituent);

        if (curr_wrapper.isIndividualGift)
          curr_wrapper.gift.Constituent__c = curr_wrapper.constituent.Id;
      }

      //>> recurring donation
      if (!GivingpowerUtility.IsEmptyOrNull(curr_wrapper.recurringDonation.Frequency__c)) {

        if (curr_wrapper.constituent.Id == null) {
          String msg = 'Organizational Contact information for recurring gift is required.';
          if (curr_wrapper.isIndividualGift)
            msg = 'Constituent information for recurring gift is required.';
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, msg));
          return false;
        } else {
          if (curr_wrapper.recurringDonation.Constituent__c == null)
            curr_wrapper.recurringDonation.Constituent__c = curr_wrapper.constituent.Id;
        }

        //later the system tests to see if payment should be processed or not, if not it zeros the payment.
        curr_wrapper.payment.Amount__c = curr_wrapper.recurringDonation.Amount__c;

        if (!GivingpowerUtility.IsEmptyOrNull(curr_wrapper.expirationDate)) {
          string monthStr = curr_wrapper.expirationDate.substring(0, 2);
          string yearStr = '20' + curr_wrapper.expirationDate.substring(2, 4);

          curr_wrapper.recurringDonation.Credit_Card_Expiry_Date__c = Date.newInstance(Integer.valueOf(yearStr), Integer.valueOf(monthStr), 1);
        }

        curr_wrapper.recurringDonation.Credit_Card_Type__c = curr_wrapper.payment.Credit_Card_Type__c;
        curr_wrapper.recurringDonation.Type__c = curr_wrapper.payment.Payment_Type__c;
        curr_wrapper.recurringDonation.Credit_Card__c = RollupHelper.maskCardNumber(curr_wrapper.CCNumber);
        DMLManager.UpsertSObject(curr_wrapper.recurringDonation);

        //setting gift last and next payment dates
        curr_wrapper.gift.Recurring_Donation__c = curr_wrapper.recurringDonation.Id;
        if (curr_wrapper.recurringDonation.Start_Date__c == Date.today())
          curr_wrapper.gift.Last_Payment_Date__c = Date.today();
      } else if (!RollupHelper.IsEmptyOrNull(curr_wrapper.recurringDonation.Id)) {
        // the record was recurring and it no longer is.
        curr_wrapper.payment.Amount__c = curr_wrapper.recurringDonation.Amount__c;
        DMLManager.DeleteSObject(curr_wrapper.recurringDonation);
      }

      //>> RD Allocation
      if (curr_wrapper.isRecurring) {
        if (curr_wrapper.giftDetails != null && curr_wrapper.giftDetails.size() > 0) {
          List<Gift_Detail__c> tbd = new List<Gift_Detail__c>();
          for (Gift_Detail__c gdItem : curr_wrapper.giftDetails) {
            if (!RollupHelper.IsEmptyOrNull(gdItem.Id)) {
              tbd.add(gdItem);
            }
          }
          if (tbd.size() > 0) {
            DMLManager.DeleteSObjects(tbd);
          }
          curr_wrapper.giftDetails.clear();
          addGiftDetail();
        }
        for (RD_Allocation__c gd : curr_wrapper.rdGiftDetails)
          if (gd.Recurring_Gift__c == null) {
            gd.Recurring_Gift__c = curr_wrapper.recurringDonation.Id;
            gd.Package__c = curr_wrapper.giftDetail.Package__c;
          }

        DMLManager.UpsertSObjects(curr_wrapper.rdGiftDetails);

      }

      curr_wrapper.gift.Batch_Status__c = 'Pending';
      if (curr_wrapper.isRecurring)
        curr_wrapper.gift.Status__c = 'Active';
      else
        curr_wrapper.gift.Status__c = 'Entered';
      curr_wrapper.gift.GiftBatch__c = SelectedBatch.Id;
      curr_wrapper.gift.RecordTypeId = BatchSettings.RegularGiftRecordTypeId__c;
      curr_wrapper.gift.Expected_Amount__c = curr_wrapper.isRecurring ? curr_wrapper.recurringDonation.Amount__c : curr_wrapper.payment.Amount__c;
      if (curr_wrapper.giftDetails.size() > 0 ) {
        curr_wrapper.gift.Package__c = curr_wrapper.giftDetail.Package__c;
      }

      DMLManager.UpsertSObject(curr_wrapper.gift);

      if (curr_wrapper.payment.Donation__c == null)
        curr_wrapper.payment.Donation__c = curr_wrapper.gift.Id;
      if ( curr_wrapper.gift.Batch_Status__c == 'Pending')
        curr_wrapper.payment.Status__c = '';

      if (curr_wrapper.isRecurring && curr_wrapper.recurringDonation.Start_Date__c > Date.today())
        curr_wrapper.payment.Amount__c = 0;

      if (curr_wrapper.payment.Payment_Type__c != 'Credit Card' && curr_wrapper.payment.Payment_Type__c != 'Credit Card - Offline') {
        List<RecordType> rTypeList = new RecordTypeSelector().SelectByNames(new List<String> { 'Payment__c', 'Standard' });
        if (rTypeList != null && rTypeList.size() > 0) {
          curr_wrapper.payment.RecordTypeId = rTypeList[0].Id;
        }
      }

      DMLManager.UpsertSObject(curr_wrapper.payment);

      //>> gift detail
      if (!curr_wrapper.isRecurring) {
        if (curr_wrapper.rdGiftDetails != null && curr_wrapper.rdGiftDetails.size() > 0) {
          List<RD_Allocation__c> tbd = new List<RD_Allocation__c>();
          for (RD_Allocation__c rdItem : curr_wrapper.rdGiftDetails) {
            if (!RollupHelper.IsEmptyOrNull(rdItem.Id)) {
              tbd.add(rdItem);
            }
          }
          if (tbd.size() > 0) {
            DMLManager.DeleteSObjects(tbd);
          }
          curr_wrapper.rdGiftDetails.clear();
          addRDGiftDetail();
        }
        for (Gift_Detail__c gd : curr_wrapper.giftDetails) {
          if (gd.Gift__c == null) {
            gd.Gift__c = curr_wrapper.gift.Id;
            gd.Allocation_Date__c = curr_wrapper.gift.Gift_Date__c;
            gd.Payment__c = curr_wrapper.payment.Id;
          }
          gd.Package__c = curr_wrapper.gift.Package__c;
        }
        DMLManager.UpsertSObjects(curr_wrapper.giftDetails);

      }

      if (curr_wrapper.receipt.Gift__c == null)
        curr_wrapper.receipt.Gift__c = curr_wrapper.gift.Id;

      if (curr_wrapper.noteSubject != null && curr_wrapper.noteSubject != '') {
        curr_wrapper.giftNote.Title = curr_wrapper.noteSubject;
        curr_wrapper.giftNote.Body = curr_wrapper.noteBody;
        if (curr_wrapper.giftNote.ParentId == null)
          curr_wrapper.giftNote.ParentId = curr_wrapper.gift.Id;
        DMLManager.UpsertSObject(curr_wrapper.giftNote);
      }

    } catch (Exception ex) {
      Database.rollback(sp);
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, ex.getMessage()));
      if (!isUpdate)
        curr_wrapper = GiftBatchWrapper.refreshInstance(curr_wrapper);
      return false;
    }

    if (!isUpdate) {
      curr_wrapper = GiftBatchWrapper.refreshInstance(curr_wrapper);
      giftItems.add(curr_wrapper);
    }

    updateReconciliation();
    curr_wrapper.Id = curr_wrapper.getUniqueId();

    return true;
  }
  //---------------------------------------------------------------------------------------------------------------------------
  public void saveItem() {
    boolean retVal = saveWrapper();
    if (!retVal) return;
    //operation sucessfull
    WizardStep = 1;
  }
  //---------------------------------------------------------------------------------------------------------------------------
  public void saveItemAndNew() {
    boolean retVal = saveWrapper();
    if (!retVal) return;
    hasPledge = false;
    //operation sucessfull
    newGift();
  }
  //---------------------------------------------------------------------------------------------------------------------------
  public void EditBatchItem() {
    curr_wrapper = GetGift(selectedGiftId);
    if (curr_wrapper == null) {
      curr_wrapper = GiftBatchWrapper.CreateInstance(selectedGiftId);
      if (curr_wrapper != null) {
        giftItems.add(curr_wrapper);
      }
    }

    if (curr_wrapper != null) {
      WizardStep = 2;
      curr_wrapper.user = GiftBatchPresets.GetPresetsData();
      curr_wrapper.presets = new GiftBatchPresets(curr_wrapper.user);
      GiftBatchPresets gbp = new GiftBatchPresets(curr_wrapper.user);
      curr_wrapper.presets.giftDetailPackage.isHidden = gbp.loadGiftDetailPackageProperty(curr_wrapper);
    } else {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Unexpected error ocurred: did not find the gift record. Please refresh the page and try again. Note that the gift entry might have been deleted by another user.'));
      return;
    }

    isGiftTypeVisible = false;
  }
  //---------------------------------------------------------------------------------------------------------------------------
  public void MakePaymentsClicked() {
    if (!ValidateBeforeCommit()) return;

    List<Gift__c> nonccGifts = new List<Gift__c>();
    List<Payment__c> nonccPayments = new List<Payment__c>();
    for (GiftBatchWrapper gift : giftItems) {
      if (gift.gift.Batch_Status__c == 'Pending' && gift.payment.Payment_Type__c != 'Credit Card') {
        gift.gift.Batch_Status__c = 'Committed';
        gift.payment.Status__c = 'Approved';
        nonccGifts.Add(gift.gift);
        nonccPayments.Add(gift.payment);
      }
    }

    if (nonccGifts.size() > 0) {
      DMLManager.UpsertSObjects(nonccGifts);
    }

    if (nonccPayments.size() > 0) {
      DMLManager.UpsertSObjects(nonccPayments);
    }

    isSubmitEnabled = true;
  }
  public Integer progress { get; set; }
  public Integer maxItemPerBatch { get; set; }

  public void submit() {
    Integer calloutLimits = 10;
    Integer calloutCount = 0;

    Integer processed = 0;

    BatchGateway4.GatewaySoap gw = new BatchGateway4.GatewaySoap();
    gw.timeout_x = 120000;
    List<Gift__c> successGifts = new List<Gift__c>();
    List<Payment__c> txPayments = new List<Payment__c>();
    List<Gift__c> recGifts = new List<Gift__c>();
    List<Recurring_Donation__c> recurringSuccessGifts = new List<Recurring_Donation__c>();
    List<Gift__c> failedGifts = new List<Gift__c>();
    List<GiftBatchWrapper> submittedGifts = new List<GiftBatchWrapper>();
    //set the endpoint
    gw.endpoint_x = BatchSettings.GatewayUrl__c;
    BatchGateway4.BatchForm form = new BatchGateway4.BatchForm();
    BatchGateway4.FormBase formBase = new BatchGateway4.FormBase();
    form.payments = new BatchGateway4.ArrayOfPaymentInfo();
    form.payments.payment = new List<BatchGateway4.PaymentInfo>();
    formBase.currency_x = BatchSettings.CurrencyCode__c;
    formBase.formId = batchSettings.BatchFormID__c;
    formBase.version = '1.0';
    formBase.debugMode = true;

    processed = 0;
    if (giftItems != null) {
      for (GiftBatchWrapper gift : giftItems) {
        if (processed >= maxItemPerBatch) break;
        if (gift.gift.Batch_Status__c == 'Committed' || gift.gift.Batch_Status__c == 'Receipted') continue;
        if (gift.payment.Payment_Type__c != 'Credit Card') {
          if (gift.gift.Batch_Status__c == 'Pending' && gift.payment.Payment_Type__c != 'Credit Card') {
            gift.gift.Batch_Status__c = 'Committed';
            gift.payment.Status__c = 'Approved';
            successGifts.Add(gift.gift);
            txPayments.Add(gift.payment);
            processed++;
            progress++;
          }
        } else {
          if (gift.CCNumber == null || gift.CCNumber == '' || gift.expirationDate == null || gift.expirationDate == '') {
            gift.gift.Batch_Status__c = 'Failed';
            failedGifts.add(gift.gift);
            ResetCreditCardInfo(gift);
            continue;
          }
          BatchGateway4.PaymentInfo payment = new BatchGateway4.PaymentInfo();
          if (gift.isIndividualGift) {
            payment.address1 = gift.constituent.MailingStreet;
            payment.city = gift.constituent.MailingCity;
            payment.state = gift.constituent.MailingState;
            payment.country = gift.constituent.MailingCountry;
            payment.zipCode = gift.constituent.MailingPostalCode;
            payment.donationType = 'IND';
            payment.email = gift.constituent.Email;
          } else {
            payment.address1 = gift.account.BillingStreet;
            payment.city = gift.account.BillingCity;
            payment.state = gift.account.BillingState;
            payment.country = gift.account.BillingCountry;
            payment.zipCode = gift.account.BillingPostalCode;
            payment.donationType = 'ORG';
            payment.email = gift.account.Email__c;
            payment.organization = gift.account.Name;
          }
          if (gift.isRecurring) {
            payment.billingStartDate = gift.recurringDonation.Start_Date__c;
          } else {
            payment.billingStartDate = date.today();
          }
          payment.numberOfPayments = '';
          if (gift.recurringDonation.of_Payments__c != null) {
            payment.numberOfPayments = gift.recurringDonation.of_Payments__c.format();
          }

          payment.PayerFirstName = gift.cardholderFirstName;
          payment.PayerLastName = gift.cardholderLastName;
          payment.isIndividual = gift.isIndividualGift;
          payment.isRecurring = gift.isRecurring;
          payment.constituentType = gift.isNewRecord ? 'Existing' : 'New';
          if (gift.gift.Expected_Amount__c != null) {
            payment.amount = gift.gift.Expected_Amount__c.format();
          } else {
            payment.amount = '0';
          }
          payment.creditCardNumber = gift.CCNumber;
          payment.creditCardType = gift.payment.Credit_Card_Type__c;
          payment.cvv2 = gift.Cvv;
          payment.currencyType = BatchSettings.CurrencyCode__c;
          payment.expiryMonth = tryParseToInt(gift.expirationDate.substring(0, 2));
          payment.expiryYear = tryParseToInt(gift.expirationDate.substring(2, 4));
          payment.frequency = gift.recurringDonation.Frequency__c;
          payment.giftId = gift.gift.Id;
          payment.paymentId = gift.payment.Id;
          form.payments.payment.add(payment);
          submittedGifts.add(gift);
          ResetCreditCardInfo(gift);
          processed++;
          progress++;
        }
      }
    }

    BatchGateway4.ArrayOfTransactionResult txResults = new BatchGateway4.ArrayOfTransactionResult();

    String userId = UserInfo.getUserId();
    User user;
    List<User> userList = new UserSelector().SelectSObjectsById(new Set<Id> { userId });
    if (userList != null && userList.size() > 0) {
      user = userList[0];
    }

    txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0', user.Payment_Gateway_Account_ID__c);

    if (txResults != null) {
      Integer count = 0;

      for (count = 0; count < submittedGifts.size(); count++) {
        if (txResults.TransactionResult != null) {
          txPayments.add(CreatePayment(submittedGifts[count], txResults.TransactionResult[count]));
          if (txResults.TransactionResult[count].TransactionStatus == null || txResults.TransactionResult[count].TransactionStatus != 'success') {
            submittedGifts[count].gift.Batch_Status__c = 'Failed';
            failedGifts.add(submittedGifts[count].gift);
          } else {
            submittedGifts[count].gift.Batch_Status__c = 'Committed';
            submittedGifts[count].gift.Reference__c = txResults.TransactionResult[count].RecurringProfileId;
            submittedGifts[count].recurringDonation.Reference__c = txResults.TransactionResult[count].RecurringProfileId;
            submittedGifts[count].recurringDonation.Encrypted_Key__c = txResults.TransactionResult[count].EncryptedRecurringProfileId;
            successGifts.add(submittedGifts[count].gift);
            if (submittedGifts[count].isRecurring) recurringSuccessGifts.add(submittedGifts[count].recurringDonation);
          }
        }
      }
      if (successGifts.size() > 0) {
        DMLManager.UpsertSObjects(successGifts);
      }

      if (failedGifts.size() > 0) {
        DMLManager.UpsertSObjects(failedGifts);
      }

      if (txPayments.size() > 0) {
        DMLManager.UpsertSObjects(txPayments);
      }

      if (recurringSuccessGifts.size() > 0) {
        DMLManager.UpsertSObjects(recurringSuccessGifts);
      }
    }

    isSubmitEnabled = IsMoreCreditCardPending();
    if (!isSubmitEnabled) {
      progress = 0;
      List<Receipt__c> receipts = new List<Receipt__c>();
      updateReconciliation();
      List<Gift__c> gifts = new List<Gift__c>();
      for (GiftBatchWrapper wrapper : giftItems) {
        if (wrapper.gift.Id == null)
          gifts.add(wrapper.gift);
      }

      if (gifts.size() > 0) {
        DMLManager.InsertSObjects(gifts);
      }

      for (GiftBatchWrapper wrapper : giftItems) {
        if (wrapper.gift.Receipt_Type__c == 'Single Receipt' && wrapper.gift.Batch_Status__c != 'Receipted' && wrapper.gift.Receipt_Later__c == false) {
          if (wrapper.payment.Payment_Type__c == 'Credit Card') {
            if (wrapper.gift.Batch_Status__c != 'Failed' && wrapper.gift.Batch_Status__c != 'Pending') {
              if (wrapper.receipt != null) {
                if (wrapper.gift.Constituent__c != null) { wrapper.receipt.Constituent__c = wrapper.gift.Constituent__c; }
                if (wrapper.gift.Organization__c != null) { wrapper.receipt.Organization__c = wrapper.gift.Organization__c; }
                wrapper.receipt.Gift__c = wrapper.gift.Id;
                wrapper.receipt.Status__c = 'To be Issued';
                if (wrapper.receipt.Amount_Not_Eligible__c == null) {
                  wrapper.receipt.Amount_Not_Eligible__c = 0;
                }
                receipts.add(wrapper.receipt);
              } else
                receipts.add(createReceipt(wrapper));

              wrapper.gift.Batch_Status__c = 'Receipted';
              recGifts.add(wrapper.gift);
            }
          } else {
            if (wrapper.gift.Batch_Status__c != 'Pending') {
              if (wrapper.receipt != null) {
                if (wrapper.gift.Constituent__c != null) { wrapper.receipt.Constituent__c = wrapper.gift.Constituent__c; }
                if (wrapper.gift.Organization__c != null) { wrapper.receipt.Organization__c = wrapper.gift.Organization__c; }
                if (wrapper.receipt.Gift__c == null) { wrapper.receipt.Gift__c = wrapper.gift.Id; }
                wrapper.receipt.Status__c = 'To be Issued';
                if (wrapper.receipt.Amount_Not_Eligible__c == null) {
                  wrapper.receipt.Amount_Not_Eligible__c = 0;
                }
                receipts.add(wrapper.receipt);
              } else
                receipts.add(createReceipt(wrapper));

              wrapper.gift.Batch_Status__c = 'Receipted';
              recGifts.add(wrapper.gift);
            }
          }
        }
      }

      if (recGifts.size() > 0) {
        DMLManager.UpsertSObjects(recGifts);
      }

      if (receipts.size() > 0) {
        DMLManager.InsertSObjects(receipts);
      }

      giftItems = GiftBatchWrapper.GetBatchData(SelectedBatch.Id, GiftBatchPresets.GetPresetsData());

      if (giftItems != null) {
        for (GiftBatchWrapper wrapper : giftItems) {
          if (wrapper.receipt != null && wrapper.payment != null) {
            wrapper.payment.Receipt__c = wrapper.receipt.Id;
            txPayments.clear();
            txPayments.add(wrapper.payment);
          }
        }
        DMLManager.UpdateSObjects(txPayments);
      }
    }
  }

  private Payment__c CreatePayment(GiftBatchWrapper gift, BatchGateway4.TransactionResult txResult) {
    Payment__c payment = gift.payment;
    if (txResult != null) {
      payment.Payment_Type__c = 'Credit Card';
      payment.Authorization__c = txResult.ApprovalCode;
      payment.CC_Reference__c = txResult.TransactionId;
      payment.Status__c = txResult.TransactionStatus == null || txResult.TransactionStatus != 'success' ? 'Declined' : 'Approved';
      if ((txResult.TransactionId == null || txResult.TransactionId == '') && txResult.TransactionStatus == 'success') payment.Amount__c = 0;
      payment.CC_Transaction_Date__c = Date.today();
      if (txResult.Errors != null) {
        if (txResult.Errors.ErrorMessages != null &&  txResult.Errors.ErrorMessages.size() > 0) {
          payment.StatusComment__c = txResult.Errors.ErrorMessages[0].Error;
        } else {
          payment.StatusComment__c = 'Approved.  Transaction Number: ' + txResult.TransactionId;
        }
      }
    }
    return payment;
  }
  //---------------------------------------------------------------------------------------------------------------------------
  @TestVisible
  private boolean ValidateBeforeCommit() {
    boolean retval = true;
    boolean giftsToProcess = false;
    if (giftItems != null) {
      for (GiftBatchWrapper gift : giftItems) {
        if (gift.gift.Batch_Status__c != 'Committed' && gift.gift.Batch_Status__c != 'Receipted' && gift.gift.Batch_Status__c != 'Failed') {
          if (gift.payment.Payment_Type__c == 'Credit Card' &&  (gift.CCNumber == null || gift.CCNumber == '' || gift.expirationDate == null || gift.expirationDate == '')) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to submit.  Credit Card Information missing for one or more gifts.'));
            retval = false;
            break;
          } else {
            giftsToProcess = true;
          }
        }
      }
      if (!giftsToProcess) {
        retval = false;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'No Credit Card gifts to process.'));
      }
    } else {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'No gifts to process.'));
    }
    return retval;
  }
  //---------------------------------------------------------------------------------------------------------------------------
  private void ResetCreditCardInfo(GiftBatchWrapper wrapper) {
    wrapper.CCNumber = '';
    wrapper.expirationDate = '';
  }
  //---------------------------------------------------------------------------------------------------------------------------
  @TestVisible
  private Boolean IsMoreCreditCardPending() {
    Boolean retval = false;
    for (GiftBatchWrapper wrapper : giftItems) {
      if (wrapper.gift.Batch_Status__c == 'Pending' /*&& wrapper.payment.Payment_Type__c == 'Credit Card'*/) {
        retval = true;
        break;
      }

    }
    return retval;
  }
  //---------------------------------------------------------------------------------------------------------------------------
  private GiftBatchWrapper GetGift(string giftId) {
    if (giftItems != null && giftItems.size() > 0) {
      for (GiftBatchWrapper giftItem : giftItems) {
        if (giftItem.gift.Id == giftId) {
          return giftItem;
        }
      }
    }
    return null;
  }
  //---------------------------------------------------------------------------------------------------------------------------
  private boolean GiftExists(string giftId) {
    if (GetGift(giftId) != null)
      return true;
    else
      return false;
  }
  //---------------------------------------------------------------------------------------------------------------------------
  public void commitBatch() {
    if ((SelectedBatch.Cash__c == null ||
         SelectedBatch.Cash_Gifts__c == null ||
         SelectedBatch.Cheque__c == null ||
         SelectedBatch.Cheque_Gifts__c == null ||
         SelectedBatch.Credit_Card__c == null ||
         SelectedBatch.Credit_Card_Gifts__c == null ||
         SelectedBatch.Direct_Deposit__c == null ||
         SelectedBatch.Direct_Deposit_Gifts__c == null ||
         SelectedBatch.Other__c == null ||
         SelectedBatch.Other_Gifts__c == null ||
         SelectedBatch.Shareplan__c == null ||
         SelectedBatch.Shareplan_Gifts__c == null ||
         SelectedBatch.Total_Gift__c == null ||
         SelectedBatch.Total_Gift_Amount__c == null) && !isTesting) {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                           'Items in the Batch Summary section are not completed. Please provide all the summary data before committing the batch.'));
      return;
    }

    if (SelectedBatch.Shareplan_Gifts__c != Recon.sharePlanCount) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Number of projected recurring gifts is not equal to actual number of recurring gifts entered for this batch.'));
      return;
    }

    if (SelectedBatch.Shareplan__c != Recon.ShareplanTotal) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Total projected recurring value is not equal to the actual total recurring. Please validate your batch entries.'));
      return;
    }

    if (SelectedBatch.Total_Gift_Amount__c != Recon.grandTotal) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Total projected Gift amount is not equal to its reconciled value. Please check your batch entries.'));
      return;
    }

    //make sure there is no pending CC item left
    for (GiftBatchWrapper wrapper : giftItems) {
      if (wrapper.payment.Payment_Type__c == 'Credit Card' && wrapper.gift.Batch_Status__c == 'Pending') {
        //53
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'There are a number of Pending Credit Card items within this Batch. Please process these payments before committing the Batch.'));
        return;
      }

      if (RollupHelper.IsEmptyOrNull(wrapper.payment.Status__c)) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'There are a number of items within this Batch that are not yet submitted. Please process these payments before committing the Batch.'));
        return;
      }
    }

    SelectedBatch.Close_Date__c = Date.Today();
    DMLManager.UpdateSObject(SelectedBatch);

  }
  //---------------------------------------------------------------------------------------------------------------------------
  private Receipt__c createReceipt(GiftBatchWrapper wrapper) {
    Receipt__c r = new Receipt__c();
    r.Gift__c = wrapper.gift.Id;
    r.Status__c = 'To be Issued';
    r.Receipt_Type__c = 'Single';
    return r;
  }

  //---------------------------------------------------------------------------------------------------------------------------
  public void addGiftDetail() {
    curr_wrapper.giftDetails.add(curr_wrapper.CreateGiftDetailInstance());
  }
  public void addRDGiftDetail() {
    curr_wrapper.rdGiftDetails.add(curr_wrapper.CreateRDGiftDetailInstance());
  }
  //---------------------------------------------------------------------------------------------------------------------------
  public void removeGiftDetail() {
    integer count = 0;

    if (!isTesting)
      GiftDetailIndex = Decimal.valueOf(ApexPages.currentPage().getParameters().get('GiftDetailIndex'));
    else
      GiftDetailIndex = 0;

    integer selectedIndex = GiftDetailIndex.intValue();

    for (Gift_Detail__c gd : curr_wrapper.giftDetails) {
      count++;
      if (count == selectedIndex )
        break;
    }

    if (count != 0) {
      Gift_Detail__c selected = curr_wrapper.giftDetails.remove(count - 1);
      if (selected.Id != null) {
        DMLManager.DeleteSObject(selected);
      }
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------
  public void removeRDGiftDetail() {
    integer count = 0;
    RDGiftDetailIndex = Decimal.valueOf(ApexPages.currentPage().getParameters().get('RDGiftDetailIndex'));

    integer selectedIndex = RDGiftDetailIndex.intValue();
    for (RD_Allocation__c gd : curr_wrapper.rdGiftDetails) {
      count++;
      if (count == selectedIndex)
        break;
    }
    if (count != 0) {
      RD_Allocation__c selected = curr_wrapper.rdGiftDetails.remove(count - 1);
      if (selected.Id != null)
        DMLManager.DeleteSObject(selected);
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------
  public void UpdateRecurringUI() {
    curr_wrapper.isRecurring = false;
    string frequency = null;
    string paymentType = null;

    if (curr_wrapper.recurringDonation != null
        && !RollupHelper.IsEmptyOrNull(curr_wrapper.recurringDonation.Frequency__c)) {
      if (!curr_wrapper.isRecurring)
        curr_wrapper.recurringDonation.Amount__c = curr_wrapper.payment.Amount__c;

      curr_wrapper.isRecurring = true;
      frequency = curr_wrapper.recurringDonation.Frequency__c;

    } else {
      curr_wrapper.isRecurring = false;
      curr_wrapper.payment.Amount__c = curr_wrapper.recurringDonation.Amount__c;
    }
  }

  @RemoteAction
  public static string insertPackage(string packageName, string appealId) {
    Package__c newP = new Package__c(Name = packageName);
    if (appealId != '') { newP.Appeal__c = appealId; }
    DMLManager.InsertSObject(newP);
    return newP.Id;
  }

  @RemoteAction
  public static string upsertPackage(string packageName) {
    string packageId = '';
    List<Package__c> thePacks = new PackageSelector().SelectSObjectsByName(packageName);
    if (thePacks.size() > 0)
    { packageId = thePacks[0].Id; }
    else
    { packageId = 'new'; }
    return packageId;
  }

  public class BatchAllocationSetting {
    public string LetterId { get; set; }
    public string LetterName { get; set; }

    public string FundId { get; set; }
    public string FundName { get; set; }

    public BatchAllocationSetting() { }
    public BatchAllocationSetting(string l, string f) {
      LetterId = l;
      FundId = f;
    }
  }

  @RemoteAction
  public static BatchAllocationSetting GetAppealDefaults(string appealId) {
    List<Campaign> camps = new CampaignSelector().SelectLetterAndFundById(new Set<Id> { appealId });
    if (camps != null && camps.size() > 0) {
      BatchAllocationSetting setting = new BatchAllocationSetting(camps[0].Letter__c, camps[0].Fund__c);
      if (camps[0].Letter__c != null)
        setting.LetterName = camps[0].Letter__r.Name;
      if (camps[0].Fund__c != null)
        setting.FundName = camps[0].Fund__r.Name;
      return setting;
    } else
      return new BatchAllocationSetting();
  }

  //---------------------------------------------------------------------------------------------------------------------------
  public class BatchReconciliation {
    public Decimal cashTotal { get; set; }
    public Decimal chequeTotal { get; set; }
    public Decimal creditCardTotal { get; set; }
    public Decimal creditCardTotalPending { get; set; }
    public Decimal ShareplanTotal { get; set; }
    public Decimal DirectDipositTotal { get; set; }
    public Decimal OtherTotal { get; set; }
    public Decimal grandTotal { get; set; }

    public Integer sharePlanCount { get; set; }
    public Integer ccApprovedCount { get; set; }
    public Integer ccDeclinedCount { get; set; }
    public Integer ccPendingCount { get; set; }
    public integer totalCount { get; set; }

    public BatchReconciliation() {
      cashTotal = 0.00;
      chequeTotal = 0.00;
      creditCardTotal = 0.00;
      creditCardTotalPending = 0.00;
      grandTotal = 0.00;
      sharePlanCount = 0;
      ccApprovedCount = 0;
      ccDeclinedCount = 0;
      ccPendingCount = 0;
      ShareplanTotal = 0.00;
      DirectDipositTotal = 0.00;
      OtherTotal = 0.00;
      totalCount = 0;
    }
  }

  private static void SetNamespace() {
    String namespace = Utilities.getCurrentNamespace();
    CvNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
  }
}