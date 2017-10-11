trigger RollupHours on Volunteer_Hours__c(after delete, after insert, after undelete, 
after update) {
    
    Set<String> HourIDs = new Set<String>();
    
    if (Trigger.isDelete)
    {
         for(Volunteer_Hours__c vh: trigger.old) 
         {
             if (!VolunteerUtil.isEmptyOrNull(vh.Id) && !HourIDs.contains(vh.Id))
             HourIDs.add(vh.Id);     
         }
    }
    else
    {
         for(Volunteer_Hours__c vh : trigger.new) 
         {
             if (!VolunteerUtil.isEmptyOrNull(vh.Id) && !HourIDs.contains(vh.Id))
             HourIDs.add(vh.Id);     
         }
    }
    
    if (HourIDs.size()>0)
    { 
        VolunteerUtil.RollupHours(HourIDs);
    }
}