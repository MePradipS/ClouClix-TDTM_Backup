public class CTDTM_CloneTriggerTriggerHandler  extends CTDTM_Runnable 
{
    /*******************************************************************************************************
* @param listNew the list of Contacts from trigger new. 
* @param listOld the list of Contacts from trigger old. 
* @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
* @param objResult the describe for Contacts 
* @return dmlWrapper.  always null.
********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
                                   CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {   
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert )
        {   
            List<Payment__c> TriggerNew = (List<Payment__c>)listNew;
            if (TriggerNew.size()>1) 
                return null;

            list<Payment__c> payments = new PaymentSelector().SelectPaymentTransactionById(TriggerNew[0].Id);
            if (payments==null || payments.size()<=0) 
                return null;

            Payment__c newPayment = payments[0];
            Gift__c gift = newPayment.Donation__r;
            if (gift==null || gift.Sys_Clone_Transaction__c==null) return null;

            List<Gift__c> gifts = new GiftSelector().SelectAllocationByTransactionId(gift.Sys_Clone_Transaction__c);

            if (gifts==null || gifts.size()<=0) return null;

            List<Gift_Detail__c> details = gifts[0].Gift_Allocations__r;
            if (details==null || details.size()<=0) return null;

            List<Gift_Detail__c> newOnes = new List<Gift_Detail__c>();
            for(Gift_Detail__c giftDetail : details)
                {
                    Gift_Detail__c item = giftDetail.clone();

                    item.Gift__c = gift.Id;
                    if (newPayment.Amount__c!=gifts[0].Amount__c) 
                    {
                        //amount is different, use radio
                        item.Amount__c = (newPayment.Amount__c * giftDetail.Amount__c) / gifts[0].Amount__c;
                    }
                item.Payment__c = TriggerNew[0].id;
                newOnes.add(item);
            }
            DMLManager.InsertSObjects(newOnes);
            
        } 
        return null;
    }
}