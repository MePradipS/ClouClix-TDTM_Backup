trigger ReceiptRichTextTrigger on Receipt__c (before insert)
{

  if(trigger.isInsert) {
    Set<Id> giftId = new Set<Id>();

    for (Receipt__c  newReceipt: Trigger.new)
        giftId.add(newReceipt.gift__c);

    Map<Id, Gift__c > lettersUpdated = new Map<Id, Gift__c>(new GiftSelector().SelectLetterByGiftId(giftId));

    for (Receipt__c updateReceipt: Trigger.new) {

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
}