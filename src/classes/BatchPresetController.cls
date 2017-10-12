public with sharing class BatchPresetController {
    public String selectedTab {get; set;}
    public Boolean isEventPreset {get; set;}
    public List<PresetWrapper> contactFields {get; set;}
    public List<PresetWrapper> accountFields {get; set;}
    public List<PresetWrapper> RecurringGiftFields {get; set;}
    public List<PresetWrapper> TransactionFields {get; set;}
    public List<PresetWrapper> PaymentFields {get; set;}
    public List<PresetWrapper> ReceiptFields {get; set;}
    public List<PresetWrapper> GiftDetailFields {get; set;}
    public List<PresetWrapper> eventRegFields {get; set;}
    public Batch_Template__c template {get; set;}
    private String templateId;

    private String namespacePrefix {
        get {
            if (namespacePrefix == null) {
                namespacePrefix = Utilities.getCurrentNamespace();
            }
            return namespacePrefix;
        }
        set;
    }
    private String namespaceFieldPrefix {
        get {
            if (namespaceFieldPrefix == null) {
                namespaceFieldPrefix = String.isEmpty(namespacePrefix) ? '' : namespacePrefix + '__';
            }
            return namespaceFieldPrefix;
        }
        set;
    }

    public BatchPresetController() {
        contactFields = new List<PresetWrapper>();
        accountFields = new List<PresetWrapper>();
        RecurringGiftFields = new List<PresetWrapper>();
        TransactionFields = new List<PresetWrapper>();
        PaymentFields = new List<PresetWrapper>();
        ReceiptFields = new List<PresetWrapper>();
        GiftDetailFields = new List<PresetWrapper>();
        eventRegFields = new List<PresetWrapper>();
        template = new Batch_Template__c();
    }

    public List<Batch_Template__c> getViewPresets() {
        List<Batch_Template__c> presetTemplates = new BatchTemplateSelector().SelectIdNameTypeOrderByName();
        return presetTemplates;
    }

    public pageReference editBatchPreset() {
        templateId = ApexPages.currentPage().getParameters().get('templateId');
        if (templateId != null) {
            contactFields.clear();
            accountFields.clear();
            RecurringGiftFields.clear();
            TransactionFields.clear();
            PaymentFields.clear();
            ReceiptFields.clear();
            GiftDetailFields.clear();
            eventRegFields.clear();

            presetTemplateData();
            PageReference pageRef = new PageReference('/apex/' + namespaceFieldPrefix + 'EditBatchPreset?Id=' + templateId);
            pageRef.setRedirect(false);
            return pageRef;
        }

        return null;
    }

    public pageReference newBatchPreset() {

        templateId = null;
        template.Name = null;

        contactFields.clear();
        accountFields.clear();
        RecurringGiftFields.clear();
        TransactionFields.clear();
        PaymentFields.clear();
        ReceiptFields.clear();
        GiftDetailFields.clear();
        eventRegFields.clear();

        newBatchPresetData();
        PageReference pageRef = new PageReference('/apex/' + namespaceFieldPrefix + 'NewBatchPreset?');
        pageRef.setRedirect(false);
        return pageRef;
    }
    public void presetTemplateData() {
        Batch_Template__c presetTemplate;
        List<Batch_Template__c> batchTemplateList = new BatchTemplateSelector().SelectSObjectsById(new Set<Id> { templateId });
        if (batchTemplateList != null && batchTemplateList.size() > 0) {
            presetTemplate = batchTemplateList[0];

            template.Name = presetTemplate.Name;
            template.Type__c = presetTemplate.Type__c;

            BatchPresetXMLParser obj_BPXMLP = new BatchPresetXMLParser();
            if (contactFields.size() == 0)
                contactFields = obj_BPXMLP.readXML(presetTemplate.ContactFieldXml__c, 'Contact');
            if (accountFields.size() == 0)
                accountFields = obj_BPXMLP.readXML(presetTemplate.AccountFieldsXml__c, 'Account');
            if (RecurringGiftFields.size() == 0)
                RecurringGiftFields = obj_BPXMLP.readXML(presetTemplate.RecurringGiftFieldsXml__c, namespaceFieldPrefix + 'Recurring_Donation__c');
            if (TransactionFields.size() == 0)
                TransactionFields = obj_BPXMLP.readXML(presetTemplate.TransactionFieldsXml__c, namespaceFieldPrefix + 'Gift__c');
            if (PaymentFields.size() == 0)
                PaymentFields = obj_BPXMLP.readXML(presetTemplate.PaymentFieldsXml__c, namespaceFieldPrefix + 'Payment__c');
            if (ReceiptFields.size() == 0)
                ReceiptFields = obj_BPXMLP.readXML(presetTemplate.ReceiptFieldsXml__c, namespaceFieldPrefix + 'Receipt__c');
            if (GiftDetailFields.size() == 0)
                GiftDetailFields = obj_BPXMLP.readXML(presetTemplate.GiftDetailFieldsXml__c, namespaceFieldPrefix + 'Gift_Detail__c');
        }
    }

    public void newBatchPresetData() {
        if (contactFields.size() == 0)
            contactFields = discribeObjects('Contact');
        if (accountFields.size() == 0)
            accountFields = discribeObjects('Account');
        if (RecurringGiftFields.size() == 0)
            RecurringGiftFields = discribeObjects(namespaceFieldPrefix + 'Recurring_Donation__c');
        if (TransactionFields.size() == 0)
            TransactionFields = discribeObjects(namespaceFieldPrefix + 'Gift__c');
        if (PaymentFields.size() == 0)
            PaymentFields = discribeObjects(namespaceFieldPrefix + 'Payment__c');
        if (ReceiptFields.size() == 0)
            ReceiptFields = discribeObjects(namespaceFieldPrefix + 'Receipt__c');
        if (GiftDetailFields.size() == 0)
            GiftDetailFields = discribeObjects(namespaceFieldPrefix + 'Gift_Detail__c');

    }

    public pageReference saveBatchPreset() {

        try {

            if (template.Name == null || template.Name == '')
                throw new MyCustomException('Template Name can not be empty.');

            BatchPresetXMLParser objBPXMLP = new BatchPresetXMLParser();
            if (templateId != null) {
                Batch_Template__c presetTemplate;
                List<Batch_Template__c> batchTemplateList = new BatchTemplateSelector().SelectSObjectsById(new Set<Id> { templateId });
                if (batchTemplateList != null && batchTemplateList.size() > 0) {
                    presetTemplate = batchTemplateList[0];

                    presetTemplate.Name = template.Name;
                    presetTemplate.Type__c = template.Type__c;
                    presetTemplate.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields);
                    presetTemplate.ContactFieldXml__c =  objBPXMLP.writeXML('Contact', contactFields);
                    presetTemplate.RecurringGiftFieldsXml__c = objBPXMLP.writeXML('Recurring_Donation__c', RecurringGiftFields);
                    presetTemplate.TransactionFieldsXml__c = objBPXMLP.writeXML('Gift__c', TransactionFields);
                    presetTemplate.PaymentFieldsXml__c = objBPXMLP.writeXML('Payment__c', PaymentFields);
                    presetTemplate.ReceiptFieldsXml__c = objBPXMLP.writeXML('Receipt__c', ReceiptFields);
                    presetTemplate.GiftDetailFieldsXml__c = objBPXMLP.writeXML('Gift_Detail__c', GiftDetailFields);
                    presetTemplate.EventRegistrationsFieldsXml__c = objBPXMLP.writeXML('Event_Registration__c', eventRegFields);

                    DMLManager.UpdateSObject(presetTemplate);
                }
            } else {
                Batch_Template__c obj_BPT = new Batch_Template__c();
                obj_BPT.Name = template.Name;
                obj_BPT.Type__c = template.Type__c;
                obj_BPT.AccountFieldsXml__c = objBPXMLP.writeXML('Account', accountFields);
                obj_BPT.ContactFieldXml__c =  objBPXMLP.writeXML('Contact', contactFields);
                obj_BPT.RecurringGiftFieldsXml__c = objBPXMLP.writeXML('Recurring_Donation__c', RecurringGiftFields);
                obj_BPT.TransactionFieldsXml__c = objBPXMLP.writeXML('Gift__c', TransactionFields);
                obj_BPT.PaymentFieldsXml__c = objBPXMLP.writeXML('Payment__c', PaymentFields);
                obj_BPT.ReceiptFieldsXml__c = objBPXMLP.writeXML('Receipt__c', ReceiptFields);
                obj_BPT.GiftDetailFieldsXml__c = objBPXMLP.writeXML('Gift_Detail__c', GiftDetailFields);
                obj_BPT.EventRegistrationsFieldsXml__c = objBPXMLP.writeXML('Event_Registration__c', eventRegFields);

                DMLManager.InsertSObject(obj_BPT);
            }

            PageReference pageRef = new PageReference('/apex/' + namespaceFieldPrefix + 'BatchPresets?');
            pageRef.setRedirect(false);
            return pageRef;
        } catch (Exception e) {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public list<SelectOption> getbatchTypeOptions() {

        Schema.DescribeFieldResult typeFieldDescription = Batch_Template__c.Type__c.getDescribe();
        list<SelectOption>  batchTypeOptions = new list<SelectOption>();

        for (Schema.Picklistentry picklistEntry : typeFieldDescription.getPicklistValues())
            batchTypeOptions.add(new SelectOption(pickListEntry.getValue(), pickListEntry.getLabel()));

        return batchTypeOptions;
    }

    public List<PresetWrapper> discribeObjects(String sObjectType) {

        List<PresetWrapper> PW_List = new List<PresetWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(sObjectType);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

        for (String fieldName : fieldMap.keySet()) {

            Schema.DescribeFieldResult desribeResult = fieldMap.get(fieldName).getDescribe();

            if (desribeResult.isAccessible() && !desribeResult.isAutoNumber() && !desribeResult.isCalculated()
                    && desribeResult.isCreateable() && !desribeResult.isDeprecatedAndHidden() && fieldName != 'OwnerId') {

                PresetWrapper pw = new PresetWrapper(objSchema);
                pw.fieldLable = desribeResult.getLabel();
                pw.fieldName = fieldName;
                pw.fieldType = String.valueOf(desribeResult.getType());
                pw.fieldValue = null;
                pw.isHidden = false;
                pw.isReadOnly = false;
                pw.isForSummary = false;
                if (desribeResult.isCreateable() && !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate())
                    pw.isRequired = true;
                else
                    pw.isRequired = false;

                PW_List.add(pw);
            }
        }

        return PW_List;
    }

    public pageReference cancel() {
        PageReference pageRef = new PageReference('/apex/' + namespaceFieldPrefix + 'BatchPresets?');
        pageRef.setRedirect(false);
        return pageRef;
    }

    public pageReference deletePreset() {
        Batch_Template__c presetTemplate;
        List<Batch_Template__c> batchTemplateList = new BatchTemplateSelector().SelectIdNameById(new Set<Id> { templateId });
        if (batchTemplateList != null && batchTemplateList.size() > 0) {
            presetTemplate = batchTemplateList[0];
        }
        if (Batch_Template__c.sObjectType.getDescribe().isDeletable()) {
            DMLManager.DeleteSObject(presetTemplate);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient access to delete preset'));
            return null;
        }

        PageReference pageRef = new PageReference('/apex/' + namespaceFieldPrefix + 'BatchPresets?');
        pageRef.setRedirect(false);
        return pageRef;
    }

    public pageReference selectTab() {
        return null;
    }

    public class MyCustomException extends exception {}
}