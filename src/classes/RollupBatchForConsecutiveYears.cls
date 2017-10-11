global with sharing class RollupBatchForConsecutiveYears implements Database.Batchable<sObject>, Database.stateful{

    global List<Contact> contactRecord = new List<Contact>();
    global set<string> cid = new Set<string>();
    global DateTime previousRunTime;
    List<String> giftQueries = new List<String>();
    global RollupBatchForConsecutiveYears()
    {
    }
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        //get a list of constieunts whose gift is updated or created since the last run.
        if (previousRunTime == null) previousRunTime = DateTime.now().addHours(-24);
          return new ContactSelector().LocateRollupBatchForConsecutiveYears();
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Map<ID, Contact> scopeMap = new Map<ID, Contact>((List<Contact>)scope);
        List<Contact> contactToUpdate = new List<Contact>();
        Set<ID> contactIds = scopeMap.keySet();
        for(Contact c : (List<Contact>)scope){
            cid.add(c.id);
            contactRecord.add(c);
        }
    }
    // Reschedule the job for an hour from now
    global void finish(Database.BatchableContext BC)
    {
        RollupBatchforgift r = new RollupBatchforgift();
        r.cid1.addAll(cid);
        r.con.addAll(contactRecord);
        r.query = new GiftSelector().QueyrStringForRollUpConsecutive(cid);
        Database.executeBatch(r);
    }
}