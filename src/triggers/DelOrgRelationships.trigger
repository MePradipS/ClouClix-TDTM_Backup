trigger DelOrgRelationships on Account (after delete) {

    public enum triggerAction {beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete}

    if( Trigger.isAfter && Trigger.isDelete ){
        OrgRelationships.deleteEmptyRelationships();
    }
}