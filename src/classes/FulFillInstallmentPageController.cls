public with sharing class FulFillInstallmentPageController {
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

    public PageReference submitPayment() {
        BatchGateway4.TransactionResult result;
        for (Payment__c p : paymentsToBeInserted) {
            try {
                result = submit(p, p.Donation__c);
            } catch (Exception ex) {
                shouldSubmit = false;
                p.Status__c = 'Declined';
                p.Credit_Card_Number__c = RollupHelper.maskCardNumber(p.Credit_Card_Number__c);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                createInstallmentFullfillment();
                return cancelAll();
            }

            shouldSubmit = false;
            if (result != null) {
                if (result.TransactionStatus == 'success') {
                    p.Authorization__c = result.ApprovalCode;
                    p.CC_Reference__c = result.TransactionId;
                    p.StatusComment__c = 'Approved.  Transaction Number: ' + result.TransactionId;
                    p.Status__c = result.TransactionStatus == null || result.TransactionStatus != 'success' ? 'Declined' : 'Approved';
                    if ((result.TransactionId == null || result.TransactionId == '') && result.TransactionStatus == 'success') p.Amount__c = 0;

                    p.CC_Transaction_Date__c = Date.today();
                    p.Status__c = 'Approved';
                } else {
                    p.Authorization__c = result.ApprovalCode;
                    p.CC_Reference__c = result.TransactionId;
                    p.Status__c = 'Declined';
                }
            }
        }

        createInstallmentFullfillment();
        return cancelAll();
    }


    public BatchGateway4.TransactionResult submit(Payment__c p, string gId) {
        BatchSettings__c BatchSettings = null;
        List<BatchSettings__c> settingList = new BatchSettingsSelector().SelectSObjectsByName('Default');
        if (settingList != null && settingList.size() > 0) {
            BatchSettings = settingList[0];
        }

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
        if (!lookupSelectedId.startsWith('001')) {
            Contact theIndividual;
            List<Contact> contactList = new ContactSelector().SelectSObjectsById(new Set<Id> { lookupSelectedId });
            if (contactList != null && contactList.size() > 0) {
                theIndividual = contactList[0];
                payment.address1 = theIndividual.MailingStreet;
                payment.city = theIndividual.MailingCity;
                payment.state = theIndividual.MailingState;
                payment.country = theIndividual.MailingCountry;
                payment.zipCode = theIndividual.MailingPostalCode;
                payment.donationType = 'IND';
                payment.email = theIndividual.Email;
                payment.PayerFirstName = theIndividual.FirstName;
                payment.PayerLastName = theIndividual.LastName;
                payment.isIndividual = true;
            }
        } else {
            Account theOrg;
            List<Account> accountList = new AccountSelector().SelectSObjectsById(new Set<Id> { lookupSelectedId });
            if (accountList != null && accountList.size() > 0) {
                theOrg = accountList[0];
                payment.address1 = theOrg.BillingStreet;
                payment.city = theOrg.BillingCity;
                payment.state = theOrg.BillingState;
                payment.country = theOrg.BillingCountry;
                payment.zipCode = theOrg.BillingPostalCode;
                payment.donationType = 'ORG';
                payment.email = theOrg.Email__c;
                payment.isIndividual = false;
                payment.PayerFirstName = '';
                payment.PayerLastName = '';
            }
        }

        payment.billingStartDate = date.today();
        payment.numberOfPayments = '';
        payment.isIndividual = true;
        payment.isRecurring = false;
        payment.constituentType = 'Existing';
        payment.amount = p.Amount__c.format();
        payment.creditCardNumber = creditcardNumber;
        payment.creditCardType = p.Credit_Card_Type__c;
        payment.cvv2 = ccCVV;
        payment.currencyType = BatchSettings.CurrencyCode__c;
        payment.expiryMonth = tryParseToInt(ccExpM);
        payment.expiryYear = tryParseToInt(ccExpY);
        payment.giftId = gid;
        payment.paymentId = p.Id;
        form.payments.payment.add(payment);
        BatchGateway4.ArrayOfTransactionResult txResults = new BatchGateway4.ArrayOfTransactionResult();
        if (!test.isrunningtest()) {
            txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0', '');
        }

        if (txResults != null && txResults.TransactionResult != null && txResults.TransactionResult.size() > 0) {
            return txResults.TransactionResult[0];
        } else {
            return null;
        }
    }

    public integer tryParseToInt(String txt) {
        integer result = 0;
        try {
            result = integer.valueOf(txt);
        } catch (Exception ex) {}

        return result;
    }

    public Payment__c Payment {get; set;}
    public String PaymentId {get; set;}
    public String TransactionId {get; set;}
    public String ContactId {get; set;}
    public List<Installment__c> InstallmentList {get; set;}
    public string ccExpM { get; set; }
    public string ccExpY { get; set; }
    public string ccCVV { get; set; }
    public string accContId {get; set;}
    public string accContName {get; set;}
    public set<Id> giftIds;
    public List<Schema.FieldSetMember> InstallmentFieldList {get; set;}
    public List<InstallmetnWrapperClass> installmentWrapper {get; set;}

    set<Id> transactonIds;
    public boolean shouldSubmit { get; set; }
    string creditcardNumber;
    String lookupSelectedId;
    String lookupSelectedId_dup;
    set<Id> contAccIds;
    string intial_Acc_Cont_Id;
    Decimal soft_Credit_Amount;
    public Id softcreditid;
    public List<Payment__c> paymentlist {get; set;}
    public List<Gift_Detail__c> allocationlist {get; set;}
    Database.SaveResult[] srList;

    Map<string, Payment__c> instPaymentMap = new Map<string, Payment__c>();
    list<Payment__c> paymentsToBeInserted = new list<Payment__c>();
    Map<String, String> rtypes_Map = new Map<String, String>();

    public string selectedCurrencyCode {get; set;}
    public Boolean multiCurrenyEnable {get; set;}
    public   Map<String, decimal> conversion_rates = new Map<String, decimal>();

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
        for (Integer i = 0; i <= 8; i++) {
            options.add(new SelectOption(String.valueOf(Date.Today().Year() + i), String.valueOf(Date.Today().Year() + i)));
        }
        return options;
    }

    public String PaymentRequiredFields {
        get{
            return ', Date__c, Amount__c, Status__c, Payment_Type__c, Donation__c';
        }
    }

    public FulFillInstallmentPageController(ApexPages.StandardController SC) {
        Payment = new Payment__c();
        giftIds = new set<Id>();
        transactonIds = new Set<Id>();
        installmentWrapper = new List<InstallmetnWrapperClass>();
        multiCurrencySupport();
        shouldSubmit = false;
        setInstallmentFieldList();
        setPayment();
        getAllTranscations();
        setInstallmentList();
        lookupSelectedId = accContId;
        intial_Acc_Cont_Id = accContId;
        String teststring;
    }

    public void SetLookupSelectedId(string newAccContId) {
        lookupSelectedId = newAccContId;
    }

    public void multiCurrencySupport() {
        multiCurrenyEnable = UserInfo.isMultiCurrencyOrganization();
        if (multiCurrenyEnable == true) {
            string fields = 'IsoCode,ConversionRate,IsCorporate';
            List<sObject> sobjList = new GenericQueryBuilder().ListQueryBuilderClause('CurrencyType', fields, '');
            for (sObject curr : sobjList) {
                conversion_rates.put((String)curr.get('IsoCode'), (decimal)curr.get('ConversionRate'));
            }
        }
    }

    public List<selectOption> getPicklistValues() {

        list<SelectOption> options = new list<SelectOption>();
        string ObjectApi_name = 'CurrencyType';
        String Accountapi = 'Account';
        String Field_name = 'IsoCode';
        String Field_name1 = 'CurrencyIsoCode';

        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        if (targetType != null) {
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues();


            Schema.SObjectType targetType1 = Schema.getGlobalDescribe().get(Accountapi);
            Sobject Object_name1 = targetType1.newSObject();
            Schema.sObjectType sobject_type1 = Object_name1.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe1 = sobject_type1.getDescribe();
            Map<String, Schema.SObjectField> field_map1 = sobject_describe1.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values1 = field_map1.get(Field_name1).getDescribe().getPickListValues();

            for (Schema.PicklistEntry a1 : pick_list_values1) {
                for (Schema.PicklistEntry a : pick_list_values) {
                    if (a.getValue() == a1.getValue()) {
                        options.add(new SelectOption(a.getValue(), a.getLabel()));
                    }
                }
            }
            return options;
        }
        return null;
    }

    public void setInstallmentFieldList() {
        InstallmentFieldList = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> afl = SObjectType.Installment__c.FieldSets.Installment_Fulfillment_List.getFields();
        for (Schema.FieldSetMember f : afl) {
            InstallmentFieldList.add(f);
        }
    }

    public void setPayment() {
        ContactId = ApexPages.currentPage().getParameters().get('ContactId');
        Payment = new Payment__c();
        Payment.Payment_Type__c = '';
        Payment.Date_Deposited__c = Date.Today();
    }

    public void getAllTranscations() {
        if (ContactId.startsWith('003')) {
            Contact c;
            List<Contact> contactList = new ContactSelector().SelectNameById(new Set<Id> { ContactId });
            if (contactList != null && contactList.size() > 0) {
                c = contactList[0];
                accContName = c.Name;
            }
            for (Gift__c g : new GiftSelector().SelectConstituentNameByConstituentId(new Set<Id> { ContactId })) {
                giftIds.add(g.id);
            }
            accContId = ContactId;
        } else if (ContactId.startsWith('001')) {
            Account a;
            List<Account> accountList = new AccountSelector().SelectIdNameById(new Set<Id> { ContactId });
            if (accountList != null && accountList.size() > 0) {
                a = accountList[0];
                accContName = a.name;
            }
            for (Gift__c g : new GiftSelector().SelectOrganizationNameByOrganizationId(new Set<Id> { ContactId })) {
                giftIds.add(g.id);
            }
            accContId = ContactId;
        } else {
            Gift__c gift;
            List<Gift__c> giftList = new GiftSelector().SelectOrganizationNameAndConstituentNameById(new Set<Id> { ContactId });
            if (giftList != null && giftList.size() > 0) {
                gift = giftList[0];
                if (gift.Organization__c != null) {
                    accContId = gift.Organization__c;
                    accContName = gift.Organization__r.Name;
                    for (Gift__c g : new GiftSelector().SelectIdByOrganization(gift.Organization__c)) {
                        giftIds.add(g.id);
                    }
                } else {
                    accContId = gift.Constituent__c;
                    accContName = gift.Constituent__r.Name;
                    for (Gift__c g : new GiftSelector().SelectIdByConstituent(accContId)) {
                        giftIds.add(g.id);
                    }
                }
            }
        }
    }

    public void setInstallmentList() {
        integer i = 0;
        while (i < installmentWrapper.size()) {
            if (installmentWrapper[i].fullfilmentAmount == null || installmentWrapper[i].fullfilmentAmount == 0 ) {
                installmentWrapper.remove(i);
            } else {
                i++;
            }
        }
        if (giftIds.size() > 0) {
            Boolean isMultiCurrency = false;
            if (multiCurrenyEnable) {
                isMultiCurrency = true;
            }

            for (Installment__c a : new InstallmentSelector().SelectInstallmentById(isMultiCurrency,giftIds)) {
                installmentWrapper.add(new InstallmetnWrapperClass(a));
            }
        }
    }

    public PageReference saveAll() {
        List<RecordType> rts = new RecordTypeSelector().SelectByTwoNamesAndPrefix('Credit Card', 'Standard', Utilities.getCurrentNamespace());
        for (RecordType r : rts) {
            rtypes_Map.put(r.Name, r.Id);
        }

        Decimal fullfillmentAmount = 0;

        for (InstallmetnWrapperClass i : installmentWrapper) {
            if (i.installment.Installment_Balance__c < ((multiCurrenyEnable) ? convertCurrencyWithApexCode(selectedCurrencyCode, (string)i.installment.get('CurrencyIsoCode'), (Decimal)i.fullfilmentAmount) : i.fullfilmentAmount)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fullfillment Balance should be less or equal to Installment Balance.'));
                return null;
            }

            if (i.fullfilmentAmount != null && i.fullfilmentAmount != 0) {
                fullfillmentAmount += i.fullfilmentAmount;
            }
        }

        if (Payment.Amount__c != fullfillmentAmount) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment Amount is not equal to Total installment Fullfillment Amount.'));
            return null;
        }

        for (InstallmetnWrapperClass i : installmentWrapper) {

            if (i.fullfilmentAmount != Null && i.fullfilmentAmount != 0) {
                Payment__c newPayment = new Payment__c();
                newPayment.Donation__c = i.installment.Pledge__r.id;
                newPayment.Date_Deposited__c = Payment.Date_Deposited__c;
                newPayment.Amount__c = i.fullfilmentAmount;
                newPayment.Payment_Type__c = Payment.Payment_Type__c;
                newPayment.Credit_Card_Type__c = Payment.Credit_Card_Type__c;
                newPayment.Date__c = Payment.Date__c;
                newPayment.Cheque_Num__c = Payment.Cheque_Num__c;
                newPayment.Cheque_Date__c = Payment.Cheque_Date__c;
                newPayment.Description__c = Payment.Description__c;

                if (multiCurrenyEnable) {
                    newPayment.put('CurrencyIsoCode', selectedCurrencyCode);
                }

                if (Payment.Payment_Type__c == 'Credit Card') {
                    newPayment.RecordTypeId = rtypes_Map.get('Credit Card');
                    newPayment.Credit_Card_Number__c = RollupHelper.maskCardNumber(Payment.Credit_Card_Number__c);
                    creditcardNumber = Payment.Credit_Card_Number__c;
                } else {
                    newPayment.RecordTypeId = rtypes_Map.get('Standard');
                    newPayment.Status__c = 'Approved';
                }
                paymentsToBeInserted.add(newPayment);
                instPaymentMap.put(i.installment.id, newPayment);
            }
        }

        if (paymentsToBeInserted.size() > 0) {
            DMLManager.InsertSObjects(paymentsToBeInserted);
        }

        if (Payment.Payment_Type__c == 'Credit Card') {
            shouldSubmit = true;
        } else {
            createInstallmentFullfillment();
            return cancelAll();
        }

        return null;
    }

    public void createInstallmentFullfillment() {
        List<Installment_Fulfillment__c> installmentFullFillmentList = new List<Installment_Fulfillment__c>();
        List<Gift_Detail__c> theGDs = new List<Gift_Detail__c>();
        List<Installment__c> installmentsToUpdate = new List<Installment__c>();

        if (Payment.Payment_Type__c == 'Credit Card') {
            for (Payment__c p : paymentsToBeInserted) {
                if (p.Status__c == 'Declined') {
                    Payment.Status__c = 'Declined';
                    DMLManager.DeleteSObjects(paymentsToBeInserted);
                    DMLManager.InsertSObject(Payment);
                    return ;
                }
            }

            if (paymentsToBeInserted.size() > 0) {
                DMLManager.UpdateSObjects(paymentsToBeInserted);
            }
        }

        for (InstallmetnWrapperClass i : installmentWrapper) {
            if (i.fullfilmentAmount != null && i.fullfilmentAmount != 0) {
                Installment_Fulfillment__c installmentFullfillment = new Installment_Fulfillment__c();
                installmentFullfillment.Installment__c = i.installment.Id;
                installmentFullfillment.Payment__c = instPaymentMap.get(i.installment.Id).id;
                installmentFullfillment.Fulfillment_Amount__c = i.fullfilmentAmount;
                if (multiCurrenyEnable) {
                    installmentFullfillment.put('CurrencyIsoCode', selectedCurrencyCode);
                }
                installmentFullFillmentList.add(installmentFullfillment);
                Gift_Detail__c gdP = new Gift_Detail__c();
                Gift_Detail__c gdN = new Gift_Detail__c();
                if (i.installment.Allocations__r.size() > 0) {
                    Integer numberOfAllocation = i.installment.Allocations__r.size();
                    for (Gift_Detail__c allocation : i.installment.Allocations__r) {
                        if (allocation.Amount__c > 0 && allocation.Payment__c == null) {
                            Gift_Detail__c gdClonePositive = allocation;
                            Gift_Detail__c gdCloneNegative = allocation;

                            gdP = gdClonePositive.clone(false, true);
                            gdP.Amount__c = i.fullfilmentAmount;
                            gdP.Payment__c = instPaymentMap.get(i.installment.Id).id;
                            gdP.Allocation_Date__c = instPaymentMap.get(i.installment.Id).Date__c;
                            gdP.Gift__c = i.installment.Pledge__r.id;
                            gdP.Installment__c = i.installment.Id;
                            if (multiCurrenyEnable) {
                                gdP.put('CurrencyIsoCode', selectedCurrencyCode);
                            }
                            theGDs.add(gdP);

                            App_Settings__c appSetting = App_Settings__c.getInstance();
                            if (appSetting.Enable_Pledge_Accrual_Accounting__c) {
                                gdN = gdCloneNegative.clone(false, true);
                                gdN.Amount__c = 0 - i.fullfilmentAmount;
                                gdN.Payment__c = null;
                                gdN.Allocation_Date__c = instPaymentMap.get(i.installment.Id).Date__c;
                                gdN.Gift__c = i.installment.Pledge__r.id;
                                gdN.Installment__c = i.installment.Id;

                                if (multiCurrenyEnable) {
                                    gdN.put('CurrencyIsoCode', selectedCurrencyCode);
                                }

                                theGDs.add(gdN);
                            }
                        }
                    }
                }
            }
        }

        if (installmentFullFillmentList.size() > 0) {
            DMLManager.InsertSObjects(installmentFullFillmentList);
        }

        if (theGDs.size() > 0) {
            DMLManager.InsertSObjects(theGDs);
        }
    }

    public PageReference cancelAll() {
        PaymentId = Payment.Id;
        PageReference p;
        if (ContactId == null || ContactId.equals('')) {
            p = null;
        } else {
            p = new PageReference('/' + ContactId);
        }

        return p;
    }

    public class InstallmetnWrapperClass {
        public Installment__c installment {get; set;}
        public Decimal fullfilmentAmount {get; set;}
        public InstallmetnWrapperClass(Installment__c inst) {
            installment = inst;
        }
    }

    public Decimal convertCurrencyWithApexCode(String oCurrency, String nCurrency, Decimal  amount) {
        amount = amount / conversion_rates.get(oCurrency);
        amount = amount * conversion_rates.get(nCurrency);
        return amount;
    }
}