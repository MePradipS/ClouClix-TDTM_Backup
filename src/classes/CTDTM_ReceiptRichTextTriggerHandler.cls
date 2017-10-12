public class CTDTM_ReceiptRichTextTriggerHandler extends CTDTM_Runnable 
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
            if (triggerAction == CTDTM_Runnable.Action.BeforeInsert) 
            {
                Set<Id> giftId = new Set<Id>();

                for (Receipt__c  newReceipt: (List<Receipt__c>)listNew)
                    giftId.add(newReceipt.gift__c);

                Map<Id, Gift__c > lettersUpdated = new Map<Id, Gift__c>(new GiftSelector().SelectLetterByGiftId(giftId));

                for (Receipt__c updateReceipt: (List<Receipt__c>)listNew) 
                {

                   Gift__c giftRec = lettersUpdated.get(updateReceipt.Gift__c);
                   if(giftRec != null && giftRec.Letter__c != null)
                   {

                   updateReceipt.Introduction_Text_Block_Rich_Text__c = giftRec.Letter__r.Introduction_Text_Block_Rich_Text__c;
                   updateReceipt.Body_Text_Block_Rich_Text__c = giftRec.Letter__r.Text_Block__c;
                   updateReceipt.Signature_Rich_Text__c = giftRec.Letter__r.Signature_Rich_Text__c;
                   updateReceipt.Email_Subject__c = giftRec.Letter__r.Email_Subject__c;

                   updateReceipt.Custom_Rich_Text_1__c = giftRec.Letter__r.Custom_Rich_Text_1__c;
                   updateReceipt.Custom_Rich_Text_2__c = giftRec.Letter__r.Custom_Rich_Text_2__c;
                   updateReceipt.Custom_Rich_Text_3__c = giftRec.Letter__r.Custom_Rich_Text_3__c;
                  }

                }
            }
                
        return null;
   }    
    
}