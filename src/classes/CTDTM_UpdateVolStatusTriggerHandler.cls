public class CTDTM_UpdateVolStatusTriggerHandler  extends CTDTM_Runnable 
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
        List<Volunteer_Application__c> newApps = (list<Volunteer_Application__c>)listNew;
        Map<String, String> con_to_status = new Map<String, String>();
        Set<String> ConIds = new Set<String>();

        if (triggerAction == CTDTM_Runnable.Action.AfterInsert)
        {
            for (Integer i = 0; i < newApps.size(); i++)
            {
                if (newApps[i].Status__c == 'Submitted / In-Screening')
                {
                    ConIds.add(newApps[i].Volunteer__c);
                    con_to_status.put(newApps[i].Volunteer__c, 'Applicant');
                }
            }
        }

        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            List<Volunteer_Application__c> oldApps = (list<Volunteer_Application__c>)listOld;

            for (Integer i = 0; i < newApps.size(); i++)
            {
                if (oldApps[i].Status__c == 'Submitted / In-Screening' && newApps[i].Status__c == 'Screening Complete')
                {
                    ConIds.add(newApps[i].Volunteer__c);
                    con_to_status.put(newApps[i].Volunteer__c, 'In Screening');
                }

                if (oldApps[i].Status__c != 'Placed' && newApps[i].Status__c == 'Placed' &&
                    (newApps[i].Program_Specific_Training_Status__c == 'To Be Done'))
                {
                    ConIds.add(newApps[i].Volunteer__c);
                    con_to_status.put(newApps[i].Volunteer__c, 'In Training');
                }

                if (newApps[i].Status__c == 'Placed' &&
                    ((newApps[i].Program_Specific_Training_Status__c == 'Completed' || newApps[i].Program_Specific_Training_Status__c == 'Not Required')))
                {
                    ConIds.add(newApps[i].Volunteer__c);
                    con_to_status.put(newApps[i].Volunteer__c, 'Active');
                }
            }
        }

        List<Contact> theContacts = new ContactSelector().SelectVolunteerStatusById(Utilities.ConvertStringSetToIdSet(ConIds));

        for (Contact c : theContacts)
        {
            if (c.Volunteer_Status__c == 'Active') { continue; }
            c.Volunteer_Status__c = con_to_status.get(c.Id);
        }

        if (theContacts != null && theContacts.size() > 0) 
        {
            DMLManager.UpdateSObjects(theContacts);
        }
        return null;
    }
}