//Users will be presented with an interface which displays all unreceipted Payments belonging to the donor.
//The user can select All or individual Payments to consolidate into the receipt.
//A new receipt record will be created, grouping all Payments (transactions) selected and Link each Payment to the master receipt record, on click of the create button.
//The user is able to filter the Payment records via a picklist of filters (This Year, Last Year, All).
    //The picklist defaults to what the user last selected.
//From the receipt record, the user can click a button to print consolidated receipt which generates an email and  PDF receipt.
    //The PDF receipt will include a list of all donation included in the consolidated receipt.

public with sharing class consolidatedReceiptController extends RedirectController {
    public Boolean containsPayment{get;set;}
    public List<paymentWrapper> payments{get;set;}
    public Receipt__c receipt{get;set;}
    public String selectedPaymentFilter{get;set;}

    private List<Payment__c> selectedPayments;
    @TestVisible
    private List<Payment__c> allPayments;
    private String cid;
    private User currentUser;
    private string NamespacePrefix = Utilities.getCurrentNamespace(); 
    private String NamespaceField = NamespacePrefix + (String.isEmpty(NamespacePrefix) ? '' : '__'); 
    private String NamespacePayment = NameSpaceField + 'Payment__c'; 

    public consolidatedReceiptController(ApexPages.StandardController controller) {
        super(controller, true);
        
        cid = ApexPages.currentPage().getParameters().get('cid');
        cid = ESAPI.encoder().SFDC_HTMLENCODE(cid);

        payments = new List<paymentWrapper>();
        selectedPayments = new List<Payment__c>();
        containsPayment = true;

        try{
            Id RT = Id.valueOf(Utilities.getObjectRecordTypeId(Payment__c.SObjectType, 'Refund'));
            allPayments = new PaymentSelector().SelectRecoveredPaymentByDonationId(cid, RT);
            //If no payments, display Info.
            if(allPayments == null || allPayments.Size() < 1) {
                containsPayment = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'There are no unreceipted Payments belonging to the donor.'));
            } else {

                //Filter out Refunded Payments
                for(Integer i = 0; i < allPayments.size(); i++) {
                    if(allPayments[i].Payments__r.size() > 0) {
                        allPayments.remove(i);
                    }
                }
    
                createNewReceipt();
    
                //Get the user last selected filter value.
                List<User> userList = new UserSelector().SelectSObjectsById(new Set<Id> { UserInfo.getUserId() });
                if (userList != null && userList.size() > 0) {
                    currentUser = userList[0];
                }
                selectedPaymentFilter = 'This Year';
                if(currentUser.Payment_Filter__c != null) {
                    selectedPaymentFilter = currentUser.Payment_Filter__c;
                }
                applyPaymentFilter();    
            }
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); } 

    @TestVisible
    //Create a new Receipt record and populate default fields.
    private void createNewReceipt() {
        receipt = new Receipt__c();

        try {
            //Populate Receipt_Email_Address__c based on the donor type.
            
            if (allPayments[0].Donation__r.Constituent__c == null) {
                List<Account> accountList = new AccountSelector().SelectEmailById(new Set<Id> { cid });
                if (accountList != null && accountList.size() > 0) {
                    receipt.Receipt_Email_Address__c = accountList[0].Email__c;
                }
            } else {
                List<Contact> contactList = new ContactSelector().SelectEmailById(new Set<Id> { cid });
                if (contactList != null && contactList.size() > 0) {
                    receipt.Receipt_Email_Address__c = contactList[0].Email;
                }
            }
    
            receipt.Constituent__c = allPayments[0].Donation__r.Constituent__c;
            receipt.Organization__c = allPayments[0].Donation__r.Organization__c;
            receipt.Receipt_Date__c = System.Today();
            receipt.Receipt_Type__c = 'Consolidated';
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }

    //Create Payment Filter options.
    public List<SelectOption> getPaymentFilters() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('This Year','This Year'));
        options.add(new SelectOption('Last Year','Last Year'));
        options.add(new SelectOption('All','All'));

        return options;
    }

    //Attach recent Transaction(Among the selected Payments) to the Receipt record.
    public List<SelectOption> getTransactionsToAttach() {
        List<SelectOption> options = new List<SelectOption>();
        Integer index = 0;
        Integer recentIndex = 0;
        Date recent;
        for(paymentWrapper PW : payments) {
            if(PW.selected) {
                if(recent == null || recent < PW.payment.Donation__r.Gift_Date__c) {
                    recent = PW.payment.Donation__r.Gift_Date__c;
                    recentIndex = index;
                }
                options.add(new SelectOption(PW.payment.Donation__c, PW.payment.Donation__r.Name));
                index++;
            }
        }

        if(recentIndex != 0) {
            SelectOption opt = options.remove(recentIndex);
            options.add(0, opt);
        }
        return options;

    }

    //Filter records based on payment filter
    public pageReference applyPaymentFilter() {
        Boolean isAll = false;
        Integer cond = System.Today().year();
        if(selectedPaymentFilter == 'All') {
            isAll = true;
        } else if(selectedPaymentFilter == 'Last Year') {
            cond = cond - 1;
        }

        payments.clear();

        for(Payment__c P : allPayments) {
            if( isAll || (P.Date__c).year() == cond ) {
                payments.add(new paymentWrapper(P));
            }
        }

        return null;
    }

    //Wrapper class for payment to store the payments that are selected.
    public class paymentWrapper {
        public Payment__c payment{get;set;}
        public boolean selected{get;set;}
        public paymentWrapper(Payment__c p) {
            payment = p;
            selected = false;
        }
    }

    public pageReference cancel() {
        return new pageReference('/' + cid);
    }

    //Insert the Receipt record with all the field values and update the payment records.
    public pageReference generateReceipt() {

        Boolean isEmpty = true;
        //If no Payments are selected
        for(paymentWrapper PW : payments) {
            if(PW.selected) {
                isEmpty = false;
            }
        }

        //If no payments are selected display Warning message.
        if(isEmpty) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Please select a Payment to generate Receipt'));
            return null;
        }

        try {
            //Update User record with the selected payment filter.
            currentUser.Payment_Filter__c = selectedPaymentFilter;
                        
            DMLManager.UpdateSObject(currentUser);
            DMLManager.InsertSObject(receipt);
    
            receipt.Amount_Receipted__c = 0;
            //Update Selected Payment records with the Receipt id, and Amount_Receipted__c field with the sum of all the payment amounts.
            for(paymentWrapper PW : payments) {
                if(PW.selected) {
                    PW.payment.Receipt__c = receipt.Id;
                    selectedPayments.add(PW.payment);
                    receipt.Amount_Receipted__c = receipt.Amount_Receipted__c + PW.payment.Amount__c;
                }
            }
            
            //Update receipt record and related payment records.
            DMLManager.UpdateSObject(receipt);
            DMLManager.UpdateSObjects(selectedPayments);
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            containsPayment = false;
            return null;
        }

        pageReference page = new pageReference('/' + receipt.id);
        return page;
    }

        //Insert the Receipt record with all the field values and update the payment records.
    public string submitErrorMsg {get;set;}
    public pageReference generateReceiptLtng() {
        submitErrorMsg = '';
        Boolean isEmpty = true;
        //If no Payments are selected
        for(paymentWrapper PW : payments) {
            if(PW.selected) {
                isEmpty = false;
            }
        }

        //If no payments are selected display Warning message.
        if(isEmpty) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Please select a Payment to generate Receipt'));
            submitErrorMsg = 'Please select a Payment to generate Receipt';
            return null;
        }

        try {
            //Update User record with the selected payment filter.
            currentUser.Payment_Filter__c = selectedPaymentFilter;
            
            DMLManager.UpdateSObject(currentUser);            
            DMLManager.UpdateSObject(receipt);            

            receipt.Amount_Receipted__c = 0;
            //Update Selected Payment records with the Receipt id, and Amount_Receipted__c field with the sum of all the payment amounts.
            for(paymentWrapper PW : payments) {
                if(PW.selected) {
                    PW.payment.Receipt__c = receipt.Id;
                    selectedPayments.add(PW.payment);
                    receipt.Amount_Receipted__c = receipt.Amount_Receipted__c + PW.payment.Amount__c;
                }
            }
            
             
            
            //Update receipt record and related payment records.
            DMLManager.UpdateSObject(receipt);
            DMLManager.UpdateSObjects(selectedPayments);
        } catch(Exception ex) {
            //ApexPages.addMessages(ex);
            submitErrorMsg = ex.getMessage();
            containsPayment = false;
            return null;
        }
        pageReference page = new pageReference('/' + receipt.id);
        return page;
    }

}