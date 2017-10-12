/**
* @group TDTM
* @description Class that contains helper methods for the TDTM Trigger Handler logic.
*/
public class CTDTM_TriggerActionHelper {
    
    /*******************************************************************************************************
    * @description Determines which TDTM action applies, based on the trigger environment.
    * @param isBefore Are we in a before trigger context.
    * @param isAfter Are we in an after trigger context.
    * @param isInsert Are we in an insert trigger context.
    * @param isUpdate Are we in an update trigger context.
    * @param isDelete Are we in a delete trigger context.
    * @param isUndelete Are we in an undelete trigger context.
    * @return CTDTM_Runnable.Action The applicable action, based on the trigger environment.
    */
    public static CTDTM_Runnable.Action determineTriggerAction(Boolean isBefore, Boolean isAfter, Boolean isInsert,
    Boolean isUpdate, Boolean isDelete, Boolean isUnDelete) {
        if (isBefore) {
            if (isInsert) return CTDTM_Runnable.Action.BeforeInsert;
            else if (isUpdate) return CTDTM_Runnable.Action.BeforeUpdate;
            else return CTDTM_Runnable.Action.BeforeDelete;
        } else {
            if (isInsert) return CTDTM_Runnable.Action.AfterInsert;
            else if (isUpdate) return CTDTM_Runnable.Action.AfterUpdate;
            else if (isDelete) return CTDTM_Runnable.Action.AfterDelete;
            else return CTDTM_Runnable.Action.AfterUndelete;
        }
    }
    
    /*******************************************************************************************************
    * @description Get the TDTM Action from the action name.
    * @param name Name of the action.
    * @return CTDTM_Runnable.Action The TDTM Action with that name.
    */
    public static CTDTM_Runnable.Action getTriggerActionFromName(String name) {
        CTDTM_Runnable.Action ta;
    
        if (name == CTDTM_Runnable.Action.BeforeInsert.name())
           ta = CTDTM_Runnable.Action.BeforeInsert;
        else if(name == CTDTM_Runnable.Action.BeforeUpdate.name())
           ta = CTDTM_Runnable.Action.BeforeUpdate;
        else if(name == CTDTM_Runnable.Action.BeforeDelete.name())
           ta = CTDTM_Runnable.Action.BeforeDelete;
        else if(name == CTDTM_Runnable.Action.AfterInsert.name())
           ta = CTDTM_Runnable.Action.AfterInsert;
        else if(name == CTDTM_Runnable.Action.AfterUpdate.name())
           ta = CTDTM_Runnable.Action.AfterUpdate;
        else if(name == CTDTM_Runnable.Action.AfterDelete.name())
           ta = CTDTM_Runnable.Action.AfterDelete;
        else if(name == CTDTM_Runnable.Action.AfterUndelete.name())
           ta = CTDTM_Runnable.Action.AfterUndelete;
        return ta;
    }
}