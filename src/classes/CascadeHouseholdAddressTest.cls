@isTest
public with sharing class CascadeHouseholdAddressTest {

    public static testMethod void UpdateAddressChange() {
    
        RecordType r = [Select Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Household'][0];

        Account a = new Account(Name = 'Individual', BillingStreet = '123 fake st', RecordTypeId = r.Id);
        insert a;

        Contact c = new Contact(
            FirstName = 'Billy', 
            LastName= 'Bob', 
            Email='billy@causeview.com', 
            Account = a, 
            Same_as_Household__c = true,
            Household_Primary_Contact__c = true,
            Household__c = a.Id);
        insert c;
        update a;

        Account newAccount = new Account(Name = 'Individual', BillingStreet = '355 Apple Creek', RecordTypeId = r.Id);
        insert newAccount;

        c.Household__c = newAccount.Id;
        update c;

        CascaseHouseholdAddressHandler.Execute(new List<Account> { a }, new List<Account> { newAccount }, 1);

        c = [Select MailingStreet FROM Contact WHERE Id =: c.Id];

        system.assertEquals(newAccount.BillingStreet, c.MailingStreet);
    }
}