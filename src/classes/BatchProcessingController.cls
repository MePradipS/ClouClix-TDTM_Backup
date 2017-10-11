global with sharing class BatchProcessingController {

    public static String PackageFieldNamespace {
        get {
            if (PackageFieldNamespace == null) {
                SetNamespace();
            }
            return PackageFieldNamespace;
        }
        set;
    }
    public static String PackageNamespace {
        get {
            if (PackageNamespace == null) {
                SetNamespace();
            }
            return PackageNamespace;
        }
        set;
    }
    public Batch_Template__c presetTemplate{get;set;}
    public Gift_Batch__c giftBatch{get;set;}
    public List<PresetWrapper> accountFields{get;set;}
    public List<PresetWrapper> contactFields{get;set;}
    public List<PresetWrapper> RecurringGiftFields{get;set;}
    public List<PresetWrapper> TransactionFields{get;set;}
    public List<PresetWrapper> PaymentFields{get;set;}
    public List<PresetWrapper> GiftDetailFields{get;set;}
    public List<PresetWrapper> ReceiptFields{get;set;}
    public List<Gift__c> transactions{get;set;}
    public Map<string, string> keyPrefixMap{get;set;}
    public static Id batchId;
    public static List<PresetWrapper> contFields;
    public String paymentTypesSelected{get;set;}
    public String batchStatusString{get;set;}
    public Boolean checkBatchStatus {get;set;}
    private BatchPresetHelper_moc obj_BPH;

    public BatchSettings__c BatchSettings { get; set; }

    public Boolean isSubmitEnabled { get; set; }

    Public string userTimezone { get; set; }
    public string usercurrencyISOcode {get;set;}

    Public string userlocale { get; set; }

    Public String eventLevelLookupId {get; set;}

    public BatchProcessingController(ApexPages.StandardController controller) {
        SetFieldNamespace();
        SetNamespace();
        userTimezone = UserInfo.getTimeZone().getId();
        userlocale = UserInfo.getLocale();
        usercurrencyISOcode = Userinfo.getDefaultCurrency();
        batchId = ApexPages.currentPage().getParameters().get('batchId');
        obj_BPH = new BatchPresetHelper_moc();
        isSubmitEnabled = false;
        keyPrefixMap = new Map<string, string>();
        keyPrefixMap.put('Fund', Fund__c.sObjectType.getDescribe().getKeyPrefix());
        keyPrefixMap.put('Letter', Letter__c.sObjectType.getDescribe().getKeyPrefix());
        keyPrefixMap.put('Account', Account.sObjectType.getDescribe().getKeyPrefix());
        keyPrefixMap.put('Contact', Contact.sObjectType.getDescribe().getKeyPrefix());

        keyPrefixMap.put('Event Level', Event_Level__c.sObjectType.getDescribe().getKeyPrefix());
        keyPrefixMap.put('Allocation', Gift_Detail__c.sObjectType.getDescribe().getKeyPrefix());
        keyPrefixMap.put('Appeal',Campaign.sObjectType.getDescribe().getKeyPrefix());

        accountFields = new List<PresetWrapper>();
        contactFields = new List<PresetWrapper>();
        RecurringGiftFields = new List<PresetWrapper>();
        TransactionFields = new List<PresetWrapper>();
        PaymentFields = new List<PresetWrapper>();
        GiftDetailFields = new List<PresetWrapper>();
        ReceiptFields = new List<PresetWrapper>();

        List<BatchSettings__c> settingList = new BatchSettingsSelector().SelectSObjectsByName('Default');
        if (settingList != null && settingList.size()>0) {
           BatchSettings = settingList[0];
        }

        eventLevelLookupId = getFieldId('Event Level');

        try {
            List<Gift_Batch__c> giftBatchList = new GiftBatchSelector().SelectSObjectsById(new Set<Id> { batchId });
            if (giftBatchList != null && giftBatchList.size() > 0) {
                giftBatch = giftBatchList[0];

                List<Batch_Template__c> batchTemplateList = new BatchTemplateSelector().SelectSObjectsById(new Set<Id> { giftBatch.Template_Name__c });
                if (batchTemplateList != null && batchTemplateList.size() > 0) {
                    presetTemplate = batchTemplateList[0];

                    if(presetTemplate != null) {
                        populateFields(presetTemplate);

                        contFields = new List<PresetWrapper>();
                        contFields = contactFields;
                    }
                    if (giftBatch.Batch_Status__c == 'Closed') {
                        batchStatusString = 'Gift Batch is Commited';
                        checkBatchStatus = true;
                    }
                    else {
                        batchStatusString = '';
                        checkBatchStatus = false;
                    }
                }
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage() + ' : Please select a proper Batch Template'));
        }


    }

    public string selectedBatchId {
        get {
        string Val = giftBatch.id;
        if (Val != null && Val != '')
        Val = Val.substring(0,Val.length()-3);
        return Val;
        }
    }

    @RemoteAction
    global static String getLookupPrefix(String objName, String fieldName){
        if(fieldName == 'ConstOrgId') {
            return Schema.getGlobalDescribe().get(objName).getDescribe().getKeyPrefix();
        }
        return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe().getReferenceTo()[0].getDescribe().getKeyPrefix();
    }

    public String getAccountFieldArray() {
        return JSON.serialize(accountFields);
    }
    public String getContactFieldArray() {
        return JSON.serialize(contactFields);
    }

    public String getRecurringGiftFieldArray() {
        return JSON.serialize(RecurringGiftFields);
    }

    public String getTransactionFieldArray() {
        return JSON.serialize(TransactionFields);
    }

    public String getPaymentFieldArray() {
        return JSON.serialize(PaymentFields);
    }

    public String getGiftDetailFieldArray() {
        return JSON.serialize(GiftDetailFields);
    }

    public String getReceiptFieldArray() {
        return JSON.serialize(ReceiptFields);
    }

    public String getSoftCreditFieldArray() {
        List<PresetWrapper> SoftCreditFields = obj_BPH.discribeObjects(PackageFieldNamespace + 'Solicitor__c');
        return JSON.serialize(SoftCreditFields);
    }

    private void populateFields(Batch_Template__c presetTemplate) {
        if(contactFields.size() == 0) {
            contactFields = obj_BPH.readXML(presetTemplate.ContactFieldXml__c, 'Contact');
        }
        if(accountFields.size() == 0) {
            accountFields = obj_BPH.readXML(presetTemplate.AccountFieldsXml__c, 'Account');
        }
        if(RecurringGiftFields.size() == 0) {
            RecurringGiftFields = obj_BPH.readXML(presetTemplate.RecurringGiftFieldsXml__c, PackageFieldNamespace + 'Recurring_Donation__c');
        }
        if(TransactionFields.size() == 0) {
            TransactionFields = obj_BPH.readXML(presetTemplate.TransactionFieldsXml__c, PackageFieldNamespace + 'Gift__c');
        }
        if(PaymentFields.size() == 0) {
            PaymentFields = obj_BPH.readXML(presetTemplate.PaymentFieldsXml__c, PackageFieldNamespace + 'Payment__c');
            paymentTypesSelected = obj_BPH.paymentTypesSelected;
        }
        if(ReceiptFields.size() == 0) {
            ReceiptFields = obj_BPH.readXML(presetTemplate.ReceiptFieldsXml__c, PackageFieldNamespace + 'Receipt__c');
        }
        if(GiftDetailFields.size() == 0) {
            GiftDetailFields = obj_BPH.readXML(presetTemplate.GiftDetailFieldsXml__c, PackageFieldNamespace + 'Gift_Detail__c');
        }
    }

    public String getAllBatchItems() {
        Gift__c gift = new Gift__c();
        String JSONString = JSON.serialize(gift);
        return '{\"Records\":' +JSONString+', \"error\": \"null\", \"status\":\"SUCCESS\", \"count\":\"' + 1 + '\" }';
    }

    @RemoteAction
    global static sObject getData(String recordId, String fields, String objName, String fieldName) {
        String whereClause = fieldName + ' = \'' + recordId + '\'';
        fields += ',id';

        sObject obj = null;
        try {
            obj = new GenericQueryBuilder().ObjectQueryBuilderWhere(objName, fields, whereClause);
        } catch(Exception ex) {
            return obj;
        }
        return obj;
    }

    @RemoteAction
  global static string submitPayment(String giftBatchId, String giftPaymentUIFieldsMap)
  {
        BatchSettings__c BatchSettings;
        List<BatchSettings__c> settingList = new BatchSettingsSelector().SelectSObjectsByName('Default');
        if (settingList != null && settingList.size()>0) {
           BatchSettings = settingList[0];
        }

        Map<String, String> accountTypeMap = new Map<String, String>();
        accountTypeMap.put('Personal Checking', 'PC');
        accountTypeMap.put('Personal Savings', 'PS');
        accountTypeMap.put('Business Checking', 'BC');
        accountTypeMap.put('Business Savings', 'BS');

        BatchGateway4.GatewaySoap gw = new BatchGateway4.GatewaySoap();
        gw.timeout_x = 120000;

        gw.endpoint_x = BatchSettings.GatewayUrl__c;
        BatchGateway4.BatchForm form = new BatchGateway4.BatchForm();
        BatchGateway4.FormBase formBase = new BatchGateway4.FormBase();
        form.payments = new BatchGateway4.ArrayOfPaymentInfo();
        form.payments.payment = new List<BatchGateway4.PaymentInfo>();
        formBase.currency_x = BatchSettings.CurrencyCode__c;
        formBase.formId = batchSettings.BatchFormID__c;
        formBase.version = '1.0';
        formBase.debugMode = true;

        Map<String, Map<String, String>> paymentUIFieldsMap;
        if(giftPaymentUIFieldsMap != null) {
            paymentUIFieldsMap = (Map<String, Map<String, String>>)JSON.deserialize(giftPaymentUIFieldsMap, Map<String, Map<String, String>>.class);
        }

        if(paymentUIFieldsMap == null) {
            return null;
        }

        Set<Id> paymentIds = Utilities.ConvertStringSetToIdSet(paymentUIFieldsMap.keySet());

        List<Gift__c > giftItems = new GiftSelector().SelectGiftConstituentOrganizationRecurringDonationById(paymentIds);
        if (giftItems != null) {
            for (Gift__c gift : giftItems) {
                Integer paymentSize = gift.Recurring_Payments__r.size() - 1;
                Map<String, String> pUIFieldMap = paymentUIFieldsMap.get(gift.Id);

                if(pUIFieldMap == null) continue;

                 if (paymentSize != -1 && (gift.Recurring_Payments__r[paymentSize].Payment_Type__c != 'Credit Card' && gift.Recurring_Payments__r[paymentSize].Payment_Type__c != 'ACH/PAD')) {
                        if (gift.Batch_Status__c == 'Pending')
                        {
                            gift.Batch_Status__c = 'Committed';
                            gift.Recurring_Payments__r[paymentSize].Status__c = 'Approved';
                        }
                    }
                else {
                    if (paymentSize  == -1)
                    {
                      gift.Batch_Status__c = 'Committed';
                    }
                    BatchGateway4.PaymentInfo payment = new BatchGateway4.PaymentInfo();
                    if (paymentSize != -1 && gift.Recurring_Payments__r[paymentSize].Payment_Type__c == 'Credit Card') {
                        if (pUIFieldMap !=null && ( pUIFieldMap.get('CCNumber') == null || pUIFieldMap.get('CCNumber') == '' || pUIFieldMap.get('Pay_Expiry_Date__x') == null || pUIFieldMap.get('Pay_Expiry_Date__x') == ''))
                        {
                            gift.Batch_Status__c = 'Failed';
                            continue;
                        } else {
                            payment.paymentType = 'Credit Card';
                            payment.creditCardNumber = pUIFieldMap.get('CCNumber');
                            payment.creditCardType = gift.Recurring_Payments__r[paymentSize].Credit_Card_Type__c;
                            payment.cvv2 = pUIFieldMap.get('Pay_Security_Code__x');
                            if(pUIFieldMap.get('Pay_Expiry_Date__x') != null && pUIFieldMap.get('Pay_Expiry_Date__x').length() > 3) {
                                payment.expiryMonth = tryParseToInt(pUIFieldMap.get('Pay_Expiry_Date__x').substring(0,2));
                                payment.expiryYear = tryParseToInt(pUIFieldMap.get('Pay_Expiry_Date__x').substring(2,4));
                            }
                        }
                    }
                    else if(paymentSize == -1 && pUIFieldMap.get('Payment_Type').equals('Credit Card'))
                    {
                         payment.paymentType = 'Credit Card';
                         payment.creditCardNumber = pUIFieldMap.get('CCNumber');
                         payment.creditCardType = pUIFieldMap.get('CCType');
                            payment.cvv2 = pUIFieldMap.get('Pay_Security_Code__x');
                            if(pUIFieldMap.get('Pay_Expiry_Date__x') != null && pUIFieldMap.get('Pay_Expiry_Date__x').length() > 3) {
                                payment.expiryMonth = tryParseToInt(pUIFieldMap.get('Pay_Expiry_Date__x').substring(0,2));
                                payment.expiryYear = tryParseToInt(pUIFieldMap.get('Pay_Expiry_Date__x').substring(2,4));
                              }
                    }
                    if ( paymentSize != -1 && gift.Recurring_Payments__r[paymentSize].Payment_Type__c == 'ACH/PAD') {
                        payment.paymentType = 'ACH';
                        payment.bankAccountNumber = pUIFieldMap.get('ACHAccountNo');
                        payment.BankRoutingNumber = gift.Recurring_Payments__r[paymentSize].Routing_Branch_Number__c;
                        if(accountTypeMap.get(gift.Recurring_Payments__r[paymentSize].Account_Type__c) != null){
                            payment.bankAccountType = accountTypeMap.get(gift.Recurring_Payments__r[paymentSize].Account_Type__c);
                        }
                        else{
                            payment.bankAccountType = '';
                        }

                        payment.checkNumber = '';
                    }
                    else if(paymentSize == -1 && pUIFieldMap.get('Payment_Type').equals('ACH/PAD')){
                         payment.paymentType = 'ACH';
                         payment.bankAccountNumber = pUIFieldMap.get('ACHAccountNo');
                         payment.BankRoutingNumber = pUIFieldMap.get('ACHRoutingNo');
                         payment.bankAccountType = pUIFieldMap.get('ACHAccountType');
                    }
                    if (gift.Constituent__c != null)
                    {
                        payment.address1 = gift.Constituent__r.MailingStreet;
                        payment.city = gift.Constituent__r.MailingCity;
                        payment.state = gift.Constituent__r.MailingState;
                        payment.country = gift.Constituent__r.MailingCountry;
                        payment.zipCode = gift.Constituent__r.MailingPostalCode;
                        payment.donationType = 'IND';
                        payment.email = gift.Constituent__r.Email;
                        payment.phone = gift.Constituent__r.Phone;
                    }
                    else
                    {
                        payment.address1 = gift.Organization__r.BillingStreet;
                        payment.city = gift.Organization__r.BillingCity;
                        payment.state = gift.Organization__r.BillingState;
                        payment.country = gift.Organization__r.BillingCountry;
                        payment.zipCode = gift.Organization__r.BillingPostalCode;
                        payment.donationType = 'ORG';
                        payment.email = gift.Organization__r.Email__c;
                        payment.phone = gift.Organization__r.Phone;
                        payment.organization = gift.Organization__r.Name;
                    }
                    if (gift.Gift_Type__c == 'Recurring')
                    {
                        payment.billingStartDate = date.valueOf(pUIFieldMap.get('billingStartDate'));
                    }
                    else
                    {
                        payment.billingStartDate = date.today();
                    }
                    payment.numberOfPayments = '';
                    if (pUIFieldMap.get('of_Payments__c') != null)
                    {
                        payment.numberOfPayments = pUIFieldMap.get(PackageFieldNamespace + 'of_Payments__c');
                    }

                    payment.PayerFirstName = gift.Constituent__r != null ? (gift.Constituent__r.FirstName != null ? gift.Constituent__r.FirstName  : '') : ( pUIFieldMap.get('RecGift_First_Name') != null ? pUIFieldMap.get('RecGift_First_Name') : '');
                    payment.PayerLastName = gift.Constituent__r != null ? gift.Constituent__r.LastName : (pUIFieldMap.get('RecGift_Last_Name') != null ? pUIFieldMap.get('RecGift_Last_Name') : '');
                    payment.isIndividual = gift.Constituent__c == null ? false : true;
                    payment.isRecurring = gift.Gift_Type__c == 'Recurring' ? true : false;
                    payment.constituentType = pUIFieldMap.get('isNewRecord');
                    if (gift.Expected_Amount__c != null) {
                        payment.amount = gift.Expected_Amount__c.format();
                    }
                    else {
                        payment.amount = '0';
                    }

                    payment.currencyType = BatchSettings.CurrencyCode__c;
                    payment.frequency = pUIFieldMap.get(PackageFieldNamespace + 'Frequency__c');
                    payment.giftId = gift.Id;
                    if(gift.Recurring_Payments__r.size() != 0 ) {
                        payment.paymentId = gift.Recurring_Payments__r[paymentSize].Id; }

                    form.payments.payment.add(payment);
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
                String res = JSON.serialize(txResults.TransactionResult);
                return res;
  }

    WebService static String submitPayment1(String giftBatchId, String giftPaymentUIFieldsMap) {
        return BatchProcessingController.submitPayment(giftBatchId, giftPaymentUIFieldsMap);
    }

    public PageReference postSave()
    {
        PageReference pageRef = new PageReference('/apex/' + PackageFieldNamespace + 'BatchTransaction?id=' + giftBatch.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    //To enable submit on visualforce page
    public void enableSubmit() {
        isSubmitEnabled = true;
    }


  public static integer tryParseToInt(String txt)
  {
     integer result = 0;
     try
     {
        result = integer.valueOf(txt);
     }
     catch(Exception ex)
     {
     }

     return result;
  }

    public static string getFieldId(String field_label){
        PageReference p = new PageReference('/' + Gift_Detail__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1');
        String html;
        if(!test.isrunningtest()){
            html = p.getContent().toString();
        }else{
            html = 'test content';
        }
        Map<String, String> labelToId = new Map<String, String>();
        Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
        while (m.find()) {
            String label = m.group(3);
            String id = m.group(1);
            if(label.equalsIgnoreCase(field_label)){
                return id;
            }
        }
        return '';
    }

    public static void SetFieldNamespace()
    {
        String fieldNamespace = Utilities.getCurrentNamespace();
        PackageFieldNamespace = String.isEmpty(fieldNamespace) ? '' : fieldNamespace + '__';
    }

    public static void SetNamespace()
    {
        String namespace = Utilities.getCurrentNamespace();
        PackageNamespace = String.isEmpty(namespace) ? '' : namespace;
    }

    public PageReference checkAccessibility()
    {
      try{
        new GiftBatchSelector().IsCustomAccessible(new List<Schema.SObjectField>{
          Gift_Batch__c.Name, Gift_Batch__c.Template_Name__c, Gift_Batch__c.Batch_Status__c, Gift_Batch__c.Cash_Gifts__c, Gift_Batch__c.Cash__c, Gift_Batch__c.Cheque_Gifts__c,
          Gift_Batch__c.Cheque__c, Gift_Batch__c.Close_Date__c, Gift_Batch__c.Credit_Card_Gifts__c, Gift_Batch__c.Credit_Card__c, Gift_Batch__c.Description__c,
          Gift_Batch__c.Direct_Deposit_Gifts__c, Gift_Batch__c.Direct_Deposit__c, Gift_Batch__c.Name__c, Gift_Batch__c.Open_Date__c, Gift_Batch__c.Other_Gifts__c, Gift_Batch__c.Other__c,
          Gift_Batch__c.Shareplan_Gifts__c, Gift_Batch__c.Shareplan__c, Gift_Batch__c.Total_Gift_Amount__c, Gift_Batch__c.Total_Gift__c, Gift_Batch__c.of_ACH_PAD_payments__c,
          Gift_Batch__c.of_In_Kind_Payments__c, Gift_Batch__c.of_Stock_Payments__c, Gift_Batch__c.Total_ACH_PAD__c, Gift_Batch__c.Total_In_Kind__c, Gift_Batch__c.Total_Stock__c});

        new SolicitorSelector().IsCustomAccessible(new List<Schema.SObjectField>{
          Solicitor__c.Id, Solicitor__c.Custom_Amount__c, Solicitor__c.Solicitor__c, Solicitor__c.Organization_Solicitor__c, Solicitor__c.Role__c});

        new AllocationSelector().IsCustomAccessible(new List<Schema.SObjectField>{
          Gift_Detail__c.Id, Gift_Detail__c.Name, Gift_Detail__c.Amount__c, Gift_Detail__c.Fund__c, Gift_Detail__c.New_Campaign__c, Gift_Detail__c.Fund_Name__c, Gift_Detail__c.Campaign__c,
          Gift_Detail__c.Custom_Allocation_Text__c, Gift_Detail__c.Package__c, Gift_Detail__c.Parent_Appeal__c, Gift_Detail__c.Installment__c, Gift_Detail__c.Allocation_Date__c, Gift_Detail__c.Gift__c,
          Gift_Detail__c.GL_Auto_Credit_Account__c, Gift_Detail__c.GL_Auto_Debit_Account__c, Gift_Detail__c.Payment__c});

        new GiftSelector().IsCustomAccessible(new List<Schema.SObjectField>{
          Gift__c.Id, Gift__c.Name, Gift__c.Gift_Type__c, Gift__c.Receipt_Type__c, Gift__c.Batch_Status__c, Gift__c.GiftBatch__c, Gift__c.Constituent__c, Gift__c.Organization__c});

        new ContactSelector().IsCustomAccessible(new List<Schema.SObjectField>{Contact.id, Contact.Name, Contact.Constituent_ID__c, Contact.FirstName, Contact.LastName});

        new AccountSelector().IsCustomAccessible(new List<Schema.SObjectField>{Account.id, Account.Name, Account.Organization_ID__c});

        new RecurringDonationSelector().IsCustomAccessible(new List<Schema.SObjectField>{Recurring_Donation__c.id, Recurring_Donation__c.Name});

        new PaymentSelector().IsCustomAccessible(new List<Schema.SObjectField>{
          Payment__c.id, Payment__c.Name, Payment__c.Amount__c, Payment__c.Date__c, Payment__c.Payment_Type__c, Payment__c.Date_Deposited__c, Payment__c.Status__c});

        new ReceiptSelector().IsCustomAccessible(new List<schema.SObjectField>{Receipt__c.id, Receipt__c.Name});

        new CampaignSelector().IsCustomAccessible(new List<schema.SObjectField>{Campaign.Id, Campaign.Name, Campaign.Fund__c, Campaign.Fund_Name__c});

        new FundSelector().IsCustomAccessible(new List<schema.SObjectField>{Fund__c.Id, Fund__c.Name});

        new PackageSelector().IsCustomAccessible(new List<schema.SObjectField>{Package__c.Name,Package__c.Id});

        new InstallmentSelector().IsCustomAccessible(new List<schema.SObjectField> {Installment__c.Installment_Balance__c});

        new hedRelationshipSelector().IsCustomAccessible(new List<Schema.SObjectField>{
          hed__Relationship__c.Id, hed__Relationship__c.hed__Contact__c, hed__Relationship__c.hed__RelatedContact__c, hed__Relationship__c.Apply_Soft_Credit__c});

        new hedAffiliationSelector().IsCustomAccessible(new List<Schema.SObjectField>{
          hed__Affiliation__c.Id, hed__Affiliation__c.hed__Account__c, hed__Affiliation__c.hed__Contact__c, hed__Affiliation__c.Apply_Soft_Credit__c});

        new RecordTypeSelector().IsCustomAccessible(new List<Schema.SObjectField>{RecordType.id, RecordType.Name, RecordType.NamespacePrefix, RecordType.SobjectType});

        new FolderSelector().IsCustomAccessible(new List<Schema.SObjectField>{Folder.Id, Folder.Name});

        return null;
      }catch(Exception ex){
        Schema.DescribeSObjectResult result = Gift_Batch__c.SObjectType.getDescribe();
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix());
        pageRef.setRedirect(true);
        return pageRef;
      }
    }
}