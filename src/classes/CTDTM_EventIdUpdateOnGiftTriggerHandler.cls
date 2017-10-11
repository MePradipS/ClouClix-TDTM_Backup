public class CTDTM_EventIdUpdateOnGiftTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Allocations from trigger new. 
    * @param listOld the list of Allocations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Allocations 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if(triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            App_Settings__c settings = App_Settings__c.getInstance();
            Set<Id> appealId = new Set<Id>();
            Set<Id> giftId = new Set<Id>();
            Map<String, Id> rt_map = new Map<String, Id>();
            List<Gift__c> giftRecordsToUpdate = new List<Gift__c>();
            Set<Gift__c> setgiftRecordsToUpdate = new Set<Gift__c>();

            rt_map.put('Event', settings.Event_RecordType_Id__c);

            for (Gift_Detail__c gd : (List<Gift_Detail__c>)listNew)
            {
                appealId.add(gd.New_Campaign__c);
                giftId.add(gd.Gift__c);
            }

            if (appealId.size() > 0 && giftId.size() > 0)
            {
                Map<Id, Campaign> camp_map = new Map<Id, Campaign>(new CampaignSelector().SelectIdById(appealId));
                Map<Id, Gift__c> gift_map = new Map<Id, Gift__c>(new GiftSelector().UpdateEventById(giftId));
                for(Gift_Detail__c gd : (List<Gift_Detail__c>)listNew)
                {
                     if(camp_map.get(gd.New_Campaign__c) != null && gift_map.get(gd.Gift__c) != null)
                     {
                          if(camp_map.get(gd.New_Campaign__c).RecordTypeId == rt_map.get('Event'))
                          {
                              gift_map.get(gd.Gift__c).Event_Id__c = camp_map.get(gd.New_Campaign__c).id;
                              giftRecordsToUpdate.add(gift_map.get(gd.Gift__c));
                          }
                     }
                }
                if(giftRecordsToUpdate.size() > 0)
                {
                    setgiftRecordsToUpdate.addAll(giftRecordsToUpdate);
                    giftRecordsToUpdate.clear();
                    giftRecordsToUpdate.addAll(setgiftRecordsToUpdate);
                    DMLManager.UpdateSObjects(giftRecordsToUpdate);
                }
            }
        }
        return null;
    }
}