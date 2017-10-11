public class PaymentWrapper {
        public String id { get; set; }
        public Payment__c thePayment {get;set;}
        public List<Gift_Detail__c> theGiftDetails {get;set;}
        public boolean isRemind {get;set;}
        public Integer daysBefore {get;set;}
        
        public PaymentWrapper(Payment__c p)
        {
            id = 'NotSavedYet-' + DateTime.now().format('hmmss');
            thePayment = p;
            theGiftDetails = new List<Gift_Detail__c>();
            theGiftDetails.add(new Gift_Detail__c());
        }

        public List<selectOption> getCustompicklist() 
        {
            list<selectoption> options= new list<selectoption>();
            options.add(new selectoption('Cash','Cash'));
            options.add(new selectoption('Check','Check'));
            options.add(new selectoption('Credit Card - Offline','Credit Card - Offline'));
            options.add(new selectoption('Stock','Stock'));
            options.add(new selectoption('Property','Property'));
            options.add(new selectoption('In Kind','In Kind'));
            options.add(new selectoption('Other','Other'));
            return options;
        } 
}