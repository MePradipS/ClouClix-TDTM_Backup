public class FraudulentPaymentsInterfaceController extends RedirectController {
    public List<PaymentWrapper> lstWrapper {get;set;}
    public List<PaymentWrapper> lstSetController{get;set;}
    public integer LimitSize = 0;
    public integer totalRecs = 0;
    public integer pageNumber {get; set;}
    public integer totalPages {get; set;}
    
    public CustomIterable obj;
    
    public FraudulentPaymentsInterfaceController() {
        super(true);
        retrievePayments();
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }    
    
    public void retrievePayments() {
        set<id> giftIds = new set<id>();
        set<id> rdGiftIds = new set<id>();
        set<id> contactIds = new set<id>();
        set<id> accountIds = new set<id>();
        map<id, list<Payment__c>> giftToPayMap = new map<id, list<Payment__c>>();
        map<id, list<Payment__c>> contactToPayMap = new map<id, list<Payment__c>>();
        map<id, list<Payment__c>> accountToPayMap = new map<id, list<Payment__c>>();
        map<id, list<Payment__c>> rdGiftToPayMap = new map<id, list<Payment__c>>();
        map<id, Payment__c> paymentsCanBeDeleted = new map<id, Payment__c>();
        List<Gift__c> gifts =new List<Gift__c>();
        List<Payment__c> lstPayment =new List<Payment__c>();
        List<Payment__c> lstPaymentRetrieved =new List<Payment__c>();
        
        set<Payment__c> paymentsCanNotBeDeleted =new set<Payment__c>();
        lstPaymentRetrieved = new PaymentSelector().SelectPotentiallyFraudulent(true);
        for(Payment__c pay : lstPaymentRetrieved){
            boolean postToFinance = false;
            for(Gift_Detail__c gd : pay.Allocations__r){
                if(gd.Posted_to_Finance__c != null ){
                    postToFinance = true;
                }
            }
            if(!postToFinance){
                lstPayment.add(pay);
            }
        }
        for(Payment__c p : lstPayment){
            paymentsCanBeDeleted.put(p.id, p);
            giftIds.add(p.Donation__c);
            
            if(giftToPayMap.containsKey(p.Donation__c)){
                giftToPayMap.get(p.Donation__c).add(p);
                
            }else{
                List<Payment__c>  paymentList =new List<Payment__c>();
                paymentList.add(p);
                giftToPayMap.put(p.Donation__c, paymentList);
                
            }   
            if(contactToPayMap.containsKey(p.Donation__r.Constituent__c)){
                contactToPayMap.get(p.Donation__r.Constituent__c).add(p);
            }else{              
                List<Payment__c>  paymentList =new List<Payment__c>();
                paymentList.add(p);
                contactToPayMap.put(p.Donation__r.Constituent__c, paymentList);
                
            }
            if(accountToPayMap.containsKey(p.Donation__r.Organization__c)){
                accountToPayMap.get(p.Donation__r.Organization__c).add(p);
            }else{              
                List<Payment__c>  paymentList =new List<Payment__c>();
                paymentList.add(p);
                accountToPayMap.put(p.Donation__r.Organization__c, paymentList);
                
            }
            if(rdGiftToPayMap.containsKey(p.Donation__r.Recurring_Donation__c)){
                rdGiftToPayMap.get(p.Donation__r.Recurring_Donation__c).add(p);
            }else{
                List<Payment__c>  paymentList =new List<Payment__c>();
                paymentList.add(p);
                rdGiftToPayMap.put(p.Donation__r.Recurring_Donation__c, paymentList);
                
            }
        }        
        gifts = new GiftSelector().SelectRecurringById(giftIds);
        for(Gift__c  g : gifts){            
            if(g.Recurring_Payments__r.size()>1){                
                for(Payment__c p : giftToPayMap.get(g.id)){                     
                    paymentsCanNotBeDeleted.add(p);
                    paymentsCanBeDeleted.remove(p.id);
                }
                                
            }else{                                  
                rdGiftIds.add(g.Recurring_Donation__c);
                contactIds.add(g.Constituent__c);
                accountIds.add(g.Organization__c);
            }            
        }        
       list<contact> contacts  =[ SELECT Name, (SELECT Name FROM Gifts__r) FROM Contact WHERE id in : contactIds];
        for(contact  c : contacts){
            if(c.Gifts__r.size()>1){
                for(Payment__c p : contactToPayMap.get(c.id)){
                    paymentsCanNotBeDeleted.add(p);
                    paymentsCanBeDeleted.remove(p.id);                    
                }                 
            }        
        }        
        list<account> accounts  =[ SELECT Name, (SELECT Name FROM Orders__r) FROM Account WHERE id in : accountIds];
        for(account  a : accounts){
            if(a.Orders__r.size()>1){
                for(Payment__c p : accountToPayMap.get(a.id)){
                    paymentsCanNotBeDeleted.add(p);
                    paymentsCanBeDeleted.remove(p.id);                    
                }                 
            }        
        }
        list<Recurring_Donation__c> rdGifts  =[ SELECT Name, (SELECT Name FROM Orders__r) FROM Recurring_Donation__c WHERE id in : rdGiftIds];
        for(Recurring_Donation__c  rd : rdGifts){
            if(rd.Orders__r.size()>1){
                for(Payment__c p : rdGiftToPayMap.get(rd.id)){
                    paymentsCanNotBeDeleted.add(p);
                    paymentsCanBeDeleted.remove(p.id) ;
                }                                    
            }           
        }
        prepareWrapper(paymentsCanBeDeleted.values(), paymentsCanNotBeDeleted);                
    }
    
    public void prepareWrapper(list<Payment__c> paymentsCanBeDeleted, set<Payment__c> paymentsCanNotBeDeleted){        
        lstWrapper =  new List<PaymentWrapper>();
        lstSetController = new List<PaymentWrapper>();
        for(Payment__c pay : paymentsCanBeDeleted )
        {
            lstWrapper.add(new PaymentWrapper(pay ,false, true));
        }
        for(Payment__c pay : paymentsCanNotBeDeleted )
        {
            lstWrapper.add(new PaymentWrapper(pay ,false, false));
        }
        obj = new CustomIterable (lstWrapper); 
        obj.setPageSize = 50;
        totalRecs = paymentsCanBeDeleted.size() + paymentsCanNotBeDeleted.size();
        LimitSize = obj.setPageSize;
        if(totalRecs > 0){
            totalPages = (Math.mod(totalRecs, LimitSize) == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize) + 1);    //To display number of pages of records in visualforce page, if more than 1500 records then display number of pages according to records
        }else
        {
            totalPages = 1;
        }
        pageNumber = 0;
        next(); 
    }
    
    public Boolean hasNext {
        get 
        {
            return obj.hasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get 
        {
            return obj.hasPrevious();
        }
        set;
    }
    
    public void fistPage() 
    {
        pageNumber = 1;
        lstSetController = obj.fistPage();
    }
    
    public void next() 
    {
        pageNumber++;
        lstSetController = obj.next();
    }
    
    public void previous() 
    {
        pageNumber--;
        lstSetController = obj.previous();
    }
    
    public void lastPage() 
    {
        pageNumber = (Math.mod(totalRecs, LimitSize) == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize) + 1);
        lstSetController = obj.lastPage();
    }    
    
    public pageReference deleteSelected() 
    {        
        set<id> payIds = new set<id>();
        set<id> giftIds = new set<id>();
        set<id> rdGiftsIds = new set<id>();
        set<id> contactIds = new set<id>();
        set<id> accountIds = new set<id>();
        set<id> gAidIds = new set<id>();
        set<Payment__c> paymentsToBeDeleted = new set<Payment__c>();
        list<Payment__c> payments = new list<Payment__c>();
        set<Installment_Fulfillment__c> instFullfills = new set<Installment_Fulfillment__c>();
        set<Gift_Detail__c> allocations = new set<Gift_Detail__c>();
        set<Receipt__c> receipts = new set<Receipt__c>();
        set<Solicitor__c> softCredits = new set<Solicitor__c>();
        set<RD_Allocation__c> rdAllocations = new set<RD_Allocation__c>();
        list<Gift__c> gifts = new list<Gift__c>();        
        list<Recurring_Donation__c> rdGifts =  new list<Recurring_Donation__c>();
        list<Gift_Aid_Declaration__c> gADeclarations =  new list<Gift_Aid_Declaration__c>();   
        
        try{
            for(PaymentWrapper Pwrap : lstWrapper){            
                if(Pwrap.isSelected){                
                    payIds.add(Pwrap.pay.id);
                    giftIds.add(Pwrap.pay.Donation__c);
                    gAidIds.add(Pwrap.pay.Gift_Aid_Declaration__c);                
                }
            }

            payments = new PaymentSelector().SelectInstallmentsAndAllocationsById(payIds);
            for(Payment__c p : payments){
                for(Installment_Fulfillment__c inF : p.Installment_Fulfillments__r){
                    instFullfills.add(inF);
                }
                for(Payment__c pTD : p.Payments__r){
                    paymentsToBeDeleted.add(pTD);
                }
                for(Gift_Detail__c gD : p.Allocations__r){
                    allocations.add(gD);
                }
            }
            list<Gift_Detail__c>  allocationsToDelete = new list<Gift_Detail__c>(allocations);
            list<Installment_Fulfillment__c>  instFullfillsToDelete = new list<Installment_Fulfillment__c>(instFullfills);            
            list<Payment__c>  refundsToBeDeleted = new list<Payment__c>(paymentsToBeDeleted);
            DMLManager.DeleteSObjects(allocationsToDelete, false); 
            DMLManager.DeleteSObjects(instFullfillsToDelete, false); 
            DMLManager.DeleteSObjects(refundsToBeDeleted, false); 
            DMLManager.DeleteSObjects(payments, false); 
            allocationsToDelete.clear();
            refundsToBeDeleted.clear();
            instFullfillsToDelete.clear();
            allocations.clear();
            allocations.clear();
            
            gifts = new GiftSelector().SelectAllRecurringInfoById(giftIds);
            for(Gift__c g: gifts){
                rdGiftsIds.add(g.Recurring_Donation__c);
                contactIds.add(g.Constituent__c);
                accountIds.add(g.Organization__c);
                for(Gift_Detail__c gD : g.Gift_Allocations__r){
                    allocations.add(gD);
                }
                for(Receipt__c recpt : g.Receipts__r){
                    receipts.add(recpt);
                }
                for(Solicitor__c sC : g.Soft_Credits__r){
                    softCredits.add(sC);
                }
                for(Payment__c pTD : g.Recurring_Payments__r){
                    paymentsToBeDeleted.add(pTD);
                }
                
            } 
            list<Receipt__c>  receiptsToDelete = new list<Receipt__c>(receipts);
            DMLManager.DeleteSObjects(receiptsToDelete, false); 
            list<Solicitor__c>  softCreditsToDelete = new list<Solicitor__c>(softCredits);
            DMLManager.DeleteSObjects(softCreditsToDelete, false); 
            
            rdGifts = new RecurringDonationSelector().SelectIdNameReferenceTypeById(rdGiftsIds);       
            gADeclarations = new GiftAidDeclarationSelector().SelectSObjectsById(gAidIds);   
            
            for(Recurring_Donation__c rd: rdGifts){            
                for(RD_Allocation__c gD : rd.Recurring_Gift_Allocations__r){
                    rdAllocations.add(gD);
                }
            }      
            
            list<RD_Allocation__c>  rdAllocationsToDelete =new  list<RD_Allocation__c>(rdAllocations);
            DMLManager.DeleteSObjects(rdAllocationsToDelete, false); 
            DMLManager.DeleteSObjects(gADeclarations, false); 
            DMLManager.DeleteSObjects(rdGifts, false); 
            DMLManager.DeleteSObjects(gifts, false); 
            
            list<contact> contactToDelete = new ContactSelector().SelectNameById(contactIds);
            DMLManager.DeleteSObjects(contactToDelete, false);

            list<account> accountToDelete = new AccountSelector().SelectIdNameById(accountIds);
            DMLManager.DeleteSObjects(accountToDelete, false);
        }catch(exception e){            
            if(e.getMessage() != null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in deleteing records'));
            }
        }
        retrievePayments();
        return null;
    }
    
    public class PaymentWrapper
    {
        public Boolean isSelected {get;set;}
        public Boolean canDelete {get;set;}        
        public Payment__c pay{get;set;}        
        public PaymentWrapper(Payment__c pay,Boolean isSelected, Boolean canDelete)
        {
            this.pay= pay;
            this.isSelected= isSelected;
            this.canDelete= canDelete;            
        }
        
    }
    public class  CustomIterable implements Iterator<list<PaymentWrapper>>
    { 
        list<PaymentWrapper> InnerList{get; set;}
        list<PaymentWrapper> ListRequested{get; set;}
        
        Integer i {get; set;} 
        public Integer setPageSize {get; set;} 
        
        public CustomIterable(List<PaymentWrapper> lstPayWr)
        {
            InnerList = new list<PaymentWrapper >(); 
            ListRequested = new list<PaymentWrapper >();     
            InnerList = lstPayWr;
            setPageSize = 10;
            i = 0; 
        }   
        
        public boolean hasNext(){ 
            if(i >= InnerList.size()) {
                return false; 
            } else {
                return true; 
            }
        } 
        
        public boolean hasPrevious(){
            if(i <= setPageSize) {
                return false; 
            } else {
                return true; 
            }
        }   
        
        public list<PaymentWrapper > fistPage(){       
            ListRequested = new list<PaymentWrapper >(); 
            integer startNumber;
            integer size = InnerList.size();             
            startNumber = 0;
            i = setPageSize;                
            for(integer start = startNumber; start < i; start++)
            {
                ListRequested.add(InnerList[start]);
            }            
            return ListRequested;
        }
        
        public list<PaymentWrapper > next(){          
            ListRequested = new list<PaymentWrapper >(); 
            integer startNumber;
            integer size = InnerList.size();
            if(hasNext())
            {  
                if(size <= (i + setPageSize))
                {
                    startNumber = i;
                    i = size;
                }
                else
                {
                    i = (i + setPageSize);
                    startNumber = (i - setPageSize);
                }
                
                for(integer start = startNumber; start < i; start++)
                {
                    ListRequested.add(InnerList[start]);
                }
            } 
            return ListRequested;
        } 
        
        public list<PaymentWrapper > previous(){            
            ListRequested = new list<PaymentWrapper >(); 
            integer size = InnerList.size(); 
            if(i == size)
            {
                if(math.mod(size, setPageSize) > 0)
                {    
                    i = size - math.mod(size, setPageSize);
                }
                else
                {
                    i = (size - setPageSize);
                } 
            }
            else
            {
                i = (i - setPageSize);
            }
            
            for(integer start = (i - setPageSize); start < i; ++start)
            {
                ListRequested.add(InnerList[start]);
            } 
            return ListRequested;
        }
        
        public list<PaymentWrapper > lastPage(){            
            ListRequested = new list<PaymentWrapper >(); 
            integer startNumber;
            integer size = InnerList.size();             
            startNumber = size - setPageSize;
            i = size;                
            for(integer start = startNumber; start < i; start++)
            {
                ListRequested.add(InnerList[start]);
            }            
            return ListRequested;
        }
    }    
}