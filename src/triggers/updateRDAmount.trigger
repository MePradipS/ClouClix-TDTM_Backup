trigger updateRDAmount on RD_Allocation__c (after update, after insert, after delete) {
    Set<ID> theRDsIDs = new Set<ID>();
    if (Trigger.isDelete)
    {
        for (RD_Allocation__c rda : Trigger.old)
        {
            theRDsIDs.add(rda.Recurring_Gift__c);
        }
    }
    if(Trigger.isUpdate || Trigger.isInsert)
    {
        for (RD_Allocation__c rda : Trigger.new)
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
}