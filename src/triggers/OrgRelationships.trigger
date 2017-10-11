trigger OrgRelationships on Organization_Relationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger.isInsert && Trigger.isBefore)
    {
        OrgRelationships process = new OrgRelationships(Trigger.new, Trigger.old, 0);
    }
    if( Trigger.isAfter && Trigger.isInsert )
    {
        OrgRelationships process = new OrgRelationships(Trigger.new, Trigger.old, 3);
    }
    if(Trigger.isUpdate && Trigger.isBefore)
    {
        OrgRelationships process = new OrgRelationships(Trigger.new, Trigger.old, 1);
    }
    if( Trigger.isAfter && Trigger.isUpdate )
    {
        OrgRelationships process = new OrgRelationships(Trigger.new, Trigger.old, 4);
    }
    if( Trigger.isAfter && Trigger.isUpdate )
    {
        OrgRelationships process = new OrgRelationships(Trigger.new, Trigger.old, 4);
    }
    if( Trigger.isAfter && Trigger.isDelete )
    {
        OrgRelationships process = new OrgRelationships(Trigger.old, null, 5);
    }   
}