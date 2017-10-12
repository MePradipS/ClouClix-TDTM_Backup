@isTest
class testHistAdd {
     static testMethod void testTrigger() {
     Contact c = new Contact(MailingStreet = '123 Test Dr', 
                             MailingState = 'Ontario', 
                             MailingCountry = 'Canada', 
                             MailingCity = 'Testerville', 
                             MailingPostalCode = 'K9H 7J8',
                             //npe01__Primary_Address_Type__c = 'Home',
                             OtherStreet = '123 Other Test Dr', 
                             OtherState = 'Other Ontario', 
                             OtherCountry = 'Other Canada', 
                             OtherCity = 'Other Testerville', 
                             OtherPostalCode = 'Other K9H 7J8',
                             //npe01__Secondary_Address_Type__c = 'Work',
                                                          
                             LastName = 'Sagat',
                             FirstName = 'Bob');

     Contact c2 = new Contact(LastName = 'Sagat',
                              FirstName = 'Bob'); 
                                                          
     insert c2;         
     c2.MailingStreet = '456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr456 Test Dr';
     update c2;    
                     
     insert c;
     c.MailingStreet = '456 Test Dr';
     update c;
     c.OtherStreet = '456 Test Dr';
     update c;
     c.Description = 'No Change to Address';
     update c;

     c.OtherStreet = '222 Test Dr';
     c.MailingStreet = '223 Test Dr';
     update c;




     Account a = new Account(BillingStreet = '123 Test Dr', 
                             BillingState = 'Ontario', 
                             BillingCountry = 'Canada', 
                             BillingCity = 'Testerville', 
                             BillingPostalCode = 'K9H 7J8',
                             ShippingStreet = '123 Shipping Test Dr', 
                             ShippingState = 'Shipping Ontario', 
                             ShippingCountry = 'Shipping Canada', 
                             ShippingCity = 'Shipping Testerville', 
                             ShippingPostalCode = 'Ship K9H 7J8',
                                                          
                             Name = 'Price is Right');

     Account a2 = new Account(Name = 'Price is Right');

     insert a2;
     a2.BillingStreet = '456 Test Dr';
     update a2;
     
     insert a;
     a.BillingStreet = '456 Test Dr';
     update a;
     a.ShippingStreet = '456 Test Dr';
     update a;
     a.Description = 'No Change to Address';
     update a;       
     
     a.BillingStreet = '222 Test Dr';
     a.ShippingStreet = '223 Test Dr';
     update a;                          
     }
}