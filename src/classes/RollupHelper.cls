public without sharing class RollupHelper {

private static String namespacePrefix = Utilities.getCurrentNamespace();
private static String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');

public static void GuestRegistrations(Set<Gift__c> giftIds) {
    Set<Event_Registration__c> eventRegs = new Set<Event_Registration__c>();
    BatchSettings__c settings = BatchSettings__c.getInstance();
    List<Gift__c> gifts = new GiftSelector().SelectGuestRegistrationWhereIdInIds(giftIds);
    for (Gift__c g : gifts) {

        if (g.Event_Registrations__r.size() > 0) {
            for (Integer i = 0; i < g.Attendee_Names_Pending__c; i++) {
                Event_Registration__c e = new Event_Registration__c();
                e.Transaction__c = g.Id;
                e.Event__c = g.Event_Registrations__r[0].Event__c;
                e.Registration_Date__c = g.Event_Registrations__r[0].Registration_Date__c;
                e.Guest_Of__c = g.Constituent__c;
                if (e.Registration_Date__c != null && e.Event__c != null && e.Transaction__c != null && e.Individual__c != null) { eventRegs.add(e); }
            }
        }
    }
    List<Event_Registration__c> eventRegList = new List<Event_Registration__c>(eventRegs);
    if (eventRegList != null && eventRegList.size() > 0) {
        DMLManager.InsertSObjects(eventRegList);
    }
}

public static void RecalculateTotalHouseholdGiving(Set<Id> hhIds)
{
    if (hhIds == null || hhIds.size()<=0) return;
    
    List<Account> households = new AccountSelector().SelectHouseholdContactTotalsWhereIdInIds(hhIds);
    List<Organization> orgs = new OrganizationSelector().SelectFiscalYearStartMonthBySingleIdAndLimit(Userinfo.getOrganizationId(), 1);
    integer org = orgs[0].FiscalYearStartMonth;
    
    List<Date> gDates = new List<Date>();
    List<Date> tDates = new List<Date>();
    Set<String> cIds = new Set<String>();

    for(Account a : households)
    {
        Decimal totalAmount = 0;
        Decimal totalFiscalAmount = 0;

        Decimal totalGivingAmount = 0;
        Decimal totalFiscalGivingAmount = 0;

        Decimal totalFundraisingAmount = 0;
        Decimal totalFiscalFundraisingAmount = 0;
        for(Contact c : a.HouseholdContacts__r)
        {
            if (c.Total_Fiscal_Transaction_Amount__c != 0 && c.Total_Fiscal_Transaction_Amount__c != null)
            { totalFiscalAmount += c.Total_Fiscal_Transaction_Amount__c; }
            if (c.Total_Lifetime_Transaction_Amount__c!= 0 && c.Total_Lifetime_Transaction_Amount__c!= null)
            { totalAmount += c.Total_Lifetime_Transaction_Amount__c; }

            if (c.Total_Fiscal_Year_Giving__c!= 0 && c.Total_Fiscal_Year_Giving__c!= null)
            { totalFiscalGivingAmount += c.Total_Fiscal_Year_Giving__c; }
            if (c.Total_Lifetime_Giving__c!= 0 && c.Total_Lifetime_Giving__c!= null)
            { totalGivingAmount += c.Total_Lifetime_Giving__c; }

            if (c.Total_Lifetime_Fundraising__c != 0 && c.Total_Lifetime_Fundraising__c != null)
            { totalFundraisingAmount += c.Total_Lifetime_Fundraising__c; }

            //newly added code
            if(c.Total_Fiscal_Fundraising__c != 0 && c.Total_Fiscal_Fundraising__c != null)
            {totalFiscalFundraisingAmount += c.Total_Fiscal_Fundraising__c; }
        }

        a.Total_Household_Giving__c = totalGivingAmount;
        a.Total_Fiscal_Household_Giving__c = totalFiscalGivingAmount;

        a.Total_Household_Transactions__c = totalAmount;
        a.Total_Fiscal_Household_Transactions__c = totalFiscalAmount;

        a.Total_Household_Fundraising__c = totalFundraisingAmount;
        a.Total_Fiscal_Household_Fundraising__c  = totalFiscalFundraisingAmount ;
    }

    DMLManager.UpdateSObjects(households);
}

public static void RecalculateTotalGivingForOrg(Set<Id> orgIds)
{
    if (orgIds == null || orgIds.size()<=0) return;
    BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
    String RecordTypeIdforRollup1;
        List<String> RecordTypeIdsforRollup1;
        Set<String> recordIds = new Set<String>();
        RecordTypeIdforRollup1 = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;

         if(RecordTypeIdforRollup1 != null)
            RecordTypeIdsforRollup1 = RecordTypeIdforRollup1.Split(',');
         else
            RecordTypeIdforRollup1 = settings.Record_Type_Id_for_Rollups__c;

        if(RecordTypeIdsforRollup1!= null && RecordTypeIdsforRollup1.size()>0)
        {
            for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++)
            {
                recordIds.add(RecordTypeIdsforRollup1[i]);
            }
        }
    List<Account> accounts = new AccountSelector().SelectHouseholdTotalsWhereIdInIds(orgIds); 
    
    List<Organization> orgs = new OrganizationSelector().SelectFiscalYearStartMonthBySingleIdAndLimit(Userinfo.getOrganizationId(), 1);
    integer org = orgs[0].FiscalYearStartMonth;
    
    List<Date> gDates = new List<Date>();
    List<Date> tDates = new List<Date>();

    for(Account c : accounts)
    {
        Decimal lastGiftAmount = 0;
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

        if (c.Orders__r!= null)
        {
            if(c.Orders__r.size() > 0) { lastGiftAmount = c.Orders__r[0].Amount__c; }
        }

        for(Gift__c g : c.Orders__r)
        {
            if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
            { totalGivingAmount += g.Amount__c; totalAmount += g.Amount__c; gDates.add(g.Gift_Date__c); tDates.add(g.Gift_Date__c); totalGivingCount++; totalCount++;}
            else
            { totalAmount += g.Amount__c; tDates.add(g.Gift_Date__c); totalCount++; }

            if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org))
            {
                 if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
                { totalFiscalGivingAmount += g.Amount__c; totalFiscalAmount += g.Amount__c; totalFiscalGivingCount++; totalFiscalCount++; }
                else
                { totalFiscalAmount += g.Amount__c; totalFiscalCount++; }
            }
        }

        for(Solicitor__c s : c.Soft_Credits__r) {
            total_additional_solicitations += s.Amount__c;
        }
        for(Gift__c g2 : c.Orders1__r) {
            total_solicitations += g2.Amount__c;
        }
        if (gDates.size() != 0)
        {
            if (org == null)
            { c.Consecutive_Years_of_Giving__c = GivingpowerUtility.ConseqFiscalYears(gDates, 1); }
            else
            { c.Consecutive_Years_of_Giving__c = GivingpowerUtility.ConseqFiscalYears(gDates, org); }
        }

        if (tDates.size() != 0)
        {
            if (org == null)
            { c.Consecutive_Years_of_Transactions__c = GivingpowerUtility.ConseqFiscalYears(tDates, 1); }
            else
            { c.Consecutive_Years_of_Transactions__c = GivingpowerUtility.ConseqFiscalYears(tDates, org); }
        }

        c.Total_Lifetime_Gifts__c = totalGivingCount;
        c.Total_Lifetime_Giving__c = totalGivingAmount;

        c.Total_Fiscal_Gifts__c = totalFiscalGivingCount;
        c.Total_Fiscal_Year_Giving__c = totalFiscalGivingAmount;

        c.Total_Lifetime_Transactions__c = totalCount;
        c.Total_Lifetime_Transaction_Amount__c = totalAmount;

        c.Last_Gift_Amount__c = lastGiftAmount;

        c.Total_Fiscal_Transactions__c = totalFiscalCount;
        c.Total_Fiscal_Transaction_Amount__c = totalFiscalAmount;

        c.Total_Lifetime_Fundraising__c = totalAmount + total_additional_solicitations + total_solicitations;
        c.Last_Gift_Amount__c = lastGiftAmount;
    }

    DMLManager.UpdateSObjects(accounts);
}

public static void RecalculateTotalGiving(Set<Id> ContactIds)
{
    if (ContactIds == null || ContactIds.size()<=0)
        return;

    BatchSettings__c settings =  BatchSettings__c.getInstance('Default');

    String RecordTypeIdforRollup1;
        List<String> RecordTypeIdsforRollup1;
        Set<String> recordIds = new Set<String>();
        RecordTypeIdforRollup1 = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;

        if(RecordTypeIdforRollup1 != null)
            RecordTypeIdsforRollup1 = RecordTypeIdforRollup1.Split(',');


        if(RecordTypeIdsforRollup1!=null && RecordTypeIdsforRollup1.size()>0)
        {
            for(integer i = 0;i<=RecordTypeIdsforRollup1.size()-1;i++)
            {
                recordIds.add(RecordTypeIdsforRollup1[i]);
            }
        }
    
    List<Contact> contacts = new ContactSelector().SelectContactTotalsWhereIdInIds(ContactIds);  
    
    List<Organization> orgs = new OrganizationSelector().SelectFiscalYearStartMonthBySingleIdAndLimit(Userinfo.getOrganizationId(), 1);
    integer org = orgs[0].FiscalYearStartMonth;
    
    List<Date> gDates = new List<Date>();
    List<Date> tDates = new List<Date>();

    for(Contact c : contacts)
    {
        Decimal lastGiftAmount = 0;
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

        Decimal total_additional_solicitations1 = 0;
        Decimal total_solicitations1 = 0;

        if (c.Gifts__r != null)
        {
            if(c.Gifts__r.size() > 0)
            {
                 lastGiftAmount = c.Gifts__r[0].Amount__c;
            }
        }

        for(Gift__c g : c.Gifts__r)
        {
            if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
            { totalGivingAmount += g.Amount__c; totalAmount += g.Amount__c; gDates.add(g.Gift_Date__c); tDates.add(g.Gift_Date__c); totalGivingCount++; totalCount++;}
            else
            { totalAmount += g.Amount__c; tDates.add(g.Gift_Date__c); totalCount++; }

            if (GivingpowerUtility.isCurrentFiscal(g.Gift_Date__c, org))
            {
                if ((g.RecordTypeId == settings.RegularGiftRecordTypeId__c)||(recordIds.Contains(g.RecordTypeId)))
                { totalFiscalGivingAmount += g.Amount__c; totalFiscalAmount += g.Amount__c; totalFiscalGivingCount++; totalFiscalCount++; }
                else
                { totalFiscalAmount += g.Amount__c; totalFiscalCount++; }
            }
        }
        if (c.Additional_Solicitations__r!=null) {
          for(Solicitor__c s : c.Additional_Solicitations__r){

              total_additional_solicitations1 += (s.Amount__c==null)? 0 : s.Amount__c;

            if(GivingpowerUtility.isCurrentFiscal(s.Gift_Date__c, org)) {
            total_additional_solicitations += (s.Amount__c==null)? 0 : s.Amount__c;
               }
              }
            }


        for(Gift__c g2 : c.Gifts1__r){

             total_solicitations1 += g2.Amount__c;

             if(GivingpowerUtility.isCurrentFiscal(g2.Gift_Date__c, org)) {
            total_solicitations += g2.Amount__c;
              }
            }

        if (gDates.size() != 0)
        {
            if (org == null)
            {
             c.Consecutive_Years_of_Giving__c = GivingpowerUtility.ConseqFiscalYears(gDates, 1); }
            else
            { c.Consecutive_Years_of_Giving__c = GivingpowerUtility.ConseqFiscalYears(gDates, org); }
        }

        if (tDates.size() != 0)
        {
            if (org == null)
            { c.Consecutive_Years_of_Transactions__c = GivingpowerUtility.ConseqFiscalYears(tDates, 1); }
            else
            { c.Consecutive_Years_of_Transactions__c = GivingpowerUtility.ConseqFiscalYears(tDates, org); }
        }

        c.Total_Lifetime_Gifts__c = totalGivingCount;
        c.Total_Lifetime_Giving__c = totalGivingAmount;

        c.Total_Fiscal_Gifts__c = totalFiscalGivingCount;
        c.Total_Fiscal_Year_Giving__c = totalFiscalGivingAmount;

        c.Total_Lifetime_Transactions__c = totalCount;
        c.Total_Lifetime_Transaction_Amount__c = totalAmount;

        c.Total_Fiscal_Transactions__c = totalFiscalCount;
        c.Total_Fiscal_Transaction_Amount__c = totalFiscalAmount;

        c.Last_Gift_Amount__c = lastGiftAmount;

        c.Total_Lifetime_Fundraising__c = totalAmount + total_additional_solicitations1 + total_solicitations1;
        c.Total_Fiscal_Fundraising__c =  totalFiscalAmount + total_additional_solicitations + total_solicitations;
    }

    DMLManager.UpdateSObjects(contacts);
  }

  public static void CreateIndividualSoftCredits(List<Gift__c> gifts) {
     Map<Id, Solicitor__c> solicitorMap = new Map<Id, Solicitor__c>();
     Set<Id> contactIds = new Set<Id>();
     set<Id> giftIds = new Set<Id>();
     for(Gift__c g : gifts) {
        if (!contactIds.contains(g.Constituent__c) && !IsEmptyOrNull(g.Constituent__c))
          contactIds.add(g.Constituent__c);
          giftIds.add(g.id);
     }
     
     List<hed__Relationship__c> relationships = new hedRelationshipSelector().SelectRelationshipWhereContactInIds(contactIds);
     
     List<hed__Affiliation__c> affiliations = new hedAffiliationSelector().SelectAffiliationWhereContactInId(contactIds);
       
     List<Solicitor__c> softCredits = new List<Solicitor__c>();
     for(Gift__c g : gifts) {
         for(hed__Relationship__c item : relationships){
            if (item.hed__Contact__c == g.Constituent__c) {
                Solicitor__c s = new Solicitor__c(Gift__c=g.Id,Role__c='General Soft Credit',Solicitor__c=item.hed__RelatedContact__c);
                softCredits.add(s);
             }
         }
         for(hed__Affiliation__c item : affiliations){
            if (item.hed__Contact__c == g.Constituent__c) {
                Solicitor__c s = new Solicitor__c(Gift__c=g.Id,Role__c='General Soft Credit',Organization_Solicitor__c=item.hed__Account__c,Relationship__c=item.hed__Role__c);
                softCredits.add(s);
            }
         }
     }
     if (softCredits.size()>0) {
        DMLManager.InsertSObjects(softCredits);
    }
  }

  public static void CreateOrganizationSoftCredits(List<Gift__c> gifts) {
     Set<Id> contactIds = new Set<Id>();
     for(Gift__c g : gifts) {
        if (!contactIds.contains(g.Organization__c) && !IsEmptyOrNull(g.Organization__c))
          contactIds.add(g.Organization__c);
     }
     
     List<hed__Affiliation__c> affiliations = new hedAffiliationSelector().SelectAffiliationWhereAccountInId(contactIds);
       
     if (affiliations==null || affiliations.size()<=0) return;

     List<Solicitor__c> softCredits = new List<Solicitor__c>();
     for(Gift__c g : gifts) {
         for(hed__Affiliation__c item : affiliations)
            if (item.hed__Account__c == g.Organization__c) {
                Solicitor__c s = new Solicitor__c(Gift__c=g.Id,Role__c='General Soft Credit',Solicitor__c=item.hed__Contact__c,Relationship__c=item.hed__Role__c);
                softCredits.add(s);
            }
     }

     if (softCredits.size()>0) {
        DMLManager.InsertSObjects(softCredits);
    }
  }

   public static void RecalculateGiftDatesForOrg(Set<Id> orgIds)
   {
      BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
      String RecordTypeIdforRollup;
      List<String> RecordTypeIdsforRollup;
        RecordTypeIdforRollup = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;
      if(RecordTypeIdforRollup != null)
            RecordTypeIdsforRollup = RecordTypeIdforRollup.Split(',');
      
      AggregateResult[] results = new GiftSelector().SelectMaxMinAvgByOrganizationAndRecordType(orgIds, settings.RegularGiftRecordTypeId__c, Utilities.ConvertStringListToIdSet(RecordTypeIdsforRollup));
      AggregateResult[] last_year = new GiftSelector().SelectSumLastYearByOrganizationAndRecordType(orgIds, settings.RegularGiftRecordTypeId__c, Utilities.ConvertStringListToIdSet(RecordTypeIdsforRollup));
                                   
      Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1);
      Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31);      
                                                  
      AggregateResult[] last2_year = new GiftSelector().SelectSumLastTwoYearsByOrganizationAndRecordType(orgIds, last2_year_start, last2_year_end,settings.RegularGiftRecordTypeId__c, Utilities.ConvertStringListToIdSet(RecordTypeIdsforRollup));
  
      List<Account> accounts = new AccountSelector().SelectAccountFirstAndLastGiftDateByIdsForUpdate(orgIds);
      for(Account c : accounts)
      {
        c.Total_Giving_Last_Year__c = 0;
        c.Total_Giving_Two_Years_Ago__c = 0;
      }

      if (results != null && results.size()>0)
      {
          for(AggregateResult result : results)
          {
              Account c = (Account)findItem('Id',String.valueOf(result.get('org')),accounts);
              if (c != null)
              {
                 c.Date_of_Last_Gift__c = Date.valueOf(result.get('maxGiftDate'));
                 c.Date_of_First_Gift__c = Date.valueOf(result.get('minGiftDate'));
                 c.Largest_Gift__c = (Decimal)result.get('maxGiftAmt');
                 c.Average_Gift__c = (Decimal)result.get('avgGiftAmt');

                 c.Date_of_Last_Transaction__c = Date.valueOf(result.get('maxGiftDate'));
                 c.Date_of_First_Transaction__c = Date.valueOf(result.get('minGiftDate'));
              }

          }
      }

      if (last_year != null && last_year.size()>0)
      {
          for(AggregateResult result : last_year)
          {
              Account c = (Account)findItem('Id',String.valueOf(result.get('org')),accounts);
              if (c != null)
              {
                  c.Total_Giving_Last_Year__c = (Decimal)result.get('total');
              }
          }
      }

      if (last2_year != null && last2_year.size()>0)
      {
          for(AggregateResult result : last2_year)
          {
              Account c = (Account)findItem('Id',String.valueOf(result.get('org')),accounts);
              if (c != null)
              {
                  c.Total_Giving_Two_Years_Ago__c = (Decimal)result.get('total');
              }
          }
      }

      if (accounts != null && accounts.size()>0) {
        DMLManager.UpdateSObjects(accounts);
      }
   }

   public static void RecalculateGiftDates(Set<Id> contactIds)
   {
      BatchSettings__c settings =  BatchSettings__c.getInstance('Default');

      String RecordTypeIdforRollup;
      List<String> RecordTypeIdsforRollup;
      RecordTypeIdforRollup = (settings.Record_Type_Id_for_Rollups__c != null) ? settings.Record_Type_Id_for_Rollups__c : settings.RegularGiftRecordTypeId__c ;

      if(RecordTypeIdforRollup!=null)
        RecordTypeIdsforRollup = RecordTypeIdforRollup.Split(',');
      
      
      AggregateResult[] results = new GiftSelector().SelectMaxMinAvgByConstituentAndRecordType(contactIds, settings.RegularGiftRecordTypeId__c, Utilities.ConvertStringListToIdSet(RecordTypeIdsforRollup));
      AggregateResult[] last_year = new GiftSelector().SelectSumLastYearByConstituentAndRecordType(contactIds, settings.RegularGiftRecordTypeId__c, Utilities.ConvertStringListToIdSet(RecordTypeIdsforRollup));
                                   
      Date last2_year_start = Date.newInstance(Date.Today().Year()-2,1,1);
      Date last2_year_end = Date.newInstance(Date.Today().Year()-2,12,31);      
                                                  
      AggregateResult[] last2_year = new GiftSelector().SelectSumLastTwoYearsByConstituentAndRecordType(contactIds, last2_year_start, last2_year_end,settings.RegularGiftRecordTypeId__c, Utilities.ConvertStringListToIdSet(RecordTypeIdsforRollup));                                                 
      
      List<Contact> contacts = new ContactSelector().SelectContactGiftsByIdForUpdate(contactIds);
      
      Set<ID> contactIdsToUpdate = new Set<ID>();
      for(Contact c : contacts)
      {
        c.Total_Giving_Last_Year__c = 0;
        c.Total_Giving_Two_Years_Ago__c = 0;
      }

      if (last_year != null && last_year.size()>0)
      {
          for(AggregateResult result : last_year)
          {
              Contact c = (Contact)findItem('Id',String.valueOf(result.get('con')),contacts);
              if (c != null)
              {
                  c.Total_Giving_Last_Year__c = (Decimal)result.get('total');
                  if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);
              }
          }
      }

      if (last2_year != null && last2_year.size()>0)
      {
          for(AggregateResult result : last2_year)
          {
              Contact c = (Contact)findItem('Id',String.valueOf(result.get('con')),contacts);
              if (c != null)
              {
                  c.Total_Giving_Two_Years_Ago__c = (Decimal)result.get('total');
                  if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);
              }
          }
      }

      if (results != null && results.size()>0)
      {
          for(AggregateResult result : results)
          {
              Contact c = (Contact)findItem('Id',String.valueOf(result.get('con')),contacts);
              if (c != null)
              {
                 c.Date_of_Last_Gift__c = Date.valueOf(result.get('maxGiftDate'));
                 c.Date_of_First_Gift__c = Date.valueOf(result.get('minGiftDate'));
                 c.Largest_Gift__c = (Decimal)result.get('maxGiftAmt');
                 c.Average_Gift__c = (Decimal)result.get('avgGiftAmt');


                 c.Date_of_Last_Transaction__c = Date.valueOf(result.get('maxGiftDate'));
                 c.Date_of_First_Transaction__c = Date.valueOf(result.get('minGiftDate'));

                 if (!contactIdsToUpdate.contains(c.Id)) contactIdsToUpdate.add(c.Id);
              }

          }
      }

         List<Contact> values = new List<Contact>();
        for (Contact c : contacts)
        {
            if (contactIdsToUpdate.contains(c.Id)) values.add(c);
        }
        if (values.size() > 0) {
            DMLManager.UpdateSObjects(values);
        }
   }

  public static sObject findItem(String propertyName, String propertyValue, List<sObject> collection)
  {
     if (isEmptyOrNull(propertyName) || isEmptyOrNull(propertyValue) || collection==null)
       return null;

     for(sObject item : collection){
      if (item.get(propertyName)==propertyValue)
        return item;
     }

     return null;
  }

  public static List<sObject> findItems(String propertyName, String propertyValue, List<sObject> collection)
  {
     if (isEmptyOrNull(propertyName) || isEmptyOrNull(propertyValue) || collection==null)
       return null;

     List<sObject> results = new List<sObject>();

     for(sObject item : collection)
      if (item.get(propertyName)==propertyValue)
        results.add(item);

     return results;
  }

  public static Boolean IsEmptyOrNull(string value) {
    return (value==null || value=='');
  }

   @future(callout=true)
   public static void issueReceipts(Set<Id> ReceiptIds)
   {
    givingpowerSettings__c settings = null;
    string templateId = '';
    string consoTemplateId = '';
    string orgWideId = '';
    String rt = Utilities.getObjectRecordTypeId(Receipt__c.SObjectType, 'Issued');
    givingpowerSettings__c settingsRecords = givingpowerSettings__c.getInstance('Settings');
    if (settingsRecords != null) { templateId = settingsRecords.EmailTemplateId__c; orgWideId = settingsRecords.Org_Wide_Email_ID__c; consoTemplateId = settingsRecords.ConsolidatedReceiptEmailTemplateId__c; }
    
    
    List<Receipt__c> rs = new ReceiptSelector().SelectTransactionRecieptWhereIdInIds(ReceiptIds);
       
    List<Receipt__c> itemsToUpdate = new List<Receipt__c>();

    for(receipt__c r : rs)
    {
       if (r.Auto_Email_Receipt__c == true && r.Gift__r.Amount__c > 0 && r.Status__c != 'Issued' && r.Constituent__c != null)
       {
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setSaveAsActivity(false);
             if(r.Receipt_Type__c == 'Consolidated') {
                 mail.setTemplateId(consoTemplateId);
             } else {
                 mail.setTemplateId(templateId);
             }
             mail.setTargetObjectId(r.Constituent__c);
             mail.setWhatId(r.Id);
             if (orgWideId != null && orgWideId != '')
             { mail.setOrgWideEmailAddressId(orgWideId); }
             if (templateId != null && templateId != '')
             {
                 Try {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    DMLManager.InsertSObject(new Task(Subject = 'Automated Email Receipt Sent', Status = 'Completed', WhatId = r.Id, ActivityDate = Date.Today(), WhoId = r.Constituent__c, Type = 'Automated Email'));
                     } catch(Exception ex) { }
             }

             r.Status__c = 'Issued';
             r.RecordTypeId = rt;
             itemsToUpdate.add(r);
       }
    }

    if (itemsToUpdate.size()>0) {
     DMLManager.UpdateSObjects(itemsToUpdate);
    }
   }


   @future
   public static void UpdateGDs(String CampId)
   {
       List<Gift_Detail__c> gds = new AllocationSelector().SelectIdByCampaignIdForUpdate(CampId);
       if (gds != null && gds.size() > 0) {
        DMLManager.UpdateSObjects(gds);
       }
   }

   public static BatchGateway4.GatewaySoap newGPServiceInstance()
   {
        BatchSettings__c settings =  BatchSettings__c.getInstance('Default');

        //call GP Getway
        BatchGateway4.GatewaySoap gateway = new BatchGateway4.GatewaySoap();
        //gateway.endpoint_x =
        gateway.timeout_x = 120000;
        gateway.endpoint_x = settings.GatewayUrl__c;
        return gateway;
   }

   public static string maskCardNumber(string num)
   {
      if (IsEmptyOrNull(num))
        return num;

      if (num.length()<5)
        return num;

      string last4chars = num.substring(num.length()-4, num.length());
      integer maskLen = num.length()-4;
      string result = '';
      for(integer i=0;i<maskLen;i++)
        result += '*';

      return result + last4chars;
   }

   public static Recurring_Payment_Batch__c CreateTodayRecurringBatch()
   {
        List<Recurring_Payment_Batch__c> batches = new RecurringPaymentBatchSelector().SelectRecurringPaymentBatch('Credit Card');
        Recurring_Payment_Batch__c TodayBatch = null;
        if (batches==null || batches.size()<=0)
        {
            TodayBatch = new Recurring_Payment_Batch__c();
            TodayBatch.Process_Date__c = Date.today();
            TodayBatch.Payment_Type__c = 'Credit Card';
            TodayBatch.Comments__c = 'Payments processed by X-Charge on :' + Date.today().format();
            DMLManager.InsertSObject(TodayBatch);
        }
        else
         TodayBatch = batches[0];

     return TodayBatch;
   }

  @future
  public static void createGiftDetails(Set<Id> paymentIds) {
  try{
      Set<String> inputs = new Set<String>();
      map<id, Payment__c> toUpdatePayment = new map<id, Payment__c>();

      Map<String,String> paymentMap = new Map<String, String>();
        List<string> RD_Ids = new List<String>();
        Receipt__c theReceipt = null;
        List<Receipt__c> toInsertReceipt = new List<Receipt__c>();
      Set<String> recurringPIds = new Set<String>();
   
        List<Payment__c> ps1 = new PaymentSelector().SelectPaymentsByTypeAndId(paymentIds);
        for(Payment__c p : ps1){
           p.Credit_Card_Number__c = p.Donation__r.Recurring_Donation__r.Credit_Card__c;
           p.Credit_Card_Type__c = p.Donation__r.Recurring_Donation__r.Credit_Card_Type__c;
           p.Account_Number__c = p.Donation__r.Recurring_Donation__r.Account__c;
           p.Routing_Branch_Number__c = p.Donation__r.Recurring_Donation__r.Branch_Num__c;
           p.Transit_Number__c = p.Donation__r.Recurring_Donation__r.Institution_Num__c;
           p.Bank_Name__c = p.Donation__r.Recurring_Donation__r.Bank_Name__c;
           toUpdatePayment.put(p.id, p);
           Validator_cls.paymentidsset.add(p.id);
           inputs.add(p.Id+':'+p.Donation__r.Recurring_Donation__c);
           paymentMap.put(p.Id,p.Donation__r.Recurring_Donation__c);
           if (!isEmptyOrNull(p.Donation__r.Recurring_Donation__c)){
            RD_Ids.add(p.Donation__r.Recurring_Donation__c);
           }
        }
        
    Map<Id, Recurring_Donation__c> RDsMap =new map<Id, Recurring_Donation__c>(new RecurringDonationSelector().SelectAllocationOfRecurringGiftWhereIdInIds(Utilities.ConvertStringListToIdSet(RD_Ids)));

    List<Gift_Detail__c> itemsToBeInserted = new List<Gift_Detail__c>();
    Map<Id, Receipt__c> giftDetailMap = new Map<Id, Receipt__c>();
    decimal rdAmount = 0;
    integer cnt = 0;
    App_Settings__c appSetting = App_Settings__c.getInstance();

    for(Payment__c p : Ps1)
    {
        if(appSetting.Enable_Recurring_Receipts__c &&  p.Donation__r.Recurring_Donation__c != NULL && p.Receipt__c == null)
        {
          if (p.Donation__R.Constituent__c != null) {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Constituent__c = p.Donation__R.Constituent__c);
          }
            else {
            theReceipt = new Receipt__c(Receipt_Date__c = Date.Today(), Status__c = 'To Be Issued', Organization__c  = p.Donation__R.Organization__c);
            }

            theReceipt.Gift__c =  p.Donation__c;
            theReceipt.Receipt_Type__c = 'Single';
            theReceipt.Amount_Receipted__c = p.Amount__c;
            giftDetailMap.put(p.id, theReceipt);
        }

    }
    if(giftDetailMap.values().size() > 0){
        DMLManager.InsertSObjects(giftDetailMap.values());
    }
    for(Payment__c p : Ps1)
    {
        if(giftDetailMap.get(p.id) != null){
            p.receipt__c = giftDetailMap.get(p.id).id;
            toUpdatePayment.put(p.id, p);
          Validator_cls.paymentidsset.add(p.id);
        }
        if(p.Donation__R.Gift_Type__c == 'Recurring' && p.Allocations__r != null && p.Allocations__r.size() > 0) {
            continue;
        }

        cnt++;
        string RD_Id = paymentMap.get(p.Id);

        Recurring_Donation__c RD =RDsMap.get(RD_Id);
        if (RD==null || RD.Recurring_Gift_Allocations__r==null || RD.Recurring_Gift_Allocations__r.size()<=0)
            continue;
        for(RD_Allocation__c allocation : RD.Recurring_Gift_Allocations__r)
        {
            Gift_Detail__c gd = new Gift_Detail__c();
            gd.Allocation_Date__c = p.Date__c;
            if (p.Amount__c < 0)
            { gd.Amount__c = (0 - allocation.Amount__c); }
            else
            { gd.Amount__c = allocation.Amount__c; }
            rdAmount = allocation.Amount__c;
            gd.New_Campaign__c = allocation.New_Campaign__c;
            gd.Campaign__c = allocation.Campaign__c;
            gd.Fund__c = allocation.Fund__c;
            gd.Custom_Allocation_Text__c = allocation.Custom_Allocation_Text__c;
            gd.Gift__c = p.Donation__c;
            gd.Payment__c = p.Id;
            gd.Package__c = allocation.Package__c;

            itemsToBeInserted.add(gd);
        }

    }
    if (itemsToBeInserted!=null && itemsToBeInserted.size()>0 && rdAmount!=-8967) {
      DMLManager.InsertSObjects(itemsToBeInserted);
    }

    if (toUpdatePayment.values().size()!=null && toUpdatePayment.values().size()>0) {
        DMLManager.UpdateSObjects(toUpdatePayment.values());
    }

    }catch(Exception e){
        if(!Test.isRunningTest()){
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            string emailAddress = userInfo.getUserEmail();
             String[] toAddresses = new String[]{emailAddress};
             mail.setToAddresses(toAddresses);
             mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
             mail.setPlainTextBody(e.getMessage());
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }
    }
  }

  public static void executeNewYearTransactionsBatch(List<sObject> scope) {
        List<Gift__c> thisYearGifts = new List<Gift__c>();

        BatchSettings__c settings = BatchSettings__c.getInstance('Default');
        Contact c = new contact(LastName = 'ssss');
        DMLManager.InsertSObject(c);

        for(sObject o : scope)
        {
              Gift__c ng = (Gift__c)o;
              Gift__c g = new Gift__c();

              g.Channel__c = ng.Channel__c;
              g.Constituent__c = ng.Recurring_Donation__r.Constituent__c;
              g.Gift_Date__c = Date.Today();
              g.Gift_Type__c = ng.Gift_Type__c;
              g.Last_Payment_Date__c = ng.Last_Payment_Date__c;

              g.Receipt_Type__c = 'Consolidated';
              g.Recurring_Donation__c = ng.Recurring_Donation__c;
              g.Status__c = 'Active';
              g.Reference__c = ng.Recurring_Donation__r.Reference__c;
              if (g.Constituent__c == null) { g.Constituent__c = c.Id; }
              thisYearGifts.add(g);
        }

        DMLManager.InsertSObjects(thisYearGifts);
  }

  public static void executeConsolidatedReceiptBatch(List<sObject> scope) {
    List<Gift__c> giftsToUpdate = new List<Gift__c>();
        List<Receipt__c> receiptsToInsert = new List<Receipt__c>();

       if (scope== null || scope.size()<=0)
         return;


      for(sObject o : scope) {

        Contact c = (Contact)o;
        if (c.Gifts__r!=null && c.Gifts__r.size()>0)
        {

            Decimal total = 0;
            Decimal total1 = 0;
            List<payment__c> paymentlist= new List<payment__c>();

            for(Gift__c g : c.Gifts__r)
            {
               paymentlist= new PaymentSelector().SelectPaymentByStatusAndDonation('Approved', g.Id); 
               
               for(payment__c p:paymentlist){

                  total1 += p.Amount__c;
               }

                g.Status__c = 'Acknowledged';
                total += g.Amount__c;
            }

            Receipt__c r = new Receipt__c();
            r.Amount_Receipted__c = total1;
            r.Gift__c = c.Gifts__r[0].Id;
            r.Receipt_Date__c = Date.today();
            r.Status__c = 'To be Issued';
            r.Receipt_Type__c ='Consolidated';
            r.sysConsolidatedJob__c = true;
            receiptsToInsert.add(r);

        }
      }

      if (receiptsToInsert.size()>0) {
         DMLManager.InsertSObjects(receiptsToInsert);
      }

      for(sObject o : scope) {

          Contact c = (Contact)o;
          if (c.Gifts__r!=null && c.Gifts__r.size()>0)
          {

                Gift__c masterGift = c.Gifts__r[0];
                Receipt__c r = (Receipt__c)RollupHelper.findItem(namespaceFieldPrefix + 'Gift__c', masterGift.Id, receiptsToInsert);
                if (r != null)
                    for(Gift__c g : c.Gifts__r)
                    {
                        g.Consolidated_Rcpt__c = r.Id;
                        giftsToUpdate.add(g);
                    }
          }
      }

     if (giftsToUpdate.size()>0) {
       List<Id> giftIds = new List<Id>();
       for(Gift__c gift : giftsToUpdate) {
           giftIds.add(gift.Id);
       }

       DMLManager.UpdateSObjects(giftsToUpdate);

       //Update all the Payment records belonging to the Transcation with the receipt Id of the Transaction record.
       List<Payment__c> payments = new PaymentSelector().SelectConsolidateReportForPaymentByStatusAndId(Utilities.ConvertIdListToIdSet(giftIds));
       if(payments != null && payments.size() > 0) {
           for(Integer i = 0; i < payments.size(); i++) {
               payments[i].Receipt__c = payments[i].Donation__r.Consolidated_Rcpt__c;
           }
           DMLManager.UpdateSObjects(payments);
       }

     }
  }

    @future
    public static void creditDetailUpdationOnGiftMethod(set<Id> giftIds){
        List<Gift__c> giftRecordsToUpdate = new List<Gift__c>();
        List<Gift__c> giftRecords = new List<Gift__c>();
        if(giftIds.size() > 0){
            giftRecords = new List<Gift__c>(new GiftSelector().SelectRecurringGiftPaymentsById(giftIds));
        }

        if(giftRecords.size() >0)
        {
            for(Gift__c gift : giftRecords)
            {
                Payment__c paymentRecord = gift.Recurring_Payments__r;
                gift.Credit_Card_Number__c = paymentRecord.Credit_Card_Number__c;
                gift.Credit_Card_Type__c = paymentRecord.Credit_Card_Type__c;
                giftRecordsToUpdate.add(gift);
            }
        }
        if(giftRecordsToUpdate.size() > 0){
            DMLManager.UpdateSObjects(giftRecordsToUpdate);
        }
    }

    @future
    public static void RefundAllocationsMethod(Set<String> refundedPaymentIds, Set<String> refundPaymentIds){
        Map<String, List<Gift_Detail__c>> payment_to_allocations = new Map<String, List<Gift_Detail__c>>();
        Map<String, Decimal> payment_to_amount = new Map<String, Decimal>();
        List<Gift_Detail__c> allocationsToInsert = new List<Gift_Detail__c>();
        List<Payment__c> refundedPayments = new PaymentSelector().SelectAllocationForPaymentById(Utilities.ConvertStringSetToIdSet(refundedPaymentIds));    
        List<Payment__c> refundPayments = new PaymentSelector().SelectRefundedPaymentByPaymentId(Utilities.ConvertStringSetToIdSet(refundPaymentIds));       
        List<Gift_Detail__c> bufferAllocations = new List<Gift_Detail__c>();
        for (Payment__c p : refundedPayments)
        {
            payment_to_allocations.put(p.Id, p.Allocations__r);
            payment_to_amount.put(p.Id, p.Amount__c);
        }
        Gift_Detail__c bufferGiftDetail = new Gift_Detail__c();

        for (Payment__c p : refundPayments)
        {
            for (Gift_Detail__c gd : payment_to_allocations.get(p.Payment_Refunded__c))
            {
                bufferGiftDetail = new Gift_Detail__c();
                bufferGiftDetail.Payment__c = p.Id;
                bufferGiftDetail.Allocation_Date__c = Date.Today();
                bufferGiftDetail.New_Campaign__c = gd.New_Campaign__c;
                bufferGiftDetail.Gift__c = gd.Gift__c;
                bufferGiftDetail.Tribute__c = gd.Tribute__c;
                bufferGiftDetail.Product__c = gd.Product__c;
                bufferGiftDetail.Fund__c = gd.Fund__c;
                bufferGiftDetail.Amount__c = (p.Amount__c * (gd.Amount__c/payment_to_amount.get(p.Payment_Refunded__c)));

                if(gd.Quantity__c != null && gd.Event_Level__c != null)
                {
                bufferGiftDetail.Quantity__c = 0 - gd.Quantity__c;
                bufferGiftDetail.Event_Level__c = gd.Event_Level__c;
                }

                allocationsToInsert.add(bufferGiftDetail);
            }
        }
        if(allocationsToInsert.size() > 0) {
            DMLManager.InsertSObjects(allocationsToInsert);
        }
    }

    public static void updateCurrency(List<Receipt__c> receiptList){
        Boolean multiCurrenyEnable = checkMCEnabled();
        if(multiCurrenyEnable){
            set<Id> giftIds = new set<Id>();
            for(Receipt__c receipt : receiptList){
                giftIds.add(receipt.Gift__c);
            }
            String inFields = Converter.ConvertListSetToString(giftIds);
            String whereClase = 'Id IN (' + inFields + ')';
            List<Gift__c> giftRecord_List = new GenericQueryBuilder().ListQueryBuilderWhere('Gift__c', 'CurrencyIsoCode', whereClase);
            Map<Id, String> giftRecord_Map = new Map<Id, String>();
            for(Gift__c gift : giftRecord_List){
                giftRecord_Map.put(gift.id, (String)gift.get('CurrencyIsoCode'));
            }
            for(Receipt__c receipt : receiptList){
                receipt.put('CurrencyIsoCode', giftRecord_Map.get(receipt.Gift__c));
            }
        }
    }

    public static Boolean checkMCEnabled(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType mcEnabled = gd.get('CurrencyType');
        return (mcEnabled != null) ? true : false;
    }

  static testMethod void testMe()
  {
      boolean value = isEmptyOrNull('');
     List<Account> accs = new AccountSelector().SelectAccountIdAndNameWithLimit(10);
     if (accs!=null && accs.size()>0) {
        Account acc = (Account)findItem('Id', accs[0].Id, accs);
     }

     string result = maskCardNumber('2632784632874');
  }
}