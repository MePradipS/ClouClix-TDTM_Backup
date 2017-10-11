trigger RollUpExitDetails on Volunteer_Application__c (after update) {
    Set<String> CIDs = new Set<String>();
    Map<String, Volunteer_Application__c> vol_to_app = new Map<String, Volunteer_Application__c>();

    for (Volunteer_Application__c va : Trigger.new)
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

    if (theContacts != null && theContacts.size() > 0) {
        DMLManager.UpdateSObjects(theContacts);
    }
}