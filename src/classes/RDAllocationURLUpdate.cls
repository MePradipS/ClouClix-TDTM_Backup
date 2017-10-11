public with sharing class RDAllocationURLUpdate extends RedirectController {
    public string gateway{get;set;}

    public RDAllocationURLUpdate(ApexPages.StandardController stdController) {
        super(stdController, true);

        gateway = ''; 
        list<Gift__c> Gifts;
        list<RD_Allocation__c>  RGiftsAllocations = new RDAllocationSelector().SelectRecurringGiftIdById(new Set<Id> { stdController.getRecord().id });
        
        if(RGiftsAllocations.size()>0){
            Gifts = new GiftSelector().SelectGatewayByRecurringGiftIdAndLimit(new Set<Id> { RGiftsAllocations[0].Recurring_Gift__r.id }, 1);
        }
        
        if(Gifts.size()>0){    
            gateway = Gifts[0].Gateway__c; 
        }        
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

}