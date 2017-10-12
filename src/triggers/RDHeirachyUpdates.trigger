trigger RDHeirachyUpdates on RD_Allocation__c (before insert, before update) {
    List<RecordType> rts = new RecordTypeSelector().SelectRecordBySObjectAndNamespace('Campaign', Utilities.getCurrentNamespace());
    Set<String> GDIDs = new Set<String>();
    Map<String, Id> rt_map = new Map<String, Id>();

    for (RecordType rt : rts)
    {
        rt_map.put(rt.Name, rt.Id);
    }

    for (RD_Allocation__c gd : Trigger.new)
    {
        GDIDs.add(gd.New_Campaign__c);
    }

    if (GDIDs.size() > 0)
    {
        Map<Id, Campaign> camp_map = new Map<Id, Campaign>(new CampaignSelector().SelectParentIds(GDIDs));

        for (RD_Allocation__c gd : Trigger.new)
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