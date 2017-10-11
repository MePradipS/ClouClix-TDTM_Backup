public class CTDTM_ReceiptUpdateOnTransTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Gifts from trigger new. 
    * @param listOld the list of Gifts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Gifts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate) 
        {
            if(!Validator_cls.isAlreadyModifiedforReceiptUpdateOnTransaction())
            {
                Validator_cls.setAlreadyModifiedforReceiptUpdateOnTransaction();
                
                Map<Id,Gift__c> newGiftMap = new Map<Id,Gift__c>();
                integer i = 0;
                for(Gift__c n : (list<Gift__c>)listNew)
                {
                    //Gift__c old = o.get(n.Id);
                    if(n.Letter__c != listOld[i].get('Letter__c'))
                    {
                        newGiftMap.put(n.Id,n);
                    }
                    i++;
                }
                List<Receipt__c> receiptListToUpdate = new List<Receipt__c>();


                if(newGiftMap.size()>0)
                {
                    for(Receipt__c updateReceipt : new ReceiptSelector().UpdateReceiptOnTrigger(newGiftMap.keyset())) 
                    {

                         updateReceipt.Introduction_Text_Block_Rich_Text__c = updateReceipt.Gift__r.Letter__r.Introduction_Text_Block_Rich_Text__c;
                         updateReceipt.Body_Text_Block_Rich_Text__c = updateReceipt.Gift__r.Letter__r.Text_Block__c;
                         updateReceipt.Signature_Rich_Text__c = updateReceipt.Gift__r.Letter__r.Signature_Rich_Text__c;

                         updateReceipt.Email_Subject__c = updateReceipt.Gift__r.Letter__r.Email_Subject__c;


                         updateReceipt.Custom_Rich_Text_1__c = updateReceipt.Gift__r.Letter__r.Custom_Rich_Text_1__c;
                         updateReceipt.Custom_Rich_Text_2__c = updateReceipt.Gift__r.Letter__r.Custom_Rich_Text_2__c;
                         updateReceipt.Custom_Rich_Text_3__c = updateReceipt.Gift__r.Letter__r.Custom_Rich_Text_3__c;
                       //update updateReceipt;
                       receiptListToUpdate.add(updateReceipt);
                    }
                   if(receiptListToUpdate.size() > 0) update receiptListToUpdate;
                }
            }
        }
        return null;
    }
}