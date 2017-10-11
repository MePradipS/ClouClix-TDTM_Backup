public class CTDTM_PreventDeleteOfAlloTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Allocations from trigger new. 
    * @param listOld the list of Allocations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Allocations 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.BeforeDelete)
        {
            App_Settings__c appSettings = App_Settings__c.getInstance();
                for(Gift_Detail__c g : (List<Gift_Detail__c>)listOld)
                {
                    if(g.Posted_to_Finance__c <> null && appSettings.Enable_Enhanced_Fund_Accounting__c == True)
                    {
                        g.addError('You can not delete this record because \'Enable Enhanced Fund Accounting\' is enabled in custom setting and \'Posted to Finance\' field is not blank!');
                    }
                }
        }
        return null;
    }
}