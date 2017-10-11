trigger TransactionBenefit on Transaction_Benefit__c (after insert, after update, after delete, after undelete) {
    if (Trigger.IsDelete) {
        TransactionBenefitHandler.RollupTotals(Trigger.old);
    }
    else {    
        TransactionBenefitHandler.RollupTotals(Trigger.new);
    }
}