public with sharing class RecurringGiftManagementExtension {

    public with sharing class AllocationWrapper {
        Public String aId { get; set; }
        Public String aName { get; set; }
        Public Id aFundId { get; set; }
        Public String aFundName { get; set; }
        Public Id aAppealId { get; set; }
        Public String aAppealName { get; set; }
        Public Decimal aAmount { get; set; }
        Public RD_Allocation__c aAllocation { get; set; }

        public AllocationWrapper() {
            aAllocation = new RD_Allocation__c();
        }

        public AllocationWrapper(RD_Allocation__c a) {
            aAllocation = a;
            aId = a.Id;
            aName = a.Name;
            aAppealId = a.New_Campaign__c;
            aAppealName = a.New_Campaign__r.Name;
            aFundId = a.Fund__c;
            aFundName = a.Fund__r.Name + ' : ' + a.Fund__r.Fund_Name__c;
            aAmount = a.Amount__c;
        }
    }

    private final String ACCOUNT_TYPE_UNDEFINED = 'Undefined';
    private final String ERROR_SYSTEM_UNAVALIABLE = 'The system is temporarly unavaliable, Please try again later.';
    private final String ERROR_INVALID_DATA = 'The data that you have entered was invalid.';
    private final String ERROR_PROCESSING = 'A unexpected error occured while processing your request, Please contact the system administrator.';
    private final String BANK_ERROR_CODE = '900';
    private final String GENERIC_ERROR_CODE = '823';
    private final Integer REQUEST_TIMEOUT = 120000;
    private final Date MIN_DATE = Date.newInstance(0001, 1, 1);

    private Date originalBeginDate;
    private Decimal originalScheduleDate;
    private String originalStatus;
    private BatchGateway4.GatewaySoap Gateway;
    private Boolean FirstTime;
    private Contact individual;

    private List<AllocationWrapper> allocationWrapperList;

    public String recurringGiftId { get; set; }
    public String recurringGiftName { get; set; }
    public String status { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public decimal amount { get; set; }
    public String frequency { get; set; }
    public String address { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String postalCode { get; set; }
    public String country { get; set; }
    public String accountType { get; set; }
    public String ccAccountType { get; set; }
    public String achAccountType { get; set; }
    public String accountNumber { get; set; }
    public String routingNumber { get; set; }
    public String expirationDate { get; set; }
    public String sortCode1 { get; set; }
    public String sortCode2 { get; set; }
    public String sortCode3 { get; set; }
    public Date beginDate { get; set; }
    public Date endDate { get; set; }
    public Decimal scheduleDate { get; set; }
    public Date nextPaymentDate { get; set; }
    public String paymentType { get; set; }
    public Boolean isCC { get; set; }
    public String cancellationReason { get; set; }
    public static String PackageNamespace { get; set; }

    public Boolean UkCancelled { get; set; }
    public Boolean IsReferenceNumberIats { get; set; }
    public Boolean Success { get; set; }
    public List<SelectOption> CountriesList { get; set; }
    public String SelectedCountry { get; set; }
    public List<String> errors;
    public List<String> validationErrors;
    public BatchGateway4.RecurringProfile recurringProfile { get; set; }
    public Recurring_Donation__c currentRecord { get; set; }
    public List<RD_Allocation__c> Allocations { get; set; }
    public List<SelectOption> ScheduleDateOptions { get; set; }
    public List<SelectOption> StatusOptions { get; set; }
    public List<SelectOption> FrequencyOptions { get; set; }

    public String RoutingNumberTitle { get; set; }
    public String AllocationTitle { get; set; }

    public Integer NewAllocationCount { get; set; }
    public AllocationWrapper NewAllocation { get; set; }
    public AllocationWrapper EditAllocation { get; set; }
    public List<RD_Allocation__c> AllocationsToDelete { get; set; }
    public String IdToDelete { get; set; }
    public String IdToEdit { get; set; }
    public Boolean AreThereDeclinedPayments { get; set; }

    public List<AllocationWrapper> AllocationList
    {
        get {
            if (allocationWrapperList == null) {
                allocationWrapperList = new List<AllocationWrapper>();
                for (RD_Allocation__c a : Allocations){
                    allocationWrapperList.add(new AllocationWrapper(a));
                }
            }
            return allocationWrapperList;
        }
        public set;
    }


    public RecurringGiftManagementExtension() {
        Initialize();
    }

    public RecurringGiftManagementExtension(ApexPages.StandardController stdController) {
        Initialize();
    }

    private void Initialize() {
        recurringGiftId = ApexPages.currentPage().getParameters().get('id');
        currentRecord = null;

        String fields = '';
        String clause = '';

        if (recurringGiftId != null && !String.isBlank(recurringGiftId)) {

            Recurring_Donation__c[] records = new RecurringDonationSelector().SelectDonationByRecurringId(recurringGiftId);

            if (records != null && records.size() > 0) {

                paymentType = records[0].Type__c;
                IsReferenceNumberIats = utilities.IsGatewayIatsOrEziDebit(records[0].Reference__c);

                Allocations = GetAllocations();

                if (AreAllocationsInitialized()) {
                    fields = 'Id,firstname,lastname,MailingState,MailingPostalCode,MailingCountry,MailingStreet,MailingCity';
                    clause = 'Id = \'' + records[0].Constituent__r.Id + '\'';

                    List<Contact> contacts = new GenericQueryBuilder().ListQueryBuilderWhere('Contact', fields, clause);

                    if (contacts != null && contacts.size() > 0) {
                        currentRecord = records[0];
                        individual = contacts[0];

                        fields = 'Id,Recurring_Donation__c';
                        clause = 'Recurring_Donation__c =\'' + recurringGiftId + '\' AND Status__c = \'Active\' ORDER BY Gift_Date__c DESC LIMIT 1';

                        List<Gift__c> recentGift = new GenericQueryBuilder().ListQueryBuilderWhere('Gift__c', fields, clause);

                        if (recentGift != null && recentGift.size() > 0) {
                            List<Payment__c> declinedPayments = GetDeclinedPayments(recentGift[0].Id);
                            AreThereDeclinedPayments = (declinedPayments != null && declinedPayments.size() > 0);
                        } else {
                            AreThereDeclinedPayments = false;
                            clause = 'Recurring_Donation__c =\'' + recurringGiftId + '\' ORDER BY Gift_Date__c DESC LIMIT 1';

                            List<Gift__c> transactions = new GenericQueryBuilder().ListQueryBuilderWhere('Gift__c', fields, clause);

                            if (transactions == null || transactions.size() < 1) {
                                AddValidationError('The Recurring Gift you are reactivating is not associated with a Transaction. Please create a Transaction for this Recurring Gift first.');
                            }
                        }

                        ResetAllocationProperties();

                        Success = false;
                        FirstTime = true;

                        InitializeTitles();
                        InitializeGateway();
                        InitializeProperties();
                        InitializeStatusDropDown();
                        InitializeCountryDropDown();
                        InitializeFrequencyDropDown();
                        InitializeScheduleDateDropDown();
                    } else {
                        AddValidationError('The recurring gift requires a contact to be editable.');
                    }
                } else {
                    AddValidationError('The recurring gift requires allocations to be editable.');
                }
            }
        }
        SetNamespace();
    }

    public PageReference redirect() {
        if (currentRecord == null) {
            return CreateErrorPageReference();
        } else  {
            if (IsRecurringGiftOffline()) {
                return CreateRedirectToDefaultEditPage();
            } else {
                return null;
            }
        }
    }

    public PageReference updateProfile() {
        PageReference pageRef = null;

        try
        {
            if (currentRecord != null) {
                errors = new List<String>();
                AssignRecurringProfile();
                FirstTime = false;

                if (!Test.isRunningTest()) {
                    try {
                        BatchGateway4.TransactionResult updateResult = Gateway.UpdateRecurringGift(recurringProfile);

                        if (updateResult != null) {

                            if (updateResult.TransactionStatus == 'success') {
                                if (DoesResultHaveErrors(updateResult)) {
                                    HandleErrors(updateResult);
                                } else {
                                    UpdateRecurringGift();
                                }
                            } else {
                                if (DoesResultHaveErrors(updateResult)) {
                                    HandleErrors(updateResult);
                                }
                            }
                        } else {
                            errors = new List<String> {
                                ERROR_SYSTEM_UNAVALIABLE
                            };
                        }
                    } catch (Exception ex) {
                        if (ex.getMessage().contains('XML')) {
                            errors.add(ERROR_INVALID_DATA);
                        } else {
                            errors.add(GetExceptionMessage(ex));
                        }
                    }
                }
            } else {
                pageRef = CreateErrorPageReference();
            }
        } catch (Exception ex) {
            errors.add(GetExceptionMessage(ex));
        }

        return pageRef;
    }

    public PageReference cancel(){
        String retUrl = '/' + recurringGiftId;
        PageReference pageRef = new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public String[] getErrors() {
        return errors;
    }

    public String[] getValidationErrors() {
        return validationErrors;
    }

    @RemoteAction
    public static List<Campaign> GetAppeals(String keyword) {

        List<Campaign> appealList = new List<Campaign>();
        String clause;

        if (keyword != null && keyword.trim() != '') {
            keyword = '%' + keyword + '%';
            clause = 'AND Name LIKE \'' + keyword + '\' LIMIT 20';
            appealList = new CampaignSelector().SelectFundByNamespace(clause, Utilities.getCurrentNamespace());
        } else {
            clause = 'LIMIT 20';
            appealList = new CampaignSelector().SelectFundByNamespace(clause, Utilities.getCurrentNamespace());
        }

        return appealList;
    }

    @RemoteAction
    public static List<Fund__c> GetFunds(String keyword) {

        List<Fund__c> fundList = new List<Fund__c>();
        String whereClause = '';
        String fields = 'ID, Name, Fund_Name__c';

        if (keyword != null && keyword.trim() != '') {
            keyword = '%' + keyword + '%';
            whereClause = 'Inactive__c = false AND (Name LIKE \'' + keyword + '\' OR Fund_Name__C LIKE \'' + keyword + '\') LIMIT 20';
            fundList = new GenericQueryBuilder().ListQueryBuilderWhere('Fund__c', fields, whereClause);
        } else {
            whereClause = 'Inactive__c = false LIMIT 20';
            fundList = new GenericQueryBuilder().ListQueryBuilderWhere('Fund__c', fields, whereClause);
        }

        return fundList;
    }

    public PageReference AddAllocation() {
        PageReference pageRef = null;

        NewAllocationCount++;
        NewAllocation.aAllocation.Recurring_Gift__c = recurringGiftId;
        NewAllocation.aAllocation.Active__c = true;

        Campaign appeal = GetCampaign(NewAllocation.aAllocation.New_Campaign__c);
        Fund__c fund = GetFund(NewAllocation.aAllocation.Fund__c);

        NewAllocation.aAppealId = appeal.Id;
        NewAllocation.aAppealName = appeal.Name;
        NewAllocation.aAllocation.New_Campaign__c = appeal.Id;
        NewAllocation.aFundId = fund.Id;
        NewAllocation.aFundName = fund.Name;
        NewAllocation.aAllocation.Fund__c = fund.Id;
        NewAllocation.aAmount = NewAllocation.aAllocation.Amount__c;
        NewAllocation.aAllocation.Amount__c = NewAllocation.aAllocation.Amount__c;
        NewAllocation.aAppealId = appeal.Id;
        NewAllocation.aName = 'New Allocation ' + NewAllocationCount;
        NewAllocation.aId = 'newAlloc' + NewAllocationCount;

        AllocationList.add(NewAllocation);
        NewAllocation = new AllocationWrapper();

        return pageRef;
    }

    public PageReference EditAllocation() {

        for (Integer i = AllocationList.size() -1; i >= 0; i--) {
            if (AllocationList[i].aId == idToEdit) {

                Campaign appeal = GetCampaign(EditAllocation.aAllocation.New_Campaign__c);
                Fund__c fund = GetFund(EditAllocation.aAllocation.Fund__c);

                AllocationList[i].aAmount = EditAllocation.aAllocation.Amount__c;
                AllocationList[i].aAllocation.Amount__c = EditAllocation.aAllocation.Amount__c;
                AllocationList[i].aAppealId = appeal.Id;
                AllocationList[i].aAppealName = appeal.Name;
                AllocationList[i].aAllocation.New_Campaign__c = EditAllocation.aAllocation.New_Campaign__c;
                AllocationList[i].aFundId = Fund.Id;
                AllocationList[i].aFundName = Fund.Name;
                AllocationList[i].aAllocation.Fund__c = EditAllocation.aAllocation.Fund__c;
            }
        }

        return null;
    }

    public PageReference DeleteAllocation() {

        for (Integer i = AllocationList.size() -1; i >= 0; i--) {
            if (AllocationList[i].aId == idToDelete) {
                AllocationsToDelete.add(AllocationList[i].aAllocation);
                AllocationList.remove(i);
            }
        }

        return null;
    }

    public List<RD_Allocation__c> GetAllocations(){
        return new RDAllocationSelector().SelectAllocationDetails(recurringGiftId);
    }

    private Campaign GetCampaign(string id) {
        String clause = 'Id =\'' + id + '\' LIMIT 1';
        return (Campaign)new GenericQueryBuilder().ObjectQueryBuilderWhere('Campaign', 'Id,Name', clause);
    }

    private Fund__c GetFund(string id) {
        String clause = 'Id =\'' + id + '\' LIMIT 1';
        return (Fund__c)new GenericQueryBuilder().ObjectQueryBuilderWhere('Fund__c', 'Id,Name', clause);
    }

    private PageReference CreateRedirectToDefaultEditPage() {
        String retUrl = '/' + recurringGiftId + '/e?nooverride=1&retURL=' + recurringGiftId;
        PageReference pageRef = new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }

    private void InitializeTitles() {

        RoutingNumberTitle = 'Routing Number';

        String locale = UserInfo.getLocale();

        if (IsLocaleCanada(locale)) {
            RoutingNumberTitle = 'Bank and Transit Number';
        } else if (IsLocaleAustralia(locale)) {
            RoutingNumberTitle = 'BSB Number';
        }
    }

    private void InitializeGateway() {
        Gateway = new BatchGateway4.GatewaySoap();
        Gateway.timeout_x = REQUEST_TIMEOUT;

        if (!Test.isRunningTest()) {
            BatchSettings__c settingObj = BatchSettings__c.getInstance('Default');

            if (settingObj != null) {
                Gateway.endpoint_x = settingObj.GatewayUrl__c;
            }
        }
    }

    private void InitializeProperties() {
        status = currentRecord.Status__c;

        ValidateCurrentRecord();

        recurringGiftName = currentRecord.name;
        beginDate = currentRecord.Start_Date__c;
        originalBeginDate = currentRecord.Start_Date__c;
        originalStatus = currentRecord.Status__c;
        endDate = currentRecord.End_Date__c;

        if (IsNewPaymentStartDateAssigned()) {
            beginDate = currentRecord.New_Payment_Start_Date__c;
            originalBeginDate = currentRecord.New_Payment_Start_Date__c;
        }

        if (IsScheduleDateAssigned()) {
            scheduleDate = currentRecord.Schedule_Date__c;
        } else {
            scheduleDate = beginDate.day();
        }

        originalScheduleDate = scheduleDate;
        firstName = individual.firstname;
        lastName = individual.lastname;
        amount = currentRecord.Amount__c;
        frequency = currentRecord.Frequency__c;
        address = individual.MailingStreet;
        city = individual.MailingCity;
        state = individual.MailingState;
        postalCode = individual.MailingPostalCode;

        if (individual.MailingCountry == null || individual.MailingCountry == '') {
            String clause = 'Id =\'' + UserInfo.getUserId() + '\'';
            User currentUser = (User)new GenericQueryBuilder().ObjectQueryBuilderWhere('User', 'Country,Id', clause);
            if (currentUser != null && currentUser.Country != null) {
                country = currentUser.Country;
            }
        } else {
            country = individual.MailingCountry;
        }

        accountNumber = currentRecord.Account__c;
        nextPaymentDate = currentRecord.Next_Payment_Date__c;
        paymentType = currentRecord.Type__c;
        cancellationReason = currentRecord.Cancellation_Reason__c;
        isCC = false;

        if (IsPaymentTypeCreditCard()) {
            isCC = true;
            if (currentRecord.Credit_Card_Expiry_Date__c != null) {
                Integer year = currentRecord.Credit_Card_Expiry_Date__c.year();
                Integer month = currentRecord.Credit_Card_Expiry_Date__c.month();
                String stringMonth = (month < 10) ? '0' + String.valueOf(month) : String.valueOf(month);
                expirationDate = stringMonth + '/' + String.valueOf(year).right(2);
            } else {
                expirationDate = null;
            }
            accountNumber = currentRecord.Credit_Card__c;
            ccAccountType = ConvertCreditCardTypeToIats();
        } else if (IsPaymentTypeAch()) {
            achAccountType = ACCOUNT_TYPE_UNDEFINED;    // no field on RG to pull from
            routingNumber = currentRecord.Branch_Num__c;
        } else if (IsPaymentTypeUkDirectDebit()) {
            UkCancelled = (FirstTime && IsStatusCancelled());
            routingNumber = currentRecord.Sort_Code__c;
            if (routingNumber != null && routingNumber != '') {
                sortCode1 = routingNumber.substring(0, 2);
                sortCode2 = routingNumber.substring(2, 4);
                sortCode3 = '**';
            } else {
                sortCode1 = '';
                sortCode2 = '';
                sortCode3 = '';
            }
            accountType = ACCOUNT_TYPE_UNDEFINED;
        }
    }

    private void InitializeCountryDropDown() {
        if (!Test.isRunningTest()) {
            BatchGateway4.CountryHelper countries = Gateway.GetCountries();
            if (countries != null) {
                CountriesList = new List<SelectOption>();
                if (countries.Countries != null && countries.Countries.Country.size() > 0) {
                    for (Integer i = 0; i < countries.Countries.Country.size(); i++) {
                        BatchGateway4.Country tempCountry = countries.Countries.Country[i];
                        CountriesList.add(new SelectOption(tempCountry.CountryCode, tempCountry.DisplayName));
                        if (country == tempCountry.DisplayName) {
                            SelectedCountry = tempCountry.CountryCode;
                        }
                    }
                }
            }
        }
    }

    private void InitializeScheduleDateDropDown() {
        ScheduleDateOptions = new List<SelectOption>();

        for (Integer day = 1; day <= 31; day++) {
            ScheduleDateOptions.add(new SelectOption(string.valueOf(day), string.valueOf(day)));
        }
    }

    private void InitializeStatusDropDown() {
        StatusOptions = new List<SelectOption>();

        StatusOptions.add(new SelectOption('Active', 'Active'));
        StatusOptions.add(new SelectOption('On Hold', 'On Hold'));
        StatusOptions.add(new SelectOption('Cancelled', 'Cancelled'));
    }

    private void InitializeFrequencyDropDown() {
        FrequencyOptions = new List<SelectOption>();

        if (currentRecord.Frequency__c == 'Weekly') {
            FrequencyOptions.add(new SelectOption('Weekly', 'Weekly'));
        }

        FrequencyOptions.add(new SelectOption('Monthly', 'Monthly'));
        FrequencyOptions.add(new SelectOption('Quarterly', 'Quarterly'));
        FrequencyOptions.add(new SelectOption('Annually', 'Annually'));
    }

    private void AssignRecurringProfile() {
        recurringProfile = new BatchGateway4.RecurringProfile();

        if (IsPaymentTypeCreditCard()) {
            accountType = ccAccountType;
        } else if (IsPaymentTypeAch()) {
            accountType = achAccountType;
        } else {
            accountType = ACCOUNT_TYPE_UNDEFINED;
        }

        if (accountNumber != null && accountNumber != '') {
            recurringProfile.AccountNumber = accountNumber;
        }

        recurringProfile.AccountType = accountType;
        recurringProfile.Address = address;

        Decimal newAmount = 0;
        for (AllocationWrapper allocation : AllocationList) {
            allocation.aAllocation.Amount__c = allocation.aAllocation.Amount__c.setScale(2);
            newAmount += allocation.aAllocation.Amount__c;
        }

        recurringProfile.Amount = newAmount.setScale(2);
        recurringProfile.BeginDate = beginDate;

        if (endDate == null) {
            endDate = MIN_DATE;
        }

        recurringProfile.EndDate = endDate;
        recurringProfile.ScheduleDate = Integer.valueOf(scheduleDate);
        recurringProfile.City = city;
        recurringProfile.Country = country;
        recurringProfile.CustomerCode = currentRecord.Reference__c;
        recurringProfile.Cvv = '';
        recurringProfile.FirstName = firstName;
        recurringProfile.Frequency = frequency;
        recurringProfile.IsCC = isCC;
        recurringProfile.LastName = lastName;

        if (nextPaymentDate == null) {
            nextPaymentDate = DetermineNextPaymentDate();
        }

        recurringProfile.NextPaymentDate = nextPaymentDate;
        recurringProfile.PaymentType = paymentType;
        recurringProfile.PostalCode = postalCode;

        if (IsPaymentTypeUkDirectDebit()) {
            recurringProfile.RoutingNumber = sortCode1 + sortCode2 + sortCode3;
            recurringProfile.AccountType = ACCOUNT_TYPE_UNDEFINED;
        } else if (IsPaymentTypeAch()) {
            if (routingNumber != null && routingNumber != '') {
                recurringProfile.RoutingNumber = routingNumber;
            } else {
                recurringProfile.RoutingNumber = '';
            }
        } else if (IsPaymentTypeCreditCard()) {
            recurringProfile.ExpirationDate = expirationDate;
        }

        recurringProfile.State = state;
        recurringProfile.Status = status;
    }

    public void UpdateRecurringGift() {
        Success = true;

        if (DidBeginDateChange()) {
            currentRecord.New_Payment_Start_Date__c = beginDate;
            currentRecord.Next_Payment_Date__c = DetermineNextPaymentDate();
        }

        currentRecord.Status__c = status;
        currentRecord.Frequency__c = frequency;

        if (IsPaymentTypeUkDirectDebit()) {
            currentRecord.Sort_Code__c = sortCode1 + sortCode2 + sortCode3;
        } else if (IsPaymentTypeAch()) {
            currentRecord.Branch_Num__c = MaskRoutingNumber();
            currentRecord.Account__c = MaskAccountNumber();
        } else if (IsPaymentTypeCreditCard()) {
            currentRecord.Credit_Card__c = MaskAccountNumber();
            currentRecord.Credit_Card_Type__c = ConvertCreditCardTypeFromIats();
            currentRecord.Credit_Card_Expiry_Date__c = ParseCreditCardExpiry();
        }

        currentRecord.Cancellation_Reason__c = null;
        if (endDate == MIN_DATE) {
            currentRecord.End_Date__c = null;
        } else {
            currentRecord.End_Date__c = endDate;
        }

        if (IsStatusCancelled()) {
            currentRecord.End_Date__c = Date.today();
            currentRecord.Next_Payment_Date__c = null;
            currentRecord.Schedule_Date__c = null;
            currentRecord.Cancellation_Reason__c = cancellationReason;
        } else if (IsStatusOnHold()) {
            currentRecord.Next_Payment_Date__c = null;
            currentRecord.Schedule_Date__c = null;
        } else {
            if (DidBeginDateChange()) {
                currentRecord.New_Payment_Start_Date__c = beginDate;
                currentRecord.Next_Payment_Date__c = beginDate;
            }

            if (IsFrequencyQuarterly() || IsFrequencyAnnually()) {
                currentRecord.Next_Payment_Date__c = beginDate;
            } else if (DidScheduleDateChange()) {
                currentRecord.Schedule_Date__c = scheduleDate;
                currentRecord.Next_Payment_Date__c = DetermineNextPaymentDate();
            }
        }

        individual.MailingStreet = address;
        individual.MailingCity = city;
        individual.MailingState = state;
        individual.MailingPostalCode = postalCode;
        individual.MailingCountry = country;

        try {
            DMLManager.UpdateSObject(currentRecord);
            UpdateAllocations();
            HandleTransaction();
            DMLManager.UpdateSObject(individual);
        } catch (DmlException ex) {
            Success = false;
            errors.add(GetExceptionMessage(ex));
        }

        Allocations = GetAllocations();
        ResetAllocationProperties();
    }

    public void AddValidationError(string message) {

        if (currentRecord == null) {
            currentRecord = new Recurring_Donation__c();
        }

        if (validationErrors == null) {
            validationErrors = new List<String>();
            Success = false;
        }

        validationErrors.add(message);
    }

    public List<Payment__c> GetDeclinedPayments(String mostRecentTransactionId) {
        String fields = 'Recovered_Payment__c,Donation__c,';
        String clause = 'Donation__c =\'' + mostRecentTransactionId + '\' AND (Recovered_Payment__c != null AND Recovered_Payment__c != \'\')';
        String inFields = '';
        List<Payment__c> recoveredPayments = new GenericQueryBuilder().ListQueryBuilderWhere('Payment__c', fields, clause);

        List<Id> recoveredPaymentIds = new List<Id>();

        if (recoveredPayments != null && recoveredPayments.size() > 0) {
            for (Payment__c payment : recoveredPayments) {
                recoveredPaymentIds.add(payment.Recovered_Payment__c);
            }
        }

        fields = 'Id,Name,Amount__c,Date__c,Payment_Type__c,Donation__c';
        inFields = Converter.ConvertListSetToString(recoveredPaymentIds);
        clause = 'Donation__c = \'' + mostRecentTransactionId + '\' AND Id NOT IN ('+ inFields +') AND Status__c = \'Declined\' AND Amount__c > 0 AND CC_Reference__c <> \'\' AND (Recovered_Payment__c = null OR Recovered_Payment__c = \'\') LIMIT 5';
        List<Payment__c> declinedPayments = new GenericQueryBuilder().ListQueryBuilderWhere('Payment__c', fields, clause);

        return declinedPayments;
    }

    private void HandleTransaction() {
        String clause = 'Recurring_Donation__c =\''+ recurringGiftId + '\' AND Gift_Date__c = THIS_YEAR ORDER BY Gift_Date__c DESC LIMIT 1';
        String queryFields = 'Id,Recurring_Donation__c,Gift_Date__c';

        List<Gift__c> currentYearGifts = new GenericQueryBuilder().ListQueryBuilderWhere('Gift__c', queryFields, clause);

        Gift__C currentYearGift = null;

        if (currentYearGifts != null && currentYearGifts.size() > 0) {
            currentYearGift = currentYearGifts[0];
        }

        if (currentYearGift != null) {
            currentYearGift.Status__c = 'Active';
            DMLManager.UpdateSObject(currentYearGift);
        } else if (DidGiftGetReactivated()) {
            List<Gift__c> mostRecentGift = new GiftSelector().SelectIdByRecurringDonation(recurringGiftId);

            if (mostRecentGift != null && mostRecentGift.size() > 0) {

                String giftObject = RollupBatch.class.getName().substringBefore('RollupBatch').substringBefore('.');
                if (giftObject != null && giftObject != '') {
                    giftObject += '__';
                }

                giftObject += 'Gift__c';

                String commaDelimitedFields = '';
                Map<String, Schema.SObjectType> globaldesc = Schema.getGlobalDescribe();
                Set<String> fields = globaldesc.get(giftObject).getDescribe().fields.getMap().keySet();

                commaDelimitedFields = Converter.ConvertListSetToString(fields);

                String whereClause = 'Recurring_Donation__c = \'' + recurringGiftId + '\'ORDER BY Gift_Date__c DESC LIMIT 1';

                mostRecentGift = new GenericQueryBuilder().ListQueryBuilderWhere('Gift__c', commaDelimitedFields, whereClause);

                Gift__C clonedGift = mostRecentGift[0].clone(false, false, false, false);
                clonedGift.Status__c = 'Active';
                clonedGift.Gift_Date__c = Date.newInstance(DateTime.now().year(), 1, 1);
                DMLManager.InsertSObject(clonedGift);
            }
        }
    }

    private void UpdateAllocations() {

        List<RD_Allocation__c> newAllocations = new List<RD_Allocation__c>();
        List<RD_Allocation__c> updateAllocations = new List<RD_Allocation__c>();

        for (AllocationWrapper alloc : AllocationList) {
            if (alloc.aId.contains('newAlloc')) {
                newAllocations.add(alloc.aAllocation);
            } else {
                updateAllocations.add(alloc.aAllocation);
            }
        }

        if (newAllocations.size() > 0) {
            DMLManager.InsertSObjects(newAllocations);
        }

        if (updateAllocations.size() > 0) {
            DMLManager.UpdateSObjects(updateAllocations);
        }

        if (AllocationsToDelete != null && AllocationsToDelete.size() > 0) {
            DMLManager.DeleteSObjects(AllocationsToDelete);
        }
    }

    private String MaskAccountNumber() {
        if(accountNumber != null && accountNumber != '') {
            String maskedAccountNumber = '';
            String lastFourAccountNumber = accountNumber.substring(accountNumber.length() - 4, accountNumber.length());
            for (Integer i = 0; i < accountNumber.length() - 4; i++) {
                maskedAccountNumber += '*';
            }
            return maskedAccountNumber + lastFourAccountNumber;
        } else {
            return '';
        }
    }

    private String MaskRoutingNumber() {
        if(routingNumber != null && routingNumber != '') {
            String maskedRoutingNumber = routingNumber.substring(0, 4);
            for (Integer i = 0; i < routingNumber.length() - 4; i++) {
                maskedRoutingNumber += '*';
            }
            return maskedRoutingNumber;
        } else {
            return '';
        }
    }

    private String ConvertCreditCardTypeToIats() {
        String cardType = currentRecord.Credit_Card_Type__c;
        if (cardType == 'Visa') {
            return 'VISA';
        } else if (cardType == 'MasterCard') {
            return 'MC';
        } else if (cardType == 'American Express') {
            return'AMX';
        } else {
            return 'DSC';
        }
    }

    private String ConvertCreditCardTypeFromIats() {
        String cardType = accountType;
        if (cardType == 'VISA') {
            return 'Visa';
        } else if (cardType == 'MC') {
            return 'MasterCard';
        } else if (cardType == 'AMX') {
            return 'American Express';
        } else {
            return 'Discover';
        }
    }

    private Date ParseCreditCardExpiry() {
        if (expirationDate != null && expirationDate != '') {
            String[] expiry = expirationDate.split('/');
            Integer month = Integer.valueOf(expiry[0]);
            Integer year = 2000 + Integer.valueOf(expiry[1]);
            return Date.newInstance(year, month, 1);
        } else {
            return null;
        }
    }

    private Date DetermineNextPaymentDate() {
        if (IsFrequencyMonthly()) {
            return GetNextPaymentDate(1);
        } else if (IsFrequencyQuarterly()) {
            return GetNextPaymentDate(3);
        } else { // annually
            return GetNextPaymentDate(12);
        }
    }

    private Date GetNextPaymentDate(Integer monthOffset) {
        if (nextPaymentDate == null) {
            nextPaymentDate = Date.today();
        }

        Date paymentDateWithOffset = nextPaymentDate.addMonths(monthOffset);
        Integer daysInNextPaymentDateMonth = Date.daysInMonth(paymentDateWithOffset.year(), paymentDateWithOffset.month());
        Integer dayToUse = (!IsScheduleDateSameAsBeginDate()) ? Integer.valueOf(scheduleDate) : beginDate.day();

        Integer monthToUse = Date.today().addMonths(monthOffset).month();
        if (IsFrequencyMonthly()) {
            if (scheduleDate > Date.today().day()) {
                monthToUse = Date.today().month();
            }
        }

        if (daysInNextPaymentDateMonth < dayToUse) {
            return Date.newInstance(paymentDateWithOffset.year(), monthToUse, daysInNextPaymentDateMonth);
        } else {
            return Date.newInstance(paymentDateWithOffset.year(), monthToUse, dayToUse);
        }
    }

    private boolean DoesResultHaveErrors(BatchGateway4.TransactionResult result) {
        return (result.Errors != null && result.Errors.ErrorMessages.size() > 0);
    }

    private void HandleErrors(BatchGateway4.TransactionResult result) {
        for (Integer i = 0; i < result.Errors.ErrorMessages.size(); i++) {
            if (result.Errors.ErrorMessages[i].ErrorCode == GENERIC_ERROR_CODE) {
                errors.add(ERROR_PROCESSING);
            } else if (result.Errors.ErrorMessages[i].ErrorCode == BANK_ERROR_CODE) {
                if (result.Errors.ErrorMessages[i].Error.contains('cancelled')) {
                    UpdateRecurringGift();
                } else {
                    errors.add('Bank Error: ' + result.Errors.ErrorMessages[i].Error);
                }
            } else {
                errors.add('Gateway Error: ' + result.Errors.ErrorMessages[i].Error);
            }
        }
    }

    private void ResetAllocationProperties() {
        AllocationsToDelete = new List<RD_Allocation__c>();
        NewAllocation = new AllocationWrapper();
        EditAllocation = new AllocationWrapper();
        NewAllocationCount = 0;
    }

    private void ValidateCurrentRecord() {
        if (!IsStatusOnHold() && !IsStatusCancelled()) {
            if (currentRecord.Next_Payment_Date__c == null) {
                AddValidationError('Please ensure the next payment date is populated on the recurring gift.');
            }
        }
    }

    private static void SetNamespace() {
        String namespace = Utilities.getCurrentNamespace();
        PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
    }

    private PageReference CreateErrorPageReference() {
        PageReference pageRef = new PageReference('/' + recurringGiftId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    private String GetExceptionMessage(Exception ex) {
        return ex.getMessage().replace('\'', '').replace('\n', '');
    }

    private Boolean IsScheduleDateSameAsBeginDate() {
        return scheduleDate == beginDate.day();
    }

    private Boolean IsGatewayIats(String recurringId) {
        if (recurringId != null && recurringId != '') {
            return Pattern.matches('[A-Z][0-9]+', recurringId);
        } else {
            return false;
        }
    }

    private Boolean IsFrequencyMonthly() {
        return (frequency == 'Monthly');
    }

    private Boolean IsFrequencyQuarterly() {
        return (frequency == 'Quarterly');
    }

    private Boolean IsFrequencyAnnually() {
        return (frequency == 'Annually');
    }

    private Boolean IsStatusCancelled() {
        return (status == 'Cancelled');
    }

    private Boolean IsStatusOnHold() {
        return (status == 'On Hold');
    }

    private Boolean IsPaymentTypeCreditCard() {
        return (paymentType == 'Credit Card');
    }

    private Boolean IsPaymentTypeAch() {
        return (paymentType == 'ACH/PAD' || paymentType == 'ACH/EFT');
    }

    private Boolean IsPaymentTypeUkDirectDebit() {
        return (paymentType == 'UK Direct Debit');
    }

    private Boolean IsLocaleCanada(String locale) {
        return (locale == 'en_CA');
    }

    private Boolean IsLocaleAustralia(String locale) {
        return (locale == 'en_AU');
    }

    private Boolean DidBeginDateChange() {
        return (originalBeginDate != beginDate);
    }

    private Boolean IsNewPaymentStartDateAssigned() {
        return (currentRecord.New_Payment_Start_Date__c != null);
    }

    private Boolean AreAllocationsInitialized() {
        return (Allocations != null && Allocations.size() > 0);
    }

    private Boolean IsThereMoreThanOneAllocation() {
        return (Allocations.size() > 1);
    }

    private Boolean IsScheduleDateAssigned() {
        return (currentRecord.Schedule_Date__c != null);
    }

    private Boolean IsRecurringGiftOffline() {
        return ((!IsPaymentTypeCreditCard() && !IsPaymentTypeAch() && !IsPaymentTypeUkDirectDebit()) || (paymentType == null || paymentType == ''));
    }

    private Boolean DidScheduleDateChange() {
        return (originalScheduleDate != scheduleDate);
    }

    private Boolean DidGiftGetReactivated() {
        return ((originalStatus == 'On Hold' || originalStatus == 'Cancelled') && status == 'Active');
    }
}