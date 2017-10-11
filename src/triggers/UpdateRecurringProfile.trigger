trigger UpdateRecurringProfile on Recurring_Donation__c(after update)
{
    List<Recurring_Donation__c> recurrings = new List<Recurring_Donation__c>();
    List<Recurring_Donation__c> changedRecurrings = new List<Recurring_Donation__c>();

    for (Recurring_Donation__c rd : trigger.new)
    {
        if ((rd.Amount__c != trigger.oldMap.get(rd.Id).Amount__c
           || rd.Frequency__c != trigger.oldMap.get(rd.Id).Frequency__c
           || rd.Status__c != trigger.oldMap.get(rd.Id).Status__c)
           && trigger.oldMap.get(rd.Id).Status__c != 'Cancelled'
           && rd.Reference__c != null && rd.Reference__c != '' && !utilities.IsGatewayIatsOrEziDebit(rd.Reference__c)
           && (Util.getDifferenceInSeconds(Datetime.now(), rd.CreatedDate) > 30))
        {
            recurrings.add(rd);
        }

        // check to see if the status has changed
        Recurring_Donation__c old = (Recurring_Donation__c)Util.FindObject(trigger.old, rd.Id, 'Id');
        if(old!=null && rd.Reference__c!=null){
        if (old.Status__c == 'Active' && rd.Status__c == 'on Hold' && !utilities.IsGatewayIatsOrEziDebit(rd.Reference__c)) {
            changedRecurrings.add(rd);
        }
            
        if (old.Status__c == 'On Hold' && rd.Status__c == 'Active' && !utilities.IsGatewayIatsOrEziDebit(rd.Reference__c)) {
            changedRecurrings.add(rd);
        }
        }   
    }

    if (recurrings.size() > 0)
    {
        if (!Test.isRunningTest()) {
            Util.SubmitRecurringChanges(Util.SerializeRecurringItems(recurrings), 'RecurringUpdate');
        }  
    }

    if (changedRecurrings.size() > 0)
    {
        if (!Test.isRunningTest()) {
            Util.SubmitRecurringChanges(Util.SerializeRecurringItems(changedRecurrings), 'EnableDisableProfile');
        }    
    }
}