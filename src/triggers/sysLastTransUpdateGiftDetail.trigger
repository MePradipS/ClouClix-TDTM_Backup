trigger sysLastTransUpdateGiftDetail on Gift_Detail__c (before insert, before update)
{
    // -------------------------------------------------------------------------------------------
    // This trigger code has been commented to reduce the probability of getting the Percent of Apex
    // Used limit. 
    // -------------------------------------------------------------------------------------------
    //    Date                Author                 Description
    // -------------------------------------------------------------------------------------------
    // 11-Oct-2017        Pradip Shukla          Initial Version
    // --------------------------------------------------------------------------------------------
     /*if(!BatchSettings__c.getInstance('Default').Data_Migration_Mode__c)
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
     }*/
}