public without sharing class AppealUtil {
     
    public static void RollupCampaigns(Set<Id> AppealIDs)
    {
        Set<Id> AppealIDsH = new Set<Id>();
        Map<String, List<Campaign>> Appeals_to_Children = new Map<String, List<Campaign>>();    
        Integer fysm;
        List<Organization> organizationList = new OrganizationSelector().SelectFiscalYearStartMonthByIdAndLimit(new Set<Id> { Userinfo.getOrganizationId() }, 1);  
        if (organizationList != null && organizationList.size() > 0) {
            fysm = organizationList[0].FiscalYearStartMonth;
        }
        List<Date> FiscalQuarterArray = getFQArray(fysm);
        Date FiscalYearStartDate = Date.Today();

        if (Date.Today().Month() >= fysm) { 
            FiscalYearStartDate = Date.newInstance(Date.Today().Year(), fysm, 1); 
        }
        if (Date.Today().Month() < fysm) { 
            FiscalYearStartDate = Date.newInstance(Date.Today().Year() - 1, fysm, 1); 
        }

        if (AppealIDs == null || AppealIDs.size()<=0)
        return;
                                  
      	List<Campaign> Appeals = new List<Campaign>();
        List<Campaign> campaignList = new CampaignSelector().SelectSObjectsByIdForUpdate(AppealIDs);
        for(Campaign appeal : campaignList) {
            Appeals.add(appeal);
        }
        
        List<Gift_Detail__c> Allocations = new List<Gift_Detail__c>();
        List<Gift_Detail__c> allocationsList = new AllocationSelector().SelectByNewCampaign(AppealIDs);
        for(Gift_Detail__c allocation : allocationsList) {
            Allocations.add(allocation);
        }
        
        for(Campaign c : Appeals) {
            AppealIDsH.add(c.Id);
        }
        
        List<Campaign> AppealsH = new CampaignSelector().SelectByParentOrParentId(AppealIDsH);
        for(Campaign c : Appeals) {
            List<Campaign> cs = new List<Campaign>();
            for(Campaign cH : AppealsH) {
                if(c.Id == cH.ParentId ) { 
                    cs.add(cH); 
                }
            }
            Appeals_to_Children.put(c.Id, cs);
        }

        for(Campaign c : Appeals) {
            transient Integer countGiftsFY = 0;
            transient Integer countGiftsFQ = 0;            
            transient Decimal Amount = 0;
            transient Decimal AmountRD = 0;            
            transient Decimal AmountH = 0;
            transient Decimal AmountRDH = 0;            
            transient Decimal AmountFY = 0;
            transient Decimal AmountFQ = 0;
            transient Decimal AmountFYH = 0;
            transient Decimal AmountFQH = 0;    
            transient Decimal AmountRDFY = 0;
            transient Decimal AmountRDFQ = 0;
            transient Decimal AmountRDFYH = 0;
            transient Decimal AmountRDFQH = 0;   
            c.Gift_Amount__c = 0; 
            c.Overall_Gift_Amount__c = 0;
            c.One_Time_Gift_Count__c = 0;           
            c.Overall_One_Time_Gift_Count__c = 0;
            c.Overall_Recurring_Gift_Count__c = 0;
            c.Recurring_Gift_Count__c = 0;
            c.Gifts_for_Current_Fiscal__c = 0;
            c.Overall_Gifts_for_Current_Fiscal__c = 0;
            c.Overall_Gifts_for_Current_Quarter__c = 0; 
            c.Gifts_for_Current_Quarter__c = 0;                              
            Set<String> Count = new Set<String>();
            Set<String> CountRD = new Set<String>();            
            Set<String> CountH = new Set<String>();
            Set<String> CountRDH = new Set<String>();            
            Campaign ParentRec =new Campaign();
            
            if (Allocations != null)           
            {
                for(Gift_Detail__c gd : Allocations)
                {
                	if(c.Id == gd.New_Campaign__c){                   
	                    if (gd.Gift__r.Gift_Type__c == 'Recurring')
	                    { 
	                        AmountRD += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
	                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
	                        { AmountRDFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
	                        { AmountRDFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        CountRD.add(gd.Gift__r.Recurring_Donation__c);
	                    }
	                    else
	                    {
	                        Amount += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
	                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
	                        { AmountFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
	                        { AmountFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        Count.add(gd.Gift__c);                    
	                    }
                	}
                }
            }                                          
            
            if (Appeals_to_Children.containsKey(c.Id))
            {
                for (Campaign cH : Appeals_to_Children.get(c.Id)) {
                    if (cH!=null){
                    
                    cH.Overall_Gift_Amount__c = cH.Overall_Gift_Amount__c == null? 0.00 : cH.Overall_Gift_Amount__c;           
                    c.Overall_Gift_Amount__c += cH.Overall_Gift_Amount__c;                   
                                 
                    cH.Overall_One_Time_Gift_Count__c = cH.Overall_One_Time_Gift_Count__c == null? 0 : cH.Overall_One_Time_Gift_Count__c;
                    c.Overall_One_Time_Gift_Count__c += cH.Overall_One_Time_Gift_Count__c;
                    
                     
                    cH.Overall_Recurring_Gift_Count__c = cH.Overall_Recurring_Gift_Count__c == null? 0 : cH.Overall_Recurring_Gift_Count__c;                                     
                    c.Overall_Recurring_Gift_Count__c += cH.Overall_Recurring_Gift_Count__c; 
                    
                    cH.Overall_Gifts_for_Current_Fiscal__c = cH.Overall_Gifts_for_Current_Fiscal__c == null? 0.00 : cH.Overall_Gifts_for_Current_Fiscal__c;
                    c.Overall_Gifts_for_Current_Fiscal__c += cH.Overall_Gifts_for_Current_Fiscal__c;
                     
                    cH.Overall_Gifts_for_Current_Quarter__c = cH.Overall_Gifts_for_Current_Quarter__c == null? 0.00 : cH.Overall_Gifts_for_Current_Quarter__c;
                    c.Overall_Gifts_for_Current_Quarter__c += cH.Overall_Gifts_for_Current_Quarter__c; 
                    
                    cH.Gifts_for_Current_Quarter__c = cH.Gifts_for_Current_Quarter__c == null? 0.00 : cH.Gifts_for_Current_Quarter__c; 
                    c.Gifts_for_Current_Quarter__c += cH.Gifts_for_Current_Quarter__c;
                    }
                }
            }            
                
            c.Overall_Gift_Amount__c += Amount + AmountH + AmountRD + AmountRDH;
            c.Gifts_for_Current_Quarter__c += AmountFQ + AmountRDFQ;
            c.Overall_Gifts_for_Current_Quarter__c += AmountFQ + AmountFQH + AmountRDFQ + AmountRDFQH;
            c.Overall_Gifts_for_Current_Fiscal__c += AmountFY + AmountFYH + AmountRDFY + AmountRDFYH;
            c.Gifts_for_Current_Fiscal__c += AmountFY + AmountRDFY;
            c.Recurring_Gift_Count__c += CountRD.size();
            c.Overall_One_Time_Gift_Count__c += (Count.size() + CountH.size());
            c.Overall_Recurring_Gift_Count__c += (CountRD.size() + CountRDH.size());
            c.Gift_Amount__c += Amount + AmountRD;
            c.One_Time_Gift_Count__c += Count.size();   
                        
            }
            
            DMLManager.UpdateSObjects(Appeals);
        }
    
    
    public static void RollupPackages(Set<Id> AppealIDs)
    {
        Integer fysm;
        List<Organization> organizationList = new OrganizationSelector().SelectFiscalYearStartMonthByIdAndLimit(new Set<Id> { Userinfo.getOrganizationId() }, 1);  
        if (organizationList != null && organizationList.size() > 0) {
            fysm = organizationList[0].FiscalYearStartMonth;
        }

        List<Date> FiscalQuarterArray = getFQArray(fysm);
        Date FiscalYearStartDate = Date.Today();

        if (Date.Today().Month() >= fysm) { 
            FiscalYearStartDate = Date.newInstance(Date.Today().Year(), fysm, 1);
        }
        if (Date.Today().Month() < fysm) { 
            FiscalYearStartDate = Date.newInstance(Date.Today().Year() - 1, fysm, 1); 
        }

        if (AppealIDs == null || AppealIDs.size()<=0)
        return;

      	List<Campaign> Appeals = new List<Campaign>();
        List<Campaign> campaignList = new CampaignSelector().SelectSObjectsByIdForUpdate(AppealIDs);
        for(Campaign appeal : campaignList) {
            Appeals.add(appeal);
        }
        
        List<Gift_Detail__c> Allocations = new List<Gift_Detail__c>();
        List<Gift_Detail__c> allocationsList = new AllocationSelector().SelectByNewCampaign(AppealIDs);
        for(Gift_Detail__c allocation : allocationsList) {
            Allocations.add(allocation);
        }
                                          
        for(Campaign c : Appeals) {
            Integer countGiftsFY = 0;
            Integer countGiftsFQ = 0;            
            Decimal Amount = 0;
            Decimal AmountRD = 0;            
            Decimal AmountH = 0;
            Decimal AmountRDH = 0;            
            Decimal AmountFY = 0;
            Decimal AmountFQ = 0;
            Decimal AmountFYH = 0;
            Decimal AmountFQH = 0;    
            Decimal AmountRDFY = 0;
            Decimal AmountRDFQ = 0;
            Decimal AmountRDFYH = 0;
            Decimal AmountRDFQH = 0;                     
            Set<String> Count = new Set<String>();
            Set<String> CountRD = new Set<String>();            
            Set<String> CountH = new Set<String>();
            Set<String> CountRDH = new Set<String>();
            
            if (Allocations != null)           
            {
                for(Gift_Detail__c gd : Allocations)
                {
                	if(c.Id == gd.New_Campaign__c){ 
                		if (gd.Gift__r.Recurring_Donation__c != null)
	                    { 
	                        AmountRD += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
	                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
	                        { AmountRDFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
	                        { AmountRDFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        CountRD.add(gd.Gift__r.Recurring_Donation__c);
	                    }
	                    else
	                    {
	                        Amount += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
	                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
	                        { AmountFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
	                        { AmountFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        Count.add(gd.Gift__c);                    
	                    }
                	}                   
                }
            }                                          
                      
            c.Gift_Amount__c = Amount + AmountRD; 
            c.Overall_Gift_Amount__c = Amount + AmountH + AmountRD + AmountRDH;
            c.One_Time_Gift_Count__c = Count.size();           
            c.Overall_One_Time_Gift_Count__c = (Count.size() + CountH.size());
            c.Overall_Recurring_Gift_Count__c = (CountRD.size() + CountRDH.size());
            c.Recurring_Gift_Count__c = CountRD.size();
            c.Gifts_for_Current_Fiscal__c = AmountFY + AmountRDFY;
            c.Overall_Gifts_for_Current_Fiscal__c = AmountFY + AmountFYH + AmountRDFY + AmountRDFYH;
            c.Overall_Gifts_for_Current_Quarter__c = AmountFQ + AmountFQH + AmountRDFQ + AmountRDFQH; 
            c.Gifts_for_Current_Quarter__c = AmountFQ + AmountRDFQ;
        }         
        DMLManager.UpdateSObjects(Appeals);
    }
    
    public static void RollupAppeals(Set<Id> AppealIDs)
    {
        Set<Id> AppealIDsH = new Set<Id>();
        Map<String, List<Campaign>> Appeals_to_Children = new Map<String, List<Campaign>>();
        Integer fysm;
        List<Organization> organizationList = new OrganizationSelector().SelectFiscalYearStartMonthByIdAndLimit(new Set<Id> { Userinfo.getOrganizationId() }, 1);  
        if (organizationList != null && organizationList.size() > 0) {
            fysm = organizationList[0].FiscalYearStartMonth;
        }
        List<Date> FiscalQuarterArray = getFQArray(fysm);
        Date FiscalYearStartDate = Date.Today();

        if (Date.Today().Month() >= fysm) { 
            FiscalYearStartDate = Date.newInstance(Date.Today().Year(), fysm, 1); 
        }
        if (Date.Today().Month() < fysm) { 
            FiscalYearStartDate = Date.newInstance(Date.Today().Year() - 1, fysm, 1); 
        }

        if (AppealIDs == null || AppealIDs.size()<=0)
        return;
                                  
        List<Campaign> Appeals = new List<Campaign>();
        List<Campaign> campaignList = new CampaignSelector().SelectSObjectsByIdForUpdate(AppealIDs);
        for(Campaign appeal : campaignList) {
            Appeals.add(appeal);
        }
        
        List<Gift_Detail__c> Allocations = new List<Gift_Detail__c>();
        List<Gift_Detail__c> allocationsList = new AllocationSelector().SelectByNewCampaign(AppealIDs);
        for(Gift_Detail__c allocation : allocationsList) {
            Allocations.add(allocation);
        }
        
        for(Campaign c : Appeals) {
            AppealIDsH.add(c.Id);
        }

        List<Campaign> AppealsH = new CampaignSelector().SelectByParentId(AppealIDsH);
        for(Campaign c : Appeals) {
            List<Campaign> cs = new List<Campaign>();
            for(Campaign cH : AppealsH) {
                if(c.Id == cH.ParentId) { 
                    cs.add(cH);
                }
            }
            Appeals_to_Children.put(c.Id, cs);
        }       
        
        for(Campaign c : Appeals) {
            transient Integer countGiftsFY = 0;
            transient Integer countGiftsFQ = 0;            
            transient Decimal Amount = 0;
            transient Decimal AmountRD = 0;            
            transient Decimal AmountH = 0;
            transient Decimal AmountRDH = 0;            
            transient Decimal AmountFY = 0;
            transient Decimal AmountFQ = 0;
            transient Decimal AmountFYH = 0;
            transient Decimal AmountFQH = 0;    
            transient Decimal AmountRDFY = 0;
            transient Decimal AmountRDFQ = 0;
            transient Decimal AmountRDFYH = 0;
            transient Decimal AmountRDFQH = 0;                     
            c.Gift_Amount__c = 0; 
            c.Overall_Gift_Amount__c = 0;
            c.One_Time_Gift_Count__c = 0;           
            c.Overall_One_Time_Gift_Count__c = 0;
            c.Overall_Recurring_Gift_Count__c = 0;
            c.Recurring_Gift_Count__c = 0;
            c.Gifts_for_Current_Fiscal__c = 0;
            c.Overall_Gifts_for_Current_Fiscal__c = 0;
            c.Overall_Gifts_for_Current_Quarter__c = 0; 
            c.Gifts_for_Current_Quarter__c = 0;
            Set<String> Count = new Set<String>();
            Set<String> CountRD = new Set<String>();            
            Set<String> CountH = new Set<String>();
            Set<String> CountRDH = new Set<String>();
            
            if (Allocations != null)           
            {
                for(Gift_Detail__c gd : Allocations)
                {
                	if(c.Id == gd.New_Campaign__c){                   
	                    if (gd.Gift__r.Gift_Type__c == 'Recurring')
	                    { 
	                        AmountRD += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
	                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
	                        { AmountRDFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
	                        { AmountRDFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        CountRD.add(gd.Gift__r.Recurring_Donation__c);
	                    }
	                    else
	                    {
	                        Amount += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; 
	                        if (isCurrentFiscal(gd.Allocation_Date__c, fysm))
	                        { AmountFY += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        if (isCurrentFiscalQuarter(gd.Allocation_Date__c, FiscalQuarterArray))
	                        { AmountFQ += (gd.Approved_Amount__c != null) ? gd.Approved_Amount__c : 0; }
	                        Count.add(gd.Gift__c);                    
	                    }
                	}
                }
            }                                          
            
            if (Appeals_to_Children.containsKey(c.Id))
            {
                for (Campaign cH : Appeals_to_Children.get(c.Id))
                {  
                  if (cH!=null){ //added by Sam  
                    cH.Overall_Gift_Amount__c = cH.Overall_Gift_Amount__c == null? 0.00 : cH.Overall_Gift_Amount__c;    
                    c.Overall_Gift_Amount__c += cH.Overall_Gift_Amount__c;  
                       
                    cH.Overall_One_Time_Gift_Count__c = cH.Overall_One_Time_Gift_Count__c == null? 0 : cH.Overall_One_Time_Gift_Count__c;                  
                    c.Overall_One_Time_Gift_Count__c += cH.Overall_One_Time_Gift_Count__c;
                    
                    cH.Overall_Recurring_Gift_Count__c = cH.Overall_Recurring_Gift_Count__c == null? 0 : cH.Overall_Recurring_Gift_Count__c;
                    c.Overall_Recurring_Gift_Count__c += cH.Overall_Recurring_Gift_Count__c;
                    
                    cH.Overall_Gifts_for_Current_Fiscal__c= cH.Overall_Gifts_for_Current_Fiscal__c == null? 0.00 :cH.Overall_Gifts_for_Current_Fiscal__c;                                        
                    c.Overall_Gifts_for_Current_Fiscal__c += cH.Overall_Gifts_for_Current_Fiscal__c;
                    
                    cH.Overall_Gifts_for_Current_Quarter__c = cH.Overall_Gifts_for_Current_Quarter__c == null? 0.00 : cH.Overall_Gifts_for_Current_Quarter__c;
                    c.Overall_Gifts_for_Current_Quarter__c += cH.Overall_Gifts_for_Current_Quarter__c;
                    
                    cH.Gifts_for_Current_Quarter__c = cH.Gifts_for_Current_Quarter__c == null? 0.00 : cH.Gifts_for_Current_Quarter__c;
                    c.Gifts_for_Current_Quarter__c += cH.Gifts_for_Current_Quarter__c;
                   }
                }
            }            
                 
            c.Overall_Gift_Amount__c += Amount + AmountH + AmountRD + AmountRDH;
            c.Gifts_for_Current_Quarter__c += AmountFQ + AmountRDFQ;
            c.Overall_Gifts_for_Current_Quarter__c += AmountFQ + AmountFQH + AmountRDFQ + AmountRDFQH;
            c.Overall_Gifts_for_Current_Fiscal__c += AmountFY + AmountFYH + AmountRDFY + AmountRDFYH;
            c.Gifts_for_Current_Fiscal__c += AmountFY + AmountRDFY;
            c.Recurring_Gift_Count__c += CountRD.size();
            c.Overall_One_Time_Gift_Count__c += (Count.size() + CountH.size());
            c.Overall_Recurring_Gift_Count__c += (CountRD.size() + CountRDH.size());
            c.Gift_Amount__c += Amount + AmountRD;
            c.One_Time_Gift_Count__c += Count.size();           
            
          
        }
        DMLManager.UpdateSObjects(Appeals);
    }
    
    public static void RollupExpenses(Set<String> AppealIDs)
    {
        if (AppealIDs == null || AppealIDs.size()<=0)
        return;

        Set<Id> idAppealSet = new Set<Id>();
        for (String strId : AppealIDs) {
            idAppealSet.add(strId);
        }
        List<Campaign> Appeals = new CampaignSelector().SelectCampaignAndExpensesById(idAppealSet);
        
        for(Campaign c : Appeals)
        {
            Decimal Amount = 0;

            if (c.Expenses__r != null)           
            {
                for(Expense__c ex : c.Expenses__r)
                { Amount += (ex.Amount__c != null) ? ex.Amount__c : 0; }
            }                               
            
            c.ActualCost = Amount;  
        }
        DMLManager.UpdateSObjects(Appeals);
    }
    
    public static Boolean isCurrentFiscal(Date aDate, Integer fysm)
   {
       Integer FYrStrtMonth = fysm;
       if (aDate == null)
           return false;
       
       //if the fiscal year starts on Jan 1st, then we only need to check the year
       if (FYrStrtMonth == 1 && aDate.Year() == Date.Today().Year())
       { return true; }       
       //if the current month is beyond the starting fiscal month, the fiscal year ends in the next calendar year
       if (Date.Today().Month() >= FYrStrtMonth && aDate >= Date.newInstance(Date.Today().Year(), FYrStrtMonth, 1) && aDate < Date.newInstance(Date.Today().Year() + 1, FYrStrtMonth, 1))
       { return true; }
       //if the current month has not reached the starting fiscal month, the fiscal year began in the previous calendar year       
       else if (Date.Today().Month() < FYrStrtMonth && aDate >= Date.newInstance(Date.Today().Year() - 1, FYrStrtMonth, 1) && aDate < Date.newInstance(Date.Today().Year(), FYrStrtMonth, 1))
       { return true; }
              
       return false;
   }
   
    public static List<Date> getFQArray(Integer fysm)
   {
        //Integer FYrStrtMonth = fysm;      
        Date FiscalYearStartDate;
        Integer currentQuarter = -1;    
        
        if (fysm == 0 || fysm == null)
            return null;
        
        if (Date.Today().Month() >= fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year(), fysm, 1); }
        if (Date.Today().Month() < fysm)
        { FiscalYearStartDate = Date.newInstance(Date.Today().Year() - 1, fysm, 1); }

        // Jan/Feb/March, April/May/June, July/Aug/Sept, Oct/Nov/Dec { [Jan 1 2011, March 31 2011], [April 1 2011, June 30 2011], [July 1 2011, Sept 31 2011], [Oct 1 2011, Dec 31 2011] }
        List<List<Date>> FiscalQuarterArray = new List<List<Date>>();      

        Integer fy = FiscalYearStartDate.Year();
        for (Integer i = 0; i < 4; i++)
        {
            List<Date> aQuarter = new List<Date>();
            aQuarter.add(Date.newInstance(fy, fysm, 1));
            fysm += 2;
            if (fysm > 12)
            { fysm = Math.mod(fysm, 12); fy++; }
            
            /*for (Integer c = 0; c < 2; c++)
            {
                fysm++;
                if (fysm > 12)
                { fysm = 1; fy++;}                              
            }*/
            
            aQuarter.add(Date.newInstance(fy, fysm, Date.daysInMonth(fy, fysm)));
            fysm++;
            FiscalQuarterArray.add(aQuarter);
        }       
        
        for (Integer i = 0; i < 4; i++)     
        {           
            Date FQstart = FiscalQuarterArray[i].get(0);
            Date FQend = FiscalQuarterArray[i].get(1);
            
            if (Date.Today() >= FQstart && Date.Today() <= FQend) {
                currentQuarter = i; break;
            }
        }
        
        return FiscalQuarterArray[currentQuarter];
    }
    
   public static Boolean isCurrentFiscalQuarter(Date aDate, List<Date> FiscalQuarterArray)
   {
        if (aDate >= FiscalQuarterArray.get(0) && aDate <= FiscalQuarterArray.get(1))
        {
            return true;
        }
        
        return false;
   }
}