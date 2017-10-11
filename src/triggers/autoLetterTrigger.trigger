trigger autoLetterTrigger on Gift_Detail__c (after insert, after update) {

        List<Gift__c> updateGift = new List<Gift__c>();
        set<Id> campId = new set<Id>(); 
        set<Id> giftId = new set<Id>();
        for(Gift_Detail__c allocation: trigger.new )
        {   
            campId.add(allocation.New_Campaign__c);
            giftId .add(allocation.Gift__c);
        }
        
        Map<Id, Gift__c> giftMap = new Map<Id, Gift__c>(new GiftSelector().SelectGiftAndLetterWhereIdInIds(giftId));
        
        Map<Id, Campaign> campMap = new Map<Id, Campaign>( new CampaignSelector().SelectFundAndLetterWhereIdInIds(campId));
        
               
        if(giftMap.size() > 0  && campMap.size()>0) 
        {
            for(Gift_Detail__c allocation: trigger.new )
            {    
             if(allocation.New_Campaign__c != null  && allocation.Gift__c != null)            
              {
              
                Campaign camp = campMap.get(allocation.New_Campaign__c); 
                Gift__c giftObj = giftMap.get(allocation.Gift__c);        
           
              if(camp!=null && giftObj!=null && giftObj.Letter__c == null && camp.Letter__c != giftObj.Letter__c)
               {
               
                   giftObj.Letter__c = camp.Letter__c;
              
                   updateGift.add(giftObj);     
               }
              }
            }         
          if(updateGift.size() > 0) {
              DMLManager.UpdateSObjects(updateGift);
          }
        }    
}