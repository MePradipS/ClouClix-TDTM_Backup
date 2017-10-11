global with sharing class MetricsCore {
    
    public static void CalculateForDate(Date dateToQuery) {
        Metric__c metric = new Metric__c();

        Metric__c[] existingMetrics = new MetricSelector().SelectIdByReportDate(dateToQuery);
        
        if (existingMetrics != null && existingMetrics.size() > 0) {
            metric = existingMetrics[0];
        }

        metric.Report_Date__c = dateToQuery;

        // Total # of Active Monthly Donors 
        AggregateResult[] totalActiveMonthlyDonors_ar = new RecurringDonationSelector().SelectActiveNumberOfConstituentsByStartDateStatusAndAmount(dateToQuery, 'Active', 0);
             
        Object totalActiveMonthlyDonors_obj = totalActiveMonthlyDonors_ar[0].get('donorCount');
        Decimal totalActiveMonthlyDonors = 0;
        if (totalActiveMonthlyDonors_obj != null)
        {
            totalActiveMonthlyDonors = (Integer) totalActiveMonthlyDonors_obj;
        } 
        
        metric.Total_of_Active_Monthly_Donors__c = totalActiveMonthlyDonors;
        
        // Month ranges used for determing if the start dates of the donations 
        // are in the current month
        Date startOfMonth = dateToQuery.toStartOfMonth();
        Date startOfNextMonth = startOfMonth.addMonths(1);
        
        // # of New Monthly Donors
        AggregateResult[] newMonthlyDonors_ar = new RecurringDonationSelector().SelectActiveNumberOfConstituentsWithinMonth(startOfMonth, startOfNextMonth, 'Active');
        
        Object newMonthlyDonors_obj = newMonthlyDonors_ar[0].get('donorCount');
        Decimal newMonthlyDonors = 0;
        if (newMonthlyDonors_obj != null) {
            newMonthlyDonors = (Integer) newMonthlyDonors_obj;
        } 
        
        metric.of_new_Monthly_Donors__c = newMonthlyDonors;
        
        // # of Converted Monthly Donors
        
        Decimal convertedMonthlyDonorCount = 0;
        List<Gift_Detail__c>  convertedMonthlyDonorList = new AllocationSelector().SelectGiftByRecurringDonationMonthAndStatus(startOfMonth, startOfNextMonth, 'Active');
        
        Set<String> convertedDonorIds = new Set<String>();
                                 
        for(Gift_Detail__c currentAllocation : convertedMonthlyDonorList) {          
            // if the monthly donor is not already in the set
            if (!convertedDonorIds.contains(currentAllocation.Gift__r.Constituent__r.Id)) {
                
                // getting the first gift date of the current allocations donor
                Date FirstGift = Date.valueOf(currentAllocation.Gift__r.Constituent__r.Date_of_First_Gift__c);
                
                // getting the start date of the current allocations recurring gift
                Date StartDate = Date.valueOf(currentAllocation.Gift__r.Recurring_Donation__r.Start_Date__c);
                
                // checking if the first gift is less than the start date of the recurring gift
                if(FirstGift < StartDate) { 
                    // they are considered a converted monthly donor
                    convertedMonthlyDonorCount++;
                    
                    // add to the set so that we skip this donor
                    convertedDonorIds.add(currentAllocation.Gift__r.Constituent__r.Id);
                }
            }
        }        
        
        metric.of_Converted_Monthly_Donors__c = convertedMonthlyDonorCount;    

        // # of Churned Monthly Donors
        AggregateResult[] churnedMonthlyDonors_ar = new RecurringDonationSelector().SelectActiveNumberOfConstituentsWithinMonth(startOfMonth, startOfNextMonth, 'Cancelled');

        Object churnedMonthlyDonors_obj = churnedMonthlyDonors_ar[0].get('donorCount');
        Decimal churnedMonthlyDonors = 0;
        if (churnedMonthlyDonors_obj != null)
        {
            churnedMonthlyDonors = (Integer) churnedMonthlyDonors_obj;
        } 
        
        metric.of_Churned_Monthly_Donors__c = churnedMonthlyDonors;
        
        // # of On Hold Monthly Donors
        AggregateResult[] totalOnHoldMonthlyDonors_ar = new RecurringDonationSelector().SelectActiveNumberOfConstituentsByStartDateStatusAndAmount(dateToQuery, 'On Hold', 0);
             
        Object totalOnHoldMonthlyDonors_obj = totalOnHoldMonthlyDonors_ar[0].get('donorCount');
        Decimal totalOnHoldMonthlyDonors = 0;
        if (totalOnHoldMonthlyDonors_obj != null)
        {
            totalOnHoldMonthlyDonors = (Integer) totalOnHoldMonthlyDonors_obj;
        } 
        
        metric.Total_of_On_Hold_Monthly_Donors__c = totalOnHoldMonthlyDonors;   
        
        // New MRG ($)
        AggregateResult[] newMrgSum_ar = new RecurringdonationSelector().SelectTotalAmountWithinMonth(startOfMonth, startOfNextMonth, 'Active');
        
        Object sumNewMRGAmount_obj = newMrgSum_ar[0].get('sum');
        Decimal newMrgSum = 0;
        
        if (sumNewMRGAmount_obj != null){
            newMrgSum = (Decimal) sumNewMRGAmount_obj;
        } 
        
        metric.New_MRG__c = newMrgSum;

        // Expansion MRG ($)
        Decimal expansionMrgSum = 0;   
        List<Gift_Detail__c> expansionMrgSumlist = new AllocationSelector().SelectGiftByRecurringDonationMonth(startOfMonth, startOfNextMonth);
                          
        for(Gift_Detail__c currentAllocation : expansionMrgSumlist) {
            
            Date FirstGift = Date.valueOf(currentAllocation.Gift__r.Constituent__r.Date_of_First_Gift__c);
            Date StartDate = Date.valueOf(currentAllocation.Gift__r.Recurring_Donation__r.Start_Date__c);
            
            Decimal tempAmount = (Decimal) currentAllocation.Amount__c;

            if(FirstGift < StartDate) {
                expansionMrgSum += tempAmount; 
            }
        }
        
        metric.Expansion_MRG__c = expansionMrgSum;

        // Churned MRG ($)
        AggregateResult[] churnedMrgSum_ar = new RecurringDonationSelector().SelectTotalAmountWithinMonth(startOfMonth, startOfNextMonth, 'Cancelled');
            
        Object sumChurnedMRGAmount_obj = churnedMrgSum_ar[0].get('sum');
        Decimal sumChurnedMRGAmount = 0 ;
        
        if (sumChurnedMRGAmount_obj != null){
            sumChurnedMRGAmount = (Decimal) sumChurnedMRGAmount_obj;
        }              
        
        metric.Churned_MRG__c = sumChurnedMRGAmount;

        // MRG ($)
        AggregateResult[] MRG_ar = new RecurringDonationSelector().SelectTotalAmountByStartDate(dateToQuery, 'Active');
            
        Object sumMRG_obj = MRG_ar[0].get('sum');
        Decimal sumMRG = 0;
        
        if (sumMRG_obj != null) {
            sumMRG = (Decimal) sumMRG_obj;
        }
        
        metric.MRG__c = sumMRG;
        
        // On Hold MRG ($)
        AggregateResult[] onHoldMRG_ar = new RecurringDonationSelector().SelectTotalAmountByStartDate(dateToQuery, 'On Hold');
            
        Object sumOnHoldMRG_obj = onHoldMRG_ar[0].get('sum');
        Decimal sumOnHoldMRG = 0;
        
        if (sumOnHoldMRG_obj != null) {
            sumOnHoldMRG = (Decimal) sumOnHoldMRG_obj;
        }
        
        metric.On_Hold_MRG__c = sumOnHoldMRG;
             
        Date dateToQueryLastYear = dateToQuery.AddYears(-1);
        Date dateToQueryTwoYearsAgo = dateToQuery.AddYears(-2);
        
        // New donors
        AggregateResult[] newDonors = new ContactSelector().SelectDonorsInPastYear(dateToQueryLastYear, dateToQuery);
        
        Object newDonors_obj = newDonors[0].get('donorCount');
        Integer newDonorsCount = 0;
        
        if (newDonors_obj != null) {
            newDonorsCount = (Integer) newDonors_obj;
        }
        
        metric.of_New_Donors__c = newDonorsCount;
        
        // Retained donors
        AggregateResult[] retainedDonors = new ContactSelector().SelectRetainedDonors(dateToQueryTwoYearsAgo, dateToQueryLastYear, dateToQuery);
        
        Object retainedDonors_obj = retainedDonors[0].get('donorCount');
        Integer retainedDonorsCount = 0;
        
        if (newDonors_obj != null) {
            retainedDonorsCount = (Integer) retainedDonors_obj;
        }
        
        metric.of_Retained_Donors__c = retainedDonorsCount;
        
        // Income / Active Donor
        Decimal activeDonors = newDonorsCount + retainedDonorsCount;
        AggregateResult[] incomeActiveDonors_ar = new PaymentSelector().SelectActiveDonorsByPayment(dateToQueryLastYear, dateToQuery);
        
        Object incomeActiveDonors_obj = incomeActiveDonors_ar[0].get('sum');
        Decimal incomeActiveDonors = 0;
        if (incomeActiveDonors_obj != null)
        { 
            if (activeDonors > 0) {
                incomeActiveDonors = (Decimal) incomeActiveDonors_obj;
                incomeActiveDonors /= activeDonors; 
            }
        }            
        
        metric.Income_Active_Donor__c = incomeActiveDonors;
        
        Boolean deleteMetric = metric.MRG__c == 0.00;
        
        // if the metric has a MRG of 0.00 then we don't want to insert update it
        if (deleteMetric) {
        	
    		// if there is an existing metric object then its a historical run
    		// so we need to delete the template object
        	if (existingMetrics != null && existingMetrics.size() > 0) {
                DMLManager.DeleteSObject(metric);
        	}
        	
        	// its a daily run metric so dont insert it 
        } else {
            DMLManager.UpsertSObject(metric);
        }
    }
}