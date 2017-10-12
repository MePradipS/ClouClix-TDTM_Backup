public class CTDTM_IssueGiftReceiptTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Receipts from trigger new. 
    * @param listOld the list of Receipts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Receipts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert)
        {
               set<Id> triggerNewMapId = new set<Id>();
               for(Receipt__c objReceipt : (List<Receipt__c>)listNew)
               {
                   triggerNewMapId.add(objReceipt.Id);
               }
               set<Id> acccontids = new set<Id>();
               Map<Id, Account> accountRecord = new Map<Id, Account>();
               Map<Id, Contact> contactRecord = new Map<Id, Contact>();
               boolean isAccount = false;
               if(System.isFuture()) 
                   return null;
               App_Settings__c appSetting = App_Settings__c.getInstance(UserInfo.getOrganizationId());
               
                if(appSetting != null && !appSetting.Use_Workflows_for_Sending_Receipts__c)
                 {
                    Boolean isIssue = true;
                    for(Receipt__c r : (List<Receipt__c>)listNew) 
                    {
                        if(r.sysConsolidatedJob__c != null && r.sysConsolidatedJob__c == true)
                            isIssue = false;
                    }
                    if(isIssue == true)
                    {
                       RollupHelper.issueReceipts(triggerNewMapId);
                    }
                
                }
        }
        
        return null;
   }    
    
}