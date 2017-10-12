global with sharing class RollupBatchForOrganization implements Database.Batchable<sObject> {

    global DateTime previousRunTime;
    global static  Map<String, decimal> conversion_rates = new Map<String, decimal>();
    global static Boolean  MultiCurrencyEn;
    global static String userIsoCode;

    global RollupBatchForOrganization()
    {
    }

    global RollupBatchForOrganization(DateTime lastRun) {
        previousRunTime = lastRun;
    }

    public static void multiCurrencySupport(){
        MultiCurrencyEn = UserInfo.isMultiCurrencyOrganization();
        userIsoCode = UserInfo.getDefaultCurrency();

        if(MultiCurrencyEn==true){
            List<sObject> sobjList = new GenericQueryBuilder().ListQueryBuilderClause('CurrencyType', 'IsoCode,ConversionRate,IsCorporate', '');
            for(sObject curr: sobjList){
              conversion_rates.put((String)curr.get('IsoCode'),(decimal)curr.get('ConversionRate'));
            }
        }
    }

    global Database.Querylocator start(Database.BatchableContext BC) {
        if (previousRunTime == null) previousRunTime = DateTime.now().addHours(-24);

        string fields = '';
        fields += 'Id, Last_Gift_Amount__c, Total_Lifetime_Fundraising__c, Consecutive_Years_of_Giving__c, Consecutive_Years_of_Transactions__c, Total_Lifetime_Gifts__c, Total_Lifetime_Giving__c, Total_Fiscal_Gifts__c, ';
        if(UserInfo.isMultiCurrencyOrganization()==true){
            fields += 'CurrencyIsoCode, ';
        }
        fields += 'Total_Fiscal_Year_Giving__c, Total_Lifetime_Transactions__c, Total_Lifetime_Transaction_Amount__c, Total_Fiscal_Transactions__c, Total_Fiscal_Transaction_Amount__c,Last_Payment_Amount__c,Last_Payment_Date__c ';
        String whereClause = 'WHERE RecordType.Name <> \'HouseHold\'';

        return new GenericQueryBuilder().getQueryLocator(whereClause, fields, 'Account');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Map<ID, Account> scopeMap = new Map<ID, Account>((List<Account>)scope);
        multiCurrencySupport();
        RecalculateTotalGivingForOrg((List<Account>)scope, scopeMap.keySet());
        RecalculateGiftDatesForOrg(scopeMap.keySet());
    }

    global void finish(Database.BatchableContext BC)
    {
        DateTime now = DateTime.now();
    }

    public static void RecalculateGiftDatesForOrg(Set<Id> orgIds)
    {
        String RecordTypeIdforRollup;
        List<String> RecordTypeIdsforRollup;
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
        RecordTypeIdforRollup = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;

        RecordTypeIdsforRollup = RecordTypeIdforRollup.Split(',');
        for (Integer i = 0; i < RecordTypeIdsforRollup.size(); i++) {
            RecordTypeIdsforRollup[i] = RecordTypeIdsforRollup[i].trim();
        }
        string bucketAccount = settings.BucketAccountId__c;

        String objectNamespacePrefix = Utilities.getCurrentNamespace();
        String objectNamespace = objectNamespacePrefix + (String.isEmpty(objectNamespacePrefix) ? '' : '__');

        List<RecordType> r = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectType(objectNamespace + 'Gift__c', 'Pledge', Utilities.getCurrentNamespace());

        if (bucketAccount == '') bucketAccount = null;

        Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1);
        Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31);

        Set<ID> accountIdsToUpdate = new Set<ID>();
        List<Account> accounts = new List<Account>();
        if(MultiCurrencyEn){
            String fields = 'Id, CurrencyIsoCode, Last_Payment_Amount__c, Last_Payment_Date__c, Largest_Gift__c, Average_Gift__c, Total_Giving_Last_Year__c, Total_Giving_Two_Years_Ago__c, Date_of_Last_Gift__c, Date_of_First_Gift__c, Date_of_First_Transaction__c, Date_of_Last_Transaction__c';
            String clause = 'Id IN (' + Converter.ConvertListSetToString(orgIds) + ')';
            accounts = new GenericQueryBuilder().ListQueryBuilderWhere('Account', fields, clause);
        }else{
            accounts = new AccountSelector().SelectPaymentInfoById(orgIds);
        }

        for(Account a:accounts)
        {
          a.Date_of_Last_Gift__c =null;
          a.Date_of_First_Gift__c=null;
          a.Largest_Gift__c=0;
          a.Average_Gift__c=0;
          a.Date_of_Last_Transaction__c=null;
          a.Date_of_First_Transaction__c=null;
          a.Total_Giving_Last_Year__c=0;
          a.Total_Giving_Two_Years_Ago__c=0;
          a.Last_Payment_Date__c = null;

          if (!accountIdsToUpdate.contains(a.Id)) accountIdsToUpdate.add(a.Id);
        }

        if (r.size() > 0)
        {
            for(AggregateResult result : new GiftSelector().SelectAccountPaymentSummary(orgIds, RecordTypeIdsforRollup, r[0].Id, bucketAccount))
            {
                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);
                Date date_of_last_gift = Date.valueOf(result.get('maxGiftDate'));
                Date date_of_first_gift = Date.valueOf(result.get('minGiftDate'));
                Decimal largest_gift = (Decimal)result.get('maxGiftAmt');
                Decimal average_gift = (Decimal)result.get('avgGiftAmt');
                if (c != null && (c.Date_of_Last_Gift__c <> date_of_last_gift ||
                    c.Date_of_First_Gift__c <> date_of_first_gift || c.Largest_Gift__c <> largest_gift || c.Average_Gift__c <> average_gift))
                {
                    c.Date_of_Last_Gift__c = date_of_last_gift;
                    c.Date_of_First_Gift__c = date_of_first_gift;
                    c.Largest_Gift__c =((MultiCurrencyEn)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)largest_gift) : largest_gift);
                    c.Average_Gift__c =((MultiCurrencyEn)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)average_gift) : average_gift);
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                }
            }
        }

            for(AggregateResult result : new GiftSelector().SelectGiftDateSummary(orgIds, bucketAccount))
            {
                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);
                Date date_of_last_gift = Date.valueOf(result.get('maxGiftDate'));
                Date date_of_first_gift = Date.valueOf(result.get('minGiftDate'));
                if (c != null && (c.Date_of_Last_Transaction__c <> date_of_last_gift || c.Date_of_First_Transaction__c <> date_of_first_gift))
                {
                    c.Date_of_Last_Transaction__c = date_of_last_gift;
                    c.Date_of_First_Transaction__c = date_of_first_gift;
                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                }
            }


            for(AggregateResult result : new GiftSelector().SelectPaymentTotal(orgIds, settings.RegularGiftRecordTypeId__c, RecordTypeIdsforRollup, bucketAccount))
            {
                    Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);

                    decimal total_giving_last_year = (Decimal)result.get('total');
                    total_giving_last_year= ((MultiCurrencyEn)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)total_giving_last_year) : total_giving_last_year);
                        if (c != null && c.Total_Giving_Last_Year__c <> total_giving_last_year)
                        {
                            c.Total_Giving_Last_Year__c = total_giving_last_year;
                             if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                        }

             }

            for(AggregateResult result : new GiftSelector().SelectPaymentTotalWithDateRange(orgIds, settings.RegularGiftRecordTypeId__c, RecordTypeIdsforRollup, bucketAccount, last2_year_start, last2_year_end))
            {

                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);

                decimal total_giving_two_years_ago = (Decimal)result.get('total');
                total_giving_two_years_ago = ((MultiCurrencyEn)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)total_giving_two_years_ago) : total_giving_two_years_ago);
                    if (c != null && c.Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago)
                    {
                        c.Total_Giving_Two_Years_Ago__c = total_giving_two_years_ago;
                         if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                    }

            }
            
            
            for(AggregateResult result : (new PaymentSelector().CalculatePaymentDatesByIds(orgIds, Utilities.ConvertStringListToIdSet(RecordTypeIdsforRollup)))) 
            {

                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('org')), accounts);

                decimal total_giving_two_years_ago = (Decimal)result.get('total');
                total_giving_two_years_ago = ((MultiCurrencyEn)? convertCurrencyWithApexCode('corpCurr', (string)c.get('CurrencyIsoCode'), (Decimal)total_giving_two_years_ago) : total_giving_two_years_ago);
                    if (c != null && c.Total_Giving_Two_Years_Ago__c <> total_giving_two_years_ago)
                    {
                        c.Total_Giving_Two_Years_Ago__c = total_giving_two_years_ago;
                         if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                    }

            }


            for(AggregateResult result : new PaymentSelector().SelectMinAndMaxGiftDateByOrgIds(orgIds, RecordTypeIdsforRollup))
            {
                Account c = (Account)RollupHelper.findItem('Id', String.valueOf(result.get('con')), accounts);

                Date Last_Payment_Date = Date.valueOf(result.get('maxpaymentDate'));

                if (c != null && (c.Last_Payment_Date__c <> Last_Payment_Date ))
                {
                    c.Last_Payment_Date__c = Last_Payment_Date;

                    if (!accountIdsToUpdate.contains(c.Id)) accountIdsToUpdate.add(c.Id);
                }

          }

        List<Account> values = new List<Account>();

        for (Account c : accounts)
        {
            if (accountIdsToUpdate.contains(c.Id)) values.add(c);
        }
        if (values.size() > 0) update values;
    }

    public static void RecalculateTotalGivingForOrg(List<Account> accounts, Set<Id> account_Ids)
    {
        if (accounts == null || accounts.size() <= 0) return;
        List<Account> accountsToUpdate = new List<Account>();
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
        String RecordTypeIdforRollup1;
        List<String> RecordTypeIdsforRollup1;
        Set<String> recordIds = new Set<String>();
        RecordTypeIdforRollup1 = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
        RecordTypeIdsforRollup1 = RecordTypeIdforRollup1.Split(',');

        String objectNamespacePrefix = Utilities.getCurrentNamespace();
        String objectNamespace = objectNamespacePrefix + (String.isEmpty(objectNamespacePrefix) ? '' : '__');

        List<RecordType> r = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectType(objectNamespace + 'Gift__c', 'Pledge', Utilities.getCurrentNamespace());
        if (r.size() > 0)
        {
            string pledgeRecordTypeId = r[0].id;
            recordIds.add(pledgeRecordTypeId);
        }

        if(RecordTypeIdsforRollup1.size()>0)
        {
            for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++)
            {
                recordIds.add(RecordTypeIdsforRollup1[i]);
            }
        }
        Organization record = new OrganizationSelector().SelectFiscalStartById(Userinfo.getOrganizationId());
        integer org = record.FiscalYearStartMonth;
        List<Date> gDates = new List<Date>();
        List<Date> tDates = new List<Date>();
        Map<Id, List<Gift__c>> gift_Map = new Map<Id, List<Gift__c>>();
        Map<Id, List<Solicitor__c>> soft_Credit_Map = new Map<Id, List<Solicitor__c>>();
        Map<Id, List<Gift__c>> gift1_Map = new Map<Id, List<Gift__c>>();
        Map<Id, List<Payment__c>> PaymentRecordMap = new Map<Id, List<Payment__c>>();

        if(MultiCurrencyEn){
        for(Gift__c gift : new GiftSelector().SelectByAccountIdAndConvert(account_Ids)){
            if(!gift_Map.containsKey(gift.Organization__c)){
                gift_Map.put(gift.Organization__c, new List<Gift__c>());
            }
            gift_Map.get(gift.Organization__c).add(gift);
        }
        }
        else{
        for(Gift__c gift : new GiftSelector().SelectGiftAndRecordTypeId(account_Ids)){
            if(!gift_Map.containsKey(gift.Organization__c)){
                gift_Map.put(gift.Organization__c, new List<Gift__c>());
            }
            gift_Map.get(gift.Organization__c).add(gift);
        }
        }

        if(MultiCurrencyEn){
        for(Solicitor__c softCredit : new SolicitorSelector().SelectByAccountIdAndConvert(account_Ids)){
            if(!soft_Credit_Map.containsKey(softCredit.Organization_Solicitor__c)){
                soft_Credit_Map.put(softCredit.Organization_Solicitor__c, new List<Solicitor__c>());
            }
            soft_Credit_Map.get(softCredit.Organization_Solicitor__c).add(softCredit);
        }
        }
        else{
        for(Solicitor__c softCredit : new SolicitorSelector().SelectByAccountId(account_Ids)){
            if(!soft_Credit_Map.containsKey(softCredit.Organization_Solicitor__c)){
                soft_Credit_Map.put(softCredit.Organization_Solicitor__c, new List<Solicitor__c>());
            }
            soft_Credit_Map.get(softCredit.Organization_Solicitor__c).add(softCredit);
        }
        }

        if(MultiCurrencyEn){
        for(Gift__c gift1 : new GiftSelector().SelectGiftByFoundationCreditAndConvert(account_Ids)){
            if(!gift1_Map.containsKey(gift1.Foundation_Credit__c)){
                gift1_Map.put(gift1.Foundation_Credit__c, new List<Gift__c>());
            }
            gift1_Map.get(gift1.Foundation_Credit__c).add(gift1);
        }
        }
        else {
        for(Gift__c gift1 : new GiftSelector().SelectGiftByFoundationCredit(account_Ids)){
            if(!gift1_Map.containsKey(gift1.Foundation_Credit__c)){
                gift1_Map.put(gift1.Foundation_Credit__c, new List<Gift__c>());
            }
            gift1_Map.get(gift1.Foundation_Credit__c).add(gift1);
        }
        }

        if(MultiCurrencyEn)
        {
            for(Payment__c p: new PaymentSelector().SelectPaymentInfoForRollUpBatchMultiByIdSets(account_Ids, recordIds))
               {
                 if(!PaymentRecordMap.containsKey(p.Donation__r.Organization__c))  {
                        paymentRecordMap.put(p.Donation__r.Organization__c, new List<Payment__c>());
                    }
                  PaymentRecordMap.get(p.Donation__r.Organization__c).add(p);
            }
        }
        else{
             for(Payment__c p: new PaymentSelector().SelectPaymentInfoForRollUpBatchByIdSets(account_Ids, recordIds))
               {
                 if(!PaymentRecordMap.containsKey(p.Donation__r.Organization__c))  {
                        paymentRecordMap.put(p.Donation__r.Organization__c, new List<Payment__c>());
                    }
                  PaymentRecordMap.get(p.Donation__r.Organization__c).add(p);
                }
        }

        for(Account c : accounts)
        {
            Decimal lastGiftAmount = 0;
            Decimal lastPaymentAmount = 0;
            Decimal totalAmount = 0;
            Decimal totalFiscalAmount = 0;
            Decimal totalCount = 0;
            Decimal totalFiscalCount = 0;
            Decimal totalGivingAmount = 0;
            Decimal totalFiscalGivingAmount = 0;
            Decimal totalGivingCount = 0;
            Decimal totalFiscalGivingCount = 0;
            Decimal total_additional_solicitations = 0;
            Decimal total_solicitations = 0;
            Decimal consecutive_years_of_giving = 0;
            Decimal consecutive_years_of_transactions = 0;

            if(gift_Map.get(c.Id) != null){
                for(Gift__c g : gift_Map.get(c.Id))
                {
                    if(settings.RegularGiftRecordTypeId__c.contains(g.RecordTypeId) && (g.RecordType.name == 'Gift' || g.RecordType.name == 'Pledge')){
                        lastGiftAmount = g.Amount__c;
                        break;
                    }
                }
            }


              if (PaymentRecordMap.get(c.id) != null)
            {
                 for(Payment__c p : PaymentRecordMap.get(c.id)){
                    if(settings.RegularGiftRecordTypeId__c.contains(p.Donation__r.RecordTypeId) && (p.Donation__r.RecordType.Name == 'Gift' || p.Donation__r.RecordType.Name == 'Pledge')){
                        lastPaymentAmount = p.Amount__c;
                        break;
                    }
                }
            }

            if(gift_Map.get(c.Id) != null){
                for(Gift__c g : gift_Map.get(c.Id))
                {
                    if ((settings.RegularGiftRecordTypeId__c.contains(g.RecordTypeId))||(recordIds.Contains(g.RecordTypeId)))
                    {
                        totalGivingAmount += g.Amount__c;
                        totalAmount += g.Amount__c;
                        gDates.add(g.Gift_Date__c);
                        tDates.add(g.Gift_Date__c);
                        totalGivingCount++;
                        totalCount++;
                    }
                    else
                    {
                        totalAmount += g.Amount__c;
                        tDates.add(g.Gift_Date__c);
                        totalCount++;
                    }
                    if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org))
                    {
                        if((settings.RegularGiftRecordTypeId__c.contains(g.RecordTypeId))||(recordIds.Contains(g.RecordTypeId)))
                        {
                            totalFiscalGivingAmount += g.Amount__c;
                            totalFiscalAmount += g.Amount__c;
                            totalFiscalGivingCount++;
                            totalFiscalCount++;
                        }
                        else
                        {
                            totalFiscalAmount += g.Amount__c;
                            totalFiscalCount++;
                        }
                    }
                }
            }

            if(soft_Credit_Map.get(c.id) != null)
            {
                for(Solicitor__c s : soft_Credit_Map.get(c.id))
                {
                    tDates.add(s.Gift_Date__c);
                    total_additional_solicitations += (s.Amount__c == null) ? 0 : s.Amount__c;
                }
            }

            if(gift1_Map.get(c.id) != null){
                for(Gift__c g2 : gift1_Map.get(c.id))
                {
                    total_solicitations += g2.Amount__c;
                }
            }
                if (gDates.size() != 0)
                {
                    if (org == null)
                    {
                        consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, 1);
                    }
                    else
                    {
                        consecutive_years_of_giving = GivingpowerUtility.ConseqFiscalYears(gDates, org);
                        set<Date> setDate  = new set<Date>(gDates);
                        setDate.remove(null);
                        gDates.clear();
                    }
                }
                if (tDates.size() != 0)
                {
                    if (org == null)
                    {
                        consecutive_years_of_transactions = GivingpowerUtility.ConseqFiscalYears(tDates, 1);
                    }
                    else
                    {
                        consecutive_years_of_transactions = GivingpowerUtility.ConseqFiscalYears(tDates, org);
                    }
                }
               tDates.clear();

                totalGivingAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalGivingAmount) : totalGivingAmount);
                totalFiscalGivingAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalGivingAmount) : totalFiscalGivingAmount);
                totalAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalAmount) : totalAmount);
                lastGiftAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastGiftAmount) : lastGiftAmount);
                totalFiscalAmount = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), totalFiscalAmount) : totalFiscalAmount);
                total_additional_solicitations=((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_additional_solicitations) : total_additional_solicitations);
                total_solicitations=((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), total_solicitations) : total_solicitations);
                lastPaymentAmount  = ((MultiCurrencyEn)? convertCurrencyWithApexCode(userIsoCode, (string)c.get('CurrencyIsoCode'), lastPaymentAmount) : lastPaymentAmount);

            if (c.Total_Lifetime_Gifts__c <> totalGivingCount || c.Total_Lifetime_Giving__c <> totalGivingAmount ||
                c.Total_Fiscal_Gifts__c <> totalFiscalGivingCount || c.Total_Fiscal_Year_Giving__c <> totalFiscalGivingAmount ||
                c.Total_Lifetime_Transactions__c <> totalCount || c.Total_Lifetime_Transaction_Amount__c <> totalAmount ||
                c.Last_Gift_Amount__c <> lastGiftAmount || c.Total_Fiscal_Transactions__c <> totalFiscalCount ||
                c.Total_Fiscal_Transaction_Amount__c <> totalFiscalAmount || c.Total_Lifetime_Fundraising__c <> totalGivingAmount + total_additional_solicitations + total_solicitations ||
                c.Last_Gift_Amount__c <> lastGiftAmount || c.Consecutive_Years_of_Giving__c <> consecutive_years_of_giving ||
                c.Consecutive_Years_of_Transactions__c <> consecutive_years_of_transactions ||
                c.Last_Payment_Amount__c  <> lastPaymentAmount)
            {
                c.Total_Lifetime_Gifts__c = totalGivingCount;
                c.Total_Lifetime_Giving__c = totalGivingAmount;
                c.Total_Fiscal_Gifts__c = totalFiscalGivingCount;
                c.Total_Fiscal_Year_Giving__c = totalFiscalGivingAmount;
                c.Total_Lifetime_Transactions__c = totalCount;
                c.Total_Lifetime_Transaction_Amount__c = totalAmount;
                c.Last_Gift_Amount__c =lastGiftAmount;
                c.Total_Fiscal_Transactions__c = totalFiscalCount;
                c.Total_Fiscal_Transaction_Amount__c = totalFiscalAmount;
                c.Total_Lifetime_Fundraising__c = totalGivingAmount + total_additional_solicitations + total_solicitations;
                c.Last_Gift_Amount__c =lastGiftAmount;
                c.Consecutive_Years_of_Giving__c = consecutive_years_of_giving;
                c.Consecutive_Years_of_Transactions__c = consecutive_years_of_transactions;
                c.Last_Payment_Amount__c  = lastPaymentAmount;

                accountsToUpdate.add(c);
            }
        }
        DMLManager.UpdateSObjects(accountsToUpdate);
    }

    public static Decimal convertCurrencyWithApexCode(String oCurrency, String nCurrency, Decimal  amount){
      if(amount != null){
          if(oCurrency!='corpCurr'){
            amount = amount / conversion_rates.get(oCurrency);
           }
           amount = amount * conversion_rates.get(nCurrency);
           return amount;
         }
         return 0;
    }
}