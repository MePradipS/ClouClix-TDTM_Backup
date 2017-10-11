/**
* @group TDTM
* @description Class that contains helper methods for the TDTM Trigger Handler logic.
*/
public class TDTM_TriggerActionHelper {
    
    /*******************************************************************************************************
    * @description Determines which TDTM action applies, based on the trigger environment.
    * @param isBefore Are we in a before trigger context.
    * @param isAfter Are we in an after trigger context.
    * @param isInsert Are we in an insert trigger context.
    * @param isUpdate Are we in an update trigger context.
    * @param isDelete Are we in a delete trigger context.
    * @param isUndelete Are we in an undelete trigger context.
    * @return TDTM_Runnable.Action The applicable action, based on the trigger environment.
    */
    public static TDTM_Runnable.Action determineTriggerAction(Boolean isBefore, Boolean isAfter, Boolean isInsert,
    Boolean isUpdate, Boolean isDelete, Boolean isUnDelete) {
        if (isBefore) {
            if (isInsert) return TDTM_Runnable.Action.BeforeInsert;
            else if (isUpdate) return TDTM_Runnable.Action.BeforeUpdate;
            else return TDTM_Runnable.Action.BeforeDelete;
        } else {
            if (isInsert) return TDTM_Runnable.Action.AfterInsert;
            else if (isUpdate) return TDTM_Runnable.Action.AfterUpdate;
            else if (isDelete) return TDTM_Runnable.Action.AfterDelete;
            else return TDTM_Runnable.Action.AfterUndelete;
        }
    }
    
    /*******************************************************************************************************
    * @description Get the TDTM Action from the action name.
    * @param name Name of the action.
    * @return TDTM_Runnable.Action The TDTM Action with that name.
    */
    public static TDTM_Runnable.Action getTriggerActionFromName(String name) {
        TDTM_Runnable.Action ta;
    
        if (name == TDTM_Runnable.Action.BeforeInsert.name())
           ta = TDTM_Runnable.Action.BeforeInsert;
        else if(name == TDTM_Runnable.Action.BeforeUpdate.name())
           ta = TDTM_Runnable.Action.BeforeUpdate;
        else if(name == TDTM_Runnable.Action.BeforeDelete.name())
           ta = TDTM_Runnable.Action.BeforeDelete;
        else if(name == TDTM_Runnable.Action.AfterInsert.name())
           ta = TDTM_Runnable.Action.AfterInsert;
        else if(name == TDTM_Runnable.Action.AfterUpdate.name())
           ta = TDTM_Runnable.Action.AfterUpdate;
        else if(name == TDTM_Runnable.Action.AfterDelete.name())
           ta = TDTM_Runnable.Action.AfterDelete;
        else if(name == TDTM_Runnable.Action.AfterUndelete.name())
           ta = TDTM_Runnable.Action.AfterUndelete;
        return ta;
    }
}