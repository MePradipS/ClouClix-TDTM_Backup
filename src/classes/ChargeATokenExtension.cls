public with sharing class ChargeATokenExtension {
    
    private final String ERROR_SYSTEM_UNAVALIABLE = 'The system is temporarly unavaliable, Please try again later.';
    private final String ERROR_INVALID_DATA = 'The data that you have entered was invalid.';
    private final String ERROR_NO_ACTIVE_TRANSACTION = 'There was no active transaction on the recurring gift.';
    private final String ERROR_PROCESSING = 'A unexpected error occured while processing your request, Please contact the system administrator.';
    private final Integer REQUEST_TIMEOUT = 120000;
    private final String GENERIC_ERROR_CODE = '823';
    
    private String paymentType;
    private Recurring_Donation__c currentRecord;
    private List<Payment__c> PaymentsToCreate;
    private Id MostRecentTransactionId;
    
    public Boolean AreThereDeclinedPayments { get; set; }
    public String PaymentsToCharge { get; set; }
    public List<String> Errors { get; set; }
    public Boolean Success { get; set; }
    public Boolean IsReferenceNumberIats { get; set; }  
    public String recurringGiftId { get; set; }
    public String recurringGiftName { get; set; }
    public List<Payment__c> DeclinedPayments { get; set; }
    public List<Payment__c> PaymentsInserted { get; set; }
    
    public ChargeATokenExtension () {
        Initialize();
    }

    public ChargeATokenExtension (ApexPages.StandardController stdController) {
        Initialize();
    }
    
    private void Initialize() {
        recurringGiftId = ApexPages.currentPage().getParameters().get('id');
        recurringGiftId = ESAPI.encoder().SFDC_HTMLENCODE(recurringGiftId);
        currentRecord = null;

        if (recurringGiftId != null && !String.isBlank(recurringGiftId)) {
            
            List<Recurring_Donation__c> records = new RecurringDonationSelector().SelectIdNameReferenceTypeById(recurringGiftId);

            Errors = new List<String>();
            
            if (utilities.IsListValid(records)) {
                
                Success = false;
                currentRecord = records[0];
                paymentType = currentRecord.Type__c;
                recurringGiftName = currentRecord.name;
                IsReferenceNumberIats = utilities.IsGatewayIatsOrEziDebit(records[0].Reference__c);               

                List<Gift__c> gifts = new GiftSelector().SelectIdByRecurringDonationAndStatus(recurringGiftId, 'Active');
                
                if (utilities.IsListValid(gifts)) {
                    MostRecentTransactionId = gifts[0].Id;
                    DeclinedPayments = GetDeclinedPayments();
                    AreThereDeclinedPayments = (utilities.IsListValid(DeclinedPayments));
                } else {
                    Errors.add(ERROR_NO_ACTIVE_TRANSACTION);
                }
            }           
        }
    }
    
    public PageReference redirect() {        
        if (currentRecord == null) {
            return CreateErrorPageReference();
        } else  { 
            if (IsRecurringGiftOffline()) {
                return CreateErrorPageReference();
            } else {
                return null;
            }
        }
    }
    
    public PageReference Back(){
        String retUrl = '/' + recurringGiftId;
        PageReference pageRef = new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference ChargePayments() {
        PageReference pageRef = null;
        
        List<String> paymentIdsToCharge = utilities.ConvertStringToList(PaymentsToCharge);
         
        try
        {       
            if (currentRecord != null && paymentIdsToCharge != null && paymentIdsToCharge.size() > 0) {   
                try {             
                    BatchGateway4.ArrayOfChargeRequest chargeRequests = CreateChargeRequests(paymentIdsToCharge);
                    
                    if (!Test.isRunningTest()) { 
                         
                            BatchGateway4.GatewaySoap gateway = InitializeGateway();                                
                            BatchGateway4.ArrayOfTransactionResult chargeResults = gateway.ChargeTokens(chargeRequests);
                            
                            if (chargeResults != null) {
                                
                                Success = true;
                                for (BatchGateway4.TransactionResult result : chargeResults.TransactionResult) {
                                    if (DoesResultHaveErrors(result)) {
                                        Success = false;
                                        HandleErrors(result);
                                    }
                                }
                                if (Success) {
                                    PaymentsInserted = InsertPayments(chargeRequests.ChargeRequest, chargeResults.TransactionResult);                                   
                                    DeclinedPayments = GetDeclinedPayments();
                                }
                            } else {
                                Errors = new List<String> {
                                    ERROR_SYSTEM_UNAVALIABLE
                                };
                            }
                        } 
                    }
                catch (Exception ex) {
                    Success = false;
                    if (ex.getMessage().contains('XML')) {
                        Errors.add(ERROR_INVALID_DATA);
                    } else {
                        Errors.add(GetExceptionMessage(ex));
                    }
                }
            } else { 
                Success = false;
                pageRef = CreateErrorPageReference();
            }
        } catch (Exception ex) {
            Success = false;
            Errors.add(GetExceptionMessage(ex));
        }
        
        return pageRef;
    }
    
    public List<Payment__c> InsertPayments(BatchGateway4.ChargeRequest[] requests, BatchGateway4.TransactionResult[] results) {
        
        List<Payment__c> paymentsToInsert = new List<Payment__c>();   
        
        for (Integer i = 0; i < results.size(); i++) {
            
            BatchGateway4.TransactionResult currentResult = results[i];     
            BatchGateway4.ChargeRequest currentRequest = requests[i];
            
            Payment__c currentPayment = PaymentsToCreate[i];
            
            currentPayment.CC_Reference__c = currentResult.TransactionId;
            currentPayment.External_Payment_ID__c = currentResult.TransactionId;
            currentPayment.Authorization__c = GetAuthorizationCode(currentResult.ApprovalCode);
            currentPayment.Date__c = Date.today();
            currentPayment.CC_Transaction_Date__c = Date.today();
            currentPayment.CC_Invoice_Number__c = currentResult.InvoiceNumber;
            currentPayment.Status__c = currentResult.TransactionStatus;
            
            paymentsToInsert.add(currentPayment);       
        }
        DMLManager.InsertSObjects(paymentsToInsert);
        
        Set<Id> paymentSetId = (new Map<Id,SObject>(paymentsToInsert)).keySet();
        paymentsToInsert = new PaymentSelector().SelectPaymentCCInfoById(paymentSetId);
        
        return paymentsToInsert;
    }
    
    public BatchGateway4.ArrayOfChargeRequest CreateChargeRequests(List<String> paymentIds) {
        
        PaymentsToCreate = new List<Payment__c>();
        BatchGateway4.ArrayOfChargeRequest requests = new BatchGateway4.ArrayOfChargeRequest();
        requests.ChargeRequest = new List<BatchGateway4.ChargeRequest>();
        
        for (String paymentId : paymentIds) {
            
            Payment__c declinedPayment = GetDeclinedPayment(paymentId);
            Payment__c newPayment = declinedPayment.clone(false, true, false, false);
            newPayment.Recovered_Payment__c = declinedPayment.Id;
            
            BatchGateway4.ChargeRequest request = new BatchGateway4.ChargeRequest();  
                
            request.Amount = declinedPayment.Amount__c;
            request.GiftId = declinedPayment.Donation__c;
            request.IsCC = IsPaymentTypeCreditCard();
            request.CustomerCode = currentRecord.Reference__c; 
               
            requests.ChargeRequest.add(request);
            
            PaymentsToCreate.add(newPayment);
        }
        
        return requests;        
    }
    
    public List<Payment__c> GetDeclinedPayments() {      
        
        List<Payment__c> recoveredPayments = new PaymentSelector().SelectRecoveredPaymentByDonationId(MostRecentTransactionId);
        
        Set<Id> recoveredPaymentIds = new Set<Id>();
        
        if (utilities.IsListValid(recoveredPayments)) {
            for (Payment__c payment : recoveredPayments) {
                recoveredPaymentIds.add(payment.Recovered_Payment__c);
            }
        } 
        
        List<Payment__c> declinedPayments = new PaymentSelector().SelectPaymentByMostRecentTransaction(MostRecentTransactionId, recoveredPaymentIds, 'Declined');
        
        return declinedPayments;
    }
    
    public BatchGateway4.GatewaySoap InitializeGateway() {
        BatchGateway4.GatewaySoap gateway = new BatchGateway4.GatewaySoap();
        gateway.timeout_x = REQUEST_TIMEOUT;

        if (!Test.isRunningTest()) {
            BatchSettings__c settingObj = BatchSettings__c.getInstance('Default');

            if (settingObj != null) {
                gateway.endpoint_x = settingObj.GatewayUrl__c;
            }
        }
        
        return gateway;
    }
    
    private PageReference CreateErrorPageReference() {
        PageReference pageRef = new PageReference('/' + recurringGiftId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private string GetAuthorizationCode(String approvalCode) {      
        if (approvalCode != null && approvalCode != '') {
            String authCode = '';
            
            Pattern digitPattern = Pattern.compile('\\d+');
            Matcher matcher = digitPattern.matcher(approvalCode);
            
            if (matcher.find()) {
                do {
                    authCode += matcher.group();
                } while (matcher.find());
            }
            
            return authCode;
        } else {
            return approvalCode;
        }
    }
    
    private void HandleErrors(BatchGateway4.TransactionResult result) {
        for (Integer i = 0; i < result.Errors.ErrorMessages.size(); i++) {
            if (result.Errors.ErrorMessages[i].ErrorCode == GENERIC_ERROR_CODE) {                
                Errors.add(ERROR_PROCESSING);
            } else {
                Errors.add('Gateway Error: ' + result.Errors.ErrorMessages[i].Error);
            }
        }
    }
    
    private Payment__c GetDeclinedPayment(String id) {
        
        Payment__c declinedPayment;
            
        for (Payment__c payment : DeclinedPayments) {
            if (payment.Id == id) {
                declinedPayment = payment;
            } 
        }
        
        return declinedPayment;
    }
    
    private boolean DoesResultHaveErrors(BatchGateway4.TransactionResult result) {
        return (result.Errors != null && result.Errors.ErrorMessages.size() > 0);
    }
    
    private String GetExceptionMessage(Exception ex) {
        return ex.getMessage().replace('\'', '').replace('\n', '');
    }
    
    private Boolean IsPaymentTypeCreditCard() {
        return (paymentType == 'Credit Card');
    }

    private Boolean IsPaymentTypeAch() {
        return (paymentType == 'ACH/PAD' || paymentType == 'ACH/EFT');
    }

    private Boolean IsPaymentTypeUkDirectDebit() {
        return (paymentType == 'UK Direct Debit');
    }
    
    private Boolean IsRecurringGiftOffline() {
        return ((!IsPaymentTypeCreditCard() && !IsPaymentTypeAch() && !IsPaymentTypeUkDirectDebit()) || (paymentType == null || paymentType == ''));
    }
}