public class CTDTM_RollUpExitDetailsTriggerHandler  extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Contacts from trigger new. 
    * @param listOld the list of Contacts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Contacts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
                                   CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {  
        if(triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            Set<String> CIDs = new Set<String>();
            Map<String, Volunteer_Application__c> vol_to_app = new Map<String, Volunteer_Application__c>();

            for (Volunteer_Application__c va : (list<Volunteer_Application__c>)listNew)
            {
                if (va.Status__c == 'Exited') { CIDs.add(va.Volunteer__c); vol_to_app.put(va.Volunteer__c, va); }
            }

            List<Contact> theContacts = new ContactSelector().SelectContactExitDetails(Utilities.ConvertStringSetToIdSet(CIDs));

            for (Contact c : theContacts)
            {
                if (vol_to_app.containsKey(c.Id)) { c.Reason_for_Last_Exit__c = vol_to_app.get(c.Id).Reason_for_Exit__c; }
                if (vol_to_app.containsKey(c.Id)) { c.Date_of_Last_Exit__c = vol_to_app.get(c.Id).Service_Exit_Date__c; }
                if (vol_to_app.containsKey(c.Id)) { c.Last_Role_Exited__c= vol_to_app.get(c.Id).Volunteer_Role__c; }
            }

            if (theContacts != null && theContacts.size() > 0) 
            {
                DMLManager.UpdateSObjects(theContacts);
            }
        }
        return null;
    }
}