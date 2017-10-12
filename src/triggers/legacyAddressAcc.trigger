trigger legacyAddressAcc on Account (after update) {
    // -------------------------------------------------------------------------------------------
    // This trigger code has been commented to reduce the probability of getting the Percent of Apex
    // Used limit. 
    // -------------------------------------------------------------------------------------------
    //    Date                Author                 Description
    // -------------------------------------------------------------------------------------------
    // 11-Oct-2017        Pradip Shukla          Initial Version
    // --------------------------------------------------------------------------------------------
    /*List<Historical_Address__c> theAdds = new List<Historical_Address__c>();
    Historical_Address__c oldAdd;
    List<Account> cOld = Trigger.old;
    List<Account> cNew = Trigger.new;    
    //Scott April-25-11: go through all the contact pairs
    for (Integer i = 0; i < Trigger.old.size(); i++)
    {
        //Scott April-25-11: all the address fields are identical, don't need to make any historical addies
        if (cOld[i].BillingStreet == cNew[i].BillingStreet && 
            cOld[i].BillingCity == cNew[i].BillingCity && 
            cOld[i].BillingPostalCode == cNew[i].BillingPostalCode && 
            cOld[i].BillingState == cNew[i].BillingState && 
            cOld[i].BillingCountry == cNew[i].BillingCountry && 
            cOld[i].ShippingStreet == cNew[i].ShippingStreet && 
            cOld[i].ShippingCity == cNew[i].ShippingCity && 
            cOld[i].ShippingPostalCode == cNew[i].ShippingPostalCode && 
            cOld[i].ShippingState == cNew[i].ShippingState && 
            cOld[i].ShippingCountry == cNew[i].ShippingCountry)
        {
            continue;    
        }
        //Scott April-25-11: there is a change to the Primary addie, lets archive the old one
        if (cOld[i].BillingStreet != cNew[i].BillingStreet ||
            cOld[i].BillingCity != cNew[i].BillingCity || 
            cOld[i].BillingPostalCode != cNew[i].BillingPostalCode || 
            cOld[i].BillingState != cNew[i].BillingState || 
            cOld[i].BillingCountry != cNew[i].BillingCountry)
        {
            if (cOld[i].BillingStreet != null || cOld[i].BillingStreet != '' ||
                cOld[i].BillingCity != null || cOld[i].BillingCity != '' ||
                cOld[i].BillingCountry != null || cOld[i].BillingCountry != '' ||
                cOld[i].BillingPostalCode != null || cOld[i].BillingPostalCode != '' ||
                cOld[i].BillingState != null || cOld[i].BillingState != '')
            { 
                oldAdd = new Historical_Address__c();
                if (cOld[i].BillingStreet != null)
                {
                    if (cOld[i].BillingStreet.length() < 60)
                    { oldAdd.Address_1__c = cOld[i].BillingStreet; }
                    if (cOld[i].BillingStreet.length() >= 60)
                    { oldAdd.Address_1__c = cOld[i].BillingStreet.substring(0, 59); }     
                }           
                oldAdd.City__c = cOld[i].BillingCity;
                oldAdd.Country__c = cOld[i].BillingCountry;
                oldAdd.Postal_Code__c = cOld[i].BillingPostalCode;
                oldAdd.Province__c = cOld[i].BillingState;            
                oldAdd.Date_To__c = Date.today();
                oldAdd.Address_Type__c = 'Billing';
                //Scott April-25-11: attach the Historical_Address__c to the org
                oldAdd.Organization__c = cOld[i].Id;
                
                //Scott April-25-11: Don't want to insert blank historical addies
                theAdds.add(oldAdd); 
            }                
        }
        
        //Scott April-25-11: there was a change to the secondary addie, lets archive the old one
        if (cOld[i].ShippingStreet != cNew[i].ShippingStreet || 
            cOld[i].ShippingCity != cNew[i].ShippingCity || 
            cOld[i].ShippingPostalCode != cNew[i].ShippingPostalCode || 
            cOld[i].ShippingState != cNew[i].ShippingState || 
            cOld[i].ShippingCountry != cNew[i].ShippingCountry)
        {
            if (cOld[i].ShippingStreet != null ||
                cOld[i].ShippingCity != null ||
                cOld[i].ShippingCountry != null ||
                cOld[i].ShippingPostalCode != null ||
                cOld[i].ShippingState != null)
            { 
                oldAdd = new Historical_Address__c();  
                if (cOld[i].ShippingStreet != null)
                {         
                    if (cOld[i].ShippingStreet.length() < 60)
                    { oldAdd.Address_1__c = cOld[i].ShippingStreet; }
                    if (cOld[i].ShippingStreet.length() >= 60)
                    { oldAdd.Address_1__c = cOld[i].ShippingStreet.substring(0, 59); }                
                }
                oldAdd.City__c = cOld[i].ShippingCity;
                oldAdd.Country__c = cOld[i].ShippingCountry;
                oldAdd.Postal_Code__c = cOld[i].ShippingPostalCode;
                oldAdd.Province__c = cOld[i].ShippingState;            
                oldAdd.Date_To__c = Date.today();    
                oldAdd.Address_Type__c = 'Shipping';
                //Scott April-25-11: Attach the Historical_Address__c to the org
                oldAdd.Organization__c = cOld[i].Id;
    
                //Scott April-25-11: Don't want to insert blank historical addies
                theAdds.add(oldAdd); 
            }        
        }                                
    }*/
}