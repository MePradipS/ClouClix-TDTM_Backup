public class CTDTM_UpdateConstituentTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Receipts from trigger new. 
    * @param listOld the list of Receipts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Receipts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            List<Id> giftIds = new List<Id>();
            List<Receipt__c> TriggerNew = (List<Receipt__c>)listNew;
            List<Receipt__c> TriggerOld = (List<Receipt__c>)listOld;

            for(Integer i = 0; i < TriggerNew.size(); i++) 
            {
                if(TriggerNew[i].Gift__c != null && (TriggerNew[i].Constituent__c == null && TriggerNew[i].Organization__c == null)) 
                {
                    giftIds.add(TriggerNew[i].Gift__c);
                }
            }

            if(giftIds.size() > 0) 
            {
                Map<Id, Gift__c> gifts = new Map<Id, Gift__c>(new GiftSelector().SelectOrganizationAndConstituentWhereIdInIds(giftIds));
                for(Integer i = 0; i < TriggerNew.size(); i++) 
                {
                    if(TriggerNew[i].Gift__c != null && (TriggerNew[i].Constituent__c == null && TriggerNew[i].Organization__c == null)) 
                    {
                        TriggerNew[i].Constituent__c = gifts.get(TriggerNew[i].Gift__c).Constituent__c;
                        TriggerNew[i].Organization__c = gifts.get(TriggerNew[i].Gift__c).Organization__c;
                    }
                }
            }
        }
        
        return null;
   }    
    
}