public with sharing class CascaseHouseholdAddressHandler {
    public static void Execute(List<Account> cOld, List<Account> cNew, Integer oldSize) {
        //only update if household recordtype and if Address, Phone, Salutation or Addressee has changed
        List<RecordType> rtypes = new RecordTypeSelector().SelectByAccountSObjectAndIsActive('Account', True);
        Map<String,String> accountRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
        { accountRecordTypes.put(rt.Name,rt.Id); }

        Set<Id> AIDs = new Set<Id>();
        for (Integer i = 0; i < oldSize; i++)
        {
            if (cOld[i].BillingStreet == cNew[i].BillingStreet &&
                cOld[i].BillingCity == cNew[i].BillingCity &&
                cOld[i].BillingPostalCode == cNew[i].BillingPostalCode &&
                cOld[i].BillingState == cNew[i].BillingState &&
                cOld[i].BillingCountry == cNew[i].BillingCountry &&
                cOld[i].Phone == cNew[i].Phone &&
                cOld[i].Household_Addressee__c == cNew[i].Household_Addressee__c &&
                cOld[i].Household_Salutation__c == cNew[i].Household_Salutation__c)
                { continue; }
            AIDS.add(cNew[i].Id);
        }
        List<Contact> ContactSet = new List<Contact>();

        String fields = 'Id,BillingStreet,BillingState,BillingCountry,BillingPostalCode,BillingCity,Phone,'+ Utilities.PackageNamespace + 'Household_Addressee__c,'+ Utilities.PackageNamespace + 'Household_Salutation__c';
        String inFields = Converter.ConvertListSetToString(AIDS);
        String subFields = 'Id,'+ Utilities.PackageNamespace + 'Use_Household_Salutation_Addressee__c,'+ Utilities.PackageNamespace + 'Same_as_Household__c,'+ Utilities.PackageNamespace + 'Primary_Addressee__c,'+ Utilities.PackageNamespace + 'Primary_Salutation__c,HomePhone,MailingStreet,MailingState,MailingCountry,MailingPostalCode,MailingCity';
        String clause = ' WHERE Id IN ('+ inFields +') AND RecordTypeId = \'' + accountRecordTypes.get('Household') + '\'';

        List<Account> theAccounts = new GenericQueryBuilder().QueryBuilderWithSubQuery(Account.sObjectType, fields, clause, Contact.sObjectType, 'HouseholdContacts__r', subFields, '');

        for(Account a : theAccounts)
        {
            for (Contact c : a.HouseholdContacts__r)
            {
                if (c.Use_Household_Salutation_Addressee__c == True)
                {
                    c.Primary_Addressee__c = a.Household_Addressee__c;
                    c.Primary_Salutation__c = a.Household_Salutation__c;
                }
                if (c.Same_as_Household__c == True)
                {
                    c.HomePhone = a.Phone;
                    c.MailingStreet = a.BillingStreet;
                    c.MailingState = a.BillingState;
                    c.MailingCountry = a.BillingCountry;
                    c.MailingPostalCode = a.BillingPostalCode;
                    c.MailingCity = a.BillingCity;
                }
                ContactSet.add(c);
            }
        }
        if (ContactSet.size() > 0) {
            DMLManager.UpdateSObjects(ContactSet);
        }
    }
}