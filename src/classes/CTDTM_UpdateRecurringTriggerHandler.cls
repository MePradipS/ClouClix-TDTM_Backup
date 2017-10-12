public class CTDTM_UpdateRecurringTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of RecurringGifts from trigger new. 
    * @param listOld the list of RecurringGifts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for RecurringGifts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if(triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            List<Recurring_Donation__c> recurrings = new List<Recurring_Donation__c>();
            List<Recurring_Donation__c> changedRecurrings = new List<Recurring_Donation__c>();
            
            integer i = 0;
            for (Recurring_Donation__c rd : (List<Recurring_Donation__c>)listNew)
            {
                if ((rd.Amount__c != listOld[i].get('Amount__c')
                   || rd.Frequency__c != listOld[i].get('Frequency__c')
                   || rd.Status__c != listOld[i].get('Status__c')
                   && listOld[i].get('Status__c ')!= 'Cancelled'
                   && rd.Reference__c != null && rd.Reference__c != '' && !utilities.IsGatewayIatsOrEziDebit(rd.Reference__c)
                   && (Util.getDifferenceInSeconds(Datetime.now(), rd.CreatedDate) > 30)))
                {
                    recurrings.add(rd);
                }

                // check to see if the status has changed
                Recurring_Donation__c old = (Recurring_Donation__c)Util.FindObject(listOld, rd.Id, 'Id');
                if(old!=null && rd.Reference__c!=null){
                    if (old.Status__c == 'Active' && rd.Status__c == 'on Hold' && !utilities.IsGatewayIatsOrEziDebit(rd.Reference__c)) {
                        changedRecurrings.add(rd);
                    }
                        
                    if (old.Status__c == 'On Hold' && rd.Status__c == 'Active' && !utilities.IsGatewayIatsOrEziDebit(rd.Reference__c)) {
                        changedRecurrings.add(rd);
                    }
                } 
                i++;                    
            }

            if (recurrings.size() > 0)
            {
                if (!Test.isRunningTest())
                    Util.SubmitRecurringChanges(Util.SerializeRecurringItems(recurrings), 'RecurringUpdate');
            }

            if (changedRecurrings.size() > 0)
            {
                if (!Test.isRunningTest())
                    Util.SubmitRecurringChanges(Util.SerializeRecurringItems(changedRecurrings), 'EnableDisableProfile');  
            }
        }
            
        return null;
    }
}