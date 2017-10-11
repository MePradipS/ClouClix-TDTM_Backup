@isTest
global with sharing class ChargeATokenExtensionTest {
	
	private static final String IATS_AUTHORIZAION = '678594';
	private static final String IATS_REFERENCE_NUMBER = 'A928E212';
	private static final String IATS_RECOVERED_REFERENCE_NUMBER = 'A928E213';
	private static final String IATS_CUSTOMER_CODE = 'A226854';
	private static final String NON_IATS_CUSTOMER_CODE = '118581660';
	
	public static testMethod void testIsReferenceNumberIatsValid() {
        
        Contact individual = InitializeContact();
        Recurring_Donation__c validReferenceNumberRecord = InitializeCreditCard(individual);
        
        ApexPages.currentPage().getParameters().put('id', validReferenceNumberRecord.Id);
        
        ChargeATokenExtension controller = new ChargeATokenExtension();
        Boolean expected = true;
        Boolean actual = controller.IsReferenceNumberIats;

        System.assertEquals(expected, actual, 'Reference number was flagged as not being iATS');
    }
	
	public static testMethod void testIsReferenceNumberNonIats() {
        
        Contact individual = InitializeContact();
        Recurring_Donation__c nonIatsRecord = InitializeCreditCardNonIats(individual);
        ApexPages.currentPage().getParameters().put('id', nonIatsRecord.Id);
        
        ChargeATokenExtension controller = new ChargeATokenExtension();
        Boolean expected = false;
        Boolean actual = controller.IsReferenceNumberIats;

        System.assertEquals(expected, actual, 'Reference number not was flagged as not being iATS');
    }
	
	public static testMethod void testNoIdInUrl() {
        ChargeATokenExtension controller = new ChargeATokenExtension();
        String nextPage = controller.ChargePayments().getUrl();

        System.assertEquals('/null', nextPage);
    }
    
    public static testMethod void testRedirectInvalid() {
        ChargeATokenExtension controller = new ChargeATokenExtension();
        String actualRedirect = controller.redirect().getUrl();

        System.assertEquals('/null', actualRedirect, 'Redirect url was not correct');
    }
    
    public static testMethod void testRedirectValid() {
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);

        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);

        ChargeATokenExtension controller = new ChargeATokenExtension();
        PageReference actualRedirect = controller.redirect();

        System.assertEquals(null, actualRedirect, 'Redirect url was not correct');
    }
    
    public static testMethod void testBackValid() {
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);

        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);

        ChargeATokenExtension controller = new ChargeATokenExtension();
        String expectedBack = new PageReference('/' + ccRecord.Id).getUrl();
        String actualBack = controller.Back().getUrl();

        System.assertEquals(expectedBack, actualBack, 'Back URL\'s where not the same.');
    }
    
    public static testMethod void testBackInvalid() {

        ChargeATokenExtension controller = new ChargeATokenExtension();
        String expectedBack = new PageReference('/null').getUrl();
        String actualBack = controller.Back().getUrl();

        System.assertEquals(expectedBack, actualBack, 'Back URL\'s where not the same.');
    }
    
    public static testMethod void testInitializeGatewayTimeout() {

        ChargeATokenExtension controller = new ChargeATokenExtension();
        Integer expectedTimeout = 120000;
		Integer actualTimeout = controller.InitializeGateway().timeout_x;
		
        System.assertEquals(expectedTimeout, actualTimeout, 'Timeout was not the same.');
    }
    
    public static testMethod void testOfflineRecurringGift() {
        Contact individual = InitializeContact();
        Recurring_Donation__c offlineRecord = InitializeOffline(individual); 

        ApexPages.currentPage().getParameters().put('id', offlineRecord.Id);   

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();         
        String actualRedirect = controller.redirect().getUrl();
        String expectedRedirect = '/' + offlineRecord.Id + '/e?nooverride=1&retURL=' + offlineRecord.Id;

        System.assertEquals(expectedRedirect, actualRedirect, 'Offline redirect urls were not the same.');
    }
    
    public static testMethod void testNoTransaction() {
    	
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);

        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);

        ChargeATokenExtension controller = new ChargeATokenExtension();
        
        List<String> expected = new List<String>();
        expected.add('There was no active transaction on the recurring gift.');
	
		List<String> actual = controller.Errors;
	
        System.assertEquals(expected, actual, 'No transaction error message was not the same.');
    }
    
    public static testMethod void testNoDeclinedPayments() {
    	
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
		Gift__c activeTransaction = InitializeActiveTransaction(ccRecord, individual);

        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
        ChargeATokenExtension controller = new ChargeATokenExtension();
        
        Boolean expectedAreDeclinedPayments = false;
        Boolean actualAreDeclinedPayments = controller.AreThereDeclinedPayments;
        
        System.assertEquals(expectedAreDeclinedPayments, actualAreDeclinedPayments, 'AreDeclinedPayments flag was not the same.');
        
        List<Payment__c> expectedDeclinedPayments = new List<Payment__c>();
        List<Payment__c> actualDeclinedPayments = controller.DeclinedPayments;
        
        System.assertEquals(expectedDeclinedPayments, actualDeclinedPayments, 'DeclinedPayments list was not the same.');
    }
    
    public static testMethod void testOneDeclinedPayment() {
        ConfigureCauseview();
    	
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        Gift__c activeTransaction = InitializeActiveTransaction(ccRecord, individual);
		Payment__c declinedPayment = InitializeDeclinedPayment(activeTransaction);

        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
        ChargeATokenExtension controller = new ChargeATokenExtension();
        
        Boolean expectedAreDeclinedPayments = true;
        Boolean actualAreDeclinedPayments = controller.AreThereDeclinedPayments;
        
        System.assertEquals(expectedAreDeclinedPayments, actualAreDeclinedPayments, 'AreDeclinedPayments flag was not the same.');
        
        List<Payment__c> expectedDeclinedPayments = new List<Payment__c>();
        expectedDeclinedPayments.add(declinedPayment);
        List<Payment__c> actualDeclinedPayments = controller.DeclinedPayments;
        
        System.assertEquals(expectedDeclinedPayments, actualDeclinedPayments, 'DeclinedPayments list was not the same.');
    }
    
    public static testMethod void testDeclinedPaymentWithRecoveredPayment() {
        ConfigureCauseview();
    	
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        Gift__c activeTransaction = InitializeActiveTransaction(ccRecord, individual);
		Payment__c declinedPayment = InitializeDeclinedPayment(activeTransaction);
		Payment__c recoveredPayment = InitializeRecoveredPayment(activeTransaction, declinedPayment);

        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
        ChargeATokenExtension controller = new ChargeATokenExtension();       
        
        List<Payment__c> expectedDeclinedPayments = new List<Payment__c>();
        List<Payment__c> actualDeclinedPayments = controller.DeclinedPayments;
        
        System.assertEquals(expectedDeclinedPayments, actualDeclinedPayments, 'DeclinedPayments list was not the same.');
    }
    
    public static testMethod void testChargePaymentsCreditCard() {
    	ConfigureCauseview();

    	Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        Gift__c activeTransaction = InitializeActiveTransaction(ccRecord, individual);
		Payment__c declinedPayment = InitializeDeclinedPayment(activeTransaction);
		
		ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
        ChargeATokenExtension controller = new ChargeATokenExtension();
    	
    	controller.PaymentsToCharge = declinedPayment.Id;
    	PageReference actual = controller.ChargePayments();
    	PageReference expected = null;
    	
    	System.assertEquals(expected, actual, 'Charge Payments Urls were not the same.');
    }
    
    public static testMethod void testInsertPaymentsSuccessResponse() {
        ConfigureCauseview();
    	
    	Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        Gift__c activeTransaction = InitializeActiveTransaction(ccRecord, individual);
		Payment__c declinedPayment = InitializeDeclinedPayment(activeTransaction);
		
        PageReference pageRef = Page.Charge_a_Token;
        Test.startTest();
            Test.setCurrentPage(pageRef);

    		ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
            ChargeATokenExtension controller = new ChargeATokenExtension();
        	
        	List<String> paymentIdsToCharge = new List<String>();
        	paymentIdsToCharge.add(declinedPayment.Id);

        	BatchGateway4.ArrayOfChargeRequest requests = controller.CreateChargeRequests(paymentIdsToCharge);
        	BatchGateway4.ArrayOfTransactionResult results = InitializeTransactionResults(requests);   	
        	
        	List<Payment__c> actual = controller.InsertPayments(requests.ChargeRequest, results.TransactionResult);
    	
        Test.stopTest();    

    	for (Payment__c payment : actual) {
    		
    		System.assertEquals(IATS_RECOVERED_REFERENCE_NUMBER, payment.CC_Reference__c, 'Reference numbers were not the same');
    		System.assertEquals(IATS_RECOVERED_REFERENCE_NUMBER, payment.External_Payment_ID__c, 'External payment Id\'s were not the same');
    		System.assertEquals(activeTransaction.Id, payment.Donation__c, 'Gift id was not the same');
    		System.assertEquals(1.00, payment.Amount__c, 'Amount was not the same');
    		System.assertEquals('Approved', payment.Status__c, 'Status was not the same');
    		System.assertEquals(activeTransaction.Recurring_Donation__r.Type__c, payment.Payment_Type__c, 'Payment Type was not the same');
    		System.assertEquals(date.today(), payment.Date__c, 'Date was not the same');
    		System.assertEquals(date.today(), payment.CC_Transaction_Date__c, 'CC Transaction Date was not the same');
    		System.assertEquals(declinedPayment.Id, payment.Recovered_Payment__c, 'Recovered Payment Id was not the same');
    		System.assertEquals(GenerateInvoiceNumber(), payment.CC_Invoice_Number__c, 'Invoice Number was not the same');
    		System.assertEquals(IATS_AUTHORIZAION, payment.Authorization__c, 'Invoice Number was not the same');
    	}
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

        insert individual;

        individual = [SELECT Id FROM Contact WHERE MailingCountry = 'Canada' LIMIT 1];

        return individual;
    }
    
    private static Recurring_Donation__c InitializeCreditCard(Contact individual) {
        Recurring_Donation__c ccRecord = new Recurring_Donation__c(
            Amount__c = 1.00,
            Reference__c = IATS_CUSTOMER_CODE,
            Type__c = 'Credit Card',
            Start_Date__c = Date.newInstance(2016, 03, 14),
            Schedule_Date__c = 14,
            Frequency__c = 'Monthly', 
            Status__c = 'Active',
            Credit_Card__c = '************2220',
            Credit_Card_Type__c = 'Visa',
            Credit_Card_Expiry_Date__c = Date.newInstance(2025, 1, 1),
            Constituent__c = individual.Id
            );

        insert ccRecord;

        ccRecord = [SELECT Id FROM Recurring_Donation__c WHERE Reference__c =: IATS_CUSTOMER_CODE LIMIT 1];

        return ccRecord;
    }
    
    private static Recurring_Donation__c InitializeOffline(Contact individual) {
        Recurring_Donation__c ccRecord = new Recurring_Donation__c(
            Amount__c = 1.00,
            Reference__c = null,
            Type__c = 'Cash',
            Start_Date__c = Date.newInstance(2016, 03, 14),
            Schedule_Date__c = 14,
            Frequency__c = 'Monthly', 
            Status__c = 'Active',
            Constituent__c = individual.Id
            );

        insert ccRecord;

        ccRecord = [SELECT Id FROM Recurring_Donation__c WHERE Amount__c = 1.00 LIMIT 1];

        return ccRecord;
    }
    
    private static Recurring_Donation__c InitializeCreditCardNonIats(Contact individual) {
        Recurring_Donation__c nonIatsRecord = new Recurring_Donation__c(
            Amount__c = 1.00,
            Reference__c = NON_IATS_CUSTOMER_CODE,
            Type__c = 'Credit Card',
            Start_Date__c = Date.newInstance(2016, 03, 14),
            Schedule_Date__c = 14,
            Frequency__c = 'Monthly', 
            Status__c = 'Active',
            Credit_Card__c = '************2220',
            Credit_Card_Type__c = 'Visa',
            Credit_Card_Expiry_Date__c = Date.newInstance(2025, 1, 1),
            Constituent__c = individual.Id
            );

        insert nonIatsRecord;

        nonIatsRecord = [SELECT Id FROM Recurring_Donation__c WHERE Reference__c =: NON_IATS_CUSTOMER_CODE LIMIT 1];

        return nonIatsRecord;
    }
    
    private static Gift__c InitializeActiveTransaction(Recurring_Donation__c recurringGift, Contact individual) {
        Gift__c activeTransaction = new Gift__c(
            Reference__c = IATS_CUSTOMER_CODE,
            Constituent__c = individual.Id,
            Recurring_Donation__c = recurringGift.Id,
            Status__c = 'Active',
            Gift_Date__c = Date.today()
            );

        insert activeTransaction;

        activeTransaction = [SELECT Id, Recurring_Donation__r.Type__c FROM Gift__c WHERE Reference__c =: IATS_CUSTOMER_CODE LIMIT 1];

        return activeTransaction;
    }
    
    private static Payment__c InitializeDeclinedPayment(Gift__c gift) {
        Payment__c declinedPayment = new Payment__c(
            CC_Reference__c = IATS_REFERENCE_NUMBER,
            External_Payment_ID__c = IATS_REFERENCE_NUMBER,
            Donation__c = gift.Id,
            Amount__c = 1.00,
            Status__c = 'Declined',
            Payment_Type__c = gift.Recurring_Donation__r.Type__c,
            Date__c = Date.today(),
            CC_Transaction_Date__c = Date.today()
        );

        insert declinedPayment;

        declinedPayment = [SELECT Id, Name, Amount__c, Date__c, Payment_Type__c, Donation__c, Status__c, CC_Reference__c  FROM Payment__c WHERE CC_Reference__c =: IATS_REFERENCE_NUMBER LIMIT 1];

        return declinedPayment;
    }
    
    private static Payment__c InitializeRecoveredPayment(Gift__c gift, Payment__c declinedPayment) {
        Payment__c recoveredPayment = new Payment__c(
            CC_Reference__c = IATS_RECOVERED_REFERENCE_NUMBER,
            External_Payment_ID__c = IATS_RECOVERED_REFERENCE_NUMBER,
            Donation__c = gift.Id,
            Amount__c = 1.00,
            Status__c = 'Approved',
            Payment_Type__c = gift.Recurring_Donation__r.Type__c,
            Date__c = Date.today(),
            CC_Transaction_Date__c = Date.today(),
            Recovered_Payment__c = declinedPayment.Id,
            CC_Invoice_Number__c = GenerateInvoiceNumber(),
            Authorization__c = IATS_AUTHORIZAION
        );

        insert recoveredPayment;

        recoveredPayment = [SELECT Id, Name, Amount__c, Date__c, Payment_Type__c, Donation__c, Recovered_Payment__c, 
        	CC_Invoice_Number__c, Authorization__c
        	FROM Payment__c WHERE CC_Reference__c =: IATS_RECOVERED_REFERENCE_NUMBER LIMIT 1];

        return recoveredPayment;
    }
    
    private static BatchGateway4.ArrayOfTransactionResult InitializeTransactionResults(BatchGateway4.ArrayOfChargeRequest requests) {
    	
    	BatchGateway4.ArrayOfTransactionResult results = new BatchGateway4.ArrayOfTransactionResult();
    	results.TransactionResult = new List<BatchGateway4.TransactionResult>();
    	
    	for (BatchGateway4.ChargeRequest request : requests.ChargeRequest) { 
    		
    		BatchGateway4.TransactionResult result = new BatchGateway4.TransactionResult();
    		result.TransactionStatus = 'Approved';
    		result.TransactionId = IATS_RECOVERED_REFERENCE_NUMBER;
    		result.ApprovalCode = 'OK: ' + IATS_AUTHORIZAION;
    		result.IsErrorFatal = false;
    		result.InvoiceNumber = GenerateInvoiceNumber();
    		results.TransactionResult.add(result);
    	}
    	
    	return results;
    	
    }
    
    private static String GenerateInvoiceNumber() {
    	return 'CV-' + date.today().day() + '/' + date.today().month() + '/' + date.today().year();
    }

    private static void ConfigureCauseview(){
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
            Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;
        
        Map<string, decimal> conversionRates = new Map <string, decimal>();
        
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        
        Id rtypes = rtype_Map.get('Gift');
        Id rtypes1 = rtype_Map.get('Matching Gift');
        
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;  
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes,Record_Type_Id_for_Rollups__c = rtypes, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
    }
}