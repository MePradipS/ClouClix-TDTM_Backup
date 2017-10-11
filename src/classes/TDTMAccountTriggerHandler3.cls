/**
* @group Accounts
* @description Trigger Handler on Accounts that handles ensuring the correct system flags are set on
* our special accounts (Household, One-to-One), and also detects changes on Household Account that requires
* name updating.
*/
public class TDTMAccountTriggerHandler3 extends TDTM_Runnable {
        
    
    /*******************************************************************************************************
    * @description Trigger Handler on Accounts that handles ensuring the correct system flags are set on
    * our special accounts (Household, One-to-One), and also detects changes on Household Account that requires
    * name updating.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) 
    {
        system.debug('Third handler has been excecuted...');
        return null;
    }
}