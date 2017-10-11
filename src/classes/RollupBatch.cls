global with sharing class RollupBatch implements Database.Batchable<sObject>, Database.stateful {

    global List<Contact> contactRecord;
    global static Map <string, decimal> conversion_rates;
    global Set <string> cid;
    global DateTime previousRunTime;
    global Static DateTime lastRunTime;
    global static Boolean multiCurrencyEn;
    global static Set <Id> contactFilter;
    global static Integer orgFiscalStart;

    global static String userIsoCode;
    public static Map <string, decimal> conversionRates = new Map <string, decimal>();
    public DateTime lastTimeRun;
    public static Boolean multiCurrencyOrganization;
    public static Integer orgFiscalYearStartMonth = 1;
    public Set <Id> alreadyUpdatedContacts = new Set<Id>();
    public Set <Id> contactsForUpdate = new Set <Id>();
    private Date todaysDate;
    public String rollupType = 'Filtered';
    public string objectNamespacePrefix = Utilities.getCurrentNamespace();
    public String objectNamespace = objectNamespacePrefix + (String.isEmpty(objectNamespacePrefix) ? '' : '__');

    global RollupBatch(){ }

    global RollupBatch(DateTime setLastRun){
        this.lastTimeRun = setLastRun;
    }

    global RollupBatch(Set <Id> pastUpdatedContacts, DateTime setLastRun){
        this.alreadyUpdatedContacts = pastUpdatedContacts;
        this.lastTimeRun = setLastRun;
    }

    global RollupBatch(String rollupType){
        if(rollupType == 'Full') {
            todaysDate = Date.newInstance(Date.Today().Year(),1,1);
            rollupType = 'Full';
        }
    }

    global RollupBatch(Set <Id> specificContactsToUpdate){
    }

    public RollupBatch(Id updateContact){
        this.contactsForUpdate.add(updateContact);
    }

    global Database.Querylocator Start(Database.BatchableContext BC){
        orgFiscalYearStartMonth = GetFiscalStartMonth();

        if (lastTimeRun == null) {
            List<AsyncApexJob> st = new AsyncApexJobSelector().SelectCompletedDateByCompletedJob();
            if(st.size() > 0){
                lastTimeRun = st[0].CompletedDate;
            }else{
                List<AsyncApexJob> listOfFailedJobRuns = new AsyncApexJobSelector().SelectCreatedDateByLastJob();
                if(listOfFailedJobRuns.size() > 0){
                    lastTimeRun = listOfFailedJobRuns[0].CreatedDate;
                }
            }

        }

        return BuildContactQuery();
    }

    public Database.QueryLocator BuildContactQuery(){
        if(lastTimeRun != null && IsFiscalOrCalendarYearStart()){
            contactsForUpdate.addAll(GetContactsForUpdate());
        }

        string fields = 'Id, Consecutive_Years_of_Giving__c, Consecutive_Years_of_Transactions__c, Last_Gift_Amount__c, Total_Lifetime_Gifts__c, Total_Lifetime_Giving__c, ';
        string clause = '';

        if(UserInfo.isMultiCurrencyOrganization()==true)
            fields += 'CurrencyIsoCode, ';

        fields += 'Total_Fiscal_Gifts__c, Total_Fiscal_Year_Giving__c, Total_Lifetime_Transactions__c, Total_Lifetime_Transaction_Amount__c, Total_Fundraising_Last_Fiscal_Year__c, First_Gift_Amount__c, Largest_Fiscal_Gift__c, Largest_Calendar_Year_Gift__c, Last_Appeal_Supported__c, Recurring_Donor__c,';
        fields += ' Date_of_Last_Gift__c,Date_of_First_Gift__c,Date_of_First_Transaction__c,Largest_Gift__c,Average_Gift__c,Date_of_Last_Transaction__c,Total_Giving_Two_Years_Ago__c, Total_Giving_Last_Year__c,Total_Fiscal_Transactions__c, Total_Fiscal_Transaction_Amount__c, Total_Lifetime_Fundraising__c, Total_Fiscal_Fundraising__c,Last_Payment_Amount__c,Last_Payment_Date__c, Total_Soft_Credits__c';

        if(IsFiscalOrCalendarYearStart() && lastTimeRun != null){
          string inFields = Converter.ConvertListSetToString(contactsForUpdate);
          clause = ' WHERE Id IN (' + inFields + ')';
        }

        return new GenericQueryBuilder().getQueryLocator(clause, fields, 'Contact');
    }

    private Set<Id> GetContactsForUpdate(){
        List<AggregateResult> queryResults = new List<AggregateResult>();
        Set <Id> contactIdsForUpdating = new Set <Id>();

        queryResults = new GiftSelector().SelectConstituentByLastTimeRun(lastTimeRun, alreadyUpdatedContacts);

        for (AggregateResult currentGift : queryResults){
            contactIdsForUpdating.add((Id)currentGift.get(objectNamespace + 'Constituent__c'));
        }

        for(Solicitor__c softCreditedContacts : new SolicitorSelector().SelectSolicitorContacts(contactIdsForUpdating))
        {
            contactIdsForUpdating.add((id)softCreditedContacts.Solicitor__c);
        }

        if(contactIdsForUpdating.size() > 0){
            alreadyUpdatedContacts.addAll(contactIdsForUpdating);
        }

        return contactIdsForUpdating;
    }

    global void execute(Database.BatchableContext BC, List<sObject> contactsToBeUpdated){
        Map <Id, Contact> contactsToBeUpdatedMap = new Map <Id, Contact>((List<Contact>)contactsToBeUpdated);
        Set <Id> householdIdsToUpdate = new Set <Id>();

        GetMultiCurrencySupport();

        householdIdsToUpdate = RecalculateTotalGiving(contactsToBeUpdated);
        RecalculateGiftDates(contactsToBeUpdatedMap);
        RefreshNonCurrencyFields(contactsToBeUpdatedMap);
        if (householdIdsToUpdate.size() > 0) RecalculateTotalHouseholdGiving(householdIdsToUpdate);
    }

    public static void GetMultiCurrencySupport(){
        multiCurrencyOrganization = UserInfo.isMultiCurrencyOrganization();
        userIsoCode = UserInfo.getDefaultCurrency();

        if(multiCurrencyOrganization==true){
            List<sObject> isoList = new GenericQueryBuilder().ListQueryBuilderClause('CurrencyType', 'IsoCode,ConversionRate,IsCorporate', '');

            for(sObject isoCode: isoList)
              conversionRates.put((String)isoCode.get('IsoCode'),(decimal)isoCode.get('ConversionRate'));
        }
    }

    private static set<id> RecalculateTotalGiving(List<Contact> contacts){
        if (contacts == null || contacts.size() <= 0) return null;

        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        List<String> RecordTypeIdsforRollup1 = new List<String>();
        Set <String> recordTypesToRollup = new Set<String>();

        Map <Id, List<Gift__c>>      GiftRecordMap           = new Map<Id, List<Gift__c>>();
        Map <Id, List<payment__c>>   PaymentRecordMap        = new Map<Id, List<payment__c>>();
        Map <Id, List<Solicitor__c>> softCreditRecordMap     = new Map<Id, List<Solicitor__c>>();
        Map<Id, List<Gift__c>>       GiftRecordMapPrimarySolicitor = new Map<Id, List<Gift__c>>();

        String objectNamespacePrefix = Utilities.getCurrentNamespace();
        String objectNamespace = objectNamespacePrefix + (String.isEmpty(objectNamespacePrefix) ? '' : '__');
        List<RecordType> transactionRecordType = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectTypeLimit(objectNamespace + 'Gift__c', 'Gift', Utilities.getCurrentNamespace());
        String transactionRecordTypeId = transactionRecordType.size() > 0 ? transactionRecordType[0].Id : '';

        if((settings != null) && settings.Record_Type_Id_for_Rollups__c != null)
            RecordTypeIdsforRollup1 = SplitStringAtCommma(settings.Record_Type_Id_for_Rollups__c, true);

        List<RecordType> loopCurrent = new RecordTypeSelector().SelectByTwoNamesPrefixAndType('Pledge', 'Gift', Utilities.getCurrentNamespace(), objectNamespace + 'Gift__c');
        for(RecordType loopCurrentRecordType : loopCurrent)
        {
            RecordTypeIdsforRollup1.add(loopCurrentRecordType.Id);
        }

        if(RecordTypeIdsforRollup1.size()>0){
            for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++){
                recordTypesToRollup.add(RecordTypeIdsforRollup1[i]);
            }
        }

        Map<Id,Contact> contactsMap = new Map<Id,Contact>(contacts);
        set<id> householdIds = new set<id>();
        set<id> contactIds = new set<Id>();
        contactIds = contactsMap.keyset();

        if(multiCurrencyOrganization)
        {
            for(Gift__c g : new GiftSelector().SelectGiftInfoAndConvert(contactIds))
            {
                if(contactsMap.keySet().contains(g.Constituent__c))
                {
                    if(!GiftRecordMap.containsKey(g.Constituent__c)){
                        GiftRecordMap.put(g.Constituent__c, new List<Gift__c>());
                        }
                        GiftRecordMap.get(g.Constituent__c).add(g);

                    if(g.HouseholdId__c !=null && g.HouseholdId__c != '')
                    {
                      householdIds.add(g.HouseholdId__c);
                    }
                }
                if(contactsMap.keySet().contains(g.Primary_Solicitor__c))
                {
                    if(!GiftRecordMapPrimarySolicitor.containsKey(g.Primary_Solicitor__c)){
                        GiftRecordMapPrimarySolicitor.put(g.Primary_Solicitor__c, new List<Gift__c>());
                    }
                    GiftRecordMapPrimarySolicitor.get(g.Primary_Solicitor__c).add(g);
                }
            }
        }
        else
        {
            for(Gift__c g : new GiftSelector().SelectGiftInfoNoConvert(contactIds))
            {
                if(contactsMap.keySet().contains(g.Constituent__c))
                {
                    if(!GiftRecordMap.containsKey(g.Constituent__c)){
                        GiftRecordMap.put(g.Constituent__c, new List<Gift__c>());
                    }
                    GiftRecordMap.get(g.Constituent__c).add(g);

                    if(g.HouseholdId__c !=null && g.HouseholdId__c != '')
                    {
                      householdIds.add(g.HouseholdId__c);
                    }
                }

                if(contactsMap.keySet().contains(g.Primary_Solicitor__c))
                {
                    if(!GiftRecordMapPrimarySolicitor.containsKey(g.Primary_Solicitor__c)){
                        GiftRecordMapPrimarySolicitor.put(g.Primary_Solicitor__c, new List<Gift__c>());
                    }
                    GiftRecordMapPrimarySolicitor.get(g.Primary_Solicitor__c).add(g);
                }
            }


        }

        if(multiCurrencyOrganization){
            for(Solicitor__c s : new SolicitorSelector().SelectSolicitorInfoAndConvert(contactIds)){
                if(!softCreditRecordMap.containsKey(s.Solicitor__c)){
                    softCreditRecordMap.put(s.Solicitor__c, new List<solicitor__c>());
                }
                softCreditRecordMap.get(s.Solicitor__c).add(s);
            }
        }
        else{
            for(solicitor__c s : new SolicitorSelector().SelectSolicitorInfoNoConvert(contactIds)){
                if(!softCreditRecordMap.containsKey(s.solicitor__c)){
                    softCreditRecordMap.put(s.Solicitor__c, new List<Solicitor__c>());
                }
                softCreditRecordMap.get(s.Solicitor__c).add(s);
            }
        }

        if(multiCurrencyOrganization){
            for(payment__c p: new PaymentSelector().SelectPaymentInfoForRollUpBatchMulti(contactIds, recordTypesToRollup)){
                 if(!PaymentRecordMap.containsKey(p.Donation__r.Constituent__c)){
                        PaymentRecordMap.put(p.Donation__r.Constituent__c, new List<payment__c>());
                    }
                  PaymentRecordMap.get(p.Donation__r.Constituent__c).add(p);
            }
        }
        else{
            for(payment__c p: new PaymentSelector().SelectPaymentInfoForRollUpBatch(contactIds, recordTypesToRollup)){
                if(!PaymentRecordMap.containsKey(p.Donation__r.Constituent__c))  {
                    PaymentRecordMap.put(p.Donation__r.Constituent__c, new List<payment__c>());
                }

                PaymentRecordMap.get(p.Donation__r.Constituent__c).add(p);
            }
        }

        integer org;
        String clause = 'id=\''+Userinfo.getOrganizationId()+'\' LIMIT 1';
        Organization orgObject = (Organization)new GenericQueryBuilder().ObjectQueryBuilderWhere('Organization', 'FiscalYearStartMonth', clause);
        org = orgObject.FiscalYearStartMonth;
        List<Contact>   contactsToUpdate    = new List<Contact>();
        List<Date>      gDates              = new List<Date>();
        List<Date>      tDates              = new List<Date>();

        for(Contact c : contacts){
            Decimal lastGiftAmount = 0;
            Decimal firstGiftAmount = 0;
            Decimal lastPaymentAmount = 0;
            Decimal totalAmount = 0;
            Decimal totalFiscalAmount = 0;
            Decimal totalGivingAmountLastYear = 0;
            Decimal totalCount = 0;
            Decimal totalFiscalCount = 0;
            Decimal totalGivingAmount = 0;
            Decimal totalFiscalGivingAmount = 0;
            Decimal totalGivingCount = 0;
            Decimal totalFiscalGivingCount = 0;
            Decimal total_additional_solicitations = 0;
            Decimal total_additional_solicitations1 = 0;
            Decimal totalAdditionalSolicitationsLastYear = 0;
            Decimal total_solicitations = 0;
            Decimal total_solicitations1 = 0;
            Decimal totalSolicitationsLastYear = 0;
            Decimal consecutive_years_of_giving = 0;
            Decimal consecutive_years_of_transactions = 0;
            Decimal totalSoftCredits = 0;
            Decimal largestFiscalGift = 0;

            if (GiftRecordMap.get(c.id) != null){
                for(Gift__c g : GiftRecordMap.get(c.id)){
                    if(recordTypesToRollup.contains(g.RecordTypeId)){
                        lastGiftAmount = g.Total_Gift_Amount__c;
                        break;
                    }
                }
                for(Gift__c g : GiftRecordMap.get(c.id)){
                    if(recordTypesToRollup.contains(g.RecordTypeId)){
                        firstGiftAmount = g.Total_Gift_Amount__c;
                    }
                }
            }

            if (PaymentRecordMap.get(c.id) != null)
            {
                for(Payment__c p : PaymentRecordMap.get(c.id)){
                    if(recordTypesToRollup.contains(p.Donation__r.RecordTypeId)){
                        lastPaymentAmount = p.Amount__c;
                        break;
                    }
                }
            }

            if(GiftRecordMap.get(c.id) != null){
                for(Gift__c g : GiftRecordMap.get(c.id)){
                    if ((transactionRecordTypeId.contains(g.RecordTypeId))||(recordTypesToRollup.Contains(g.RecordTypeId))){
                        totalGivingAmount   += g.Total_Gift_Amount__c;
                        totalAmount         += g.Amount__c;
                        gDates.add(g.Gift_Date__c);
                        tDates.add(g.Gift_Date__c);
                        totalGivingCount++;
                        totalCount++;
                    }
                    else{
                        totalAmount += g.Amount__c;
                        tDates.add(g.Gift_Date__c);
                        totalCount++;
                    }
                    if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org)){
                        if ((transactionRecordTypeId.contains(g.RecordTypeId))||(recordTypesToRollup.Contains(g.RecordTypeId))){
                            totalFiscalGivingAmount     += g.Total_Gift_Amount__c;
                            totalFiscalAmount           += g.Amount__c;
                            totalFiscalGivingCount++;
                            totalFiscalCount++;
                            if(g.Total_Gift_Amount__c > largestFiscalGift) {
                                largestFiscalGift = g.Total_Gift_Amount__c;
                            }
                        }
                        else{
                            totalFiscalAmount += g.Amount__c;
                            totalFiscalCount++;
                        }
                    }
                    if (GivingPowerUtility.isLastFiscalYear(g.Gift_Date__c, org)){
                        if ((transactionRecordTypeId.contains(g.RecordTypeId))||(recordTypesToRollup.Contains(g.RecordTypeId)))
                            totalGivingAmountLastYear += g.Total_Gift_Amount__c;
                    }
                }
            }

            if (softCreditRecordMap.get(c.id) != null){
                for(Solicitor__c s : softCreditRecordMap.get(c.id)){
                    total_additional_solicitations1 += (s.Amount__c == null) ? 0 : s.Amount__c;
                    if (GivingPowerUtility.isCurrentFiscal(s.Gift_Date__c, org))
                         total_additional_solicitations += (s.Amount__c == null) ? 0 : s.Amount__c;
                    if (GivingPowerUtility.isLastFiscalYear(s.Gift_Date__c, org))
                         totalAdditionalSolicitationsLastYear += (s.Amount__c == null) ? 0 : s.Amount__c;
                }
            }

            if(GiftRecordMapPrimarySolicitor.get(c.Id) != null ){
                for(Gift__c g2 : GiftRecordMapPrimarySolicitor.get(c.Id))
                {
                    total_solicitations1 += g2.Amount__c;

                    if (GivingPowerUtility.isCurrentFiscal(g2.Gift_Date__c, org)) {
                        total_solicitations += g2.Amount__c;
                    }
                    if (GivingPowerUtility.isLastFiscalYear(g2.Gift_Date__c, org)) {
                        totalSolicitationsLastYear += g2.Amount__c;
                    }
                }
            }

            if (gDates.size() != 0){
                if (org == null){
                     consecutive_years_of_giving = GivingPowerUtility.ConseqFiscalYears(gDates, 1);
                }
                else{
                    consecutive_years_of_giving = GivingPowerUtility.ConseqFiscalYears(gDates, org);
                }
            }

            if (tDates.size() != 0){
                if (org == null){
                    consecutive_years_of_transactions = GivingPowerUtility.ConseqFiscalYears(tDates, 1);
                }
                else{
                    consecutive_years_of_transactions = GivingPowerUtility.ConseqFiscalYears(tDates, org);
                }
            }

            gDates.clear();
            tDates.clear();

            totalGivingAmount                   = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalGivingAmount) : totalGivingAmount);
            totalFiscalGivingAmount             = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalGivingAmount) : totalFiscalGivingAmount);
            totalGivingAmountLastYear           = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalGivingAmountLastYear) : totalGivingAmountLastYear);
            totalAmount                         = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalAmount) : totalAmount);
            totalFiscalAmount                   = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalAmount) : totalFiscalAmount);
            lastGiftAmount                      = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastGiftAmount) : lastGiftAmount);
            firstGiftAmount                     = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), firstGiftAmount) : firstGiftAmount);
            lastPaymentAmount                   = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastPaymentAmount) : lastPaymentAmount);
            total_additional_solicitations1     = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_additional_solicitations1) : total_additional_solicitations1);
            total_additional_solicitations      = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_additional_solicitations) : total_additional_solicitations);
            total_solicitations1                = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_solicitations1) : total_solicitations1);
            total_solicitations                 = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_solicitations) : total_solicitations);
            largestFiscalGift                   = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), largestFiscalGift) : largestFiscalGift);

            if (c.Total_Lifetime_Gifts__c <> totalGivingCount || c.Total_Lifetime_Giving__c <> totalGivingAmount ||
                c.Total_Fiscal_Gifts__c <> totalFiscalGivingCount || c.Total_Fiscal_Year_Giving__c <> totalFiscalGivingAmount ||
                c.Total_Lifetime_Transactions__c <> totalCount || c.Total_Lifetime_Transaction_Amount__c <> totalAmount ||
                c.Total_Fiscal_Transactions__c <> totalFiscalCount || c.Total_Fiscal_Transaction_Amount__c <> totalFiscalAmount ||
                c.Last_Gift_Amount__c <> lastGiftAmount || c.Total_Lifetime_Fundraising__c <> totalGivingAmount + total_additional_solicitations1 + total_solicitations1 ||
                c.Consecutive_Years_of_Giving__c <> consecutive_years_of_giving || c.Consecutive_Years_of_Transactions__c <> consecutive_years_of_transactions ||
                c.Total_Fiscal_Fundraising__c <> totalFiscalGivingAmount + total_additional_solicitations + total_solicitations ||
                c.Last_Payment_Amount__c  <> lastPaymentAmount || c.Total_Fundraising_Last_Fiscal_Year__c <> totalGivingAmountLastYear + totalAdditionalSolicitationsLastYear + totalSolicitationsLastYear ||
                c.Total_Soft_Credits__c <> total_solicitations1 + total_additional_solicitations1 || c.First_Gift_Amount__c <>firstGiftAmount || c.Largest_Fiscal_Gift__c <> largestFiscalGift){

                c.Total_Lifetime_Gifts__c                = totalGivingCount;
                c.Total_Lifetime_Giving__c               = totalGivingAmount;
                c.Total_Fiscal_Gifts__c                  = totalFiscalGivingCount;
                c.Total_Fiscal_Year_Giving__c            = totalFiscalGivingAmount;
                c.Total_Lifetime_Transactions__c         = totalCount;
                c.Total_Lifetime_Transaction_Amount__c   = totalAmount;
                c.Total_Fiscal_Transactions__c           = totalFiscalCount;
                c.Total_Fiscal_Transaction_Amount__c     = totalFiscalAmount;
                c.Last_Gift_Amount__c                    = lastGiftAmount;
                c.Last_Payment_Amount__c                 = lastPaymentAmount;
                c.Total_Lifetime_Fundraising__c          = totalGivingAmount + total_additional_solicitations1 + total_solicitations1;
                c.Total_Fiscal_Fundraising__c            = totalFiscalGivingAmount + total_additional_solicitations + total_solicitations;
                c.Total_Fundraising_Last_Fiscal_Year__c  = totalGivingAmountLastYear + totalAdditionalSolicitationsLastYear + totalSolicitationsLastYear;
                c.Consecutive_Years_of_Giving__c         = consecutive_years_of_giving;
                c.Consecutive_Years_of_Transactions__c   = consecutive_years_of_transactions;
                c.Total_Soft_Credits__c                  = total_solicitations1 + total_additional_solicitations1;
                c.First_Gift_Amount__c                   = firstGiftAmount;
                c.Largest_Fiscal_Gift__c                 = largestFiscalGift;

                contactsToUpdate.add(c);
            }
        }
        if (contactsToUpdate != null && contactsToUpdate.size() > 0) {
            DMLManager.UpdateSObjects(contactsToUpdate);
        }
        return householdIds;
    }

    public void RecalculateGiftDates(Map<Id,Contact> contactMap){
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
        String                      RecordTypeIdforRollup;
        List<String>                recordTypesToRollup = new List<String>();

        String objectNamespacePrefix = Utilities.getCurrentNamespace();
        String objectNamespace = objectNamespacePrefix + (String.isEmpty(objectNamespacePrefix) ? '' : '__');
        List<RecordType> r = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectType(objectNamespace + 'Gift__c', 'Pledge', Utilities.getCurrentNamespace());

        List<RecordType> transactionRecordType = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectTypeLimit(objectNamespace + 'Gift__c', 'Gift', Utilities.getCurrentNamespace());
        String transactionRecordTypeId;
        if (transactionRecordType.size() > 0)
        {
            transactionRecordTypeId = transactionRecordType[0].Id;
        }

        if(settings.Record_Type_Id_for_Rollups__c != null){
            RecordTypeIdforRollup = settings.Record_Type_Id_for_Rollups__c;

            recordTypesToRollup = SplitStringAtCommma(RecordTypeIdforRollup, true);
        }

        List<RecordType> loopCurrent = new RecordTypeSelector().SelectByTwoNamesPrefixAndType('Pledge', 'Gift', Utilities.getCurrentNamespace(), objectNamespace + 'Gift__c');
        for(RecordType loopCurrentRecordType : loopCurrent)
        {
            recordTypesToRollup.add(loopCurrentRecordType.Id);
        }

        Map<Id,Contact> contactRecordsToUpdate = new Map<Id,Contact>();
        List<Contact> contacts = contactMap.values();

        Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1);
        Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31);
        Date thisYearStart = Date.newInstance(Date.Today().Year(),1,1);
        Date thisYearEnd = Date.newInstance(Date.Today().Year(),12,31);

        set<Id> Contactsetids = new set<Id>();
        Contactsetids=contactMap.KeySet();
        if(IsFiscalOrCalendarYearStart() && r.size() > 0){
            for(AggregateResult result : new GiftSelector().SelectConstituentById(Contactsetids, recordTypesToRollup, r[0].Id)){
                Contact c               = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
                Date date_of_last_gift  = null;
                Date date_of_first_gift = null;
                Decimal largest_gift    = 0;
                Decimal average_gift    = 0;
                Decimal largestAnnualGift = 0;

                Date date_of_last_gift_transaction  = null;
                Date date_of_first_gift_transaction = null;
                Date Last_Payment_Date              = null;

                Decimal total_giving_two_years_ago  = 0;
                Decimal total_giving_last_year      = 0;

                if (c != null &&
                (c.Date_of_Last_Gift__c <> date_of_last_gift ||
                c.Date_of_First_Gift__c <> date_of_first_gift || c.Largest_Gift__c <> largest_gift || c.Average_Gift__c <> average_gift||
                c.Total_Giving_Last_Year__c <> total_giving_last_year||c.Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago||
                c.Date_of_Last_Transaction__c <> date_of_last_gift_transaction || c.Date_of_First_Transaction__c <> date_of_first_gift_transaction ||
                c.Largest_Calendar_Year_Gift__c <> largestAnnualGift))
                {
                    c.Date_of_Last_Gift__c           = null;
                    c.Date_of_First_Gift__c          = null;
                    c.Largest_Gift__c                = 0;
                    c.Average_Gift__c                = 0;
                    c.Largest_Calendar_Year_Gift__c  = 0;

                    c.Date_of_Last_Transaction__c    = null;
                    c.Date_of_First_Transaction__c   = null;
                    c.Last_Payment_Date__c           = null;

                    c.Total_Giving_Last_Year__c      = 0;
                    c.Total_Giving_Two_Years_Ago__c  = 0;

                    ContactRecordsToUpdate.put(c.Id, c);
                }
            }
        }


        for(contact c:contacts)
        {

                    c.Date_of_Last_Gift__c  = null;
                    c.Date_of_First_Gift__c = null;
                    c.Date_of_Last_Transaction__c    = null;
                    c.Date_of_First_Transaction__c   = null;
                    c.Last_Payment_Date__c           = null;


                    c.Largest_Gift__c               = 0;
                    c.Average_Gift__c               = 0;
                    c.Largest_Calendar_Year_Gift__c = 0;
                    c.Total_Giving_Last_Year__c     = 0;
                    c.Total_Giving_Two_Years_Ago__c = 0;

                    ContactRecordsToUpdate.put(c.Id, c);

        }

        for(AggregateResult result : new GiftSelector().SelectTotalGiftAmountSOQLDate(Contactsetids, recordTypesToRollup, transactionRecordTypeId))
        {
            Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);

            decimal total_giving_last_year = (Decimal)result.get('total');
            total_giving_last_year= ((multiCurrencyOrganization)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)total_giving_last_year) : total_giving_last_year);
            if (c != null && c.Total_Giving_Last_Year__c <> total_giving_last_year)
            {
                c.Total_Giving_Last_Year__c = total_giving_last_year;
                ContactRecordsToUpdate.put(c.Id, c);
            }
        }

        for(AggregateResult result : new GiftSelector().SelectTotalGiftAmount(Contactsetids, recordTypesToRollup, transactionRecordTypeId, last2_year_start, last2_year_end))
        {
            Contact c2 = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);

            decimal total_giving_two_years_ago = (Decimal)result.get('total');
            total_giving_two_years_ago= ((multiCurrencyOrganization)? convertCurrencyWithApexCode('corpCurr', (string)c2.get('CurrencyIsoCode'), (Decimal)total_giving_two_years_ago) : total_giving_two_years_ago);
            if (c2 != null && c2.Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago)
            {
                c2.Total_Giving_Two_Years_Ago__c = total_giving_two_years_ago ;
                ContactRecordsToUpdate.put(c2.Id, c2);
            }
        }




        for(AggregateResult result : new GiftSelector().SelectMaxGiftAmount(Contactsetids, recordTypesToRollup, transactionRecordTypeId, thisYearStart, thisYearEnd))
          {
              Contact c2 = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);

              decimal largestCalendarYearGift = (Decimal)result.get('largestGift');
              largestCalendarYearGift= ((multiCurrencyOrganization)? convertCurrencyWithApexCode('corpCurr', (string)c2.get('CurrencyIsoCode'), (Decimal)largestCalendarYearGift) : largestCalendarYearGift);
              if (c2 != null && c2.Largest_Calendar_Year_Gift__c <> largestCalendarYearGift)
              {
                  c2.Largest_Calendar_Year_Gift__c = largestCalendarYearGift ;
                  ContactRecordsToUpdate.put(c2.Id, c2);
              }
          }

        if (r.size() > 0)
        {
            for(AggregateResult result : new GiftSelector().SelectGiftAmountSummary(Contactsetids, recordTypesToRollup, r[0].Id)){
                Contact c               = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
                Date date_of_last_gift  =  Date.valueOf(result.get('maxGiftDate'));
                Date date_of_first_gift =  Date.valueOf(result.get('minGiftDate'));
                Decimal largest_gift    = (Decimal)result.get('maxGiftAmt');
                Decimal average_gift    = (Decimal)result.get('avgGiftAmt');
                largest_gift            = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), (Decimal)largest_gift) : largest_gift);
                average_gift            = ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), (Decimal)average_gift) : average_gift);

                if (c != null && (c.Date_of_Last_Gift__c <> date_of_last_gift ||
                    c.Date_of_First_Gift__c <> date_of_first_gift || c.Largest_Gift__c <> largest_gift || c.Average_Gift__c <> average_gift))
                {
                    c.Date_of_Last_Gift__c   = date_of_last_gift;
                    c.Date_of_First_Gift__c  = date_of_first_gift;
                    c.Largest_Gift__c        = largest_gift;
                    c.Average_Gift__c        = average_gift;

                    ContactRecordsToUpdate.put(c.Id, c);
                }
            }
        }

        for(AggregateResult result : new GiftSelector().SelectMinAndMaxGiftDate(Contactsetids))
        {
            Contact c               = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);
            Date date_of_last_gift  = Date.valueOf(result.get('maxGiftDate'));
            Date date_of_first_gift = Date.valueOf(result.get('minGiftDate'));
            if (c != null && (c.Date_of_Last_Transaction__c <> date_of_last_gift || c.Date_of_First_Transaction__c <> date_of_first_gift)){
                c.Date_of_Last_Transaction__c    = date_of_last_gift;
                c.Date_of_First_Transaction__c   = date_of_first_gift;
                ContactRecordsToUpdate.put(c.Id, c);
            }
        }

        if (r.size() > 0)
        {
            for(AggregateResult result : new PaymentSelector().SelectMinAndMaxGiftDateByContactIds(Contactsetids, recordTypesToRollup, r[0].Id))
            {
              Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);

                    Date Last_Payment_Date = Date.valueOf(result.get('maxpaymentDate'));

                    if (c != null && (c.Last_Payment_Date__c <> Last_Payment_Date )){
                        c.Last_Payment_Date__c = Last_Payment_Date;

                        ContactRecordsToUpdate.put(c.Id, c);
                    }
            }
        }

        if( ContactRecordsToUpdate.size() > 0 )
       {
            DMLManager.UpdateSObjects(ContactRecordsToUpdate.values());
       }
    }

    public void RefreshNonCurrencyFields(Map<Id,Contact> contactMap){
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
        String                      RecordTypeIdforRollup;
        List<String>                recordTypesToRollup = new List<String>();

        String objectNamespacePrefix = Utilities.getCurrentNamespace();
        String objectNamespace = objectNamespacePrefix + (String.isEmpty(objectNamespacePrefix) ? '' : '__');
        List<RecordType> transactionRecordType = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectTypeLimit(objectNamespace + 'Gift__c', 'Gift', Utilities.getCurrentNamespace());
        String transactionRecordTypeId;
        if (transactionRecordType.size() > 0)
        {
            transactionRecordTypeId = transactionRecordType[0].Id;
        }


        if(settings.Record_Type_Id_for_Rollups__c != null){
            RecordTypeIdforRollup = settings.Record_Type_Id_for_Rollups__c;

            recordTypesToRollup = SplitStringAtCommma(RecordTypeIdforRollup, true);
        }

        List<RecordType> loopCurrent = new RecordTypeSelector().SelectByTwoNamesPrefixAndType('Pledge', 'Gift', Utilities.getCurrentNamespace(), objectNamespace + 'Gift__c');
        for(RecordType loopCurrentRecordType : loopCurrent)
        {
            recordTypesToRollup.add(loopCurrentRecordType.Id);
        }

        Map<Id,Contact> contactRecordsToUpdate = new Map<Id,Contact>();
        List<Contact> contacts = contactMap.values();

        set<Id> Contactsetids = new set<Id>();
        Contactsetids=contactMap.KeySet();

        Map<Id,Gift_Detail__c> allocationMap = new Map<Id,Gift_Detail__c>();
        for(Gift_Detail__c test : new AllocationSelector().SelectRelatedConstituentAndNameById(Contactsetids))
            allocationMap.put(test.Gift__r.Constituent__c, test);

        for(contact c : contacts){
            Gift_Detail__c gd = allocationMap.get(c.Id);

            if (gd != null && (c.Last_Appeal_Supported__c <> gd.New_Campaign__r.Name )){
                c.Last_Appeal_Supported__c = gd.New_Campaign__r.Name;
                ContactRecordsToUpdate.put(c.Id, c);
            }
        }

        for(AggregateResult result : new RecurringDonationSelector().SelectByActiveRecordAndContactId(Contactsetids)){
            Contact c = (Contact)RollupHelper.findItem('Id', String.valueOf(result.get('con')), contacts);

            c.Recurring_Donor__c = true;
            ContactRecordsToUpdate.put(c.Id, c);
        }

        for(Contact currentContact : contacts){
            if(currentContact.Recurring_Donor__c == true && ContactRecordsToUpdate.containsKey(currentContact.id) == false) {
                Contact c = (Contact)RollupHelper.findItem('Id', currentContact.Id, contacts);

                c.Recurring_Donor__c = false;
                ContactRecordsToUpdate.put(c.Id, c);
            }
        }

         if( ContactRecordsToUpdate.size() > 0 )
         {
             DMLManager.UpdateSObjects(ContactRecordsToUpdate.values());
         }
    }

    public static void RecalculateTotalHouseholdGiving(Set<Id> hhIds1){
        if (hhIds1 == null || hhIds1.size()<=0) return;

        List<Account> households = new List<Account>();
        String fields = '';
        String subFields = '';
        String inFields = Converter.ConvertListSetToString(hhIds1);
        String clause = ' WHERE Id IN ('+ inFields +')';

        if(multiCurrencyOrganization){
            fields = 'Id,CurrencyIsoCode,'+ Utilities.PackageNamespace + 'Total_Household_Fundraising__c,'+ Utilities.PackageNamespace + 'Total_Fiscal_Household_Transactions__c,'+ Utilities.PackageNamespace + 'Total_Household_Transactions__c,'+ Utilities.PackageNamespace + 'Total_Household_Giving__c,'+ Utilities.PackageNamespace + 'Total_Fiscal_Household_Giving__c,'+ Utilities.PackageNamespace + 'Total_Fiscal_Household_Fundraising__c';
            subFields = 'Id,CurrencyIsoCode,'+ Utilities.PackageNamespace + 'Total_Fiscal_Transaction_Amount__c,'+ Utilities.PackageNamespace + 'Total_Lifetime_Transaction_Amount__c,'+ Utilities.PackageNamespace + 'Total_Fiscal_Year_Giving__c,'+ Utilities.PackageNamespace + 'Total_Lifetime_Fundraising__c,'+ Utilities.PackageNamespace + 'Total_Lifetime_Giving__c,'+ Utilities.PackageNamespace + 'Total_Fiscal_Fundraising__c';

            households=new GenericQueryBuilder().QueryBuilderWithSubQuery(Account.sObjectType, fields, clause, Contact.sObjectType, 'HouseholdContacts__r', subFields, '');
        }else{
            fields = 'Id,'+ Utilities.PackageNamespace + 'Total_Household_Fundraising__c,'+ Utilities.PackageNamespace + 'Total_Fiscal_Household_Transactions__c,'+ Utilities.PackageNamespace + 'Total_Household_Transactions__c,'+ Utilities.PackageNamespace + 'Total_Household_Giving__c ,'+ Utilities.PackageNamespace + 'Total_Fiscal_Household_Giving__c,'+ Utilities.PackageNamespace + 'Total_Fiscal_Household_Fundraising__c';
            subFields = 'Id,'+ Utilities.PackageNamespace + 'Total_Fiscal_Transaction_Amount__c,'+ Utilities.PackageNamespace + 'Total_Lifetime_Transaction_Amount__c,'+ Utilities.PackageNamespace + 'Total_Fiscal_Year_Giving__c,'+ Utilities.PackageNamespace + 'Total_Lifetime_Fundraising__c,'+ Utilities.PackageNamespace + 'Total_Lifetime_Giving__c,'+ Utilities.PackageNamespace + 'Total_Fiscal_Fundraising__c';

            households=new GenericQueryBuilder().QueryBuilderWithSubQuery(Account.sObjectType, fields, clause, Contact.sObjectType, 'HouseholdContacts__r', subFields, '');
        }
        clause = 'id=\'' + Userinfo.getOrganizationId() + '\' LIMIT 1';
        Organization orgObject = (Organization)new GenericQueryBuilder().ObjectQueryBuilderWhere('Organization', 'FiscalYearStartMonth,id', clause);
        integer org = orgObject.FiscalYearStartMonth;
        List<Account>   accountsToUpdate  = new List<Account>();
        List<Date>      gDates            = new List<Date>();
        List<Date>      tDates            = new List<Date>();
        Set <String>    cIds              = new Set <String>();

        for(Account a : households){
            Decimal totalAmount                     = 0;
            Decimal totalFiscalAmount               = 0;
            Decimal totalGivingAmount               = 0;
            Decimal totalFiscalGivingAmount         = 0;
            Decimal totalFundraisingAmount          = 0;
            Decimal totalFiscalFundraisingAmount    = 0;

            for(Contact c : a.HouseholdContacts__r){
                if (c.Total_Fiscal_Transaction_Amount__c != 0 && c.Total_Fiscal_Transaction_Amount__c != null){
                    totalFiscalAmount +=((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.Total_Fiscal_Transaction_Amount__c) : c.Total_Fiscal_Transaction_Amount__c);
                }
                if (c.Total_Lifetime_Transaction_Amount__c!= 0 && c.Total_Lifetime_Transaction_Amount__c!= null){
                    totalAmount += ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.Total_Lifetime_Transaction_Amount__c) : c.Total_Lifetime_Transaction_Amount__c);
                }
                if (c.Total_Fiscal_Year_Giving__c!= 0 && c.Total_Fiscal_Year_Giving__c!= null){
                    totalFiscalGivingAmount +=  ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.Total_Fiscal_Year_Giving__c) : c.Total_Fiscal_Year_Giving__c);
                }
                if (c.Total_Lifetime_Giving__c!= 0 && c.Total_Lifetime_Giving__c!= null){
                    totalGivingAmount += ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.Total_Lifetime_Giving__c) : c.Total_Lifetime_Giving__c);
                }
                if (c.Total_Lifetime_Fundraising__c != 0 && c.Total_Lifetime_Fundraising__c != null){
                    totalFundraisingAmount += ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.Total_Lifetime_Fundraising__c) : c.Total_Lifetime_Fundraising__c);
                }
                if(c.Total_Fiscal_Fundraising__c != 0 && c.Total_Fiscal_Fundraising__c != null){
                    totalFiscalFundraisingAmount += ((multiCurrencyOrganization)? ConvertCurrencyWithApexCode((string)c.get('CurrencyIsoCode'), (string)a.get('CurrencyIsoCode'),  (Decimal)c.Total_Fiscal_Fundraising__c) : c.Total_Fiscal_Fundraising__c);
                }
            }
            if (a.Total_Household_Giving__c <> totalGivingAmount || a.Total_Fiscal_Household_Giving__c <> totalFiscalGivingAmount ||
                a.Total_Household_Transactions__c <> totalAmount || a.Total_Fiscal_Household_Transactions__c <> totalFiscalAmount ||
                a.Total_Household_Fundraising__c <> totalFundraisingAmount || a.Total_Fiscal_Household_Fundraising__c <> totalFiscalFundraisingAmount)
            {
                a.Total_Household_Giving__c              = totalGivingAmount;
                a.Total_Fiscal_Household_Giving__c       = totalFiscalGivingAmount;
                a.Total_Household_Transactions__c        = totalAmount;
                a.Total_Fiscal_Household_Transactions__c = totalFiscalAmount;
                a.Total_Household_Fundraising__c         = totalFundraisingAmount;
                a.Total_Fiscal_Household_Fundraising__c  = totalFiscalFundraisingAmount;

                accountsToUpdate.add(a);
            }
        }
        if (accountsToUpdate != null && accountsToUpdate.size() > 0) {
            DMLManager.UpdateSObjects(accountsToUpdate);
        }
    }

    public static Decimal ConvertCurrencyWithApexCode(String oCurrency, String nCurrency, Decimal  amount){
        if(oCurrency!='corpCurr')
            amount = amount / conversionRates.get(oCurrency);

        amount = amount * conversionRates.get(nCurrency);
        return amount;
    }

    global void finish(Database.BatchableContext BC){
        if(contactsForUpdate.size() == 1000)
            Database.executeBatch(new RollupBatch(alreadyUpdatedContacts, lastTimeRun));
        if(rollupType == 'Full'){
            List<AsyncApexJob> a = new AsyncApexJobSelector().SelectJobByJobId(BC.getJobId());

            if(a.size() > 0){
                system.abortJob(a[0].id);
            }
        }
    }

    public boolean IsFiscalOrCalendarYearStart(){
        return (Date.newInstance(Date.Today().Year(),1,1) != todaysDate && Date.newInstance(Date.Today().Year(), orgFiscalYearStartMonth, 1) != todaysDate);
    }

    public Integer GetFiscalStartMonth() {
        Organization orgObject = (Organization)new GenericQueryBuilder().ObjectQueryBuilderClause('Organization', 'FiscalYearStartMonth', '');
        return orgObject.FiscalYearStartMonth;
    }

    public static List<String> SplitStringAtCommma(String stringWithCommas, Boolean clearWhitespace) {
        if(stringWithCommas.containsWhitespace() && clearWhitespace == true)
            stringWithCommas = (String)stringWithCommas.deleteWhitespace();
        return stringWithCommas.Split(',');
    }
}