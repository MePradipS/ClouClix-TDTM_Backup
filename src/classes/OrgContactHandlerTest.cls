@isTest
public class OrgContactHandlerTest{
    
    public static testMethod void OrgContactHandlerTest(){
        String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> rtypes = database.query(rtypesQuery);
        Account a1 = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a1;

        if (rtypes.size() > 0)
        {
            BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas', BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id, BucketAccountId__c = a1.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd', LockBucketAccount__c = true);        
            insert cs2;
        }
        
        Account a = new Account();
        a.name = 'Test-1234';
        a.BillingStreet = 'abc';
        a.BillingCity = 'abc';
        a.BillingPostalCode = '12345';
        a.BillingState = 'abc';
        a.BillingCountry = 'abc';
        insert a;
        
        a.Active__c = 'yes';
        update a;
        
        a.BillingStreet = 'abc';
        a.BillingCity = 'abc';
        a.BillingPostalCode = '12345';
        a.BillingState = 'ghi';
        a.BillingCountry = 'abc';
        a.ShippingStreet = 'abc';
        a.ShippingCity = 'abc';
        a.ShippingPostalCode = '12345';
        a.ShippingState = 'abc';
        a.ShippingCountry = 'abc';
        update a;
        
        a.ShippingStreet = 'abc';
        a.ShippingCity = 'abc';
        a.ShippingPostalCode = 'KA 01';
        a.ShippingState = 'abc';
        a.ShippingCountry = 'abc';
        update a;
        
        delete a;
        
        Contact c = new Contact();
        c.LastName = 'Test12345';
        c.MailingStreet = 'abc';
        c.MailingCity = 'abc';
        c.MailingPostalCode = '12345';
        c.MailingState = 'abc';
        c.MailingCountry = 'abc';
        insert c;
        
        c.MailingStreet = 'abc';
        c.MailingCity = 'ghi';
        c.MailingPostalCode = '12345';
        c.MailingState = 'abc';
        c.MailingCountry = 'abc';
        c.OtherStreet = 'abc';
        c.OtherCity = 'abc';
        c.OtherPostalCode = 'abc';
        c.OtherState = 'abc';
        c.OtherCountry = 'abc';
        update c;
        
        c.OtherStreet = 'abc';
        c.OtherCity = 'abc';
        c.OtherPostalCode = '12345';
        c.OtherState = 'abc';
        c.OtherCountry = 'abc';
        update c;
    } 

    public static testMethod void checkDuplicateAccountTest() {
        OrgContactHandler.checkDuplicate(new List<sObject>(), new Set<string>(), new Set<Id>(), 'Account');
    }

    public static testMethod void checkDuplicateContactTest() {
        OrgContactHandler.checkDuplicate(new List<sObject>(), new Set<string>(), new Set<Id>(), 'Contact');
    }

    public static testMethod void legacyAddressAccountTest() {
        OrgContactHandler.LegacyAddress(new List<sObject>(), new List<sObject>(), 'Account');
    }

    public static testMethod void legacyAddressContactTest() {
        OrgContactHandler.LegacyAddress(new List<sObject>(), new List<sObject>(), 'Contact');
    }

    public static testMethod void UpdateHouseholdRollupsTest() {

        Account houseHold = new Account(Name = 'Old House');
        insert houseHold;

        List<Contact> oldContacts = new List<Contact>();
        Contact oldContact = new Contact(LastName = 'old', Email = 'test@causeview.com', Household__c = houseHold.Id);
        insert oldContact;
        oldContacts.add(oldContact);

        Account newHouseHold = new Account(Name = 'New House');
        insert newHouseHold;

        List<Contact> newContacts = new List<Contact>();
        Contact newContact = new Contact(LastName = 'new', Email = 'test@causeview.com', Household__c = newHouseHold.Id);
        insert newContact;
        newContacts.add(newContact);

        OrgContactHandler.UpdateHouseholdRollups(oldContacts, newContacts);
    }
}