public with sharing class ApplyAdjustmentButtonPageController extends RedirectController {
    public String fieldNamespace {
        get{
            if(String.isBlank(fieldNamespace))
                fieldNamespace = Utilities.getCurrentNamespace() + '__';
            return fieldNamespace;
        }
        set;
    }

    public Gift_Detail__c giftDetail {get;set;}
    public String PackageNamespace {
        get {
            if (PackageNamespace == null) {
                String namespace = Utilities.getCurrentNamespace();
                PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
            }
            return PackageNamespace;
         }
         set;
    }
    Id allocationId;

    public ApplyAdjustmentButtonPageController(ApexPages.standardController sc){
        super(sc, true);
        giftDetail = new Gift_Detail__c();
        allocationId = sc.getRecord().Id;
        string namespace = Utilities.getCurrentNamespace();
        PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

    public pageReference submit(){
        List<Gift_Detail__c> allocationsToInsert = new List<Gift_Detail__c>();
        Gift_Detail__c giftDetail1;
        Gift_Detail__c giftDetail2;
        Gift_Detail__c ExistingGiftDetail;
        List<Gift_Detail__c> giftDetailList = new AllocationSelector().SelectSObjectsById(new Set<Id> { allocationId });
        if (giftDetailList != null && giftDetailList.size() > 0) {
            ExistingGiftDetail = giftDetailList[0];
        }

        giftDetail1 = ExistingGiftDetail.clone(false, true);
        giftDetail1.Amount__c = 0 - ExistingGiftDetail.Amount__c;
        allocationsToInsert.add(giftDetail1);
        giftDetail2 = ExistingGiftDetail.clone(false, true);
        giftDetail2.Fund__c = giftDetail.Fund__c;
        allocationsToInsert.add(giftDetail2);
        if(allocationsToInsert.size() > 0){
            DMLManager.InsertSObjects(allocationsToInsert);
        }
        PageReference pageToRedirect = new PageReference('/'+allocationId);
        pageToRedirect.setRedirect(True);
        return pageToRedirect;
    }
}