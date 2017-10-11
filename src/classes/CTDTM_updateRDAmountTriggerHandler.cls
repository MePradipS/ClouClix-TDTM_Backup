public class CTDTM_updateRDAmountTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of RecurringGiftAllocations from trigger new. 
    * @param listOld the list of RecurringGiftAllocations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for RecurringGiftAllocations 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        Set<ID> theRDsIDs = new Set<ID>();
        if (triggerAction == CTDTM_Runnable.Action.AfterDelete)
        {
            for (RD_Allocation__c rda : (List<RD_Allocation__c>)listOld)
            {
                theRDsIDs.add(rda.Recurring_Gift__c);
            }
        }
        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterInsert)
        {
            for (RD_Allocation__c rda : (List<RD_Allocation__c>)listNew)
            {
                theRDsIDs.add(rda.Recurring_Gift__c);
            }
        }

        Decimal sum;

        String inFields = Converter.ConvertListSetToString(theRDsIDs);
        String clause = ' WHERE Id IN ('+ inFields +') FOR UPDATE';
        String subClause = ' WHERE Active__c = TRUE';

        List<Recurring_Donation__c> theRDs = new GenericQueryBuilder().QueryBuilderWithSubQuery(Recurring_Donation__c.sObjectType, 'Id,'+ Utilities.PackageNamespace + 'Amount__c', clause, RD_Allocation__c.sObjectType, 'Recurring_Gift_Allocations__r', ''+ Utilities.PackageNamespace + 'Amount__c,'+ Utilities.PackageNamespace + 'Recurring_Gift__c', subClause);
        for (Recurring_Donation__c rd : theRDs)
        {
            sum = 0;
            for (RD_Allocation__c rda : rd.Recurring_Gift_Allocations__r)
            {
                if (rda.Amount__c != null && rda.Amount__c != 0) {
                    sum += rda.Amount__c;
                }
            }
            rd.Amount__c = sum;
        }
        DMLManager.UpdateSObjects(theRDs);
        return null;
    }
        
}