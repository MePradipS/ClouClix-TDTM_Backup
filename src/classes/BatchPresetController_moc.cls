public with sharing class BatchPresetController_moc extends RedirectController {

    public BatchPresetController_moc() {
    }

    public static String NamespacedRecurringDonation {
        get {
            if (NamespacedRecurringDonation == null) {
                NamespacedRecurringDonation = PackageNamespace + 'Recurring_Donation__c';
            }
            return NamespacedRecurringDonation;
        }
        set;
    }
    public static String NamespacedGift {
        get {
            if (NamespacedGift == null) {
                NamespacedGift = PackageNamespace + 'Gift__c';
            }
            return NamespacedGift;
        }
        set;
    }
    public static String NamespacedPayment {
        get {
            if (NamespacedPayment == null) {
                NamespacedPayment = PackageNamespace + 'Payment__c';
            }
            return NamespacedPayment;
        }
        set;
    }
    public static String NamespacedPaymentType {
        get {
            if (NamespacedPaymentType == null) {
                NamespacedPaymentType = PackageNamespace + 'Payment_Type__c';
            }
            return NamespacedPaymentType;
        }
        set;
    }
    public static String NamespacedReceipt {
        get {
            if (NamespacedReceipt == null) {
                NamespacedReceipt = PackageNamespace + 'Receipt__c';
            }
            return NamespacedReceipt;
        }
        set;
    }
    public static String NamespacedGiftDetail {
        get {
            if (NamespacedGiftDetail == null) {
                NamespacedGiftDetail = PackageNamespace + 'Gift_Detail__c';
            }
            return NamespacedGiftDetail;
        }
        set;
    }
    public static String NamespacedNewCampaign {
        get {
            if (NamespacedNewCampaign == null) {
                NamespacedNewCampaign = PackageNamespace + 'New_Campaign__c';
            }
            return NamespacedNewCampaign;
        }
        set;
    }
    public static String NamespacedFund {
        get {
            if (NamespacedFund == null) {
                NamespacedFund = PackageNamespace + 'Fund__c';
            }
            return NamespacedFund;
        }
        set;
    }
    public static String NamespacedBatchTemplate {
        get {
            if (NamespacedBatchTemplate == null) {
                NamespacedBatchTemplate = PackageNamespace + 'Batch_Template__c';
            }
            return NamespacedBatchTemplate;
        }
        set;
    }
    public static String NamespacedCampaign {
        get {
            if (NamespacedCampaign == null) {
                NamespacedCampaign = PackageNamespace + 'Campaign__c';
            }
            return NamespacedCampaign;
        }
        set;
    }
    public static String NamespacedEventRegistration {
        get {
            if (NamespacedEventRegistration == null) {
                NamespacedEventRegistration = PackageNamespace + 'Event_Registration__c';
            }
            return NamespacedEventRegistration;
        }
        set;
    }
    public static String NamespacedGiftBatch {
        get {
            if (NamespacedGiftBatch == null) {
                NamespacedGiftBatch = PackageNamespace + 'Gift_Batch__c';
            }
            return NamespacedGiftBatch;
        }
        set;
    }
    public static String NamespacedTemplateName{
        get {
            if (NamespacedTemplateName == null) {
                NamespacedTemplateName = PackageNamespace + 'Template_Name__c';
            }
            return NamespacedTemplateName;
        }
        set;
    }

    public static String PackageNamespace {
        get
        {
            if (PackageNamespace == null) {
                String namespace = Utilities.getCurrentNamespace();
                PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
            }
            return PackageNamespace;
        }
        set;
    }
    public Boolean isPresetSaved { get; set; }
    public Boolean isCloned { get; set; }
    public Boolean isSelectPreset { get; set; }
    public Boolean isShowPreset { get; set; }
    public Boolean isNewPreset { get; set; }
    private Map < string, Integer > conAddressFields;
    private Map < string, Integer > accAddressFields;
    private Boolean isBillingAddressReq;
    public List < String > conSelected { get; set; }
    public List < String > accSelected { get; set; }
    public List < String > rgfSelected { get; set; }
    public List < String > trnxSelected { get; set; }
    public List < String > pymtSelected { get; set; }
    public List < String > rcptSelected { get; set; }
    public List < String > giftDetailSelected { get; set; }
    public List < String > eventRegSelected { get; set; }
    public List < String > fundForAppeal { get; set; }
    public String successMessage { get; set; }
    public Batch_Template__c temp { get; set; }
    public list < String > AlphaList { get; set; }
    public String AlphaFilter { get; set; }
    public Batch_Template__c template { get; set; }
    public List < PresetWrapper > contactFields { get; set; }
    public List < PresetWrapper > accountFields { get; set; }
    public List < PresetWrapper > RecurringGiftFields { get; set; }
    public List < PresetWrapper > TransactionFields { get; set; }
    public List < PresetWrapper > PaymentFields { get; set; }
    public List < PresetWrapper > ReceiptFields { get; set; }
    public List < PresetWrapper > GiftDetailFields { get; set; }
    public List < PresetWrapper > eventRegFields { get; set; }
    public List < Batch_Template__c > batchtemp { get; set; }
    public List < Batch_Template__c > tempRecord { get; set; }
    Set < string > conPickValues = new Set < string > ();
    Set < string > accPickValues = new Set < string > ();
    Set < string > rgfPickValues = new Set < string > ();
    Set < string > trnxPickValues = new Set < string > ();
    Set < string > pymtPickValues = new Set < string > ();
    Set < string > rcptPickValues = new Set < string > ();
    Set < string > giftDetailPickValues = new Set < string > ();
    Set < string > eventRegPickValues = new Set < string > ();
    Map < String, PresetWrapper > contactFieldsMap = new Map < String, PresetWrapper > ();
    Map < String, PresetWrapper > accountFieldsMap = new Map < String, PresetWrapper > ();
    Map < String, PresetWrapper > recGiftFieldsMap = new Map < String, PresetWrapper > ();
    Map < String, PresetWrapper > tranxFieldsMap = new Map < String, PresetWrapper > ();
    Map < String, PresetWrapper > paymentFieldsMap = new Map < String, PresetWrapper > ();
    Map < String, PresetWrapper > receiptFieldsMap = new Map < String, PresetWrapper > ();
    Map < String, PresetWrapper > giftDetailFieldsMap = new Map < String, PresetWrapper > ();
    Map < String, PresetWrapper > eventRegFieldsMap = new Map < String, PresetWrapper > ();
    Map < string, string > fundDetails = new Map < string, string > ();
    public map < ID, string > lookupIds { get; set; }
    public String giftTypePicklistValues { get; set; }
    public Map < string, string > keyPrefixMap { get; set; }
    Public String eventLevelLookupId { get; set; }
    private RecordType RT;
    private BatchPresetHelper_moc objBPH;
    @TestVisible private String templateId;

    @RemoteAction
    public static Campaign getFundName(Id appealId){
        Campaign list1 = new Campaign ();
        List<Campaign> campaignList;
        try {
            campaignList = new CampaignSelector().SelectCampaignAndFundById(new Set<Id> { appealId });
            if (campaignList != null && campaignList.size() > 0) {
                list1 = campaignList[0];
            }
            return list1;
        }
        catch(QueryException e) {
            return null;
        }
    }
    public Map < String, Schema.SObjectType > schemaDesc { get; set; }
    public boolean isEditMode { get; set; }

    public BatchPresetController_moc(ApexPages.StandardController controller) {
        Super(controller, true);

	lookupIds=new  map<ID ,string>();
        lookupIds.put(null,'');
        keyPrefixMap = new Map < string, string > ();
        keyPrefixMap.put('Event Level', Event_Level__c.sObjectType.getDescribe().getKeyPrefix());
        keyPrefixMap.put('Allocation', Gift_Detail__c.sObjectType.getDescribe().getKeyPrefix());
        eventLevelLookupId = getFieldId('Event Level', 'Gift Detail');
	schemaDesc = Schema.getGlobalDescribe();
        isPresetSaved = false;
        isCloned = false;
        getPicklistCon();
        getPicklistAcc();
        getPicklistGift();
        getPicklistRecorringDonation();
        getPicklistpayment();
        getPicklistRecipt();
        isSelectPreset = false;
        isShowPreset = true;
        isBillingAddressReq = false;

        conSelected = new List < String > ();
        accSelected = new List < String > ();
        rgfSelected = new List < String > ();
        trnxSelected = new List < String > ();
        pymtSelected = new List < String > ();
        rcptSelected = new List < String > ();
        giftDetailSelected = new List < String > ();
        eventRegSelected = new List < String > ();
        contactFields = new List < PresetWrapper > ();
        accountFields = new List < PresetWrapper > ();
        RecurringGiftFields = new List < PresetWrapper > ();
        TransactionFields = new List < PresetWrapper > ();
        PaymentFields = new List < PresetWrapper > ();
        ReceiptFields = new List < PresetWrapper > ();
        GiftDetailFields = new List < PresetWrapper > ();
        eventRegFields = new List < PresetWrapper > ();
        conAddressFields = new Map < String, Integer > ();
        conAddressFields.put('MailingStreet', 0);
        conAddressFields.put('MailingCity', 1);
        conAddressFields.put('MailingState', 2);
        conAddressFields.put('MailingCountry', 3);
        conAddressFields.put('MailingPostalCode', 4);
        accAddressFields = new Map < String, Integer > ();
        accAddressFields.put('BillingStreet', 0);
        accAddressFields.put('BillingCity', 1);
        accAddressFields.put('BillingState', 2);
        accAddressFields.put('BillingCountry', 3);
        accAddressFields.put('BillingPostalCode', 4);

        temp = new Batch_Template__c();
        temp.Type__c = 'Global';
        template = new Batch_Template__c();
        template.Type__c = 'Global';
        template.Transaction_Type__c = 'Individuals';
        objBPH = new BatchPresetHelper_moc();
        List<RecordType> rtList = new RecordTypeSelector().SelectBySObjectAndName(NamespacedBatchTemplate, 'Parent');
        if (rtList != null && rtList.size() > 0) {
            RT = rtList[0];
        }
        tempRecord = new List<Batch_Template__c>();
        templateId = ApexPages.currentPage().getParameters().get('id');
        successMessage = ApexPages.currentPage().getParameters().get('msg');
        if (templateId != '' && templateId != null) {
            editPresetTemplate();
            createPaymentFieldIdMap();
            isEditMode = true;
        } else {
            isEditMode = false;
            newPresetTemplate();
        }
        AlphaList = new list < String > { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Other', 'All' };

        if (apexpages.currentpage().getparameters().get('alpha') == null) {
            AlphaFilter = 'All';
        } else {
            AlphaFilter = apexpages.currentpage().getparameters().get('alpha');
        }
        viewPresets();
    }

    protected override String SetRedirectPage() {
        return getPageUrl(); }
    protected override String SetUrlParameters() {
        return getUrlParams(); }

    public string pType { get; set; }
    public List < SelectOption > getPTypes() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('-- None --', '-- None --'));
        options.add(new SelectOption('Personal', 'Personal'));
        options.add(new SelectOption('Global', 'Global'));
        return options;
    }

    public PageReference BuildQuery() {
        tempRecord = new List < Batch_Template__c > ();
        String QueryWhere = '';
        if (AlphaFilter == null || AlphaFilter.trim().length() == 0) {
            AlphaFilter = 'All';
        }
        String QueryFields = 'Name,Type__c,RecordTypeId';
        string s = '%';

        if (AlphaFilter == 'Other') {
            QueryWhere = '(Not Name LIKE ' + '\'' + 'A' + s + '\') AND (Not Name LIKE ' + '\'' + 'B' + s + '\')AND (Not Name LIKE ' + '\'' + 'C' + s + '\')AND(Not Name LIKE ' + '\'' + 'D' + s + '\')AND(Not Name LIKE ' + '\'' + 'E' + s + '\')AND(Not Name LIKE ' + '\'' + 'F' + s + '\')AND (Not Name LIKE ' + '\'' + 'G' + s + '\')AND(Not Name LIKE ' + '\'' + 'H' + s + '\')AND (Not Name LIKE ' + '\'' + 'I' + s + '\')AND (Not Name LIKE ' + '\'' + 'J' + s + '\') AND (Not Name LIKE ' + '\'' + 'K' + s + '\') AND (Not Name LIKE ' + '\'' + 'L' + s + '\') AND (Not Name LIKE ' + '\'' + 'M' + s + '\') AND (Not Name LIKE ' + '\'' + 'N' + s + '\')AND  (Not Name LIKE ' + '\'' + 'O' + s + '\') AND (Not Name LIKE ' + '\'' + 'P' + s + '\') AND (Not Name LIKE ' + '\'' + 'Q' + s + '\') AND (Not Name LIKE ' + '\'' + 'R' + s + '\') AND (Not Name LIKE ' + '\'' + 'S' + s + '\') AND (Not Name LIKE ' + '\'' + 'T' + s + '\') AND (Not Name LIKE ' + '\'' + 'U' + s + '\') AND (Not Name LIKE ' + '\'' + 'V' + s + '\') AND (Not Name LIKE ' + '\'' + 'W' + s + '\') AND (Not Name LIKE ' + '\'' + 'X' + s + '\') AND (Not Name LIKE ' + '\'' + 'Y' + s + '\') AND (Not Name LIKE ' + '\'' + 'Z' + s + '\') AND RecordTypeId=' + '\'' + string.escapeSingleQuotes(RT.Id) + '\'' + 'AND Type__c =' + '\'' + string.escapeSingleQuotes(temp.Type__c) + '\'';
        } else if (AlphaFilter == 'All') {
            QueryWhere = 'Type__c =' + '\'' + string.escapeSingleQuotes(temp.Type__c) + '\'' + 'AND RecordTypeId=' + '\'' + string.escapeSingleQuotes(RT.Id) + '\'';
        } else {
            QueryWhere = 'Name LIKE ' + '\'' + AlphaFilter + s + '\' AND RecordTypeId=' + '\'' + string.escapeSingleQuotes(RT.Id) + '\'' + 'AND Type__c=' + '\'' + string.escapeSingleQuotes(temp.Type__c) + '\'';
        }

        if (temp.Type__c == 'Personal') {
            QueryWhere += ' And CreatedById=' + '\'' + string.escapeSingleQuotes(UserInfo.getUserId()) + '\'' + 'Order By Name Limit 1000 ';
            QueryFields += ',CreatedById';
        } else {
            QueryWhere += ' Order By Name Limit 1000 ';
        }
        tempRecord = new GenericQueryBuilder().ListQueryBuilderWhere('Batch_Template__c', QueryFields, QueryWhere);
        return null;
    }

    Private String paymentTypesSelected = '';
    public List < String > paymentTypesToAdd { get; set; }
    public List < String > paymentTypesToRemove { get; set; }

    public String getPaymentTypeFields() {
        return objBPH.getPaymentTypeFields();
    }

    public map < string, string > fieldIdMap { get; set; }
    public string fieldIdMapStr { get; set; }
    public void createPaymentFieldIdMap() {
        List < SelectOption > optionsToRemove = getPTypePickListOptionsToRemove();
        List < string > paymentTypeKeyList = new list < string > ();
        for (SelectOption selOption: optionsToRemove) {
            if (selOption.getValue() == '') continue;
            paymentTypeKeyList.add(selOption.getValue());
        }

        Map < String, List < String >> PaymentTypeFieldMap = objBPH.getPaymentTypeFieldMap();
        if (!PaymentTypeFieldMap.isEmpty()) {
            fieldIdMap = new map < string, string > ();
            fieldIdMapStr = '';
            for (string keyStr: paymentTypeKeyList) {
                if (!PaymentTypeFieldMap.containsKey(keyStr)) keyStr = 'Other';
                list < string > fieldList = PaymentTypeFieldMap.get(keyStr);
                if (!fieldList.isEmpty()) {
                    for (string str: fieldList) {
                        fieldIdMap.put(str, keyStr);
                        fieldIdMapStr = fieldIdMapStr + ':' + str;
                    }
                }
            }
        }
    }

    public void addPaymentTypes() {
        for (String type: paymentTypesToAdd) {
            if (type == 'Credit Card' || type == 'ACH/PAD') {
                isBillingAddressReq = true;
                ApexPages.currentPage().getParameters().put('ObjectType', 'Contact');
                if (type == 'ACH/PAD') {
                    conSelected.add('Phone');
                }
                for (String fld: conAddressFields.keySet()) {
                    conSelected.add(fld);
                }
                addInPreset();
                sortBillingAddressFields(contactFields, true, type == 'ACH/PAD');
                ApexPages.currentPage().getParameters().put('ObjectType', 'Account');
                if (type == 'ACH/PAD') {
                    accSelected.add('Phone');
                }
                for (String fld: accAddressFields.keySet()) {
                    accSelected.add(fld);
                }
                addInPreset();
                sortBillingAddressFields(accountFields, false, type == 'ACH/PAD');
            }

            if (!paymentTypesSelected.contains(type + ',')) {
                paymentTypesSelected += type + ',';
            }
            if (objBPH.getPaymentTypes().contains(type + ',')) {
                if (objBPH.getPaymentTypeFieldMap().get(type) == null) {
                    type = 'Other';
                }
                for (String field: objBPH.getPaymentTypeFieldMap().get(type)) {
                    if (paymentFieldsMap.get(field) != null) {
                        PaymentFields.add(paymentFieldsMap.get(field));
                    }
                    paymentFieldsMap.remove(field);
                }
            }
        }
        createPaymentFieldIdMap();
    }

    public void removePaymentTypes() {
        isPresetSaved = false;

        String temp = '';
        for (String type: paymentTypesSelected.split(',', 0)) {
            if (!((new Set < String > (paymentTypesToRemove)).contains(type) || temp.contains(type))) {
                temp += type + ',';
            }
        }
        paymentTypesSelected = temp;

        try {
            if (!paymentTypesSelected.contains('Credit Card,') && !paymentTypesSelected.contains('ACH/PAD,')) {
                isBillingAddressReq = false;
                for (PresetWrapper fld: contactFields) {
                    if (conAddressFields.keySet().contains(fld.fieldName) || fld.fieldName == 'Phone') {
                        fld.isRequired = false;
                    }
                }
                for (PresetWrapper fld: accountFields) {
                    if (accAddressFields.keySet().contains(fld.fieldName) || fld.fieldName == 'Phone') {
                        fld.isRequired = false;
                    }
                }
            } else if (!paymentTypesSelected.contains('ACH/PAD,')) {
                for (PresetWrapper fld: contactFields) {
                    if (fld.fieldName == 'Phone') {
                        fld.isRequired = false;
                    }
                }
                for (PresetWrapper fld: accountFields) {
                    if (fld.fieldName == 'Phone') {
                        fld.isRequired = false;
                    }
                }
            }
        } catch (Exception ex) {
            //do nothing.
        }

        for (Integer i = 0; i < PaymentFields.size(); i++) {
            if (PaymentFields[i] != null && objBPH.getPaymentTypeFields().contains(PaymentFields[i].fieldName)) {
                paymentFieldsMap.put(PaymentFields[i].fieldName, PaymentFields[i]);
                PaymentFields.remove(i);
                i--;
            }
        }

        for (String type: paymentTypesSelected.split(',', 0)) {
            if (!String.isEmpty(type)) {
                if (objBPH.getPaymentTypeFieldMap().get(type) == null) { type = 'Other'; }
            }

            List < String > fields = objBPH.getPaymentTypeFieldMap().get(type);
            if (fields != null) {
                for (String field: fields) {
                    if (paymentFieldsMap.get(field) != null) {
                        PaymentFields.add(paymentFieldsMap.get(field));
                    }
                    paymentFieldsMap.remove(field);
                }
            }
        }
    }

    public List < SelectOption > getPTypePickListOptionsToAdd() {
        return getPTypePickListOptions(true);
    }

    public List < SelectOption > getPTypePickListOptionsToRemove() {
        List < SelectOption > optionsToRemove = getPTypePickListOptions(false);
        if (optionsToRemove.size() > 0) {
            optionsToRemove.add(0, new SelectOption('', '--Choosen--', true));
        } else {
            optionsToRemove.add(new SelectOption('', '--Choosen--', true));
        }
        return optionsToRemove;
    }
    private List < SelectOption > getPTypePickListOptions(Boolean toAdd) {
        List < SelectOption > optionsToAdd = new List < SelectOption > ();
        List < SelectOption > optionsToRemove = new List < SelectOption > ();
        optionsToAdd.add(new SelectOption('', '--Available--', true));

        for (String type: objBPH.getPaymentTypes().split(',', 0)) {
            if (!paymentTypesSelected.contains(type + ',')) {
                optionsToAdd.add(new SelectOption(type.trim(), type.trim()));
            } else {
                optionsToRemove.add(new SelectOption(type.trim(), type.trim()));
            }
        }
        return toAdd ? optionsToAdd : optionsToRemove;
    }

    public List < SelectOption > getPaymentTypePickListOptions() {
        List < SelectOption > options = getPTypePickListOptions(false);
        if (options.size() > 0) {
            options.add(0, new SelectOption('', '--None--'));
        } else {
            options.add(new SelectOption('', '--None--'));
        }
        return options;
    }

    public List < SelectOption > getConPickListOptions() {
        return objBPH.pickListOptions(contactFieldsMap, conPickValues, false);
    }

    public List < SelectOption > getAccPickListOptions() {
        return objBPH.pickListOptions(accountFieldsMap, accPickValues, false);
    }

    public List < SelectOption > getRgfPickListOptions() {
        return objBPH.pickListOptions(recGiftFieldsMap, rgfPickValues, false);
    }

    public List < SelectOption > getTrnxPickListOptions() {
        return objBPH.pickListOptions(tranxFieldsMap, trnxPickValues, false);
    }

    public List < SelectOption > getPymtPickListOptions() {
        return objBPH.pickListOptions(paymentFieldsMap, pymtPickValues, true);
    }

    public List < SelectOption > getRcptPickListOptions() {
        return objBPH.pickListOptions(receiptFieldsMap, rcptPickValues, false);
    }

    public List < SelectOption > getDGPickListOptions() {
        return objBPH.pickListOptions(giftDetailFieldsMap, giftDetailPickValues, false);
    }

    public List < SelectOption > getEventPickListOptions() {
        return objBPH.pickListOptions(eventRegFieldsMap, eventRegPickValues, false);
    }

    public pageReference showTemplate() {
        isSelectPreset = false;
        isShowPreset = true;
        viewPresets();
        return null;
    }

    public pageReference viewPresets() {
        List < Batch_Template__c > presetTemplates;
        if (RT == null) {
            return null;
        }

        if(temp.Type__c == 'Personal') {
            presetTemplates = new BatchTemplateSelector().SelectByTypeRecordTypeCreatedByOrderByName(temp.Type__c, RT.Id, UserInfo.getUserId());
        } else {
            presetTemplates = new BatchTemplateSelector().SelectByTypeRecordTypeOrderByName(temp.Type__c, RT.Id);
        }
        isSelectPreset = false;
        isShowPreset = true;
        tempRecord = presetTemplates;
        return null;
    }

    public pageReference CreateNewPresetTemplate() {
        PageReference pageRef = new PageReference('/apex/' + PackageNamespace + 'EditBatchPreset_moc');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public pageReference newPresetTemplate() {
        isNewPreset = true;
        if (contactFields.size() == 0)
            objBPH.bildFieldsMap(contactFieldsMap, contactFields, 'Contact', isNewPreset);
        if (accountFields.size() == 0)
            objBPH.bildFieldsMap(accountFieldsMap, accountFields, 'Account', isNewPreset);
        if (RecurringGiftFields.size() == 0)
            objBPH.bildFieldsMap(recGiftFieldsMap, RecurringGiftFields, NamespacedRecurringDonation, isNewPreset);
        if (TransactionFields.size() == 0)
            objBPH.bildFieldsMap(tranxFieldsMap, TransactionFields, NamespacedGift, isNewPreset);
        if (PaymentFields.size() == 0)
            objBPH.bildFieldsMap(paymentFieldsMap, PaymentFields, NamespacedPayment, isNewPreset);
        if (ReceiptFields.size() == 0)
            objBPH.bildFieldsMap(receiptFieldsMap, ReceiptFields, NamespacedReceipt, isNewPreset);
        if (GiftDetailFields.size() == 0)
            objBPH.bildFieldsMap(giftDetailFieldsMap, GiftDetailFields, NamespacedGiftDetail, isNewPreset);
        return null;
    }

    public PageReference editAPresetTemplate() {
        templateId = ApexPages.currentPage().getParameters().get('templateId');
        PageReference pageRef = new PageReference('/apex/' + PackageNamespace + 'EditBatchPreset_moc?id=' + templateId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference editPresetTemplate() {
        isPresetSaved = true;
        isNewPreset = false;
        Batch_Template__c presetTemplate;
        List<Batch_Template__c> batchTemplateList = new BatchTemplateSelector().SelectBatchTemplateAndRecordTypeNameById(new Set<Id> { string.escapeSingleQuotes(templateId) });
        if (batchTemplateList != null && batchTemplateList.size() > 0) {
            presetTemplate = batchTemplateList[0];
        }

        if (presetTemplate.RecordType.Name == 'Cloned') {
            isCloned = true;
        }

        template.Name = presetTemplate.Name;
        template.Type__c = presetTemplate.Type__c;
        template.Transaction_Type__c = presetTemplate.Transaction_Type__c;

        BatchPresetHelper_moc obj_BPH = new BatchPresetHelper_moc();
        if (contactFields.size() == 0) {
            contactFields = obj_BPH.readXML(presetTemplate.ContactFieldXml__c, 'Contact');
            obj_BPH.bildFieldsMap(contactFieldsMap, contactFields, 'Contact', isNewPreset);
        }
        if (accountFields.size() == 0) {
            accountFields = obj_BPH.readXML(presetTemplate.AccountFieldsXml__c, 'Account');
            obj_BPH.bildFieldsMap(accountFieldsMap, accountFields, 'Account', isNewPreset);
        }
        if (RecurringGiftFields.size() == 0) {
            RecurringGiftFields = obj_BPH.readXML(presetTemplate.RecurringGiftFieldsXml__c, NamespacedRecurringDonation);
            obj_BPH.bildFieldsMap(recGiftFieldsMap, RecurringGiftFields, NamespacedRecurringDonation, isNewPreset);
        }
        if (TransactionFields.size() == 0) {
            TransactionFields = obj_BPH.readXML(presetTemplate.TransactionFieldsXml__c, NamespacedGift);
            obj_BPH.bildFieldsMap(tranxFieldsMap, TransactionFields, NamespacedGift, isNewPreset);
        }
        if (PaymentFields.size() == 0) {
            PaymentFields = obj_BPH.readXML(presetTemplate.PaymentFieldsXml__c, NamespacedPayment);
            //Get Payment Types Selected.
            paymentTypesSelected = obj_BPH.paymentTypesSelected;
            obj_BPH.bildFieldsMap(paymentFieldsMap, PaymentFields, NamespacedPayment, isNewPreset);
        }
        if (ReceiptFields.size() == 0) {
            ReceiptFields = obj_BPH.readXML(presetTemplate.ReceiptFieldsXml__c, NamespacedReceipt);
            obj_BPH.bildFieldsMap(receiptFieldsMap, ReceiptFields, NamespacedReceipt, isNewPreset);
        }
        if (GiftDetailFields.size() == 0) {
            GiftDetailFields = obj_BPH.readXML(presetTemplate.GiftDetailFieldsXml__c, NamespacedGiftDetail);
            obj_BPH.bildFieldsMap(giftDetailFieldsMap, GiftDetailFields, NamespacedGiftDetail, isNewPreset);
        }
        templateId = presetTemplate.Id;
        return null;
    }

    public string objectRecordsIndexStr { get;set; }

    public string IndexListStr0 { get; set; }
    public string IndexListStr1 { get; set; }
    public string IndexListStr2 { get; set; }
    public string IndexListStr3 { get; set; }
    public string IndexListStr4 { get; set; }
    public string IndexListStr5 { get; set; }
    public string IndexListStr6 { get; set; }

    public list < PresetWrapper > buildPresetWrapperListAsPerIndex(string objectName, list < Integer > indexList) {
        list < PresetWrapper > recordList_Temp = new list < PresetWrapper > ();
        for (Integer index: indexList) {
            if (objectName == 'Contact') recordList_Temp.add(contactFields.get(index));
            if (objectName == 'Account') recordList_Temp.add(accountFields.get(index));
            if (objectName == NamespacedRecurringDonation) recordList_Temp.add(RecurringGiftFields.get(index));
            if (objectName == NamespacedGift) recordList_Temp.add(TransactionFields.get(index));
            if (objectName == NamespacedPayment) recordList_Temp.add(PaymentFields.get(index));
            if (objectName == NamespacedReceipt) recordList_Temp.add(ReceiptFields.get(index));
            if (objectName == NamespacedGiftDetail) recordList_Temp.add(GiftDetailFields.get(index));
        }
        return recordList_Temp;
    }

    public list < Integer > createIndexList(string IndexListStr_Temp) {
        list < Integer > indexList = new list < Integer > ();
        if (IndexListStr_Temp.contains(',')) {
            list < string > idStrList = IndexListStr_Temp.split(',');
            if (idStrList != null && !idStrList.isEmpty()) {
                for (string idStr: idStrList) {
                    if (idStr.contains(':')) {
                        string indexVal = idStr.split(':')[1];
                        integer indexVal_Int = Integer.valueOf(indexVal);
                        indexList.add(indexVal_Int);
                    }
                }
            }
        }
        return indexList;
    }

    public void SaveOrderListForAll() {
        string IndexListStr_Temp;
        if (!IndexListStr0.contains('done') && IndexListStr0.contains(',')) {
            IndexListStr_Temp = IndexListStr0;
            list < Integer > indexList = createIndexList(IndexListStr_Temp);
            list < PresetWrapper > recordList_Temp;
            if (indexList != null && !indexList.isEmpty()) recordList_Temp = buildPresetWrapperListAsPerIndex('Contact', indexList);
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == contactFields.size()) {
                    contactFields.clear();
                    contactFields.addAll(recordList_Temp);
                }
            }
        }
        if (!IndexListStr1.contains('done') && IndexListStr1.contains(',')) {
            IndexListStr_Temp = IndexListStr1;
            list < Integer > indexList = createIndexList(IndexListStr_Temp);
            list < PresetWrapper > recordList_Temp;
            if (indexList != null && !indexList.isEmpty()) recordList_Temp = buildPresetWrapperListAsPerIndex('Account', indexList);
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == accountFields.size()) {
                    accountFields.clear();
                    accountFields.addAll(recordList_Temp);
                }
            }
        }

        if (!IndexListStr2.contains('done') && IndexListStr2.contains(',')) {
            IndexListStr_Temp = IndexListStr2;
            list < Integer > indexList = createIndexList(IndexListStr_Temp);
            list < PresetWrapper > recordList_Temp;
            if (indexList != null && !indexList.isEmpty()) { recordList_Temp = buildPresetWrapperListAsPerIndex(NamespacedRecurringDonation, indexList); }
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == RecurringGiftFields.size()) {
                    RecurringGiftFields.clear();
                    RecurringGiftFields.addAll(recordList_Temp);
                }
            }
        }

        if (!IndexListStr3.contains('done') && IndexListStr3.contains(',')) {
            IndexListStr_Temp = IndexListStr3;
            list < Integer > indexList = createIndexList(IndexListStr_Temp);
            list < PresetWrapper > recordList_Temp;
            if (indexList != null && !indexList.isEmpty()) { recordList_Temp = buildPresetWrapperListAsPerIndex(NamespacedGift, indexList); }
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == TransactionFields.size()) {
                    TransactionFields.clear();
                    TransactionFields.addAll(recordList_Temp);
                }
            }
        }

        if (!IndexListStr4.contains('done') && IndexListStr4.contains(',')) {
            IndexListStr_Temp = IndexListStr4;
            list < Integer > indexList = createIndexList(IndexListStr_Temp);
            list < PresetWrapper > recordList_Temp;
            if (indexList != null && !indexList.isEmpty()) { recordList_Temp = buildPresetWrapperListAsPerIndex(NamespacedPayment, indexList); }
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == PaymentFields.size()) {
                    PaymentFields.clear();
                    PaymentFields.addAll(recordList_Temp);
                }
            }
        }

        if (!IndexListStr5.contains('done') && IndexListStr5.contains(',')) {
            IndexListStr_Temp = IndexListStr5;
            list < Integer > indexList = createIndexList(IndexListStr_Temp);
            list < PresetWrapper > recordList_Temp;
            if (indexList != null && !indexList.isEmpty()) { recordList_Temp = buildPresetWrapperListAsPerIndex(NamespacedReceipt, indexList); }
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == ReceiptFields.size()) {
                    ReceiptFields.clear();
                    ReceiptFields.addAll(recordList_Temp);
                }
            }
        }

        if (!IndexListStr6.contains('done') && IndexListStr6.contains(',')) {
            IndexListStr_Temp = IndexListStr6;
            list < Integer > indexList = createIndexList(IndexListStr_Temp);
            list < PresetWrapper > recordList_Temp;
            if (indexList != null && !indexList.isEmpty()) { recordList_Temp = buildPresetWrapperListAsPerIndex(NamespacedGiftDetail, indexList); }
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == GiftDetailFields.size()) {
                    GiftDetailFields.clear();
                    GiftDetailFields.addAll(recordList_Temp);
                }
            }
        }
    }

    public void addInPreset() {
        isPresetSaved = false;

        String objectName = ApexPages.currentPage().getParameters().get('ObjectType');
        string IndexListStr_Temp;

        if (objectName == 'Contact') IndexListStr_Temp = IndexListStr0;
        if (objectName == 'Account') IndexListStr_Temp = IndexListStr1;
        if (objectName == NamespacedRecurringDonation) IndexListStr_Temp = IndexListStr2;
        if (objectName == NamespacedGift) IndexListStr_Temp = IndexListStr3;
        if (objectName == NamespacedPayment) IndexListStr_Temp = IndexListStr4;
        if (objectName == NamespacedReceipt) IndexListStr_Temp = IndexListStr5;
        if (objectName == NamespacedGiftDetail) IndexListStr_Temp = IndexListStr6;

        list < Integer > indexList = new list < Integer > ();
        if (IndexListStr_Temp.contains(',')) {
            list < string > idStrList = IndexListStr_Temp.split(',');
            if (idStrList != null && !idStrList.isEmpty()) {
                for (string idStr: idStrList) {
                    if (idStr.contains(':')) {
                        string indexVal = idStr.split(':')[1];
                        integer indexVal_Int = Integer.valueOf(indexVal);
                        indexList.add(indexVal_Int);
                    }
                }
            }
        }
        list < PresetWrapper > recordList_Temp;
        if (!indexList.isEmpty()) recordList_Temp = buildPresetWrapperListAsPerIndex(objectName, indexList);

        if (objectName == 'Contact') {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == contactFields.size()) {
                    contactFields.clear();
                    contactFields.addAll(recordList_Temp);
                }
            }
            for (String pwSelected: conSelected) {
                conPickValues.remove(pwSelected);
                PresetWrapper pw = contactFieldsMap.get(pwSelected);
                try {
                    if (pw != null) {
                        contactFields.add(pw);
                    }
                } catch (Exception ex) {
                    //do nothing.
                }
                contactFieldsMap.remove(pwSelected);
            }
        } else if (objectName == 'Account') {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == accountFields.size()) {
                    accountFields.clear();
                    accountFields.addAll(recordList_Temp);
                }
            }
            for (String pwSelected: accSelected) {
                accPickValues.remove(pwSelected);
                PresetWrapper pw = accountFieldsMap.get(pwSelected);
                try {
                    if (pw != null) {
                        accountFields.add(pw);
                    }
                } catch (Exception ex) {
                    //do nothing.
                }
                accountFieldsMap.remove(pwSelected);
            }
        } else if (objectName == NamespacedRecurringDonation) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == RecurringGiftFields.size()) {
                    RecurringGiftFields.clear();
                    RecurringGiftFields.addAll(recordList_Temp);
                }
            }
            for (String pwSelected: rgfSelected) {
                rgfPickValues.remove(pwSelected);
                RecurringGiftFields.add(recGiftFieldsMap.get(pwSelected));
                recGiftFieldsMap.remove(pwSelected);
            }
        } else if (objectName == NamespacedGift) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == TransactionFields.size()) {
                    TransactionFields.clear();
                    TransactionFields.addAll(recordList_Temp);
                }
            }
            for (String pwSelected: trnxSelected) {
                trnxPickValues.remove(pwSelected);
                TransactionFields.add(tranxFieldsMap.get(pwSelected));
                tranxFieldsMap.remove(pwSelected);
            }
        } else if (objectName == NamespacedPayment) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == PaymentFields.size()) {
                    PaymentFields.clear();
                    PaymentFields.addAll(recordList_Temp);
                }
            }
            for (String pwSelected: pymtSelected) {
                PaymentFields.add(paymentFieldsMap.get(pwSelected));
                paymentFieldsMap.remove(pwSelected);
                pymtPickValues.remove(pwSelected);
            }
        } else if (objectName == NamespacedReceipt) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == ReceiptFields.size()) {
                    ReceiptFields.clear();
                    ReceiptFields.addAll(recordList_Temp);
                }
            }
            for (String pwSelected: rcptSelected) {
                rcptPickValues.remove(pwSelected);
                ReceiptFields.add(receiptFieldsMap.get(pwSelected));
                receiptFieldsMap.remove(pwSelected);
            }
        } else if (objectName == NamespacedGiftDetail) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == GiftDetailFields.size()) {
                    GiftDetailFields.clear();
                    GiftDetailFields.addAll(recordList_Temp);
                }
            }

            for (String pwSelected: giftDetailSelected) {
                giftDetailPickValues.remove(pwSelected);
                GiftDetailFields.add(giftDetailFieldsMap.get(pwSelected));
                giftDetailFieldsMap.remove(pwSelected);
            }
        }
    }

    public string removalIndex1 { get; set; }
    public void removeFromPreset() {

        isPresetSaved = false;

        PresetWrapper pw;
        String objectName = ApexPages.currentPage().getParameters().get('ObjectType');
        Integer listIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
        integer removalIndex_Temp = Integer.valueOf(removalIndex1) - 1;
        string IndexListStr_Temp;

        if (objectName == 'Contact') IndexListStr_Temp = IndexListStr0;
        if (objectName == 'Account') IndexListStr_Temp = IndexListStr1;
        if (objectName == NamespacedRecurringDonation) IndexListStr_Temp = IndexListStr2;
        if (objectName == NamespacedGift) IndexListStr_Temp = IndexListStr3;
        if (objectName == NamespacedPayment) IndexListStr_Temp = IndexListStr4;
        if (objectName == NamespacedReceipt) IndexListStr_Temp = IndexListStr5;
        if (objectName == NamespacedGiftDetail) IndexListStr_Temp = IndexListStr6;

        list < Integer > indexList = new list < Integer > ();
        if (IndexListStr_Temp.contains(',')) {
            list < string > idStrList = IndexListStr_Temp.split(',');
            if (idStrList != null && !idStrList.isEmpty()) {
                for (string idStr: idStrList) {
                    if (idStr.contains(':')) {
                        string indexVal = idStr.split(':')[1];
                        integer indexVal_Int = Integer.valueOf(indexVal);
                        indexList.add(indexVal_Int);
                    }
                }
            }
        }
        list < PresetWrapper > recordList_Temp;
        if (!indexList.isEmpty()) recordList_Temp = buildPresetWrapperListAsPerIndex(objectName, indexList);

        if (objectName == 'Contact') {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == contactFields.size()) {
                    contactFields.clear();
                    contactFields.addAll(recordList_Temp);
                }
            }

            pw = contactFields[removalIndex_Temp];
            conPickValues.add(pw.fieldName);
            contactFields.remove(removalIndex_Temp);
            contactFieldsMap.put(pw.fieldName, pw);
        } else if (objectName == 'Account') {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == accountFields.size()) {
                    accountFields.clear();
                    accountFields.addAll(recordList_Temp);
                }
            }

            pw = accountFields[removalIndex_Temp];
            accPickValues.add(pw.fieldName);
            accountFields.remove(removalIndex_Temp);
            accountFieldsMap.put(pw.fieldName, pw);
        } else if (objectName == NamespacedRecurringDonation) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == RecurringGiftFields.size()) {
                    RecurringGiftFields.clear();
                    RecurringGiftFields.addAll(recordList_Temp);
                }
            }

            pw = RecurringGiftFields[removalIndex_Temp];
            rgfPickValues.add(pw.fieldName);
            RecurringGiftFields.remove(removalIndex_Temp);
            recGiftFieldsMap.put(pw.fieldName, pw);
        } else if (objectName == NamespacedGift) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == TransactionFields.size()) {
                    TransactionFields.clear();
                    TransactionFields.addAll(recordList_Temp);
                }
            }

            pw = TransactionFields[removalIndex_Temp];
            trnxPickValues.add(pw.fieldName);
            TransactionFields.remove(removalIndex_Temp);
            tranxFieldsMap.put(pw.fieldName, pw);
        } else if (objectName == NamespacedPayment) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == PaymentFields.size()) {
                    PaymentFields.clear();
                    PaymentFields.addAll(recordList_Temp);
                }
            }

            pw = PaymentFields[removalIndex_Temp];
            pymtPickValues.add(pw.fieldName);
            PaymentFields.remove(removalIndex_Temp);
            paymentFieldsMap.put(pw.fieldName, pw);
        } else if (objectName == NamespacedReceipt) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == ReceiptFields.size()) {
                    ReceiptFields.clear();
                    ReceiptFields.addAll(recordList_Temp);
                }
            }

            pw = ReceiptFields[removalIndex_Temp];
            rcptPickValues.add(pw.fieldName);
            ReceiptFields.remove(removalIndex_Temp);
            receiptFieldsMap.put(pw.fieldName, pw);
        } else if (objectName == NamespacedGiftDetail) {
            if (recordList_Temp != null && !recordList_Temp.isEmpty()) {
                if (recordList_Temp.size() == GiftDetailFields.size()) {
                    GiftDetailFields.clear();
                    GiftDetailFields.addAll(recordList_Temp);
                }
            }

            pw = GiftDetailFields[removalIndex_Temp];
            giftDetailPickValues.add(pw.fieldName);
            GiftDetailFields.remove(removalIndex_Temp);
            giftDetailFieldsMap.put(pw.fieldName, pw);
        }
    }

    public pageReference saveBatchPreset() {
        if (getPaymentTypePickListOptions().size() < 2) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select at least one Payment Type'));
            return null;
        }

        for (PresetWrapper each: GiftDetailFields) {
            String fldValue = String.valueOf(each.sObjectType.get(each.fieldName));
            if (fldValue != null && fldValue != '') {
                Campaign cmpgn;
                try {
                    List<Campaign> cmpgnList = new CampaignSelector().SelectIdAndRecordTypeNameById(new Set<Id> { fldValue } );
                    if (cmpgnList != null && cmpgnList.size() > 0) {
                        cmpgn = cmpgnList[0];
                    }
                } catch(Exception ex) {
                    //Do nothing
                }
                if (each.fieldName == NamespacedNewCampaign) {
                    if (cmpgn != null && cmpgn.RecordType != null && (cmpgn.RecordType.Name != 'Appeal' && cmpgn.RecordType.Name != 'Event')) { //madhu event validation
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select a valid Appeal record'));
                        return null;
                    }
                }
                if (each.fieldName == NamespacedCampaign) {
                    if (cmpgn != null && cmpgn.RecordType != null && cmpgn.RecordType.Name != 'Campaign') {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Select a valid Campaign record'));
                        return null;
                    }
                }
            }
        }

        try {
            if (template.Name == null || template.Name == '')
                throw new MyCustomException('Template Name can not be empty.');

            BatchPresetHelper_moc objBPXMLP = new BatchPresetHelper_moc();

            objBPXMLP.giftTypePicklistValues = giftTypePicklistValues;

            if (templateId != null && templateId != '') {
                SaveOrderListForAll();
                Batch_Template__c presetTemplate;
                List<Batch_Template__c> btList = new BatchTemplateSelector().SelectSObjectsById(new Set<Id> { string.escapeSingleQuotes(templateId) });
                if (btList != null && btList.size() > 0) {
                    presetTemplate = btList[0];
                }

                presetTemplate.Name = template.Name;
                presetTemplate.Type__c = template.Type__c;
                presetTemplate.Transaction_Type__c = template.Transaction_Type__c;

                presetTemplate.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields, null);
                presetTemplate.ContactFieldXml__c = objBPXMLP.writeXML('Contact', contactFields, null);
                presetTemplate.RecurringGiftFieldsXml__c = objBPXMLP.writeXML(NamespacedRecurringDonation, RecurringGiftFields, null);
                presetTemplate.TransactionFieldsXml__c = objBPXMLP.writeXML(NamespacedGift, TransactionFields, null);
                presetTemplate.PaymentFieldsXml__c = objBPXMLP.writeXML(NamespacedPayment, PaymentFields, paymentTypesSelected);
                presetTemplate.ReceiptFieldsXml__c = objBPXMLP.writeXML(NamespacedReceipt, ReceiptFields, null);
                presetTemplate.GiftDetailFieldsXml__c = objBPXMLP.writeXML(NamespacedGiftDetail, GiftDetailFields, null);

                DMLManager.UpdateSObject(presetTemplate);
            } else {
                SaveOrderListForAll();
                Batch_Template__c obj_BPT = new Batch_Template__c();
                obj_BPT.RecordTypeId = RT.Id;
                obj_BPT.Name = template.Name;
                obj_BPT.Type__c = template.Type__c;
                obj_BPT.Transaction_Type__c = template.Transaction_Type__c;

                obj_BPT.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields, null);
                obj_BPT.ContactFieldXml__c = objBPXMLP.writeXML('Contact', contactFields, null);
                obj_BPT.RecurringGiftFieldsXml__c = objBPXMLP.writeXML(NamespacedRecurringDonation, RecurringGiftFields, null);
                obj_BPT.TransactionFieldsXml__c = objBPXMLP.writeXML(NamespacedGift, TransactionFields, null);
                obj_BPT.PaymentFieldsXml__c = objBPXMLP.writeXML(NamespacedPayment, PaymentFields, paymentTypesSelected);
                obj_BPT.ReceiptFieldsXml__c = objBPXMLP.writeXML(NamespacedReceipt, ReceiptFields, null);
                obj_BPT.GiftDetailFieldsXml__c = objBPXMLP.writeXML(NamespacedGiftDetail, GiftDetailFields, null);
                obj_BPT.EventRegistrationsFieldsXml__c = objBPXMLP.writeXML(NamespacedEventRegistration, eventRegFields, null);

                DMLManager.InsertSObject(obj_BPT);
                templateId = obj_BPT.Id;
            }
            PageReference pageRef = new PageReference('/apex/' + PackageNamespace + 'EditBatchPreset_moc?id=' + templateId+'&msg=Batch Template has been saved!');
            pageRef.setRedirect(true);
            return pageRef;

        } catch (DMLException e) {
            ApexPages.addMessages(e);
            return null;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        return null;
    }

    public PageReference clonePresetTemplate() {
        isPresetSaved = false;

        template.Name = null;
        templateId = null;

        PageReference pageRef = new PageReference('/apex/' + PackageNamespace + 'EditBatchPreset_moc');
        pageRef.setRedirect(false);
        return pageRef;
    }

    public pageReference cancel() {
        PageReference pageRef = new PageReference('/apex/' + PackageNamespace + 'BatchPresets_moc');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public pageReference deletePreset() {
        if(templateId != null && templateId != '') {
            list<Batch_Template__c> presetTemplate = new BatchTemplateSelector().SelectIdNameById(new Set<Id> { string.escapeSingleQuotes(templateId) } );
            if(presetTemplate != null && presetTemplate.size() > 0 ) {
                DMLManager.DeleteSObjects(presetTemplate);
            }
            PageReference pageRef = new PageReference('/apex/' + PackageNamespace + 'BatchPresets_moc');
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }

    String templatelookupFieldId;
    public string getFieldId(String field_label, string objectName) {
        PageReference p;
        if (objectName == 'Gift Batch')
            p = new PageReference('/' + Gift_Batch__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1');

        if (objectName == 'Gift Detail')
            p = new PageReference('/' + Gift_Detail__c.SObjectType.getDescribe().getKeyPrefix() + '/e?nooverride=1');

        String html;
        if (!test.isrunningtest()) {
            html = p.getContent().toString();
        } else {
            html = 'test content';
        }
        Map < String, String > labelToId = new Map < String, String > ();
        Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
        while (m.find()) {
            String label = m.group(3);
            String id = m.group(1);
            if (label.containsIgnoreCase(field_label))
                return id;
        }
        return '';
    }

    public pageReference createNewBatch() {
        String key = Gift_Batch__c.SObjectType.getDescribe().getKeyPrefix();
        Schema.SObjectType schema_giftBatchObj = Schema.getGlobalDescribe().get(NamespacedGiftBatch);
        Map < String, Schema.SObjectField > fieldMap = schema_giftBatchObj.getDescribe().fields.getMap();
        string fieldLabelName;
        if (fieldMap.get(NamespacedTemplateName) != null) {
            fieldLabelName = fieldMap.get(NamespacedTemplateName).getDescribe().getlabel();
        } else {
            fieldLabelName = fieldMap.get('Template_Name__c').getDescribe().getlabel();
        }

        templatelookupFieldId = getFieldId(fieldLabelName, 'Gift Batch');
        String strTemplateName = EncodingUtil.urlEncode(template.name, 'UTF-8');
        PageReference pageRef;
        if (templatelookupFieldId != '' && templatelookupFieldId.contains('CF')) {
            pageRef = new PageReference('/' + key + '/e' + '?' + templatelookupFieldId + '=' + strTemplateName + '&' + templatelookupFieldId + '_lkid' + '=' + templateId);
        } else {
            pageRef = new PageReference('/' + key + '/e');
        }
        pageRef.setRedirect(true);
        return pageRef;
    }

    public string getNameById(string oName, string fValue, string FName) {
        list < string > ObjDescName = new list < string > ();
        List < sObject > sobjList = new List < sObject > ();
        ObjDescName.add(oName);
        Map < String, Schema.SObjectField > results = Schema.describeSObjects(ObjDescName)[0].fields.getMap();
        for (Schema.SObjectField f: results.values()) {
            Schema.DescribeFieldResult fieldDescr = f.getDescribe();
            if (fieldDescr.getName() == FName) {
              sobjList = new PaymentSelector().SelectNameByPaymentId(fValue);
                if (sobjList.size() > 0) {
                    String parentName = String.valueOf(sobjList[0].getSObject(fieldDescr.getRelationshipName()).get('Name'));
                    return parentName;
                }
                return null;
            }
        }
        return null;
    }

    public Date protectedDateParse(string vl) {
        Date dt = null;
        try {
            dt = date.valueOf(vl);
        } catch (Exception ex) {}

        if (dt == null) {

            dt = date.today();
        }
        return dt;
    }

    public string protectedDateFormat(string suspisousDateStr) {
        Date dt = protectedDateParse(suspisousDateStr);
        List < Integer > li = new List < Integer > { dt.month(), dt.day(), dt.year() };
        return string.join(li, '/');
    }

    public pagereference createCSV() {
        if(RedirectByTheme()!=null) return RedirectByTheme();

        for (PresetWrapper con: contactFields) {
            if (con.fieldType == 'REFERENCE') {
                if (con.fieldValue != con.fieldName && con.fieldValue != null) {
                    string pname = getNameById('Contact', con.fieldValue, con.fieldName);
                    if (pname != null) {
                        con.fieldValue = pname;
                    } else {
                        con.fieldValue = '';
                    }
                }
            }
            if ((con.fieldType == 'DATE' || con.fieldType == 'DATE/TIME') && con.fieldValue != null) {
                con.fieldValue = protectedDateFormat(con.fieldValue);
            }
        }

        for (PresetWrapper acc: accountFields) {
            if (acc.fieldType == 'REFERENCE') {
                if (acc.fieldValue != acc.fieldName && acc.fieldValue != null) {
                    string pname = getNameById('Account', acc.fieldValue, acc.fieldName);
                    if (pname != null) {
                        acc.fieldValue = pname;
                    }
                }
            }
            if ((acc.fieldType == 'DATE' || acc.fieldType == 'DATE/TIME') && acc.fieldValue != null) {
                acc.fieldValue = protectedDateFormat(acc.fieldValue);
            }
        }

        for (PresetWrapper RG: RecurringGiftFields) {
            if (RG.fieldType == 'REFERENCE') {
                if (RG.fieldValue != RG.fieldName && RG.fieldValue != null) {
                    string pname = getNameById(PackageNamespace + 'Recurring_Donation__c', RG.fieldValue, RG.fieldName);
                    if (pname != null) {
                        RG.fieldValue = pname;
                    }
                }
            }
            if ((RG.fieldType == 'DATE' || RG.fieldType == 'DATE/TIME') && RG.fieldValue != null) {
                RG.fieldValue = protectedDateFormat(RG.fieldValue);
            }
        }

        for (PresetWrapper tran: TransactionFields) {
            if (tran.fieldType == 'REFERENCE') {
                if (tran.fieldValue != tran.fieldName && tran.fieldValue != null) {
                    string pname = getNameById(PackageNamespace + 'Gift__c', tran.fieldValue, tran.fieldName);
                    if (pname != null) {
                        tran.fieldValue = pname;
                    }
                }
            }
            if ((tran.fieldType == 'DATE' || tran.fieldType == 'DATE/TIME') && tran.fieldValue != null) {
                tran.fieldValue = protectedDateFormat(tran.fieldValue);
            }
        }

        for (PresetWrapper pay: PaymentFields) {
            if (pay.fieldType == 'REFERENCE') {
                if (pay.fieldValue != pay.fieldName && pay.fieldValue != null) {
                    string pname = getNameById(PackageNamespace + 'Payment__c', pay.fieldValue, pay.fieldName);
                    if (pname != null) {
                        pay.fieldValue = pname;
                    }
                }
            }
            if ((pay.fieldType == 'DATE' || pay.fieldType == 'DATE/TIME') && pay.fieldValue != null) {
                pay.fieldValue = protectedDateFormat(pay.fieldValue);
            }
        }

        for (PresetWrapper recei: ReceiptFields) {
            if (recei.fieldType == 'REFERENCE') {
                if (recei.fieldValue != recei.fieldName && recei.fieldValue != null) {
                    string pname = getNameById(PackageNamespace + 'Receipt__c', recei.fieldValue, recei.fieldName);
                    if (pname != null) {
                        recei.fieldValue = pname;
                    }
                }
            }
            if ((recei.fieldType == 'DATE' || recei.fieldType == 'DATE/TIME') && recei.fieldValue != null) {
                recei.fieldValue = protectedDateFormat(recei.fieldValue);
            }
        }

        for (PresetWrapper alloc: GiftDetailFields) {
            if (alloc.fieldType == 'REFERENCE') {
                if (alloc.fieldValue != alloc.fieldName && alloc.fieldValue != null) {
                    string pname = getNameById(PackageNamespace + 'Fund__c', alloc.fieldValue, alloc.fieldName);
                    if (pname != null) {
                        alloc.fieldValue = pname;
                    }
                }
            }
            if ((alloc.fieldType == 'DATE' || alloc.fieldType == 'DATE/TIME') && alloc.fieldValue != null) {
                alloc.fieldValue = protectedDateFormat(alloc.fieldValue);
            }
        }
        return null;
    }

    public void contactSort(List < PresetWrapper > conFields) {
        for (integer i = 0; i < conFields.size(); i++) {
            if (conFields[i].fieldName == 'FirstName') {
                PresetWrapper conIndex = contactFields[0];
                contactFields[0] = conFields[i];
                contactFields[i] = conIndex;
            }
            if (conFields[i].fieldName == 'LastName') {
                PresetWrapper conIndex = contactFields[1];
                contactFields[1] = conFields[i];
                contactFields[i] = conIndex;
            }
        }
    }

    public void sortBillingAddressFields(List < PresetWrapper > conFields, Boolean isContact, Boolean isACH) {
        Map < String, Integer > addressFieldMap = isContact ? conAddressFields : accAddressFields;
        List < PresetWrapper > sortedAddFields = new PresetWrapper[addressFieldMap.size()];

        for (integer i = 0; i < conFields.size(); i++) {
            if (conFields[i].fieldName == 'Phone' && isBillingAddressReq && isACH) {
                conFields[i].isRequired = true;
            }
            Integer indx = addressFieldMap.get(conFields[i].fieldName);
            if (indx != null) {
                sortedAddFields.set(indx, conFields.remove(i));
                i--;
                sortedAddFields[indx].isRequired = isBillingAddressReq ? true : sortedAddFields[indx].isRequired;
            }
        }
        for (integer i = 0; i < sortedAddFields.size(); i++) {
            if (sortedAddFields[i] == null) {
                sortedAddFields.remove(i);
            }
        }
        conFields.addAll(sortedAddFields);
    }

    public class MyCustomException extends exception {}

    public string btemptype { get; set; }
    public List < SelectOption > getTemplateType() {
        List < SelectOption > options = new List < SelectOption > ();
        Schema.DescribeFieldResult fieldResult = Batch_Template__c.fields.Type__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple)
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        return options;
    }

    public List < SelectOption > getTemplateTranType() {
        List < SelectOption > options = new List < SelectOption > ();
        Schema.DescribeFieldResult fieldResult = Batch_Template__c.fields.Transaction_Type__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f: ple)
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        return options;
    }
    public Map < string, list < string >> contactPicklistFieldValue { get;
        set; }

    public Map < string, list < string >> getPicklistCon() {

        List < string > fieldApi = new List < string > ();
        fieldApi.add(PackageNamespace + 'Donor_Level__c');
        fieldApi.add(PackageNamespace + 'Donor_Status__c');
        fieldApi.add(PackageNamespace + 'Education_Level__c');
        fieldApi.add(PackageNamespace + 'Gender__c');

        fieldApi.add(PackageNamespace + 'Household_Role__c');
        fieldApi.add(PackageNamespace + 'Receipt_Preference__c');
        fieldApi.add(PackageNamespace + 'Region__c');
        fieldApi.add('Salutation');

        contactPicklistFieldValue = new Map < string, list < string >> ();
        List < String > donorleveloptions = new List < String > ();
        List < String > donorstatusoptions = new List < String > ();
        List < String > educationleveloptions = new List < string > ();
        List < String > genderoptions = new List < string > ();
        List < String > householdroleoptions = new List < string > ();
        List < String > receiptpreferenceoptions = new List < string > ();
        List < String > regionoptions = new List < string > ();
        List < String > salutationoptions = new List < string > ();
        List < String > tradestatusoptions = new List < string > ();

        Schema.DescribeFieldResult donorlevel = contact.fields.Donor_Level__c.getDescribe();
        List < Schema.PicklistEntry > donorpvalue = donorlevel.getPicklistValues();

        for (Schema.PicklistEntry donorpv: donorpvalue)
            donorleveloptions.add(String.valueOf(donorpv.getLabel()));

        contactPicklistFieldValue.put(PackageNamespace + 'Donor_Level__c', donorleveloptions);

        Schema.DescribeFieldResult donorstatus = contact.fields.Donor_Status__c.getDescribe();
        List < Schema.PicklistEntry > donorstatuspval = donorstatus.getPicklistValues();

        for (Schema.PicklistEntry pval: donorstatuspval)
            donorstatusoptions.add(String.valueOf(pval.getLabel()));
        
        contactPicklistFieldValue.put(PackageNamespace + 'Donor_Status__c', donorstatusoptions);

        Schema.DescribeFieldResult educationlevel = contact.fields.Education_Level__c.getDescribe();
        List < Schema.PicklistEntry > educationlevelpval = educationlevel.getPicklistValues();

        for (Schema.PicklistEntry pval: educationlevelpval)
            educationleveloptions.add(String.valueOf(pval.getLabel()));
        
        contactPicklistFieldValue.put(PackageNamespace + 'Education_Level__c', educationleveloptions);

        Schema.DescribeFieldResult gender = contact.fields.Gender__c.getDescribe();
        List < Schema.PicklistEntry > genderpval = educationlevel.getPicklistValues();

        for (Schema.PicklistEntry pval: genderpval)
            genderoptions.add(String.valueOf(pval.getLabel()));
        
        contactPicklistFieldValue.put(PackageNamespace + 'Gender__c', genderoptions);

        Schema.DescribeFieldResult householdrole = contact.fields.Household_Role__c.getDescribe();
        List < Schema.PicklistEntry > householdpval = householdrole.getPicklistValues();

        for (Schema.PicklistEntry pval: householdpval)
            householdroleoptions.add(String.valueOf(pval.getLabel()));
        
        contactPicklistFieldValue.put(PackageNamespace + 'Household_Role__c', householdroleoptions);

        Schema.DescribeFieldResult receiptpref = contact.fields.Receipt_Preference__c.getDescribe();
        List < Schema.PicklistEntry > receiptprefpval = receiptpref.getPicklistValues();

        for (Schema.PicklistEntry pval: receiptprefpval)
            receiptpreferenceoptions.add(String.valueOf(pval.getLabel()));
        
        contactPicklistFieldValue.put(PackageNamespace + 'Receipt_Preference__c', receiptpreferenceoptions);

        Schema.DescribeFieldResult region = contact.fields.Region__c.getDescribe();
        List < Schema.PicklistEntry > regionpval = receiptpref.getPicklistValues();

        for (Schema.PicklistEntry pval: regionpval)
            regionoptions.add(String.valueOf(pval.getLabel()));
        
        contactPicklistFieldValue.put(PackageNamespace + 'Region__c', regionoptions);

        Schema.DescribeFieldResult salutation = contact.fields.Salutation.getDescribe();
        List < Schema.PicklistEntry > salutationpval = salutation.getPicklistValues();
        for (Schema.PicklistEntry pval: salutationpval)
            salutationoptions.add(String.valueOf(pval.getLabel()));
        contactPicklistFieldValue.put('Salutation', salutationoptions);
        Schema.DescribeFieldResult tradestatus = contact.fields.Trade_Status__c.getDescribe();
        List < Schema.PicklistEntry > tradestatuspval = tradestatus.getPicklistValues();
        for (Schema.PicklistEntry pval: tradestatuspval)
            tradestatusoptions.add(String.valueOf(pval.getLabel()));
        contactPicklistFieldValue.put(PackageNamespace + 'Trade_Status__c', tradestatusoptions);
        return contactPicklistFieldValue;
    }

    public Map < string, list < string >> accountPicklistFieldValue { get; set; }
    public Map < string, list < string >> getPicklistAcc() {
        accountPicklistFieldValue = new Map < string, list < string >> ();
        List < String > ratingoptions = new List < String > ();
        List < String > typeoptions = new List < String > ();
        List < String > activeoptions = new List < String > ();
        List < String > induoptions = new List < String > ();
        List < String > accstoptions = new List < String > ();
        List < String > ownoptions = new List < String > ();
        List < String > regionoptions = new List < String > ();
        List < String > trstatusoptions = new List < String > ();
        List < String > customerprioptions = new List < String > ();

        Schema.DescribeFieldResult rating = account.fields.Rating.getDescribe();
        List < Schema.PicklistEntry > ratingpval = rating.getPicklistValues();

        for (Schema.PicklistEntry pval: ratingpval)
            ratingoptions.add(String.valueOf(pval.getLabel()));

        accountPicklistFieldValue.put('Rating', ratingoptions);

        Schema.DescribeFieldResult type = account.fields.Type.getDescribe();
        List < Schema.PicklistEntry > typepval = type.getPicklistValues();

        for (Schema.PicklistEntry pval: typepval)
            typeoptions.add(String.valueOf(pval.getLabel()));

        accountPicklistFieldValue.put('Type', typeoptions);

        Schema.DescribeFieldResult active = account.fields.Active__c.getDescribe();
        List < Schema.PicklistEntry > activepval = active.getPicklistValues();

        for (Schema.PicklistEntry pval: activepval)
            activeoptions.add(String.valueOf(pval.getLabel()));

        accountPicklistFieldValue.put(PackageNamespace + 'Active__c', activeoptions);

        Schema.DescribeFieldResult Industry = account.fields.Industry.getDescribe();
        List < Schema.PicklistEntry > Industrypval = Industry.getPicklistValues();

        for (Schema.PicklistEntry pval: Industrypval)
            induoptions.add(String.valueOf(pval.getLabel()));

        accountPicklistFieldValue.put('Industry', induoptions);

        Schema.DescribeFieldResult accsource = account.fields.AccountSource.getDescribe();
        List < Schema.PicklistEntry > accsourcepval = accsource.getPicklistValues();

        for (Schema.PicklistEntry pval: Industrypval)
            accstoptions.add(String.valueOf(pval.getLabel()));

        accountPicklistFieldValue.put('AccountSource', accstoptions);

        Schema.DescribeFieldResult ownership = account.fields.Ownership.getDescribe();
        List < Schema.PicklistEntry > ownershippval = ownership.getPicklistValues();

        for (Schema.PicklistEntry pval: ownershippval)
            ownoptions.add(String.valueOf(pval.getLabel()));

        accountPicklistFieldValue.put('Ownership', ownoptions);

        Schema.DescribeFieldResult Region = account.fields.Region__c.getDescribe();
        List < Schema.PicklistEntry > Regionppval = Region.getPicklistValues();

        for (Schema.PicklistEntry pval: Regionppval)
            regionoptions.add(String.valueOf(pval.getLabel()));

        accountPicklistFieldValue.put(PackageNamespace + 'Region__c', regionoptions);

        Schema.DescribeFieldResult tradesta = account.fields.Trade_Status__c.getDescribe();
        List < Schema.PicklistEntry > tradestappval = tradesta.getPicklistValues();

        for (Schema.PicklistEntry pval: tradestappval)
            trstatusoptions.add(String.valueOf(pval.getLabel()));

        accountPicklistFieldValue.put(PackageNamespace + 'Trade_Status__c', trstatusoptions);

        Schema.DescribeFieldResult custpri = account.fields.CustomerPriority__c.getDescribe();
        List < Schema.PicklistEntry > custpripval = custpri.getPicklistValues();

        for (Schema.PicklistEntry pval: custpripval)
            customerprioptions.add(String.valueOf(pval.getLabel()));

        accountPicklistFieldValue.put(PackageNamespace + 'CustomerPriority__c', customerprioptions);

        return accountPicklistFieldValue;
    }
    public Map < string, list < string >> recorringPicklistFieldValue { get;
        set; }
    public Map < string, list < string >> getPicklistRecorringDonation() {
        recorringPicklistFieldValue = new Map < string, list < string >> ();
        List < String > freqoptions = new List < String > ();

        Schema.DescribeFieldResult frequency = Recurring_Donation__c.fields.Frequency__c.getDescribe();
        List < Schema.PicklistEntry > frequencypval = frequency.getPicklistValues();

        for (Schema.PicklistEntry pval: frequencypval)
            freqoptions.add(String.valueOf(pval.getLabel()));

        recorringPicklistFieldValue.put(PackageNamespace + 'Frequency__c', freqoptions);
        return recorringPicklistFieldValue;
    }

    public Map < string, list < string >> giftPicklistFieldValue { get; set; }
    public Map < string, list < string >> getPicklistGift() {
        giftPicklistFieldValue = new Map < string, list < string >> ();
        List < String > trinomoptions = new List < String > ();
        List < String > tritypeoptions = new List < String > ();
        List < String > statusoptions = new List < String > ();
        List < String > sourceoptions = new List < String > ();
        List < String > gifttypeoptions = new List < String > ();
        List < String > recetypeoptions = new List < String > ();

        List < String > channeloptions = new List < String > ();
        Schema.DescribeFieldResult channel = Gift__c.fields.Channel__c.getDescribe();
        List < Schema.PicklistEntry > channelpval = channel.getPicklistValues();

        for (Schema.PicklistEntry pval: channelpval)
            channeloptions.add(String.valueOf(pval.getLabel()));

        giftPicklistFieldValue.put(PackageNamespace + 'Channel__c', channeloptions);

        Schema.DescribeFieldResult receipttype = Gift__c.fields.Receipt_Type__c.getDescribe();
        List < Schema.PicklistEntry > receipttypepval = receipttype.getPicklistValues();

        for (Schema.PicklistEntry pval: receipttypepval)
            recetypeoptions.add(String.valueOf(pval.getLabel()));

        giftPicklistFieldValue.put(PackageNamespace + 'Receipt_Type__c', recetypeoptions);

        Schema.DescribeFieldResult gifttype = Gift__c.fields.Gift_Type__c.getDescribe();
        List < Schema.PicklistEntry > gifttypepval = gifttype.getPicklistValues();

        for (Schema.PicklistEntry pval: gifttypepval)
            gifttypeoptions.add(String.valueOf(pval.getLabel()));

        giftPicklistFieldValue.put(PackageNamespace + 'Gift_Type__c', gifttypeoptions);

        Schema.DescribeFieldResult source = Gift__c.fields.Source__c.getDescribe();
        List < Schema.PicklistEntry > sourcepval = source.getPicklistValues();

        for (Schema.PicklistEntry pval: sourcepval)
            sourceoptions.add(String.valueOf(pval.getLabel()));

        giftPicklistFieldValue.put(PackageNamespace + 'Source__c', sourceoptions);

        Schema.DescribeFieldResult status = Gift__c.fields.Status__c.getDescribe();
        List < Schema.PicklistEntry > statuspval = status.getPicklistValues();

        for (Schema.PicklistEntry pval: statuspval)
            statusoptions.add(String.valueOf(pval.getLabel()));

        giftPicklistFieldValue.put(PackageNamespace + 'Status__c', statusoptions);

        Schema.DescribeFieldResult tributetype = Gift__c.fields.Tribute_Type__c.getDescribe();
        List < Schema.PicklistEntry > tributetypepval = tributetype.getPicklistValues();

        for (Schema.PicklistEntry pval: tributetypepval)
            tritypeoptions.add(String.valueOf(pval.getLabel()));

        giftPicklistFieldValue.put(PackageNamespace + 'Tribute_Type__c', tritypeoptions);

        Schema.DescribeFieldResult tributenotimethod = Gift__c.fields.Tribute_Notification_Method__c.getDescribe();
        List < Schema.PicklistEntry > tributenotimethpval = tributenotimethod.getPicklistValues();

        for (Schema.PicklistEntry pval: tributenotimethpval)
            trinomoptions.add(String.valueOf(pval.getLabel()));

        giftPicklistFieldValue.put(PackageNamespace + 'Tribute_Notification_Method__c', trinomoptions);

        return recorringPicklistFieldValue;
    }

    public Map < string, list < string >> paymentPicklistFieldValue { get; set; }
    public Map < string, list < string >> getPicklistpayment() {
        paymentPicklistFieldValue = new Map < string, list < string >> ();
        List < String > giftaidoptions = new List < String > ();
        List < String > paymenttypeoptions = new List < String > ();
        List < String > cardtypeoptions = new List < String > ();
        List < String > acctypeoptions = new List < String > ();

        Schema.DescribeFieldResult giftaid = Payment__c.fields.Gift_Aid_Claim_Status__c.getDescribe();
        List < Schema.PicklistEntry > giftaidpval = giftaid.getPicklistValues();

        for (Schema.PicklistEntry pval: giftaidpval)
            giftaidoptions.add(String.valueOf(pval.getLabel()));

        paymentPicklistFieldValue.put(PackageNamespace + 'Gift_Aid_Claim_Status__c', giftaidoptions);

        Schema.DescribeFieldResult paymenttype = Payment__c.fields.Payment_Type__c.getDescribe();
        List < Schema.PicklistEntry > paymenttypepval = paymenttype.getPicklistValues();

        for (Schema.PicklistEntry pval: paymenttypepval)
            paymenttypeoptions.add(String.valueOf(pval.getLabel()));

        paymentPicklistFieldValue.put(PackageNamespace + 'Payment_Type__c', paymenttypeoptions);

        Schema.DescribeFieldResult cardtype = Payment__c.fields.Credit_Card_Type__c.getDescribe();
        List < Schema.PicklistEntry > cardtypepval = cardtype.getPicklistValues();

        for (Schema.PicklistEntry pval: cardtypepval)
            cardtypeoptions.add(String.valueOf(pval.getLabel()));

        paymentPicklistFieldValue.put(PackageNamespace + 'Credit_Card_Type__c', cardtypeoptions);

        Schema.DescribeFieldResult acctype = Payment__c.fields.Account_Type__c.getDescribe();
        List < Schema.PicklistEntry > acctypepval = acctype.getPicklistValues();

        for (Schema.PicklistEntry pval: acctypepval)
            acctypeoptions.add(String.valueOf(pval.getLabel()));

        paymentPicklistFieldValue.put(PackageNamespace + 'Account_Type__c', acctypeoptions);
        return paymentPicklistFieldValue;
    }

    public Map < string, list < string >> reciptPicklistFieldValue { get;
        set; }
    public Map < string, list < string >> getPicklistRecipt() {
        reciptPicklistFieldValue = new Map < string, list < string >> ();
        List < String > statusoptions = new List < String > ();

        Schema.DescribeFieldResult status = Receipt__c.fields.Status__c.getDescribe();
        List < Schema.PicklistEntry > statuspval = status.getPicklistValues();

        for (Schema.PicklistEntry pval: statuspval)
            statusoptions.add(String.valueOf(pval.getLabel()));

        reciptPicklistFieldValue.put(PackageNamespace + 'Status__c', statusoptions);
        return reciptPicklistFieldValue;
    }

    public string recordName { get;
        set; }
    public string recordId { get;
        set; }

    public void preparelookupname() {
        lookupIds.put(Id.valueof(recordId), recordName);

    }

    public List < String > getConstituentCodes() {
        List < String > concodeoptions = new List < String > ();
        Schema.DescribeFieldResult conscode = Contact.fields.Constituent_Codes__c.getDescribe();
        List < Schema.PicklistEntry > concodepval = conscode.getPicklistValues();

        for (Schema.PicklistEntry pval: concodepval)
            concodeoptions.add(String.valueOf(pval.getLabel()));
        return concodeoptions;
    }

    public List < String > getSolicitCodes() {

        List < String > solicodeoptions = new List < String > ();
        Schema.DescribeFieldResult solicode = Contact.fields.Solicit_Codes__c.getDescribe();
        List < Schema.PicklistEntry > solicodepval = solicode.getPicklistValues();

        for (Schema.PicklistEntry pval: solicodepval)
            solicodeoptions.add(String.valueOf(pval.getLabel()));
        return solicodeoptions;
    }

    public List < String > getAccConstituCodes() {
        List < String > concodeoptions = new List < String > ();
        Schema.DescribeFieldResult conscode = Account.fields.Constituent_Codes__c.getDescribe();
        List < Schema.PicklistEntry > concodepval = conscode.getPicklistValues();

        for (Schema.PicklistEntry pval: concodepval)
            concodeoptions.add(String.valueOf(pval.getLabel()));
        return concodeoptions;
    }

    public List < String > getAccSolicitCodes() {
        List < String > solicodeoptions = new List < String > ();
        Schema.DescribeFieldResult solicode = Account.fields.Solicit_Codes__c.getDescribe();
        List < Schema.PicklistEntry > solicodepval = solicode.getPicklistValues();

        for (Schema.PicklistEntry pval: solicodepval)
            solicodeoptions.add(String.valueOf(pval.getLabel()));
        return solicodeoptions;
    }

    public List < String > getHowDidYouHearAboutUs() {
        List < String > options = new List < String > ();
        Schema.DescribeFieldResult aboutus = contact.fields.How_Did_You_Hear_About_Us__c.getDescribe();
        List < Schema.PicklistEntry > aboutuspval = aboutus.getPicklistValues();

        for (Schema.PicklistEntry pval: aboutuspval)
            options.add(String.valueOf(pval.getLabel()));

        return options;
    }

    public List < String > getSuffix() {
        List < String > options = new List < String > ();
        Schema.DescribeFieldResult suffixs = contact.fields.Suffix__c.getDescribe();
        List < Schema.PicklistEntry > suffixspval = suffixs.getPicklistValues();

        for (Schema.PicklistEntry pval: suffixspval)
            options.add(String.valueOf(pval.getLabel()));

        return options;
    }

}