@isTest
public class TransactionBatchPresetsControllerTest {
	static testMethod void testMe() {

        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;

        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();

        cnt.wrapper.presets.giftSubject.readOnly = true;
        cnt.wrapper.noteSubject = '';
        cnt.save();

        cnt.wrapper.noteSubject = 'jkjkjl';

        cnt.wrapper.presets.receiptType.readOnly = true;
        cnt.wrapper.gift.Receipt_Type__c = '';
        cnt.save();

        cnt.wrapper.gift.Receipt_Type__c = 'xvxczvz';

        cnt.wrapper.presets.paymentType.readOnly = true;
        cnt.wrapper.payment.Payment_Type__c = '';
        cnt.save();

        cnt.wrapper.gift.Receipt_Type__c = 'On time only';
        cnt.wrapper.payment.Payment_Type__c = 'Credit Card';
        cnt.save();

        cnt.clear();
    }

    static testMethod void getConstituentRegionTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getConstituentRegion();
    }

    static testMethod void getConstituentTraidStatusTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getConstituentTraidStatus();
    }

    static testMethod void getAccountRegionTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getAccountRegion();
    }

    static testMethod void getAccountTypeTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getAccountType();
    }

    static testMethod void getAccountTraidStatusTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getAccountTraidStatus();
    }

    static testMethod void getReccuringDonationTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getReccuringDonation();
    }

    static testMethod void getGiftChannalTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getGiftChannal();
    }

    static testMethod void getGiftTypeTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getGiftType();
    }

    static testMethod void getGiftReciptTypeTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getGiftReciptType();
    }

    static testMethod void getPaymentTypeTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getPaymentType();
    }

    static testMethod void getCreditCardTypeTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getCreditCardType();
    }

    static testMethod void getConstituentCodes() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getConstituentCodes();
    }

    static testMethod void getSolicitCodesTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getSolicitCodes();
    }

    static testMethod void getAccConstituCodesTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getAccConstituCodes();
    }

    static testMethod void getAccSolicitCodesTest() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        PageReference pageRef = Page.TransactionBatchPresets;
        Test.setCurrentPage(pageRef);
        TransactionBatchPresetsController cnt = new TransactionBatchPresetsController();
        cnt.getAccSolicitCodes();
    }
}