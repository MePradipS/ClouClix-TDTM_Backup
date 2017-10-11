public class CTDTM_AssignShiftsTriggerHandler extends CTDTM_Runnable 
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
            Map<String, Volunteer_Application__c> position_to_app = new Map<String, Volunteer_Application__c>();
            Set<String> Pids = new Set<String>();
            
            list<Volunteer_Application__c> TriggerNew = (list<Volunteer_Application__c>)listNew;
            list<Volunteer_Application__c> TriggerOld = (list<Volunteer_Application__c>)listOld;
            
            for (Integer i = 0; i < TriggerNew.size(); i++)
            {
                if (TriggerNew[i].Status__c == 'Placed' && TriggerOld[i].Status__c != 'Placed')
                { 
                    Pids.add(TriggerNew[i].Volunteer_Role__c);             
                    position_to_app.put(TriggerNew[i].Volunteer_Role__c, TriggerNew[i]);
                }
            }
            
            List<Volunteer_Shift__c> theShifts = new VolunteerShiftSelector().SelectVolunteerWhereRoleInIds(Pids);
            
            for (Volunteer_Shift__c shift : theShifts)
            {
                if (shift.Volunteer__c == position_to_app.get(shift.Volunteer_Role__c).Volunteer__c) 
                {
                    shift.Volunteer_Application__c = position_to_app.get(shift.Volunteer_Role__c).Id;
                }
            }
            
            if (theShifts != null && theShifts.size() > 0) 
            {
                DMLManager.UpdateSObjects(theShifts);
            }
        }
        
        return null;
    }
}