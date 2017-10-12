trigger IsParent on Campaign (before update, before insert) {

    List<RecordType> rt = new RecordTypeSelector().SelectRecordsByNameNamespacePrefixAndName(Utilities.getCurrentNamespace(), 'Campaign');

    Set<String> CIDs = new Set<String>();
    Map<String, String> cmp_to_par_rt = new Map<String, String>();

    for (Campaign c : Trigger.new)
    {
        CIDs.add(c.ParentId);
    }

    for (Campaign c : new CampaignSelector().SelectIdById(Utilities.ConvertStringSetToIdSet(CIDs)))
    {
        cmp_to_par_rt.put(c.Id, c.RecordTypeId);
    }

    if (rt.size() > 0)
    {
        for (Campaign c : Trigger.new)
        {
            if (cmp_to_par_rt.get(c.ParentId) == rt[0].Id)
            { c.ParentAppeal__c = True; }

            if (cmp_to_par_rt.get(c.ParentId) != rt[0].Id)
            { c.ParentAppeal__c = False; }
        }
    }
}