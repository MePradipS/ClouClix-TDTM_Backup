trigger TDTM_AccountTrigger on Account (after delete, after insert, after undelete, 
    after update, before delete, before insert, before update) {

    TDTM_TriggerHandler handler = new TDTM_TriggerHandler();  
    handler.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, 
        Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.Account, 
        new TDTM_ObjectDataGateway());
}