/**
* @author Salesforce.com Foundation
* @date 2014
*
* @group Accounts
* @group-content ../../ApexDocContent/Accounts.htm
*
* @description Trigger Handler on Accounts that handles ensuring the correct system flags are set on
* our special accounts (Household, One-to-One), and also detects changes on Household Account that requires
* name updating.
*/
trigger RollupOppStatus on Volunteer_Role__c (after insert, after update, after delete) {
    Set<String> oppIds = new Set<String>();
    
    if (Trigger.IsInsert || Trigger.IsUpdate)
    {
        for (Volunteer_Role__c vp : Trigger.new)
        {
            oppIds.add(vp.Volunteer_Opportunity__c);
        }
    }

    if (Trigger.IsDelete)
    {
        for (Volunteer_Role__c vp : Trigger.old)
        {
            oppIds.add(vp.Volunteer_Opportunity__c);
        }    
    }

    VolunteerUtil.RecalculateOpportunityStatus(oppIds);
}