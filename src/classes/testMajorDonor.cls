@isTest
class testMajorDonor {

    private static String namespacePrefix = Utilities.getCurrentNamespace();
    private static String Namespace = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');    private static String NamespaceGift = Namespace + 'Gift__c';
    private static String NamespacePayment = Namespace + 'Payment__c';

     static testMethod void testTrigger() {
         Contact aContact = new Contact(LastName = 'Test');     
         insert aContact;
         
         List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType=:NamespaceGift and isActive=true and Name = 'Gift'];

         Gift__c aGift = new Gift__c(Status__c = 'Entered', RecordTypeID = rtypes[0].Id, Constituent__c = aContact.Id, Gift_Date__c = Date.Today());
         insert aGift;
         
         List<RecordType> rtypes2 = [Select Name, Id From RecordType where sObjectType=:NamespacePayment and isActive=true and Name = 'Credit Card'];
         Payment__c aPayment = new Payment__c(Payment_Type__c = 'Credit Card', RecordTypeID = rtypes2[0].Id, Status__c = 'Approved', Amount__c = 10000, Donation__c = aGift.Id);   
         insert aPayment; 
         
         aPayment.Date_Deposited__c = date.today();
         update aPayment;
         
         aGift.Constituent__c = null;
         Account anAcc = new Account(Name = 'Test');
         insert anAcc;
         
         aGift.Organization__c = anAcc.Id;
         update aGift;
         
         List<RecordType> rtypes3 = [Select Name, Id From RecordType where sObjectType=:NamespaceGift and isActive=true and Name = 'Grant'];
         aGift.RecordTypeID = rtypes3[0].Id;
         update aGift;      
     }
     
     //test clone transaction trigger
     static testMethod void testCloneTransactionTrigger()
     {
         Contact aContact = new Contact(LastName = 'Test');    
         insert aContact;
         
         List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType=:NamespaceGift and isActive=true and Name = 'Gift'];

         Gift__c aGift = new Gift__c(Status__c = 'Entered', RecordTypeID = rtypes[0].Id, Constituent__c = aContact.Id, Gift_Date__c = Date.Today());
         insert aGift;
         
         List<RecordType> rtypes2 = [Select Name, Id From RecordType where sObjectType=:NamespacePayment and isActive=true and Name = 'Credit Card'];
         Payment__c aPayment = new Payment__c(Payment_Type__c = 'Credit Card', RecordTypeID = rtypes2[0].Id, Status__c = 'Approved', Amount__c = 10000, Donation__c = aGift.Id);   
         insert aPayment; 
         
         Gift_Detail__c gd1 = new Gift_Detail__c(Payment__c = aPayment.Id, Gift__c = aGift.Id, Allocation_Date__c = Date.Today()-5, Amount__c = 10000);
         insert gd1;
         
         Gift__c bGift = new Gift__c(Status__c = 'Entered', Sys_Clone_Transaction__c=aGift.Id, RecordTypeID = rtypes[0].Id, Constituent__c = aContact.Id, Gift_Date__c = Date.Today());
         insert bGift;
         
         Payment__c bPayment = new Payment__c(Payment_Type__c = 'Credit Card', RecordTypeID = rtypes2[0].Id, Status__c = 'Approved', Amount__c = 5000, Donation__c = bGift.Id);   
         insert bPayment; 
        
     }
}