public class CTDTM_RefundAllocationsTriggerHandler  extends CTDTM_Runnable 
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
        if(triggerAction == CTDTM_Runnable.Action.AfterInsert)
        {
            Set<String> refundedPaymentIds = new Set<String>();
            Set<String> refundPaymentIds = new Set<String>();    
            Map<String, List<Gift_Detail__c>> payment_to_allocations = new Map<String, List<Gift_Detail__c>>();
            Map<String, Decimal> payment_to_amount = new Map<String, Decimal>();    
            List<Gift_Detail__c> allocationsToInsert = new List<Gift_Detail__c>();
            
            for (Payment__c p :  (List<Payment__c>)listNew)
            {
                if (p.Payment_Refunded__c == null || p.Status__c != 'Refunded')
                    { continue; }
                    refundPaymentIds.add(p.Id);
                    refundedPaymentIds.add(p.Payment_Refunded__c);
            }
            if (refundPaymentIds.size() == 0 || refundedPaymentIds.size() == 0) 
            { 
                return null;
            }
            RollupHelper.RefundAllocationsMethod(refundedPaymentIds, refundPaymentIds);
        }
        return null;
    }
}