public class CTDTM_CopyDescriptionTriggerHandler  extends CTDTM_Runnable 
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
             Set<String> vpdIds = new Set<String>();
             Map<String, Role_Template__c> vpds = new Map<String, Role_Template__c>();
             for(Volunteer_Role__c vpdList : (List<Volunteer_Role__c >)listNew)
                {
                    vpdIds.add(vpdList.Role_Description_Templates__c);
                }

             for(Role_Template__c vpd : new RoleTemplateSelector().SelectVPDById(vpdIds))
                {
                    vpds.put(vpd.Id, vpd);
                }

             for (Volunteer_Role__c vp : (List<Volunteer_Role__c >)listNew)
                {
                    if (vp.Role_Description_Templates__c!= null)
                    {
                        vp.Role_Description__c= vpds.get(vp.Role_Description_Templates__c).Role_Description__c;
                        vp.Skills_Needed__c = vpds.get(vp.Role_Description_Templates__c).Skills_And_Experience__c;
                        vp.Materials_Needed__c = vpds.get(vp.Role_Description_Templates__c).Special_Requirements__c;
                        //vp.Qualifications__c = vpds.get(vp.Volunteer_Position_Description__c).Qualifications__c;
                        vp.Tasks__c = vpds.get(vp.Role_Description_Templates__c).Role_Tasks__c;
                        vp.Training_Provided__c = vpds.get(vp.Role_Description_Templates__c).Training_Provided__c ;
                    }
                }
        }
        return null;
    }
}