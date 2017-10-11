trigger checkDuplicateBatchTemplateNameTrigger on Batch_Template__c (before insert) {
    List<RecordType> rtype = new RecordTypeSelector().SelectRecordsByNameNamespacePrefixAndName(Utilities.getCurrentNamespace(), 'Parent');
    Set<String> batchTemplateName = new Set<String>();
    for(Batch_Template__c b : Trigger.New){
        batchTemplateName.add(b.Name);
    }

    if (rtype.size() > 0)
    {
        List<Batch_Template__c> batchTemplateRecordList = new BatchTemplateSelector().SelectBatchTemplateByNameAndId(batchTemplateName, rtype[0].id);

        if(batchTemplateRecordList.size() > 0){
            for(Batch_Template__c batchTemplate : trigger.New){
                for(Batch_Template__c batchTemplateList : batchTemplateRecordList){
                    if(batchTemplate.Name == batchTemplateList.Name && batchTemplate.RecordTypeId == rtype[0].id){
                        batchTemplate.addError('The Gift Batch Template Name you entered already exists. Please enter a unique name.');
                    }
                }
            }
        }
    }
}