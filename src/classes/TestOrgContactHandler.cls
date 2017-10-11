@isTest
public with sharing class TestOrgContactHandler{
  
static testMethod void testorg()
 {
    
    Account aOld = new Account();
     aOld.Name = 'test1';
     aOld.BillingStreet = 'asa';
     aOld.BillingCity = 'canada';
     aOld.BillingPostalCode = '456456';
     aOld.BillingState = 'CA';
     aOld.BillingCountry = 'US';
     aOld.Phone = '7564864';
     aOld.Household_Addressee__c = 'sdfsd'; 
     aOld.Household_Salutation__c = '';
     insert aOld;
     
     
      Account aNew = new Account();
     aNew.Name = 'test2';
     aNew.BillingStreet = 'dddddd';
     aNew.BillingCity = 'cana';
     aNew.BillingPostalCode = '456546';
     aNew.BillingState = 'CA';
     aNew.BillingCountry = 'US';
     aNew.Phone = '7564864';
     aNew.Household_Addressee__c = 'asfasas'; 
     aNew.Household_Salutation__c = '';
     insert aNew;
     
      List<Account> cOld = new List<Account>();
      cOld.add(aOld);
      
      List<Account> cNew = new List<Account>();
      cNew.add(aNew);
      
      Account aNew1 = new Account();
     aNew1.Name = 'test3';
     aNew1.BillingStreet = 'dddddd';
     aNew1.BillingCity = 'cana';
     aNew1.BillingPostalCode = '459456';
     aNew1.BillingState = 'CA';
     aNew1.BillingCountry = 'US';
     aNew1.Phone = '7564864';
     aNew1.Household_Addressee__c = 'asfasas'; 
     aNew1.Household_Salutation__c = '';
     insert aNew1;

      String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
      List<RecordType> rtypes = database.query(rtypesQuery);        
      if (rtypes.size() > 0)
      {
        BatchSettings__c settingList= new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id, BucketAccountId__c = aNew1.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert settingList;
             
        cNew.clear(); 
        aNew.Id = settingList.BucketAccountId__c;
        cNew.add(aNew);
        OrgContactHandler.PreventBucketDelete(cNew);  
        OrgContactHandler.PreventBucketModify(cOld,cNew);
          
        aNums__c a = new aNums__c(Name = 'Default', ContactCount__c = 1, ContactLength__c = 8, ContactPrefix__c = 'CON-', OrgCount__c = 1, OrgLength__c = 8,  OrgPrefix__c = 'ORG-');
        insert a;
        boolean reValue = OrgContactHandler.IsAssigned('accout', 'Account', a.Id);
          
        String val = OrgContactHandler.GetNext('Account', a);
      }
  }
}