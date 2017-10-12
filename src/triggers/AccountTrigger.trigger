trigger AccountTrigger on Account (after insert, after update, after delete, after undelete, before insert, before update, before delete) {
    App_Settings__c appSetting = App_Settings__c.getInstance();
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        OrgContactHandler.AutoNumber(Trigger.new, 'Account');
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        OrgContactHandler.PreventBucketModify(Trigger.old, Trigger.new);
    }        
    if (Trigger.isBefore && Trigger.isDelete) {
        OrgContactHandler.PreventBucketDelete(Trigger.old);
    }    
    if( Trigger.isAfter && Trigger.isDelete ){
        OrgRelationships.deleteEmptyRelationships();
    }    
    if (Trigger.isAfter && Trigger.isUpdate) {
        OrgContactHandler.CascadeHouseholdAddress(Trigger.old, Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        if(appSetting.Other_Address_Trigger_Setting__c){
            OrgContactHandler.LegacyAddress(Trigger.old, Trigger.new, 'Account');  
        }      
    }
}