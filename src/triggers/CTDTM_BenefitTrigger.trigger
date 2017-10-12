trigger CTDTM_BenefitTrigger on Benefit__c (after delete, after insert, after undelete, 
    after update, before delete, before insert, before update) {

    CTDTM_TriggerHandler handler = new CTDTM_TriggerHandler();  
    handler.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, 
        Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.Benefit__c, 
        new CTDTM_ObjectDataGateway());
}