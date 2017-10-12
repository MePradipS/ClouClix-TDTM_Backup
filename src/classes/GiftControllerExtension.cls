public with sharing class GiftControllerExtension {
    // * Standard Objects  * //
    // final tesing 2
    public Gift__c theGift { get; set; }
    public Payment__c thePayment { get; set; }
    public Receipt__c theReceipt { get; set; }
    public Recurring_Donation__c theRecurring { get; set; }
    public List<Payment__c> thePayments { get; set; }
    public List<Gift_Detail__c> theGiftDetails { get; set; }
    public List<Solicitor__c> softCredits { get; set; }
    public Contact theIndividual { get; set; }
    public Account theOrg { get; set; }
    public boolean isOrg { get; set; }
    private string authToken { get; set; }
    public string orgId { get; set;}
    public map<String, List<String>> paymentmap = new map<String, List<String>> ();
    public string FirstName { get; set; }
    public string lastName { get; set; }
    public string hiddenInputValue { get; set; }
    public string hiddenAppeal { get; set;}
    public string hiddenInputId { get; set; }
    public string contactlookup1 { get; set; }
    public boolean enablefield {get; set;}
    public contact lookupcontact;
    public Gift__c giftForContact { get; set; }
    public String conId {get; set;}
    public String amt {get; set;}
    public String appeal {get; set;}
    public string prop {get; set;}
    public string payment_structure { get; set; }
    public string default_payment_status { get; set; }
    public string per_payment_amount { get; set; }
    public string ccExpM { get; set; }
    public string ccExpY { get; set; }
    public string ccCVV { get; set; }
    public boolean shouldSubmit { get; set; }
    public boolean paymentReference { get; set; }//to know payment processing and has reference no. shri story #102065790

    public BatchGateway4.ArrayOfTransactionResult txResults { get; set; }
    public BatchGateway4.ArrayOfSerializableKeyValuePairOfStringString txtResultsGateway { get; set; }
    public Map<Id, String> Merchant_gateway_key = new Map<Id, String> ();
    public boolean shouldInsertReceipt { get; set; }
    public static string TestContactId { get; set; }

    /** Used for Fund Lookup Override **/

    public string FundKeyPrefix { get; set; }
    public string cId { get; set; }

    String ccNumber;
    App_Settings__c appSetting;

    /** Dynamic Fieldsets **/

    public List<Schema.FieldSetMember> PaymentFieldList {get; set;}
    public List<Schema.FieldSetMember> FilteredPaymentFieldList {get; set;}
    public List<Schema.FieldSetMember> AllocationFieldList {get; set;}
    public string selectedCurrencyCode1 ;
    public string stringSTR { get; set; }
    public Boolean multiCurrenyEnable {get; set;}
    public string selectedCurrencyCode {get; set;}
    public Boolean pledgeInstallmentEnable {get; set;}
    public Integer fixedNumberInstallment {get; set;}
    public List<Installment__c> theInstallments {get; set;}
    private String NamespacePrefix = Utilities.getCurrentNamespace();
    public String NamespaceField {
        get {
            if (NamespaceField == null) {
                NamespaceField = NamespacePrefix + (String.isEmpty(NamespacePrefix) ? '' : '__');
            }
            return NamespaceField;
        }
        set;
    }
    private String NamespacePayment = NamespaceField + 'Payment__c';
    List<Gift_Detail__c> deleteallocation;

    public void setAllocationFieldList() {
        AllocationFieldList = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> afl = SObjectType.Gift_Detail__c.FieldSets.allocation.getFields();
        for (Schema.FieldSetMember f : afl) {
            AllocationFieldList.add(f);
        }
    }

    public void setPaymentFieldList() {
        PaymentFieldList = new List<Schema.FieldSetMember>();
        stringSTR = '';
        FilteredPaymentFieldList = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> pfl = SObjectType.Payment__c.FieldSets.Single_Transation_Custom_Fields.getFields();
        if (pfl.size() > 0) {
            for (Schema.FieldSetMember f : pfl) {
                if (!(f.FieldPath.equalsIgnoreCase('Payment_Type__c'))) {
                    PaymentFieldList.add(f);
                    stringSTR += f.FieldPath;
                }
            }
        } else {
            stringSTR = 'itShoulHaveSomeValue';
        }
        FilteredPaymentFieldList.addAll(PaymentFieldList);
    }

    public PageReference  savecontact() {
        if ((string.isBlank(FirstName) || string.isBlank(lastName)) && string.isBlank(hiddenInputValue)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter FirstName and Last Name'));
            return null;
        }

        if (hiddenInputValue != null && hiddenInputValue != '') {
            Contact c;
            List<Contact> contactList = new ContactSelector().SelectAccountInfoById(new Set<String> { hiddenInputId });
            if (contactList != null && contactList.size() > 0) {
                c = contactList[0];
                c.AccountId = theOrg.id;
                DMLManager.UpdateSObject(c);
                giftForContact.Constituent__c = hiddenInputId;
            }
            return null;
        }

        if (FirstName != null && lastName != null ) {
            if (!(string.isEmpty(FirstName) && string.isEmpty(lastName)) ) {
                Contact c = new Contact();
                c.FirstName = FirstName;
                c.LastName = lastName;
                c.AccountId = theOrg.id;
                DMLManager.InsertSObject(c);
                giftForContact.Constituent__c = c.Id;
                theGift.Affiliated_Contact__c = c.Id;
                hiddenInputValue = c.FirstName + ' ' + c.LastName;
                hiddenInputId = c.id;
            }
        }
        return null;
    }

    public GiftControllerExtension(ApexPages.StandardController controller) {
        Schema.DescribeSObjectResult fund = Fund__c.sObjectType.getDescribe();
        FundKeyPrefix = fund.getKeyPrefix();
        setAllocationFieldList();
        setPaymentFieldList();
        theGift = (Gift__c)controller.getRecord();
        giftForContact = new Gift__c();
        theRecurring = new Recurring_Donation__c();
        cId = System.currentPagereference().getParameters().get('cid');
        if (cId !=  null && cId.length() > 18 ) {
            string c = cId;
            string amt1 = 'amt' ;
            string appeal1 = 'appeal';
            string prop1 = 'prop';
            List<string> valuelist = new List<string>();
            List<string> mm = c.split('/');
            cId = mm[0];
            string cId1 = mm[0];
            for (string test : mm) {
                if (test.indexOf('=') != -1) {
                    List<string> a = test.split('=');
                    if (a.size() > 1) {
                        if (a[0].equalsIgnoreCase(amt1)) {
                            amt = a[1];
                            string regex = '[^0-9,.]';
                            amt = amt.replaceAll(regex, '');
                        }
                        else if (a[0].equalsIgnoreCase(appeal1)) {
                            appeal = a[1];
                        } else if (a[0].equalsIgnoreCase(prop1)) {
                            prop = a[1];
                        }
                    }
                }
            }
            if (string.isEmpty(amt)) {amt = null;}

            if (String.isEmpty(appeal)) {appeal = null;}

            if (String.isEmpty(prop)) {prop = null;}

            InitializeContact_url(cId1, amt, appeal, prop);
        } else {
            if (cId == null) {
                cId = TestContactId;
            }
            InitializeContact(cId);
        }

        selectedCurrencyCode1 = userinfo.getDefaultCurrency();

        appSetting = App_Settings__c.getInstance();

        pledgeInstallmentEnable = appSetting.Enable_Pledge_Installment_Model__c;

        if (pledgeInstallmentEnable) {
            payment_structure = '# of Installment';
        } else {
            payment_structure = '# of Payments';
        }

        CalcPaymentAmount();
        shouldInsertReceipt = false;
        multiCurrenyEnable = checkMCEnabled();
    }

    public void multicurrencytest() {
        if (multiCurrenyEnable) {
            Organization orgIdrec;
            List<Organization> organizationList = new OrganizationSelector().SelectIdByLimit(1);
            if (organizationList != null && organizationList.size() > 0) {
                orgIdrec = organizationList[0];
                orgId = (string)orgIdrec.Id;
                orgId = orgId.substring(0, 15);
                BatchGateway4.ArrayOfSerializableKeyValuePairOfStringString txtResultsGateway1 = new BatchGateway4.ArrayOfSerializableKeyValuePairOfStringString();
                txtResultsGateway1 = GetMerchantKeyValueCurrency(orgId);

                if (txtResultsGateway1.SerializableKeyValuePairOfStringString != null  ) {

                    for (integer i = 0; i < txtResultsGateway1.SerializableKeyValuePairOfStringString.size(); i++) {
                        string a1 = JSON.serialize(txtResultsGateway1.SerializableKeyValuePairOfStringString[i].value);
                        a1 = a1.replaceAll('"', '');

                        string a2 = JSON.serialize(txtResultsGateway1.SerializableKeyValuePairOfStringString[i].key);
                        a2 = a2.replaceAll('"', '');

                        Merchant_gateway_key.put(a2, a1);
                    }
                }
            }
        }
    }

    public void InitializeContact(string contactId) {
        shouldSubmit = false;
        paymentReference = false;
        isOrg = contactId.startsWith('001');

        if (isOrg) {
            List<Account> contacts = new AccountSelector().SelectAccountAndRecordTypeNameById(new Set<Id> { string.escapeSingleQuotes(contactId) });
            if (contacts == null || contacts.size() <= 0) return;

            theOrg = contacts[0];
            theGift.Organization__c = theOrg.Id;
        } else {
            List<Contact> contacts = new ContactSelector().SelectSObjectsById(new Set<Id> { string.escapeSingleQuotes(contactId) });
            if (contacts == null || contacts.size() <= 0) return;
            theIndividual = contacts[0];
            theGift.Constituent__c = theIndividual.Id;
        }

        theGift.Gift_Type__c = 'One Time Gift';
        theGift.Gift_Date__c = Date.Today();
        theGift.Status__c = 'Entered';
        theGift.Receipt_Type__c = 'Single Receipt';

        thePayment = new Payment__c();
        thePayment.Payment_Type__c = '';
        thePayment.Status__c = 'Approved';
        thePayment.Date__c = Date.Today();

        theGiftDetails = new List<Gift_Detail__c>();
        theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
        theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
        theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));

        if (!isOrg) {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Constituent__c = theIndividual.Id);
        } else {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Organization__c  = theOrg.Id);
        }

        softCredits = new List<Solicitor__c>();
        softCredits.add(new Solicitor__c());
        softCredits.add(new Solicitor__c());

        thePayments = new List<Payment__c>();
        theInstallments = new List<Installment__c>();
    }

    public void InitializeContact_url(string contactId, string urlamount , string urlappeal , String urlprop) {
        shouldSubmit = false;
        paymentReference = false;
        isOrg = contactId.startsWith('001');

        if (isOrg) {
            List<Account> contacts = new AccountSelector().SelectAccountAndRecordTypeNameById(new Set<Id> { contactId });
            if (contacts == null || contacts.size() <= 0) return;

            theOrg = contacts[0];
            theGift.Organization__c = theOrg.Id;
        } else {
            List<Contact> contacts = new ContactSelector().SelectSObjectsById(new Set<Id> { contactId });
            if (contacts == null || contacts.size() <= 0) return;

            theIndividual = contacts[0];
            theGift.Constituent__c = theIndividual.Id;
        }

        theGift.Gift_Type__c = 'One Time Gift';
        theGift.Gift_Date__c = Date.Today();
        theGift.Status__c = 'Entered';
        theGift.Receipt_Type__c = 'Single Receipt';

        if (urlamount != null) {
            theGift.Expected_Amount__c = Integer.valueof(urlamount);
        }

        if (urlprop != null) {
            list<OPPORTUNITY> O = new OpportunitySelector().SelectSObjectsById(new Set<Id> { urlprop });

            if (!o.isEmpty()) {
                theGift.Proposal__c = o[0].Id;
            }
        }

        thePayment = new Payment__c();
        thePayment.Payment_Type__c = '';
        thePayment.Status__c = 'Approved';
        thePayment.Date__c = Date.Today();

        theGiftDetails = new List<Gift_Detail__c>();

        if (urlAppeal != null) {
            List<CAMPAIGN> C = new CampaignSelector().SelectIdNameById(new Set<Id> { urlAppeal });

            if (!c.isEmpty()) {
                if (urlamount != null) {
                    theGiftDetails.add(new Gift_Detail__c(Amount__c = Integer.valueof(urlamount), Allocation_Date__c = Date.Today(), New_Campaign__c = c[0].id));
                } else {
                    theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today(), New_Campaign__c = c[0].id));
                }
            }

            theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
            theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
        } else {
            if (urlamount != null) {
                theGiftDetails.add(new Gift_Detail__c(Amount__c = Integer.valueof(urlamount), Allocation_Date__c = Date.Today()));
                theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
                theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
            } else {
                theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
                theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
                theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
            }
        }

        if (!isOrg) {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Constituent__c = theIndividual.Id);
        } else {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Organization__c  = theOrg.Id);
        }

        softCredits = new List<Solicitor__c>();
        softCredits.add(new Solicitor__c());
        softCredits.add(new Solicitor__c());

        thePayments = new List<Payment__c>();
        theInstallments = new List<Installment__c>();
    }

    public void CalcPaymentAmount() {
        if (theRecurring.of_Payments__c != null) {
            if (theRecurring.of_Payments__c == 0) {
                per_payment_amount = '0';
            } else {
                per_payment_amount = String.valueOf(theGift.Expected_Amount__c / theRecurring.of_Payments__c);
            }
        }
    }

    public PageReference GeneratePaymentSched() {
        thePayments = new List<Payment__c>();

        Integer modvalue = 0;

        //Validate "# of Payments" and "Per Payment Amount" fields.
        //Both "# of Payments" and "Per Payment Amount" cannot be null.
        if ( (per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (theRecurring.of_Payments__c == null || theRecurring.of_Payments__c <= 0) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:"' + payment_structure + '" should be a positive value.'));
            return null;
        }

        //If payment structure is "per payment amount", calculate "number of payments" based on the "per payment amount" value.
        if (payment_structure == 'Per Payment Amount') {
            theRecurring.of_Payments__c = Math.floor(theGift.Expected_Amount__c / Decimal.valueOf(per_payment_amount));
        }

        if (payment_structure == 'Per Payment Amount' && Math.mod(Integer.Valueof(theGift.Expected_Amount__c), Integer.valueOf(per_payment_amount)) != 0) {
            theRecurring.of_Payments__c = theRecurring.of_Payments__c + 1;
            modvalue = Math.mod(Integer.Valueof(theGift.Expected_Amount__c), Integer.valueOf(per_payment_amount));
        }

        decimal rounded_amount = 0;
        string standard_rt;
        List<RecordType> rtList = new RecordTypeSelector().SelectBySObjectAndName(NamespacePayment, 'Standard');
        if (rtList != null && rtList.size() > 0) {
            standard_rt = rtList[0].Id;
        }

        for (integer i = 0; i < theRecurring.of_Payments__c; i++) {

            Payment__c p = new Payment__c();
            p.Donation__c = theGift.Id;
            p.RecordTypeId = standard_rt;
            P.Payment_Type__c = thePayment.Payment_Type__c;
            p.Status__c = default_payment_status;

            if (theRecurring.Frequency__c == 'Monthly') {
                p.Date__c = theRecurring.Start_Date__c.addMonths(i);
            } else if (theRecurring.Frequency__c == 'Quarterly') {
                p.Date__c = theRecurring.Start_Date__c.addDays(i * 90);
            } else if (theRecurring.Frequency__c == 'Annually') {
                p.Date__c = theRecurring.Start_Date__c.addYears(i);
            }

            if (payment_structure != '# of Payments') {
                theRecurring.Amount__c = Decimal.valueOf(per_payment_amount);
                if (Math.mod(Integer.Valueof(theGift.Expected_Amount__c), Integer.valueOf(per_payment_amount)) == 0) {
                    p.Amount__c = Decimal.valueOf(per_payment_amount);
                } else {
                    if ( i != theRecurring.of_Payments__c - 1 ) {
                        p.Amount__c = Decimal.valueOf(per_payment_amount);
                    } else {
                        p.amount__c = modvalue;
                    }
                }
            } else {
                theRecurring.Amount__c = (theGift.Expected_Amount__c / theRecurring.of_Payments__c).setScale(2);

                if (Math.mod(Integer.Valueof(theGift.Expected_Amount__c), Integer.valueOf(theRecurring.of_Payments__c)) == 0) {
                    p.Amount__c = (theGift.Expected_Amount__c / theRecurring.of_Payments__c).setScale(2);
                    rounded_amount = rounded_amount + p.Amount__c;
                } else {
                    if ( i != theRecurring.of_Payments__c - 1 ) {
                        p.Amount__c = (theGift.Expected_Amount__c / theRecurring.of_Payments__c).setScale(2);
                        rounded_amount = rounded_amount + p.Amount__c;
                    } else {
                        p.Amount__c = theGift.Expected_Amount__c - rounded_amount;
                    }
                }
            }
            thePayments.add(p);
        }
        return null;
    }

    public pageReference generateInstallments() {

        theInstallments = new List<Installment__c>();

        Integer modvalue = 0;

        if ( (per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (fixedNumberInstallment == null || Decimal.valueOf(fixedNumberInstallment) <= 0) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:"' + payment_structure + '" should be a positive value.'));
            return null;
        }

        if (payment_structure == 'Per Installment Amount')   {
            Decimal decimalValue = Math.floor(theGift.Expected_Amount__c / Decimal.valueOf(per_payment_amount));
            fixedNumberInstallment = decimalValue.intValue();

            if (Math.mod(Integer.Valueof(theGift.Expected_Amount__c), Integer.valueOf(per_payment_amount)) != 0) {
                modvalue = Math.mod(Integer.valueof(theGift.Expected_Amount__c), Integer.valueOf(per_payment_amount)) ;
                fixedNumberInstallment = fixedNumberInstallment + 1;
            }
        }

        decimal rounded_amount = 0;

        for (integer i = 0; i < fixedNumberInstallment; i++) {

            Installment__c p = new Installment__c();
            p.Inst_No__c = i + 1;

            if (theRecurring.Frequency__c == 'Monthly') {
                p.Installment_Date__c = theRecurring.Start_Date__c.addMonths(i);
            } else if (theRecurring.Frequency__c == 'Quarterly') {
                p.Installment_Date__c = theRecurring.Start_Date__c.addDays(i * 90);
            } else if (theRecurring.Frequency__c == 'Annually') {
                p.Installment_Date__c = theRecurring.Start_Date__c.addYears(i);
            }

            if (payment_structure != '# of Installment' && Math.mod(Integer.valueof(theGift.Expected_Amount__c), Integer.valueOf(per_payment_amount)) == 0) {
                p.Installment_Amount__c = Decimal.valueOf(per_payment_amount);

            } else if (payment_structure != '# of Installment' && Math.mod(Integer.valueOf(theGift.Expected_Amount__c), Integer.valueOf(per_payment_amount)) != 0) {
                if ( i != fixedNumberInstallment - 1 ) {
                    p.Installment_Amount__c = Decimal.valueOf(per_payment_amount);
                } else {
                    p.Installment_Amount__c = modvalue;
                }
            } else {
                if (Math.mod(Integer.valueOf(theGift.Expected_Amount__c), Integer.valueOf(fixedNumberInstallment)) == 0) {
                    p.Installment_Amount__c = (theGift.Expected_Amount__c / fixedNumberInstallment).setScale(2);
                    rounded_amount = rounded_amount + p.Installment_Amount__c;
                } else {
                    if (i != fixedNumberInstallment - 1 ) {
                        p.Installment_Amount__c = (theGift.Expected_Amount__c / fixedNumberInstallment).setScale(2);
                        rounded_amount = rounded_amount + p.Installment_Amount__c;
                    } else {
                        p.Installment_Amount__c = theGift.Expected_Amount__c - rounded_amount;
                    }
                }
            }

            if (theOrg != null) {
                p.Name = theOrg.Name + ' - ' + p.Installment_Date__c.format() + ' - Inst ' + p.Inst_No__c;
            } else {
                p.Name = theIndividual.Name + ' - ' + p.Installment_Date__c.format() + ' - Inst ' + p.Inst_No__c;
            }

            theInstallments.add(p);
        }
        return null;
    }

    public PageReference Submit() {
        if (isOrg) {
            if (hiddenInputValue != null && String.isNotEmpty(hiddenInputValue)) {
                theGift.Affiliated_Contact__c = hiddenInputId;
            }

            if ((String.isNotEmpty(FirstName) && String.isNotEmpty(lastName)) && String.isEmpty(hiddenInputValue)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please click save before submit.'));
                return null;
            }
        }

        //Validation
        if (theGift.Gift_Type__c == 'Pledge') {

            //Validate "# of Payments" and "Per Payment Amount" fields.
            //Both "# of Payments" and "Per Payment Amount" cannot be null.
            if (pledgeInstallmentEnable) {
                if ((per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (fixedNumberInstallment == null || Decimal.valueOf(fixedNumberInstallment) <= 0)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:"' + payment_structure + '" should be a positive value.'));
                    return null;
                }
            } else {
                if ((per_payment_amount == null || Decimal.valueOf(per_payment_amount) <= 0) && (theRecurring.of_Payments__c == null || theRecurring.of_Payments__c <= 0)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:"' + payment_structure + '" should be a positive value.'));
                    return null;
                }
            }

            //Added by nitin to check generate payment schedule button is clicked
            if (thePayments.size() == 0 && theInstallments.size() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must click the Generate Payment Schedule or Generate Installment Schedule button before saving.'));
                return null;
            }
        }

        List<Solicitor__c> theSoftCredits = getSotCreditsToUpdate();
        if (theSoftCredits == null) return null;

        List<Gift_Detail__c> theFinalGifts = new  List<Gift_Detail__c>();
        theFinalGifts = getGiftDetailstoUpdate();
        if (theFinalGifts == null) return null;

        if (theFinalGifts.size() <= 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: At least one Allocation is required.'));
            return null;
        }

        Decimal total = 0;
        for (Gift_Detail__c gd : theFinalGifts) {
            total = total + gd.Amount__c;
        }

        if (theGift.Expected_Amount__c != total) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: The sum of the Allocations must equal the Transaction Amount.'));
            return null;
        }

        if (!isOrg) {
            if (theReceipt.Auto_Email_Receipt__c == true && theIndividual.Email == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Email Address for Individual, Please update Email Address if you want to use Auto Email Receipt Feature!'));
                return null;
            }

            DMLManager.UpsertSObject(theIndividual);

            theRecurring.Constituent__c = theIndividual.Id;
            theGift.Constituent__c = theIndividual.Id;
        } else {
            if (theReceipt.Auto_Email_Receipt__c == true && theOrg.Email__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Email Address for Organisation, Please update Email Address if you want to use Auto Email Receipt Feature!'));
                return null;
            }
            DMLManager.UpsertSObject(theOrg);
            theGift.Organization__c = theOrg.Id;

            if ((string.isEmpty(hiddenInputId) && theGift.Gift_Type__c == 'Recurring')  ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter or select a contact for an Organization Recurring Gift'));
                return null;
            }

            if (string.isNotEmpty(hiddenInputId)) {
                theRecurring.Constituent__c = hiddenInputId;
            }

            theRecurring.Organization__c = theOrg.Id;
        }

        if (multiCurrenyEnable) {

            if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                theGift.put('CurrencyIsoCode', selectedCurrencyCode);
            } else {
                string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                List<String> CurrencyValueList = CurrencyValue.split('-');
                String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                theGift.put('CurrencyIsoCode', CurrencyValue1);
            }
        }

        DMLManager.UpsertSObject(theGift);

        ccNumber = thePayment.Credit_Card_Number__c;
        thePayment.Credit_Card_Number__c = RollupHelper.maskCardNumber(ccNumber);

        if (multiCurrenyEnable) {

            if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                thePayment.put('CurrencyIsoCode', selectedCurrencyCode);
            } else {

                string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                List<String> CurrencyValueList = CurrencyValue.split('-');
                String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                thepayment.put('CurrencyIsoCode', CurrencyValue1);
            }
        }

        if (theGift.Gift_Type__c == 'Pledge') {

            /** DO PLEDGE STUFF **/
            //If payment structure is "per payment amount", calculate "number of payments" based on the "per payment amount" value.

            if (payment_structure != '# of Payments' && payment_structure != '# of Installment') {
                theRecurring.of_Payments__c = Math.floor(theGift.Expected_Amount__c / Decimal.valueOf(per_payment_amount));
            }

            if (pledgeInstallmentEnable) {
                theGift.Per_Payment_Amount__c = theGift.Expected_Amount__c / fixedNumberInstallment;
            } else {
                theGift.Per_Payment_Amount__c = theGift.Expected_Amount__c / theRecurring.of_Payments__c;
            }

            theGift.Pledge_Start_Date__c = theRecurring.Start_Date__c;
            theGift.Pledge_Payment_Frequency__c = theRecurring.Frequency__c;
            theGift.No_of_Expected_Payments__c = theRecurring.Of_Payments__c;

            DMLManager.UpsertSObject(theGift);

            if (thePayments.size() > 0) {
                for (Payment__c p : thePayments) {
                    p.Donation__c = theGift.Id;

                    if (multiCurrenyEnable) {
                        if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                            p.put('CurrencyIsoCode', selectedCurrencyCode);
                        } else {
                            string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                            List<String> CurrencyValueList = CurrencyValue.split('-');
                            String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                            p.put('CurrencyIsoCode', CurrencyValue1);
                        }
                    }
                }

                DMLManager.UpsertSObjects(thePayments);

                List<Gift_Detail__c> theGds = new List<Gift_Detail__c>();
                for (Payment__c p : thePayments) {
                    for (Gift_Detail__c gd : theFinalGifts) {
                        Gift_Detail__c nGd = new Gift_Detail__c();

                        nGd = gd.clone(false, false, false, false);
                        nGd.Payment__c = p.Id;
                        nGd.Amount__c = gd.Amount__c / theRecurring.of_Payments__c;
                        nGd.New_Campaign__c = gd.New_Campaign__c;
                        nGd.Campaign__c = gd.Campaign__c;
                        nGd.Custom_Allocation_Text__c = gd.Custom_Allocation_Text__c;
                        nGd.Fund__c = gd.Fund__c;
                        nGd.Package__c = gd.Package__c;

                        if (!appSetting.Enable_Pledge_Accrual_Accounting__c)
                            nGd.Allocation_Date__c = p.Date__c;
                        else
                            nGd.Allocation_Date__c = theGift.Gift_Date__c;

                        nGd.Parent_Appeal__c = gd.Parent_Appeal__c;

                        if (nGd.Id == null) nGd.Gift__c = theGift.Id;

                        if (multiCurrenyEnable) {
                            if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                                nGd.put('CurrencyIsoCode', selectedCurrencyCode);
                            } else {
                                string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                                List<String> CurrencyValueList = CurrencyValue.split('-');
                                String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                                nGd.put('CurrencyIsoCode', CurrencyValue1);
                            }
                        }
                        theGDs.add(nGd);
                    }
                }

                DMLManager.UpsertSObjects(theGDs);
            } else {
                if (theInstallments.size() > 0) {
                    for (Installment__c p : theInstallments) {
                        p.Pledge__c = theGift.Id;
                        p.Status__c = 'Open';

                        if (multiCurrenyEnable) {
                            if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                                p.put('CurrencyIsoCode', selectedCurrencyCode);
                            } else {
                                string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                                List<String> CurrencyValueList = CurrencyValue.split('-');
                                String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                                p.put('CurrencyIsoCode', CurrencyValue1);
                            }
                        }
                    }

                    DMLManager.UpsertSObjects(theInstallments);

                    List<Gift_Detail__c> theGds = new List<Gift_Detail__c>();
                    for (Installment__c p : theInstallments) {
                        for (Gift_Detail__c gd : theFinalGifts) {
                            Gift_Detail__c nGd = new Gift_Detail__c();
                            nGd = gd.clone(false, false, false, false);

                            nGd.Installment__c = p.Id;
                            nGd.Amount__c = p.Installment_Amount__c;
                            nGd.New_Campaign__c = gd.New_Campaign__c;
                            nGd.Campaign__c = gd.Campaign__c;
                            nGd.Custom_Allocation_Text__c = gd.Custom_Allocation_Text__c;
                            nGd.Fund__c = gd.Fund__c;
                            nGd.Package__c = gd.Package__c;

                            if (!appSetting.Enable_Pledge_Accrual_Accounting__c)
                                nGd.Allocation_Date__c = p.Installment_Date__c;
                            else
                                nGd.Allocation_Date__c = theGift.Gift_Date__c;

                            nGd.Parent_Appeal__c = gd.Parent_Appeal__c;

                            if (nGd.Id == null) nGd.Gift__c = theGift.Id;

                            if (multiCurrenyEnable) {
                                if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                                    nGd.put('CurrencyIsoCode', selectedCurrencyCode);
                                } else {
                                    string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                                    List<String> CurrencyValueList = CurrencyValue.split('-');
                                    String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                                    nGd.put('CurrencyIsoCode', CurrencyValue1);
                                }
                            }
                            theGDs.add(nGd);
                        }
                    }
                    DMLManager.UpsertSObjects(theGDs);
                }
            }
        }

        //when gift type is recurring while creating a new gift
        if (theGift.Gift_Type__c == 'Recurring') {

            // ** DO RECURRING STUFF **
            theRecurring.Status__c = 'Active';
            theRecurring.Type__c = thePayment.Payment_Type__c;
            theRecurring.Amount__c = theGift.Expected_Amount__c;

            //if the payment type is not credit card for recurring gift
            if (thePayment.Payment_Type__c != 'Credit Card' || (thePayment.Payment_Type__c == 'Credit Card' && theRecurring.Start_Date__c > system.Today())) {

                if (multiCurrenyEnable) {
                    if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                        theRecurring.put('CurrencyIsoCode', selectedCurrencyCode);
                    } else {
                        string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                        List<String> CurrencyValueList = CurrencyValue.split('-');
                        String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                        theRecurring.put('CurrencyIsoCode', CurrencyValue1);
                    }
                }

                DMLManager.UpsertSObject(theRecurring);
                theGift.Recurring_Donation__c = theRecurring.Id;

                DMLManager.UpsertSObject(theGift);
                List<RD_Allocation__c> theRds = new List<RD_Allocation__c>();

                for (Gift_Detail__c gd : theFinalGifts) {

                    RD_Allocation__c rd = new RD_Allocation__c();
                    rd.Active__c = True;
                    rd.Amount__c = gd.Amount__c;
                    rd.New_Campaign__c = gd.New_Campaign__c;
                    rd.Campaign__c = gd.Campaign__c;
                    rd.Custom_Allocation_Text__c = gd.Custom_Allocation_Text__c;
                    rd.Fund__c = gd.Fund__c;
                    rd.Package__c = gd.Package__c;
                    rd.Parent_Appeal__c = gd.Parent_Appeal__c;
                    rd.Recurring_Gift__c = theRecurring.Id;

                    if (multiCurrenyEnable) {

                        if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                            rd.put('CurrencyIsoCode', selectedCurrencyCode);
                        } else {
                            string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                            List<String> CurrencyValueList = CurrencyValue.split('-');
                            String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                            rd.put('CurrencyIsoCode', CurrencyValue1);
                        }
                    }
                    theRds.add(rd);

                }

                DMLManager.UpsertSObjects(theRds);
            }

            if (thePayment.Id == null)
                thePayment.Donation__c = theGift.Id;

            if (theRecurring.Start_Date__c > system.Today() && thePayment.Payment_Type__c != 'Credit Card') {
                thePayment.Amount__c = 0;
            } else {
                thePayment.Amount__c = theGift.Expected_Amount__c;
            }

            if (theRecurring.Start_Date__c <= system.Today()) {
                DMLManager.UpsertSObject(thePayment);
            }
        }

        if (theGift.Gift_Type__c != 'Recurring' && theGift.Gift_Type__c != 'Pledge') {

            // ** DO Single Gift STUFF **
            if (thePayment.Id == null) {
                thePayment.Donation__c = theGift.Id;
            }

            thePayment.Amount__c = theGift.Expected_Amount__c;
            DMLManager.UpsertSObject(thePayment);

            for (Gift_Detail__c gd : theFinalGifts) {
                gd.Payment__c = thePayment.Id;

                if (gd.Id == null) gd.Gift__c = theGift.Id;

                if (multiCurrenyEnable) {
                    if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                        gd.put('CurrencyIsoCode', selectedCurrencyCode);
                    } else {
                        string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                        List<String> CurrencyValueList = CurrencyValue.split('-');
                        String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                        gd.put('CurrencyIsoCode', CurrencyValue1);
                    }
                }
            }
            DMLManager.UpsertSObjects(theFinalGifts);
        }
        App_Settings__c appSetting1 = App_Settings__c.getInstance(UserInfo.getOrganizationId());
        if (theReceipt.Id == null ) theReceipt.Gift__c = theGift.Id;

        //Upsert the Rreceipt record only if the Gift associated with the Receipt record is not of type "No Receipt", "Consolidated" or Receipt Later is false.
        if ( theGift.Receipt_Type__c  ==  'Single Receipt' && theGift.Receipt_Later__c != true ) {

            shouldInsertReceipt = true;

            theReceipt.Receipt_Type__c = 'Single';
            theReceipt.Receipt_Date__c = theGift.Gift_Date__c;

            //recurring -single gift condition

            if (theGift.Gift_Type__c == 'Recurring' && appSetting1.Enable_Recurring_Receipts__c ) {
                theReceipt.Amount_Receipted__c = thePayment.Amount__c;
            }

            if (thePayment.Payment_Type__c != 'Credit Card') {
                // If Payment is not created then do not create Reciept
                // Payment not created when Gift = Recurring and RD Start Date is Future date

                if (thePayment.Id != null) {
                    if (multiCurrenyEnable) {
                        if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                            theReceipt.put('CurrencyIsoCode', selectedCurrencyCode);
                        } else {
                            string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                            List<String> CurrencyValueList = CurrencyValue.split('-');
                            String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                            theReceipt.put('CurrencyIsoCode', CurrencyValue1);
                        }
                    }

                    DMLManager.UpsertSObject(theReceipt);
                    thePayment.Receipt__c = theReceipt.Id;
                }

                //To update recipt id on Payment Record when Gift type is "Pledge"
                if (thePayments.size() > 0) {
                    for (Payment__c p : thePayments) {
                        p.Receipt__c = theReceipt.Id;
                    }
                    DMLManager.UpsertSObjects(thePayments);
                }
            }
        }

        if (theSoftCredits.size() > 0) {
            for (Solicitor__c s : theSoftCredits) {
                s.Gift__c = theGift.Id;

                if (multiCurrenyEnable) {
                    if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                        s.put('CurrencyIsoCode', selectedCurrencyCode);
                    } else {
                        string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                        List<String> CurrencyValueList = CurrencyValue.split('-');
                        String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                        s.put('CurrencyIsoCode', CurrencyValue1);
                    }
                }
            }
            DMLManager.UpsertSObjects(theSoftCredits);
        }

        if (thePayment.Payment_Type__c == 'Credit Card') {
            List<RecordType> paymentCCRTList = new RecordTypeSelector().SelectBySObjectAndName(NamespacePayment, 'Credit Card');
            if (paymentCCRTList != null && paymentCCRTList.size() > 0) {
                thePayment.RecordTypeId = paymentCCRTList[0].Id;
            }
            shouldSubmit = true;
            return null;
        } else {
            List<RecordType> paymentStandardRTList = new RecordTypeSelector().SelectBySObjectAndName(NamespacePayment, 'Standard');
            if (paymentStandardRTList != null && paymentStandardRTList.size() > 0) {
                thePayment.RecordTypeId = paymentStandardRTList[0].Id;
            }
            if (theGift.Gift_Type__c != 'Pledge' && thePayment.Id != null) {
                DMLManager.UpdateSObject(thePayment);
            }
            return null;
        }
    }

    public void SubmitPayment() {
        boolean result = false;

        try {
            result = UpdatePaymentAndGift(thePayment, theGift, submit(thePayment, theGift.Id));

            if (result && shouldInsertReceipt && thePayment.Payment_Type__c == 'Credit Card') {
                DMLManager.UpsertSObject(theReceipt);
                thePayment.Receipt__c = theReceipt.Id;

                if (thePayment.Id != null) {
                    DMLManager.UpsertSObject(thePayment);
                }
            }
        }
        catch (Exception ex) {
            shouldSubmit = false;

            thePayment.Status__c = 'Declined';
            thePayment.Credit_Card_Number__c = RollupHelper.maskCardNumber(thePayment.Credit_Card_Number__c);

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));

            if (thePayment.Id != null) {
                DMLManager.UpsertSObject(thePayment);
            }
        }

        shouldSubmit = true;
        if (result) {
            shouldSubmit = false;
        }

        if (!result) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in proccessing payment'));
            shouldSubmit = false;
        }
    }

    public PageReference GoBack() {
        if (!isOrg) {
            PageReference pr = new ApexPages.StandardController(theIndividual).view();
            pr.setRedirect(true);
            return pr;
        }

        PageReference pr = new ApexPages.StandardController(theOrg).view();
        pr.setRedirect(true);
        return pr;
    }

    public PageReference GoToPayment() {
        PageReference pr = new ApexPages.StandardController(thePayment).view();
        pr.setRedirect(true);
        return pr;
    }

    public PageReference GoToRecurringGift() {
        PageReference pr = new ApexPages.StandardController(theRecurring).view();
        pr.setRedirect(true);
        return pr;
    }

    public PageReference GoToGift() {
        PageReference pr = new ApexPages.StandardController(theGift).view();
        pr.setRedirect(true);
        return pr;
    }

    @testVisible
    private boolean UpdatePaymentAndGift(Payment__c paymnt, Gift__c gift, BatchGateway4.TransactionResult result) {
        boolean retVal = false;
        if (result.TransactionStatus == null || result.TransactionStatus != 'success') {
            gift.Batch_Status__c = 'Failed';
            paymnt.Status__c = 'Declined';
            if (gift.Gift_Type__c == 'Recurring') {

                deleteallocation = new AllocationSelector().SelectNameAndPaymentByPaymentId(thePayment.id);
                if (deleteallocation != null && deleteallocation.size() > 0) {
                    DMLManager.DeleteSObjects(deleteallocation);
                }

                theGiftDetails.clear();
                theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
                theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
                theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
            }
        } else {
            gift.Batch_Status__c = 'Committed';
            gift.Reference__c = result.RecurringProfileId;

            theRecurring.Reference__c = result.RecurringProfileId;
            theRecurring.Encrypted_Key__c = result.EncryptedRecurringProfileId;

            if (!isOrg) {
                theRecurring.Constituent__c = theIndividual.Id;
            }

            theRecurring.Amount__c = theGift.Expected_Amount__c;
            theRecurring.Credit_Card_Expiry_Date__c = Date.newInstance(tryParseToInt(ccExpY), tryParseToInt(ccExpM), 1);
            theRecurring.Credit_Card__c = RollupHelper.maskCardNumber(paymnt.Credit_Card_Number__c);
            theRecurring.Credit_Card_Type__c = paymnt.Credit_Card_Type__c;

            Integer freq = 1;

            if (theRecurring.Frequency__c == 'Monthly') {
                freq = 30;
            } else if (theRecurring.Frequency__c == 'Quarterly') {
                freq = 90;
            } else if (theRecurring.Frequency__c == 'Annually') {
                freq = 365;
            }

            retVal = true;
        }
        paymnt.Authorization__c = result.ApprovalCode;

        //If Transaction Id is -1 do not add it to CC_Reference__c.
        if (result.TransactionId != '-1') {
            paymnt.CC_Reference__c = result.TransactionId;
        }

        paymnt.Status__c = result.TransactionStatus == null || result.TransactionStatus != 'success' ? 'Declined' : 'Approved';

        if ((result.TransactionId == null || result.TransactionId == '') && result.TransactionStatus == 'success') {
            paymnt.Amount__c = 0;
        }

        paymnt.CC_Transaction_Date__c = Date.today();
        paymnt.Credit_Card_Number__c = RollupHelper.maskCardNumber(paymnt.Credit_Card_Number__c);

        if (result.Errors != null) {
            if (result.Errors.ErrorMessages != null && result.Errors.ErrorMessages.size() > 0) {
                paymentReference = false;
                paymnt.Authorization__c = result.Errors.ErrorMessages[0].ErrorCode;

                paymnt.StatusComment__c = 'REJ ' + result.Errors.ErrorMessages[0].ErrorCode + ':  ' + result.Errors.ErrorMessages[0].Error;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.Errors.ErrorMessages[0].Error));
            } else {
                paymnt.StatusComment__c = 'Approved.  Transaction Number: ' + result.TransactionId;
                paymentReference = true;
            }
        }
        //New Gift Interface: Re-Submit Due to CC Error --fix

        if (result.TransactionStatus == 'success') {
            paymentReference = true;
        }

        if (result.TransactionStatus == 'success' && gift.Gift_Type__c == 'One Time Gift') {
            gift.Status__c = 'Entered';
            DMLManager.UpdateSObject(gift);

            if (result.Errors == null) {
                paymnt.StatusComment__c = 'Approved.  Transaction Number: ' + result.TransactionId;
            }
        }

        //if the Transaction gets success and Gift Type is recurring then it creates recurring gift
        if ( gift.Gift_Type__c == 'Recurring') {
            if (result.TransactionStatus == 'success') {
                List<Gift_Detail__c> theFinalGifts = getGiftDetailstoUpdate();
                if (theFinalGifts == null) return null;
                if (theFinalGifts.size() <= 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: At least one Allocation is required.'));
                    return null;
                }

                Decimal total = 0;
                for (Gift_Detail__c gd : theFinalGifts) {
                    total = total + gd.Amount__c;
                }

                //if Payment Type is Credit card then it inserts the recurring gift record.
                if (paymnt.Payment_Type__c == 'Credit Card') {
                    if (theRecurring.Start_Date__c > system.Today()) {
                        paymnt.Amount__c = 0;
                    }

                    if (multiCurrenyEnable) {
                        if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                            theRecurring.put('CurrencyIsoCode', selectedCurrencyCode);
                        } else {
                            string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                            List<String> CurrencyValueList = CurrencyValue.split('-');
                            String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                            theRecurring.put('CurrencyIsoCode', CurrencyValue1);
                        }
                    }

                    DMLManager.UpsertSObject(theRecurring);

                    gift.Recurring_Donation__c = theRecurring.Id;

                    DMLManager.UpsertSObject(gift);

                    List<Gift_Detail__c> theGds = new List<Gift_Detail__c>();

                    if (theRecurring.Start_Date__c <= system.Today() ) {

                        for (Gift_Detail__c gd : theFinalGifts) {

                            Gift_Detail__c nGd = new Gift_Detail__c();
                            nGd.Payment__c = paymnt.Id;
                            nGd.Amount__c = gd.Amount__c;
                            nGd.New_Campaign__c = gd.New_Campaign__c;
                            nGd.Campaign__c = gd.Campaign__c;
                            nGd.Fund__c = gd.Fund__c;
                            nGd.Allocation_Date__c = paymnt.Date__c;
                            nGd.Parent_Appeal__c = gd.Parent_Appeal__c;
                            nGd.Gift__c = gift.Id;

                            if (multiCurrenyEnable) {
                                if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {
                                    nGd.put('CurrencyIsoCode', selectedCurrencyCode);
                                } else {
                                    string CurrencyValue = Merchant_gateway_key.get(selectedCurrencyCode);
                                    List<String> CurrencyValueList = CurrencyValue.split('-');
                                    String CurrencyValue1 = CurrencyValueList[0].replace(' ', '');
                                    nGd.put('CurrencyIsoCode', CurrencyValue1);
                                }
                            }

                            theGDs.add(nGd);
                        }
                    }

                    DMLManager.InsertSObjects(theGDs);
                }

                Integer freq = 1;

                if (theRecurring.Frequency__c == 'Monthly') {
                    freq = 30;
                } else if (theRecurring.Frequency__c == 'Quarterly') {
                    freq = 90;
                } else if (theRecurring.Frequency__c == 'Annually') {
                    freq = 365;
                }

                DMLManager.UpsertSObject(theRecurring);

                List<RD_Allocation__c> theRDs = new List<RD_Allocation__c>();

                if (theRecurring.Start_Date__c == system.Today()) {
                    for (Gift_Detail__c gd : getGiftDetailstoUpdate()) {
                        RD_Allocation__c rda = new RD_Allocation__c();
                        rda.Recurring_Gift__c = theRecurring.Id;
                        rda.Amount__c = gd.Amount__c;
                        rda.New_Campaign__c = gd.New_Campaign__c;
                        rda.Fund__c = gd.Fund__c;
                        rda.Package__c = gd.Package__c;
                        rda.Campaign__c = gd.Campaign__c;
                        rda.Parent_Appeal__c = gd.Parent_Appeal__c;

                        theRds.add(rda);
                    }

                    DMLManager.UpsertSObjects(theRds);
                }

                gift.Next_Payment_Date__c = theRecurring.Start_Date__c.addDays(freq);
                gift.Recurring_Donation__c = theRecurring.Id;
                gift.Status__c = 'Active';

                DMLManager.UpdateSObject(gift);
            }
        }

        if (theGift.Gift_Type__c == 'Recurring' && paymnt.Payment_Type__c != 'Credit Card') {

            Integer freq = 1;

            if (theRecurring.Frequency__c == 'Monthly') {
                freq = 30;
            } else if (theRecurring.Frequency__c == 'Quarterly') {
                freq = 90;
            } else if (theRecurring.Frequency__c == 'Annually') {
                freq = 365;
            }

            DMLManager.UpdateSObject(theRecurring);

            List<RD_Allocation__c> theRDs = new List<RD_Allocation__c>();

            for (Gift_Detail__c gd : getGiftDetailstoUpdate()) {
                RD_Allocation__c rda = new RD_Allocation__c();
                rda.Recurring_Gift__c = theRecurring.Id;
                rda.Amount__c = gd.Amount__c;
                rda.New_Campaign__c = gd.New_Campaign__c;
                rda.Fund__c = gd.Fund__c;
                rda.Package__c = gd.Package__c;
                rda.Campaign__c = gd.Campaign__c;
                rda.Parent_Appeal__c = gd.Parent_Appeal__c;
            }

            gift.Next_Payment_Date__c = theRecurring.Start_Date__c.addDays(freq);
            gift.Recurring_Donation__c = theRecurring.Id;
            gift.Status__c = 'Active';

            DMLManager.UpdateSObject(gift);
        }

        if (result.TransactionStatus != 'success') {
            gift.Status__c = 'Cancelled';

            DMLManager.UpdateSObject(gift);
        }

        if (paymnt.Id != null) {
            DMLManager.UpdateSObject(paymnt);
        }

        return retVal;
    }

    private BatchGateway4.TransactionResult submit(Payment__c paymnt, string giftId) {
        BatchSettings__c BatchSettings = null;
        BatchSettings__c settingObj = BatchSettings__c.getInstance('Default');

        if (settingObj != null) {
            BatchSettings = settingObj;
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

        if (!isOrg) {
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
        } else {
            payment.address1 = theOrg.BillingStreet;
            payment.city = theOrg.BillingCity;
            payment.state = theOrg.BillingState;
            payment.country = theOrg.BillingCountry;
            payment.zipCode = theOrg.BillingPostalCode;
            payment.donationType = 'ORG';
            payment.email = theOrg.Email__c;
            payment.isIndividual = false;

            payment.PayerFirstName = FirstName;
            payment.PayerLastName = lastName;
        }

        if (theGift.Gift_Type__c == 'Recurring') {
            payment.billingStartDate = theRecurring.Start_Date__c;
        } else {
            payment.billingStartDate = date.today();
        }

        payment.numberOfPayments = '';
        payment.isRecurring = (theGift.Gift_Type__c == 'Recurring');
        payment.constituentType = 'Existing';
        payment.amount = paymnt.Amount__c.format();
        payment.creditCardNumber = ccNumber;
        payment.creditCardType = paymnt.Credit_Card_Type__c;
        payment.cvv2 = ccCVV;
        payment.currencyType = BatchSettings.CurrencyCode__c;
        payment.expiryMonth = tryParseToInt(ccExpM);
        payment.expiryYear = tryParseToInt(ccExpY);
        payment.frequency = (theGift.Gift_Type__c == 'Recurring') ? theRecurring.Frequency__c : '';
        payment.giftId = giftId;
        payment.paymentId = paymnt.Id;
        form.payments.payment.add(payment);
        txResults = new BatchGateway4.ArrayOfTransactionResult();

        //for multi currency
        if (multiCurrenyEnable) {
            string thepaymentkey = selectedCurrencyCode;
            txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0', selectedCurrencyCode);
        } else {
            String userId = UserInfo.getUserId();
            User user;
            List<User> userList = new UserSelector().SelectSObjectsById(new Set<Id> { userId });
            if (userList != null && userList.size() > 0) {
                user = userList[0];
                txResults = gw.SubmitBatch(formBase, form, 'http://www.force.com', '1.0', user.Payment_Gateway_Account_ID__c);
            }
        }

        if (txResults != null && txResults.TransactionResult != null && txResults.TransactionResult.size() > 0) {
            return txResults.TransactionResult[0];
        } else {
            return null;
        }
    }

    private BatchGateway4.ArrayOfSerializableKeyValuePairOfStringString GetMerchantKeyValueCurrency(string orgId) {
        BatchGateway4.GatewaySoap gw = new BatchGateway4.GatewaySoap();

        BatchSettings__c BatchSettings = BatchSettings__c.getInstance('Default');
        if (BatchSettings != null) {
            gw.endpoint_x = BatchSettings.GatewayUrl__c;
        }

        gw.timeout_x = 120000;
        BatchGateway4.ArrayOfSerializableKeyValuePairOfStringString txtResultsGateway = new BatchGateway4.ArrayOfSerializableKeyValuePairOfStringString();
        txtResultsGateway = gw.GetActiveCurrenciesByOrganizationId(orgId);

        return txtResultsGateway;
    }

    public List<Solicitor__c> getSotCreditsToUpdate() {
        List<Solicitor__c> result = new List<Solicitor__c>();

        for (Solicitor__c s : softCredits) {
            if (RollupHelper.IsEmptyOrNull(s.Organization_Solicitor__c) && RollupHelper.IsEmptyOrNull(s.Solicitor__c) && s.Custom_Amount__c == null) {
                continue;
            }

            if (RollupHelper.IsEmptyOrNull(s.Organization_Solicitor__c) && RollupHelper.IsEmptyOrNull(s.Solicitor__c) && s.Custom_Amount__c != null) {
                s.addError('Soft Credits: Either Individual Solicitor or Organization Solicitor should be entered');
                return null;

            }

            if (!RollupHelper.IsEmptyOrNull(s.Organization_Solicitor__c) && !RollupHelper.IsEmptyOrNull(s.Solicitor__c) && s.Custom_Amount__c != null) {
                s.addError('Soft Credits: Either Individual Solicitor or Organization Solicitor should be entered, both cannot be entered.');
                return null;

            }

            if ( s.Custom_Amount__c != null && ( s.Custom_Amount__c <= 0 || s.Custom_Amount__c > theGift.Expected_Amount__c ) ) {
                s.addError('Soft Credits: Custom Amount should be a positive value and should not exceed the Transaciton Amount.');
                return null;
            }

            result.add(s);
        }

        return result;
    }

    public List<Gift_Detail__c> getGiftDetailstoUpdate() {
        List<Gift_Detail__c> result = new List<Gift_Detail__c>();

        for (Gift_Detail__c gd : theGiftDetails) {

            if (RollupHelper.IsEmptyOrNull(gd.New_Campaign__c) && RollupHelper.IsEmptyOrNull(gd.Fund__c) && gd.Amount__c == null) continue;

            if (gd.Allocation_Date__c == null) { gd.addError('Allocations: Allocation date is required.'); return null; }

            if (RollupHelper.IsEmptyOrNull(gd.New_Campaign__c)) { gd.addError('Allocations: Allocation Appeal is required'); return null; }

            if (RollupHelper.IsEmptyOrNull(gd.Fund__c)) { gd.addError('Allocations: Allocation Fund is required'); return null; }

            if (gd.Amount__c == null) { gd.addError('Allocations: Allocation Amount is required'); return null; }

            List<RecordType> RT =  new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectType('Campaign', 'Campaign', Utilities.getCurrentNamespace());

            Campaign cmp;
            List<Campaign> campaignList = new CampaignSelector().SelectRecordTypeIdById(new Set<Id> { gd.New_Campaign__c });
            if (campaignList != null && campaignList.size() > 0) {
                cmp = campaignList[0];
            }

            //If Appeal record is not of type Appeal or Event, Send Error message.
            if (RT.size() > 0) {
                if (cmp.RecordTypeId == RT[0].Id) {
                    gd.addError('Appeal: "' + cmp.Name + '" must be of type Appeal or Event.'); return null;
                }
            }
            result.add(gd);
        }

        return result;
    }

    public integer tryParseToInt(String txt) {
        integer result = 0;

        try {
            result = integer.valueOf(txt);
        } catch (Exception ex) { }

        return result;
    }

    //** Used to feed Javascript to Dynamicly populate fund when an Appeal is selected ** //
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

            if (camps[0].Letter__c != null) {
                setting.LetterName = camps[0].Letter__r.Name;
            }

            if (camps[0].Fund__c != null) {
                setting.FundName = camps[0].Fund__r.Name;
            }

            return setting;
        } else {
            return new BatchAllocationSetting();
        }
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

        for (Integer i = 0; i < 10; i++) {
            options.add(new SelectOption(String.valueOf(Date.Today().Year() + i), String.valueOf(Date.Today().Year() + i)));
        }

        return options;
    }

    public void addGiftDetail() {
        theGiftDetails.add(new Gift_Detail__c(Allocation_Date__c = Date.Today()));
    }

    public void addSoftCredit() {
        softCredits.add(new Solicitor__c());
    }

    public void addPayment() {
        thePayments.add(new Payment__c());
    }

    public void addInstallment() {
        theInstallments.add(new Installment__c());
    }

    public void removeGiftDetail() {

        Integer count = 0;
        string ind = ApexPages.currentPage().getParameters().get('ind');
        Integer selectedIndex = 1;

        if (ind != null && ind != '') selectedIndex = Integer.valueOf(ind);

        for (Gift_Detail__c gd : theGiftDetails) {
            count++;
            if (count == selectedIndex ) {
                theGiftDetails.remove(count - 1);
                break;
            }
        }
    }

    public void changeReceipttype() {

        if (theGift.Gift_Type__c == 'Recurring') {
            theGift.Receipt_Type__c = 'Consolidated';
        } else {
            theGift.Receipt_Type__c = 'Single Receipt';
        }
    }

    //added by nitin to check exsiting org has currency enabled or not
    public Boolean checkMCEnabled() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType mcEnabled = gd.get('CurrencyType');
        return (mcEnabled != null) ? true : false;
    }

    //To get list of enabled currencies in org
    public List<selectOption> getPicklistValues() {

        list<SelectOption> options = new list<SelectOption>();

        string ObjectApi_name = 'CurrencyType';
        String Accountapi = 'Account';
        String Field_name = 'IsoCode';
        String Field_name1 = 'CurrencyIsoCode';

        // Get the object type of the SObject.
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        String defalutval;

        if (targetType != null ) {

            Sobject Object_name = targetType.newSObject();

            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject

            if (thePayment.Payment_Type__c != 'Credit Card' && thePayment.Payment_Type__c != 'ACH/PAD') {

                Schema.SObjectType targetType1 = Schema.getGlobalDescribe().get(Accountapi);
                Sobject Object_name1 = targetType1.newSObject();
                Schema.sObjectType sobject_type1 = Object_name1.getSObjectType(); //grab the sobject that was passed
                Schema.DescribeSObjectResult sobject_describe1 = sobject_type1.getDescribe(); //describe the sobject
                Map<String, Schema.SObjectField> field_map1 = sobject_describe1.fields.getMap(); //get a map of fields for the passed sobject
                List<Schema.PicklistEntry> pick_list_values1 = field_map1.get(Field_name1).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject

                for (Schema.PicklistEntry a1 : pick_list_values1) {
                    for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                        if (a.getValue() == a1.getValue()) {
                            options.add(new SelectOption(a.getValue(), a.getLabel()));
                        }
                    }
                }
                selectedCurrencyCode = selectedCurrencyCode1;
            } else {
                multicurrencytest();
                Set<Id> CurrencyList = Merchant_gateway_key.KeySet();

                for (string m : CurrencyList) {
                    String value = Merchant_gateway_key.get(m);

                    if (value.contains('-')) {

                        List<String> valuelist = value.split('-');
                        for (Schema.PicklistEntry a : pick_list_values) {

                            if (valuelist[0].replace(' ', '').equals(a.getValue())) {
                                options.add(new SelectOption(m, a.getLabel() + valuelist[1]));
                            }
                        }

                        if (valuelist[0].replace(' ', '').equals(selectedCurrencyCode1)) {
                            defalutval = m;
                        }
                    }

                    else {
                        for (Schema.PicklistEntry a : pick_list_values) {
                            if (Merchant_gateway_key.get(m) == a.getValue()) {
                                options.add(new SelectOption(m, a.getLabel()));
                            }
                        }

                        if ( Merchant_gateway_key.get(m) == selectedCurrencyCode1 ) {
                            defalutval = m;
                        }
                    }
                }
                selectedCurrencyCode = defalutval;
            }
            return options;
        }
        return null;
    }

    public PageReference contactFieldSet() {
        try {
            if (string.isEmpty(hiddenInputValue)) {
                FirstName = '';
                lastName = '';
                hiddenInputValue = '';
            }
        } catch (Exception ex) {}

        return null;
    }
}