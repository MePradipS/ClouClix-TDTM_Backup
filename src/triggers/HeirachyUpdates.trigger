trigger HeirachyUpdates on Gift_Detail__c (before insert, before update) {
    App_Settings__c settings = App_Settings__c.getInstance();
    Set<String> GDIDs = new Set<String>();
    Map<String, Id> rt_map = new Map<String, Id>();

    rt_map.put('Campaign', settings.Campaign_RecordType_Id__c);
    rt_map.put('Appeal', settings.Appeal_RecordType_Id__c);

    for (Gift_Detail__c gd : Trigger.new)
    {
        GDIDs.add(gd.New_Campaign__c);
    }

    if (GDIDs.size() > 0)
    {
        Map<Id, Campaign> camp_map = new Map<Id, Campaign>(new CampaignSelector().SelectParentIds(GDIDs));

        for (Gift_Detail__c gd : Trigger.new)
        {
            if (camp_map.get(gd.New_Campaign__c) != null)
            {
                if (camp_map.get(gd.New_Campaign__c).Parent.RecordTypeId == rt_map.get('Campaign'))
                {
                    gd.Campaign__c = camp_map.get(gd.New_Campaign__c).ParentId;
                }
                if (camp_map.get(gd.New_Campaign__c).Parent.RecordTypeId == rt_map.get('Appeal'))
                {
                    gd.Campaign__c = camp_map.get(gd.New_Campaign__c).Parent.ParentId;
                    gd.Parent_Appeal__c = camp_map.get(gd.New_Campaign__c).ParentId;
                }
            }
        }
    }
}