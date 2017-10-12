@isTest(seeAllData=true) 
public class GiftAidControllerTest {
    public static testMethod void testGiftAidController() {
        GiftAidController ga = new GiftAidController();
        
        Boolean isGiftAid = ga.IsGiftAidEnabled;        
        
        contact newContact = new contact( LastName = 'test' );
        insert newContact;

        gift__c newTransaction = new gift__c( Constituent__c = newContact.Id );
        insert newTransaction;

        payment__c newPayment = new payment__c( 
            Donation__c = newTransaction.Id,
            Gift_Aid_Claim_Status__c = 'not claimed'
        );
        insert newPayment;

        List<Payment__c> qNotClaimed  = [SELECT id FROM Payment__c WHERE Gift_Aid_Claim_Status__c = 'Not claimed' LIMIT 100];
        String ids = '[';
        for(Payment__c p: qNotClaimed){
            ids += String.valueOf(p.id) + ',';
        }
        ids = ids.removeEnd(',');
        ids += ']';

        System.assertNotEquals(null,GiftAidController.UpdateNotClaimed(ids));
        System.assertNotEquals(null,GiftAidController.UpdateClaimed(ids, 'received'));
        System.assertNotEquals(null,GiftAidController.UpdateClaimed(ids, 'rejected'));
        System.assertNotEquals(null,GiftAidController.UpdateClaimed(ids, 'to be refunded'));
        System.assertNotEquals(null,GiftAidController.UpdateClaimed(ids, 'refunded'));
    }
}