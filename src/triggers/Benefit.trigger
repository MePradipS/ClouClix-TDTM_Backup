trigger Benefit on Benefit__c (after insert, after update, after delete, after undelete) {
    
    if (Trigger.IsUpdate) {
        BenefitHandler.UpdateEventLevels(Trigger.new);                        
    }
    
}