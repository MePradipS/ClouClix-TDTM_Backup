global with sharing class RecurringProcessor implements Database.Batchable<sObject>,Database.AllowsCallouts  {

    global Database.Querylocator start(Database.BatchableContext BC)
    {
        return new GiftSelector().LocateActiveRecurringGift();
    }
    //uncommented by nitin
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        //create a list of tokens
        BatchGateway4.ArrayOfRecurringTransaction params = new BatchGateway4.ArrayOfRecurringTransaction();
        params.RecurringTransaction = new List<BatchGateway4.RecurringTransaction>();

        for(sObject o : scope) {
            Gift__c g = (Gift__c)o;
            if (!RollupHelper.IsEmptyOrNull(g.Recurring_Donation__r.Reference__c))
            {
                BatchGateway4.RecurringTransaction rt = new BatchGateway4.RecurringTransaction();
                rt.Amount = g.Recurring_Donation__r.Amount__c;
                rt.RecurringId = g.Recurring_Donation__r.Reference__c;
                params.RecurringTransaction.add(rt);
            }
        }

        //call GP Getway
        BatchGateway4.GatewaySoap gateway = RollupHelper.newGPServiceInstance();
        gateway.SubmitRecurring(params);

    }
    global void finish(Database.BatchableContext BC)
    {
    }
}