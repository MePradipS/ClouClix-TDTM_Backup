public class AccountTriggerHandler1 extends TDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == TDTM_Runnable.Action.BeforeInsert) 
        {
            OrgContactHandler.AutoNumber(listNew, 'Account');
        }
        if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) 
        {
            OrgContactHandler.AutoNumber(listNew, 'Account');
            OrgContactHandler.PreventBucketModify(listOld, listNew);
        }
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) 
        {
            OrgContactHandler.CascadeHouseholdAddress(listOld, listNew);
            
            App_Settings__c appSetting = App_Settings__c.getInstance();
            if(appSetting.Other_Address_Trigger_Setting__c)
            {
                OrgContactHandler.LegacyAddress(listOld, listNew, 'Account');  
            }
        }
        return null;
    }
}