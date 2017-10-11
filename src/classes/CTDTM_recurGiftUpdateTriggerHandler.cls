public class CTDTM_recurGiftUpdateTriggerHandler  extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of payment from trigger new. 
    * @param listOld the list of payment from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for payment 
    * @return dmlWrapper.  always null.
    
    On the "Recurring Gift" record, display payment summary new fields:
    1). Declined Payments (Declined_Payments__c):
        a). For All Transactions with Status = Active
        b). Count all Payments with Status = Declined
    2). Consecutive Declined Payments (Consecutive_Declined_Payments__c)
        a). If last Payment.Status = Declined then
        b). count all consecutive payment records with Status = Declined
    3). Approved Payments (Approved_Payments__c)
        a). For All Transactions with Status = Active
        b). Count all Payments with Status = Approved
    Trigger roll up Payment records for the most recent Active Transactions into "Recurring Gift" record.

    payment.Status__c <> Trigger.oldMap.get(payment.id).Status__c &&

********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
                                   CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterDelete)
        {
            BatchSettings__c settings = BatchSettings__c.getInstance('Default');
            if(settings != null && !settings.Data_Migration_Mode__c)
            {
                Set<Id> transactionIds = new Set<Id>();
                Set<Id> recurringGiftIds = new Set<Id>();
                Set<Id> transctionsIds = new Set<Id>();
                Map<Id, Map<Id, List<Payment__c>>> recurringGiftMap = new Map<Id, Map<Id, List<Payment__c>>>();
                
                if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate) // check Condition if inserting new payment record or updating existing payment record
                {  
                    integer i=0;
                    for(Payment__c payment : (List<Payment__c>)listNew)
                    {
                        // check condition wheather the payment status is 'Approved' or 'Declined' or status was 'Approved' or 'Declined'
                        if(triggerAction == CTDTM_Runnable.Action.AfterInsert && (payment.Status__c == 'Approved' || payment.Status__c == 'Declined') ){

                            transactionIds.add(payment.Donation__c); //adding Gift ID into set of Id type

                        }
                        if(triggerAction == CTDTM_Runnable.Action.AfterUpdate && (payment.Status__c == 'Approved' || payment.Status__c == 'Declined' || listOld[i].get('Status__c') == 'Approved' || listOld[i].get('Status__c')  == 'Declined'))
                        {
                            transactionIds.add(payment.Donation__c); //adding Gift ID into set of Id type
                        }
                        i++;
                    }
                }
                if(triggerAction == CTDTM_Runnable.Action.AfterDelete){    // Condition to check if deleting a payment record
                    for(Payment__c payment : (List<Payment__c>)listOld){
                        if(payment.Status__c == 'Approved' || payment.Status__c == 'Declined'){ // check condition wheather the payment status is 'Approved' or 'Declined'
                            transactionIds.add(payment.Donation__c);    //adding Gift Id into set of Id type
                        }
                    }
                }
                if(transactionIds.size() > 0)
                {
                    recurringGiftFieldUpdateTriggerclass.recurringGiftFieldUpdateSwitcher(transactionIds);
                }
            }
        }
        return null;
    }
}