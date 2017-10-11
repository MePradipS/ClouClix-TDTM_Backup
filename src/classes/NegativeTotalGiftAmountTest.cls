/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class NegativeTotalGiftAmountTest {

    static testMethod void testForNegativeTotalGiftAmountTest() {
        // TO DO: implement unit test
    	contact testContact = InitializeContact();
    	insert testContact;
        
    	gift__c testGift = InitializeGift();
    	testGift.Constituent__c = testContact.Id;
    	testGift.Sponsorship_Amount__c = 210;
    	insert testGift;
        
    	payment__c testPayment = InitializePayment();
    	testPayment.Donation__c = testGift.Id;
    	insert testPayment;
        
    	gift__c testGiftResult = [SELECT Id, Total_Gift_Amount__c FROM Gift__c WHERE Id = :testGift.Id];
    	
    	System.assertEquals(0, testGiftResult.Total_Gift_Amount__c, ' Total_Gift_Amount isnt equal to expected!');
    }
    
    private static Contact InitializeContact() {
        Contact individual = new Contact(
            firstName = 'QA',
            lastName = 'Tester',
            MailingStreet = '355 Apple Creek Blvd.',
            MailingCity = 'Markham',
            MailingState = 'Ontario', 
            MailingPostalCode = 'L3R 9X7',
            MailingCountry = 'Canada'
            );

        return individual;
    }
    
    private static Gift__c InitializeGift(){
        Gift__c g= new Gift__c();
        g.Status__c = 'Active';
        g.Gift_Type__c = 'One Time Gift';
        return g;
    }
    
    public static Payment__c InitializePayment(){
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 200;
        p1.Status__c = 'Approved';
        return p1;
    }
}