@isTest
public with sharing class TestRegistrationWrapper {

    public static testMethod void testRegistrationWrapper(){
        RegistrationWrapper wrapper = new RegistrationWrapper();
        
        String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> rtypes = database.query(rtypesQuery);        

        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;

        if (rtypes.size() > 0)
        {
            BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id, BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
            insert cs2;
        }
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Sanders';
        insert c;
        c = [SELECT Id FROM Contact LIMIT 1];
        
        wrapper.con = [SELECT Id FROM Contact LIMIT 1];
        
        Campaign campaign = new Campaign();
        campaign.Name = 'Test Campaign';
        insert campaign;
        campaign = [SELECT Id FROM Campaign LIMIT 1];
        
        Event_Registration__c evntReg = new Event_Registration__c();
        evntReg.Individual__c = c.Id;
        evntReg.Event__c = campaign.Id;
        evntReg.Registration_Date__c = Date.today();
        insert evntReg;
        evntReg = [SELECT Id FROM Event_Registration__c LIMIT 1];
        wrapper.reg = evntReg; 
        
    }
}