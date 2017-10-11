public class CTDTM_checkDuplicateGiftTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of GiftBatches from trigger new. 
    * @param listOld the list of GiftBatches from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for GiftBatches 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.BeforeInsert) 
        {
            Set<String> giftBatchName = new Set<String>();
            for(Gift_Batch__c g : (List<Gift_Batch__c>)listNew)
            {
                giftBatchName.add(g.Name__c);
            }
            List<Gift_Batch__c> giftBatchRecordList = new GiftBatchSelector().SelectGiftNameByName(giftBatchName);

            if(giftBatchRecordList.size() > 0)
            {
                for(Gift_Batch__c giftBatch : (List<Gift_Batch__c>)listNew)
                {
                    for(Gift_Batch__c giftBatchList : giftBatchRecordList)
                    {
                        if(giftBatch.Name__c == giftBatchList.Name__c)
                        {
                            giftBatch.addError('Name already Exist!'); //
                        }
                    }
                }
            }
       }
       return null;
    }
}