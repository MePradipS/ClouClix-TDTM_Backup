trigger RefundAllocations on Payment__c (after insert) {  
    Set<String> refundedPaymentIds = new Set<String>();
    Set<String> refundPaymentIds = new Set<String>();    
    Map<String, List<Gift_Detail__c>> payment_to_allocations = new Map<String, List<Gift_Detail__c>>();
    Map<String, Decimal> payment_to_amount = new Map<String, Decimal>();    
    List<Gift_Detail__c> allocationsToInsert = new List<Gift_Detail__c>();
    
    for (Payment__c p : Trigger.new)
    {
        if (p.Payment_Refunded__c == null || p.Status__c != 'Refunded')
        { continue; }
        
        refundPaymentIds.add(p.Id);
        refundedPaymentIds.add(p.Payment_Refunded__c);
    }
    if (refundPaymentIds.size() == 0 || refundedPaymentIds.size() == 0) { return; }
    RollupHelper.RefundAllocationsMethod(refundedPaymentIds, refundPaymentIds);
}