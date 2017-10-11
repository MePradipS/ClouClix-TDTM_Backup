trigger IssueGiftReceipt on Receipt__c (after insert) {
   set<Id> acccontids = new set<Id>();
   Map<Id, Account> accountRecord = new Map<Id, Account>();
   Map<Id, Contact> contactRecord = new Map<Id, Contact>();
   boolean isAccount = false;
   if(System.isFuture()) return;
   App_Settings__c appSetting = App_Settings__c.getInstance(UserInfo.getOrganizationId());
   
    if(appSetting != null && !appSetting.Use_Workflows_for_Sending_Receipts__c)
     {
        Boolean isIssue = true;
        for(Receipt__c r : trigger.new) {
            if(r.sysConsolidatedJob__c != null && r.sysConsolidatedJob__c == true)
                isIssue = false;
        }
        if(isIssue == true) {
           RollupHelper.issueReceipts( trigger.newMap.keySet());
        }
    
    }
}