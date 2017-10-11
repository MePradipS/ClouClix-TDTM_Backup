trigger updateFund on Gift_Detail__c (before insert, before update) {
    Set<Id> appealIds = new Set<Id>();
    for(Gift_Detail__c giftDetail : Trigger.new)
    {
        if(giftDetail.Fund__c == null && giftDetail.New_Campaign__c <> null)
        {
            if(Trigger.isInsert){
                appealIds.add(giftDetail.New_Campaign__c);
            }else
            if(Trigger.isUpdate && giftDetail.New_Campaign__c <> Trigger.oldMap.get(giftDetail.id).New_Campaign__c){
                appealIds.add(giftDetail.New_Campaign__c);
            }
        }
    }
    
    if(appealIds.size() > 0)
    {
        Map<Id, Campaign> appealFund= new Map<Id, Campaign>(new CampaignSelector().SelectIdandFundById(appealIds));
        
        for(Gift_Detail__c giftDetail : Trigger.new)
        {
            if(appealFund.get(giftDetail.New_Campaign__c) != null)
            {   
                 giftDetail.Fund__c = appealFund.get(giftDetail.New_Campaign__c).Fund__c;
            }
        }
    }
}