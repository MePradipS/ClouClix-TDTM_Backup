public with sharing class Payment extends RedirectController {
    public static String PackageNamespace {
        get {
            if (PackageNamespace == null) {
                String namespace = Utilities.getCurrentNamespace();
                PackageNamespace = String.isEmpty(namespace) ? '' : (namespace + '__');
            }
            return PackageNamespace;
        }
        set;
    }

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

    public PageReference submitPayment() {
        BatchGateway4.TransactionResult result;
        try
        {
           result = submit(Payment, Payment.Donation__c);
        }
        catch(Exception ex)
        {
           shouldSubmit = false;
           Payment.Status__c = 'Declined';
           Payment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
           DMLManager.UpdateSObject(Payment);
        }

        shouldSubmit = false;

        if (result.TransactionStatus == 'success') {
            Payment.Authorization__c = result.ApprovalCode;
            Payment.CC_Reference__c = result.TransactionId;
            Payment.Status__c = result.TransactionStatus == null || result.TransactionStatus != 'success' ? 'Declined' : 'Approved';
            if ((result.TransactionId == null || result.TransactionId == '') && result.TransactionStatus == 'success') Payment.Amount__c = 0;

            Payment.CC_Transaction_Date__c = Date.today();
            Payment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);
           Payment.Status__c = 'Approved';
           Payment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);
           DMLManager.UpdateSObject(Payment);
           return cancelAll();
        }
        else
           return null;
    }

    public BatchGateway4.TransactionResult submit(Payment__c p, string gId) {
        BatchSettings__c BatchSettings = null;
        List<BatchSettings__c> settingList = new BatchSettingsSelector().SelectSObjectsByName('Default');
        if (settingList != null && settingList.size()>0)
           BatchSettings = settingList[0];
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

        BatchGateway4.PaymentInfo payment = new BatchGateway4.PaymentInfo();
        payment.donationType = 'IND';

        payment.billingStartDate = date.today();
        payment.numberOfPayments = '';
        payment.isIndividual = true;
        payment.isRecurring = false;
        payment.constituentType ='Existing';
        payment.amount = p.Amount__c.format();
        payment.creditCardNumber = p.Credit_Card_Number__c;
        payment.creditCardType = p.Credit_Card_Type__c;
        payment.cvv2 = ccCVV;
        payment.currencyType = BatchSettings.CurrencyCode__c;
        payment.expiryMonth = tryParseToInt(ccExpM);
        payment.expiryYear = tryParseToInt(ccExpY);
        payment.giftId = gid;
        payment.paymentId = p.Id;
        form.payments.payment.add(payment);
        BatchGateway4.ArrayOfTransactionResult txResults = new BatchGateway4.ArrayOfTransactionResult();
        txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0', '');
        if (txResults!=null && txResults.TransactionResult!=null && txResults.TransactionResult.size()>0) {
          return txResults.TransactionResult[0];
        }
        else
          return null;
    }

    public integer tryParseToInt(String txt)
    {
        integer result = 0;
        try {
            result = integer.valueOf(txt);
        }
        catch(Exception ex) {

        }

        return result;
    }

    public String PaymentId {get; set;}
    public String Url {get;set;}
    public String Msg {get; set;}
    public Payment__c Payment {get;set;}
    public Boolean HasError {get; set;}
    public List<Gift_Detail__c> AllocationList { get; set; }
    public List<Schema.FieldSetMember> PaymentFieldList {get; set;}
    public List<Schema.FieldSetMember> AllocationFieldList {get; set;}
    public List<Gift_Detail__c> DelAllocationList {get; set;}
    public List<Gift_Detail__c> UpsertAllocationList {get; set;}
    public boolean shouldSubmit { get; set; }
    public String TransactionId {get; set;}
    public String FundKeyPrefix {get; set;}

    public String PaymentRequiredFields {
        get{
            return ', Date__c, Amount__c, Status__c, Payment_Type__c, Donation__c';
        }
    }

    public String Aviliableinfieldset {
           get{
            return ', Credit_Card_Type__c, Credit_Card_Number__c, Description__c, Cheque_Num__c, Date_Deposited__c, Cheque_Date__c  ';
        }
    }

    public String AllocationRequiredFields {
        get{
            return ', New_Campaign__c, Fund__c, Amount__c, Allocation_Date__c, Payment__c, Gift__c';
        }
    }

    public string localeDateFormatVal {get;set;}
    public Map<String, Schema.SObjectType> getschemaDesc (){return Schema.getGlobalDescribe();}
    public String user_locale {get;set;}
    public Payment(ApexPages.StandardController stdController) {
        super(stdController, true);
        Payment = (Payment__c)stdController.getRecord();
        setKeyPrefix();
        setPaymentFieldList();
        setAllocationFieldList();
        setPayment();
        setAllocationList();
        shouldSubmit = false;

        user_locale = UserInfo.getLocale();
        LocaleFormattedDateContrl localeFDC = new LocaleFormattedDateContrl();
        localeDateFormatVal = localeFDC.getDateLocale(UserInfo.getLocale());
        createPaymentStaticFieldsToRender();
        createPaymentFieldsToRender();

        ccExpM = 'Jan';
        ccExpY = String.valueOf(Date.Today().Year()+0);
        reFreshAllocationShowHideRequiredFieldMap();

    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

    public void reFreshAllocationShowHideRequiredFieldMap(){
        allocationShowHideRequiredFieldMap = new map<string,boolean>();
        integer allocationShowHideRequiredFielCount = 0;
        for(Gift_Detail__c gd : AllocationList){
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Amount',false);
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Date',false);
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Appeal',false);
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Fund',false);
            allocationShowHideRequiredFielCount++;
        }
    }

    public map<string,list<string>> paymentTypeFieldsMap {get;set;}
    public list<string> paymentFieldList1;
    public list<list<string>> paymentFieldListOfList1 {get;set;}

    public list<string> paymentFieldList2;
    public list<list<string>> paymentFieldListOfList2 {get;set;}

    public list<string> paymentTypeList {get;set;}

    public void createPaymentStaticFieldsToRender(){
        paymentFieldList1 = new list<string>();
        paymentFieldList1.add('Donation__c');
        if(Payment.Payment_Type__c == 'Credit Card' && !string.isBlank(PaymentId)){
            paymentFieldList1.add('Amount__c');
            paymentFieldList1.add('Date__c');
            paymentFieldList1.add('Payment_Type__c');
        }
        paymentFieldListOfList1 = createListOfList(paymentFieldList1);
    }

    public void createPaymentFieldsToRender(){
        paymentFieldList2 = new list<string>();
        if(Payment.Payment_Type__c != 'Credit Card' || PaymentId == ''){
            paymentFieldList2.add('Amount__c');
            paymentFieldList2.add('Date__c');
        }
        paymentFieldList2.add('Payment_Type__c');
        if(Payment.Payment_Type__c == 'Credit Card' && Payment.Status__c == 'Approved'){
            paymentFieldList2.add('Credit_Card_Type__c');
            paymentFieldList2.add('Credit_Card_Number__c');
            paymentFieldList2.add('Credit Card Expiry');
            paymentFieldList2.add('CVV');
        }
        if(Payment.Payment_Type__c == 'Credit Card' && Payment.Status__c != 'Approved'){
            paymentFieldList2.add('Credit_Card_Type__c');
            paymentFieldList2.add('Credit_Card_Number__c');
            paymentFieldList2.add('Credit Card Expiry');
            paymentFieldList2.add('CVV');
        }

        if(Payment.Payment_Type__c == 'Credit Card - Offline'){
            paymentFieldList2.add('Credit_Card_Type__c');
            paymentFieldList2.add('Date_Deposited__c');
            paymentFieldList2.add('Status__c');
        }

        if(Payment.Payment_Type__c == 'Check' || Payment.Payment_Type__c == 'Cheque'){
            paymentFieldList2.add('Cheque_Num__c');
            paymentFieldList2.add('Cheque_Date__c');
            paymentFieldList2.add('Date_Deposited__c');
            paymentFieldList2.add('Status__c');
        }

        if(Payment.Payment_Type__c == 'Cash' || Payment.Payment_Type__c == 'Stock' || Payment.Payment_Type__c == 'Other'){
            paymentFieldList2.add('Date_Deposited__c');
            paymentFieldList2.add('Status__c');
        }
        paymentFieldList2.add('Description__c');
        paymentFieldList2.add('Transit_Number__c');

        paymentFieldListOfList2 = createListOfList(paymentFieldList2);
    }

    public list<list<string>> createListOfList(list<string> fieldList){
        list<list<string>> fieldListOfList = new list<list<string>>();
        if(fieldList != null && !fieldList.isEmpty()){
            list<string> fieldListTemp = new list<string>();
            for(string str : fieldList){
                fieldListTemp.add(str);
                if(fieldListTemp.size() == 2){
                    fieldListOfList.add(fieldListTemp);
                    fieldListTemp = new list<string>();
                }
            }
            if(fieldListTemp.size() == 1){
                fieldListOfList.add(fieldListTemp);
            }
        }
        return fieldListOfList;
    }

    public Payment(String strTransactionId) {
        super(true);
        shouldSubmit = false;
        TransactionId = strTransactionId;
        setKeyPrefix();
        setPaymentFieldList();
        setAllocationFieldList();
        setPayment();
        setAllocationList();
    }

    public void setKeyPrefix(){
        Schema.DescribeSObjectResult fund = Fund__c.sObjectType.getDescribe();
        FundKeyPrefix = fund.getKeyPrefix();
    }

    public void setPaymentFieldList() {
        PaymentFieldList = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> pfl = SObjectType.Payment__c.FieldSets.Single_Transation_Custom_Fields.getFields();
        for(Schema.FieldSetMember f : pfl) {
            if(!PaymentRequiredFields.contains(f.getFieldPath())) {
                PaymentFieldList.add(f);
            }
        }
    }

    public void setAllocationFieldList() {
        AllocationFieldList = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> afl = SObjectType.Gift_Detail__c.FieldSets.allocation.getFields();
        for(Schema.FieldSetMember f : afl) {
            if(!AllocationRequiredFields.contains(f.getFieldPath())){
                AllocationFieldList.add(f);
            }
        }
    }

    public void setPayment() {
        if(PaymentId == null){
            Url = ApexPages.currentPage().getParameters().get('Url');
            PaymentId = ApexPages.currentPage().getParameters().get('Id');
        }
        if(PaymentId != null && !PaymentId.equals('')){
            String fields = 'Id, Credit_Card_Type__c, Credit_Card_Number__c, Description__c, Cheque_Num__c, Date_Deposited__c, Cheque_Date__c';
            for(Schema.FieldSetMember f : PaymentFieldList) {
               if((!Aviliableinfieldset.contains(f.getFieldPath()))) {
                fields += f.getFieldPath() + ', ';
                }
            }
            fields += PaymentRequiredFields;
            string whereClause = 'id=\'' + string.escapeSingleQuotes(PaymentId) + '\' LIMIT 1';

            Payment = (Payment__c)new GenericQueryBuilder().ObjectQueryBuilderWhere('Payment__c', fields, whereClause);
        }else{
            if(TransactionId == null){
                TransactionId = ApexPages.currentPage().getParameters().get('TransactionId');
            }
            Payment = new Payment__c();
            Payment.Donation__c = TransactionId;
            Payment.Payment_Type__c = '';
            Payment.Date_Deposited__c = Date.Today();
        }
    }

    public void setAllocationList() {
        AllocationList = new List<Gift_Detail__c>();
        if(PaymentId != null && !PaymentId.equals('')){
            String fields = 'Id ';
            for(Schema.FieldSetMember f : AllocationFieldList) {
                fields += f.getFieldPath() + ', ';
            }
            fields += AllocationRequiredFields;
            string whereClause = 'Payment__c=\'' +string.escapeSingleQuotes(PaymentId) + '\' ';

            for(Gift_Detail__c a : (List<Gift_Detail__c>)new GenericQueryBuilder().ListQueryBuilderWhere('Gift_Detail__c', fields, whereClause)){
                AllocationList.add(a);
            }
        }
        if(AllocationList.size()<5){
            for(Integer i=AllocationList.size(); i<5; i++){
                AllocationList.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
                if(AllocationList.size() >=5) break;
            }
        }
    }

    public List<Gift_Detail__c> getGiftDetailstoUpdate(){
       List<Gift_Detail__c> result = new List<Gift_Detail__c>();
       for(Gift_Detail__c gd : AllocationList){
           if ((gd.New_Campaign__c == null) && (gd.Fund__c == null) && gd.Amount__c==null) continue;
           if (gd.Allocation_Date__c == null) { gd.Allocation_Date__c.addError('Allocations: Allocation date is required.'); return null; }
           if (gd.New_Campaign__c == null) { gd.New_Campaign__c.addError('Allocations: Allocation Appeal is required'); return null; }
           if (gd.Amount__c==null) { gd.Amount__c.addError('Allocations: Allocation Amount is required'); return null; }
           result.add(gd);
       }
       return result;
    }

    public void setAllocationOperationList(){
       HasError = false;
       DelAllocationList = new List<Gift_Detail__c>();
       UpsertAllocationList = new List<Gift_Detail__c>();
       for(Gift_Detail__c gd : AllocationList){
           if ((gd.New_Campaign__c == null) && (gd.Fund__c == null) && gd.Amount__c==null){
               if(gd.Id != null){
                   DelAllocationList.add(gd);
               }
               continue;
           }
           if (gd.Allocation_Date__c == null) { gd.Allocation_Date__c.addError('Allocations: Allocation date is required.'); HasError = true; }
           if (gd.New_Campaign__c == null) { gd.New_Campaign__c.addError('Allocations: Allocation Appeal is required'); HasError = true; }
           if (gd.Amount__c==null) { gd.Amount__c.addError('Allocations: Allocation Amount is required'); HasError = true; }
           if(!HasError){
               UpsertAllocationList.add(gd);
           }
       }
       if(HasError){
           DelAllocationList = new List<Gift_Detail__c>();
           UpsertAllocationList = new List<Gift_Detail__c>();
       }
    }

    public map<string,boolean> allocationShowHideRequiredFieldMap {get;set;}
    public void setAllocationOperationList2(){
        allocationShowHideRequiredFieldMap = new map<string,boolean>();
       HasError = false;
       DelAllocationList = new List<Gift_Detail__c>();
       UpsertAllocationList = new List<Gift_Detail__c>();

       integer allocationShowHideRequiredFielCount = 0;
       for(Gift_Detail__c gd : AllocationList){
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Amount',false);
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Date',false);
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Appeal',false);
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Fund',false);

           if ((string.isblank(gd.New_Campaign__c)) && (string.isblank(gd.Fund__c)) && gd.Amount__c==null){
               if(gd.Id != null){
                   DelAllocationList.add(gd);
               }
               allocationShowHideRequiredFielCount++;
               continue;
           }
           if(gd.Allocation_Date__c == null) {
            convertOppSubmitErrorMsg = 'Review the errors on this page.';
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Date',true);
            HasError = true;
           }
           if(string.isblank(gd.New_Campaign__c)) {
            convertOppSubmitErrorMsg = 'Review the errors on this page.';
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Appeal',true);
            HasError = true;
           }
           if (gd.Amount__c==null) {
            convertOppSubmitErrorMsg = 'Review the errors on this page.';
            allocationShowHideRequiredFieldMap.put(allocationShowHideRequiredFielCount+'Amount',true);
            HasError = true;
            }
            if(!HasError){
               UpsertAllocationList.add(gd);
            }
            allocationShowHideRequiredFielCount++;
       }
       if(HasError){
           DelAllocationList = new List<Gift_Detail__c>();
           UpsertAllocationList = new List<Gift_Detail__c>();
       }
    }

    public string convertOppSubmitErrorMsg {get;set;}
    public PageReference saveAll2(){
        try{
            if(monthMap.containsKey(ccExpM))ccExpM = monthMap.get(ccExpM);
            convertOppSubmitErrorMsg = '';

            setAllocationOperationList2();
            if(HasError){
                return null;
            }else{
                if (Payment.Amount__c <= 0) {
                   convertOppSubmitErrorMsg = 'Amount must be greater than 0.';
                   return null;
                }
                else {
                if (UpsertAllocationList.size()<=0) {
                   convertOppSubmitErrorMsg = 'At least one Allocation is required.';
                   return null;
                }
                else{
                    Decimal dTotalAllocationAmount = 0;
                    for (Gift_Detail__c gd : UpsertAllocationList){
                        dTotalAllocationAmount += gd.Amount__c;
                    }
                    if(Payment.Amount__c == dTotalAllocationAmount){
                        Id rt = Id.valueOf(Utilities.getObjectRecordTypeId(Payment__c.SObjectType, 'Standard'));
                        if(Payment.Payment_Type__c.equals('Credit Card')){
                            rt = Id.valueOf(Utilities.getObjectRecordTypeId(Payment__c.SObjectType, 'Credit Card'));
                            shouldSubmit = true;
                        }
                        Payment.RecordTypeId = rt;
                        for(Schema.FieldSetMember f : PaymentFieldList) {
                            Payment.put(f.getFieldPath(), Payment.get(f.getFieldPath()));
                            Payment.put('Date__c', Payment.get('Date__c'));
                            Payment.put('Amount__c', Payment.get('Amount__c'));
                            Payment.put('Status__c', Payment.get('Status__c'));
                            Payment.put('Payment_Type__c', Payment.get('Payment_Type__c'));
                            Payment.put('Donation__c', Payment.get('Donation__c'));
                        }
                        DMLManager.UpsertSObject(Payment);
                        for (Gift_Detail__c gd : UpsertAllocationList){
                            if(gd.Payment__c == null){
                                gd.Payment__c = Payment.Id;
                            }
                            if(gd.Gift__c == null){
                                gd.Gift__c = Payment.Donation__c;
                            }
                            if(gd.Fund__c == null){
                                gd.Fund__c = getDefaultFund(gd.New_Campaign__c);
                            }

                        }
                        if (UpsertAllocationList != null && UpsertAllocationList.size() != 0) {
                            DMLManager.UpsertSObjects(UpsertAllocationList);
                        }
                        if (DelAllocationList != null && DelAllocationList.size() != 0) {
                            DMLManager.DeleteSObjects(DelAllocationList);
                        }
                        if (!shouldSubmit)
                        { return cancelAll(); }
                        else { return null; }
                    }else{
                        convertOppSubmitErrorMsg = 'Sum of Allocations must total the Payment amount.';
                        return null;
                    }
                }
            }  }
        }catch(Exception e){
            convertOppSubmitErrorMsg = e.getMessage();
            return null;
        }
    }

    public PageReference saveAll(){
        try{
            if(monthMap.containsKey(ccExpM))ccExpM = monthMap.get(ccExpM);
            convertOppSubmitErrorMsg = '';

            setAllocationOperationList();
            if(HasError){
                return null;
            }else{
                if (Payment.Amount__c <= 0) {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Amount must be greater than 0.'));
                   return null;
                }
                else {
                if (UpsertAllocationList.size()<=0) {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: At least one Allocation is required.'));
                   return null;
                }
                else{
                    Decimal dTotalAllocationAmount = 0;
                    for (Gift_Detail__c gd : UpsertAllocationList){
                        dTotalAllocationAmount += gd.Amount__c;
                    }
                    if(Payment.Amount__c == dTotalAllocationAmount){
                        Id rt = Id.valueOf(Utilities.getObjectRecordTypeId(Payment__c.SObjectType, 'Standard'));
                        if(Payment.Payment_Type__c.equals('Credit Card')){
                            rt = Id.valueOf(Utilities.getObjectRecordTypeId(Payment__c.SObjectType, 'Credit Card'));
                            shouldSubmit = true;
                        }
                        Payment.RecordTypeId = rt;
                        for(Schema.FieldSetMember f : PaymentFieldList) {
                            Payment.put(f.getFieldPath(), Payment.get(f.getFieldPath()));
                            Payment.put('Date__c', Payment.get('Date__c'));
                            Payment.put('Amount__c', Payment.get('Amount__c'));
                            Payment.put('Status__c', Payment.get('Status__c'));
                            Payment.put('Payment_Type__c', Payment.get('Payment_Type__c'));
                            Payment.put('Donation__c', Payment.get('Donation__c'));
                        }
                        DMLManager.UpsertSObject(Payment);
                        for (Gift_Detail__c gd : UpsertAllocationList){
                            if(gd.Payment__c == null){
                                gd.Payment__c = Payment.Id;
                            }
                            if(gd.Gift__c == null){
                                gd.Gift__c = Payment.Donation__c;
                            }
                            if(gd.Fund__c == null){
                                gd.Fund__c = getDefaultFund(gd.New_Campaign__c);
                            }

                        }
                        if (UpsertAllocationList != null && UpsertAllocationList.size() != 0) {
                            DMLManager.UpsertSObjects(UpsertAllocationList);
                        }
                        if (DelAllocationList != null && DelAllocationList.size() != 0) {
                            DMLManager.DeleteSObjects(DelAllocationList);
                        }
                        if (!shouldSubmit)
                        { return cancelAll(); }
                        else { return null; }
                    }else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Sum of Allocations must total the Payment amount.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
            }  }
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    public PageReference cancelAll(){
        PageReference p;
        if(PaymentId == null || PaymentId.equals('')){
            p = new PageReference(Url);
        }else{
            p = new PageReference('/' + PaymentId);
        }
        return p;
    }
    public PageReference newAllocation(){
        AllocationList.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
        reFreshAllocationShowHideRequiredFieldMap();
        return null;
    }

    public Gift__c theGift { get; set; }
    public string ccExpM { get; set; }
    public string ccExpY { get; set; }
    public string ccCVV { get; set; }

    public map<string,string> monthMap = new map<string,string>{'Jan'=>'1','Feb'=>'2','Mar'=>'3','Apr'=>'4','May'=>'5','Jun'=>'6','Jul'=>'7','Aug'=>'8','Sept'=>'9','Oct'=>'10','Nov'=>'11','Dec'=>'12'};

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
        for (Integer i = 0; i <= 8; i++)
        {
            options.add(new SelectOption(String.valueOf(Date.Today().Year()+i), String.valueOf(Date.Today().Year()+i)));
        }
        return options;
    }
    public Id getDefaultFund(Id AppealId){
        Id fundId = null;
        for(Campaign appeal : new CampaignSelector().SelectIdandFundById(new Set<Id> { AppealId })){
            fundId = appeal.Fund__c;
        }
        return fundId;
    }
}