trigger TriggerRecurringPayment on Payment__c (after insert, after update) {
    Set<Id> paymentIdstest = new Set<Id>(trigger.newMap.keyset());
    if(Validator_cls.paymentidsset.isEmpty() || !(paymentIdstest.containsAll(Validator_cls.paymentidsset) ))  
    {   
      
        Boolean myval = paymentIdstest.containsAll(Validator_cls.paymentidsset);
        Set<Id> paymentIds = new Set<Id>();
       
        if (trigger.isInsert)
        {
            for(Payment__c p : trigger.new)
             if (p.Status__c=='Approved' && p.Amount__c!=0)
                paymentIds.add(p.Id); 
        }
        else if (trigger.isUpdate)
        {
            for(Payment__c p : trigger.new)
                if ((p.Status__c=='Approved') && (trigger.oldMap.get(p.Id).Status__c!='Approved'))
                {
                    if (p.Amount__c!=0)
                        paymentIds.add(p.Id);  
                }
        }
        
        if (paymentIds!=null && paymentIds.size()>0)
        {
           RollupHelper.createGiftDetails(paymentIds);
        }
    }
}