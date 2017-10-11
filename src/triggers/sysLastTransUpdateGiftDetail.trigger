trigger sysLastTransUpdateGiftDetail on Gift_Detail__c (before insert, before update)
{
     if(!BatchSettings__c.getInstance('Default').Data_Migration_Mode__c)
     {
        List<Event_Registration__c> toUpdateEventReg = new List<Event_Registration__c>();
        set<Id> giftId = new set<Id>();
        for(Gift_Detail__c giftDetail: Trigger.new){
              giftId.add(giftDetail.Gift__c);
        }
        List<Event_Registration__c> eventRegList = new EventRegistrationSelector().SelectLastTransactionByGiftId(giftId);

        if(eventRegList.size() > 0)
        {
            for(Event_Registration__c eventReg: eventRegList)
            {
               eventReg.sysLastTransactionUpdate__c = system.today();
            }
       }
     }
}