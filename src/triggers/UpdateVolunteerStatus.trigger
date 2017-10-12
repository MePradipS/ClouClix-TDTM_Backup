trigger UpdateVolunteerStatus on Volunteer_Application__c (after update, after insert) {
    List<Volunteer_Application__c> newApps = Trigger.new;
    Map<String, String> con_to_status = new Map<String, String>();
    Set<String> ConIds = new Set<String>();

    if(Trigger.IsInsert)
    {
        for (Integer i = 0; i < Trigger.new.size(); i++)
        {
            if (newApps[i].Status__c == 'Submitted / In-Screening')
            {
                ConIds.add(newApps[i].Volunteer__c);
                con_to_status.put(newApps[i].Volunteer__c, 'Applicant');
            }
        }
    }

    if(Trigger.IsUpdate)
    {
        List<Volunteer_Application__c> oldApps = Trigger.old;

        for (Integer i = 0; i < Trigger.new.size(); i++)
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

    if (theContacts != null && theContacts.size() > 0) {
        DMLManager.UpdateSObjects(theContacts);
    }
}