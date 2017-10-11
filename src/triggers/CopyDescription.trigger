trigger CopyDescription on Volunteer_Role__c (before insert) {

    Set<String> vpdIds = new Set<String>();
    Map<String, Role_Template__c> vpds = new Map<String, Role_Template__c>();
    for(Volunteer_Role__c vpdList : Trigger.new)
    {
        vpdIds.add(vpdList.Role_Description_Templates__c);
    }

    for(Role_Template__c vpd : new RoleTemplateSelector().SelectVPDById(vpdIds))
    {
        vpds.put(vpd.Id, vpd);
    }

    for (Volunteer_Role__c vp : Trigger.new)
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