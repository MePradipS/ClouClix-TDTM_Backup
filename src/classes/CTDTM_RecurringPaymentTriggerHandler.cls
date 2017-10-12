public class CTDTM_RecurringPaymentTriggerHandler  extends CTDTM_Runnable 
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
        if(triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            Set<Id> paymentIdstest = new Set<Id>();
            for(Payment__c objPay : (List<Payment__c>)listNew)
            {
                paymentIdstest.add(objPay.Id);
            }
            if(Validator_cls.paymentidsset.isEmpty() || !(paymentIdstest.containsAll(Validator_cls.paymentidsset) ))  
            {   
                integer i=0;
                Boolean myval = paymentIdstest.containsAll(Validator_cls.paymentidsset);
                Set<Id> paymentIds = new Set<Id>();
                if (triggerAction == CTDTM_Runnable.Action.AfterInsert)
                {
                    for(Payment__c p : (List<Payment__c>)listNew)
                    {
                        if (p.Status__c=='Approved' && p.Amount__c!=0)
                            paymentIds.add(p.Id); 
                    }
                }
                else if (triggerAction == CTDTM_Runnable.Action.AfterUpdate)
                {
                    for(Payment__c p : (List<Payment__c>)listNew)
                    {
                        if ((p.Status__c=='Approved') && (listOld[i].get('Status__c')!='Approved'))
                        {
                            if (p.Amount__c!=0)
                                paymentIds.add(p.Id);  
                        }
                    }
                }
                if (paymentIds!=null && paymentIds.size()>0)
                {
                   RollupHelper.createGiftDetails(paymentIds);
                }
            }
        }
        return null;
    }
}