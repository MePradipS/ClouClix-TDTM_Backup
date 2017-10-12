public class CTDTM_CloneBatchTempOnTriggerHandler extends CTDTM_Runnable 
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
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert) 
        {
            set<Id> triggerNewMapId = new set<Id>();
            for(Gift_Batch__c objGift : (List<Gift_Batch__c>)listNew)
            {
                triggerNewMapId.add(objGift.id);
            }
            String namespacePrefix = Utilities.getCurrentNamespace();
            String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
            List<RecordType> RTList = new RecordTypeSelector().SelectRecordTypeBySObjectAndName(namespaceFieldPrefix + 'Batch_Template__c', 'Cloned');
            RecordType RT;

            if (RTList != null && RTList.size() > 0)
              RT = RTList[0];

            Map<Id, List<Gift_Batch__c>> giftBatchMap = new Map<Id, List<Gift_Batch__c>>();
            Map<Id, Batch_Template__c> templateMap = new Map<Id, Batch_Template__c>();

            for(Gift_Batch__c gb : new GiftBatchSelector().SelectByKeySet(triggerNewMapId))
            {
                if(giftBatchMap.get(gb.Template_Name__c) != null)
                    giftBatchMap.get(gb.Template_Name__c).add(gb);
                else {
                    List<Gift_Batch__c> gbs = new List<Gift_Batch__c>();
                    gbs.add(gb);
                    giftBatchMap.put(gb.Template_Name__c, gbs);
                }
            }

            for(Batch_Template__c temp : new BatchTemplateSelector().SelectAllById(giftBatchMap.keySet())) {
                for(Gift_Batch__c g : giftBatchMap.get(temp.Id)) {
                    Batch_Template__c newTemp = temp.clone(false, true, false, true);
                    newTemp.RecordTypeId = RT.Id;
                    templateMap.put(g.Id, newTemp);
                }
            }

            if (templateMap.isEmpty() == false)
                DMLManager.InsertSObjects(templateMap.values());

            List<Gift_Batch__c> giftBatches = new List<Gift_Batch__c>();

            for(Id id : giftBatchMap.keySet()) {
                for(Gift_Batch__c g : giftBatchMap.get(id)) {
                    if(templateMap.get(g.Id) != null) {
                        g.Template_Name__c = templateMap.get(g.Id).Id;
                        giftBatches.add(g);
                    }
                }
            }

            if (giftBatches != null && giftBatches.size() > 0)
                DMLManager.UpdateSObjects(giftBatches);
        }
        return null;
    }
}