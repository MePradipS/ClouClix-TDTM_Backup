public class CTDTM_BatchTemplateTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of BatchTemplates from trigger new. 
    * @param listOld the list of BatchTemplates from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for BatchTemplates 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.BeforeInsert) 
        {
            List<RecordType> rtype = new RecordTypeSelector().SelectRecordsByNameNamespacePrefixAndName(Utilities.getCurrentNamespace(), 'Parent');
            Set<String> batchTemplateName = new Set<String>();
            for(Batch_Template__c b : (List<Batch_Template__c>)listNew){
                batchTemplateName.add(b.Name);
            }

            if (rtype.size() > 0)
            {
                List<Batch_Template__c> batchTemplateRecordList = new BatchTemplateSelector().SelectBatchTemplateByNameAndId(batchTemplateName, rtype[0].id);

                if(batchTemplateRecordList.size() > 0){
                    for(Batch_Template__c batchTemplate : (List<Batch_Template__c>)listNew){
                        for(Batch_Template__c batchTemplateList : batchTemplateRecordList){
                            if(batchTemplate.Name == batchTemplateList.Name && batchTemplate.RecordTypeId == rtype[0].id){
                                batchTemplate.addError('The Gift Batch Template Name you entered already exists. Please enter a unique name.');
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
}