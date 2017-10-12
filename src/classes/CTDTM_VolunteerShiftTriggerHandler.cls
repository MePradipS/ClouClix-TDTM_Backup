public class CTDTM_VolunteerShiftTriggerHandler extends CTDTM_Runnable 
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
        if (triggerAction == CTDTM_Runnable.Action.BeforeInsert) 
        {
            //collect Ids
            Set<string> vpIds = new Set<string>();
            Map<String, String> vp_to_app = new Map<String, String>();

            for (Volunteer_Shift__c vps : (list<Volunteer_Shift__c>)listNew)
            {
                vpIds.add(vps.Volunteer_Role__c);
            }

            //map Position to App (first or default)
            String inFields = Converter.ConvertListSetToString(vpIds);
            String clause = ' WHERE Id IN ('+ inFields +')';
            String subClause = ' WHERE Status__c = \'Placed\'';

            List<Volunteer_Role__c> vol_pos = new GenericQueryBuilder().QueryBuilderWithSubQuery(Volunteer_Role__c.sObjectType, 'Id', clause, Volunteer_Application__c.sObjectType, 'Volunteer_Applications__r', 'Id', subClause);
            for (Volunteer_Role__c vp : vol_pos)
            {
                if (vp.Volunteer_Applications__r.size() > 0)
                {
                    vp_to_app.put(vp.Id, vp.Volunteer_Applications__r[0].Id);
                }
            }

            //assign app to Shift's app lookup
            for (Volunteer_Shift__c vps : (list<Volunteer_Shift__c>)listNew)
            {
                vps.Volunteer_Application__c = vp_to_app.get(vps.Volunteer_Role__c);
            }
        }

        return null;
    }
}