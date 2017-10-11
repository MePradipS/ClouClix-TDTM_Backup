public with sharing class ReceiptPrinter {

    public static String PackageNamespace { get; set; }
    private String namespacePrefix = Utilities.getCurrentNamespace();
    private String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');

    public Receipt__c receipt { get; set; }

    public PageReference rerender() {
        if (receipt.Constituent__c == null)
        { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Constituent Lookup on Receipt, cannot Email receipt.')); }
        return null;
    }

    public Boolean format { get; set; }
    public Boolean isDupe { get; set; }
    //For Consolidated Receipt
    public Boolean isConsolidatedReceipt { get; set; }

    public String giftRecordType  { get; set; }
    public String emailSubject  { get; set; }
    public String templateId  { get; set; }
    public String dupeTemplateId  { get; set; }
    public String orgWideId { get; set; }
    public RecordType rt { get; set; }

    public PageReference print() {
        if (format == true) {
            try {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if (isDupe) {
                    mail.setTemplateID(dupeTemplateId);
                } else {
                    mail.setTemplateID(templateId);
                }

                mail.setWhatId(receipt.Id);
                mail.setTargetObjectId(receipt.Constituent__c);
                mail.setOrgWideEmailAddressId(orgWideId);
                mail.setSaveAsActivity(False);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                if (!isDupe) {
                    DMLManager.InsertSObject(new Task(Subject = 'Receipt Emailed', Status = 'Completed', WhatId = receipt.Id, ActivityDate = Date.Today(), WhoId = receipt.Constituent__c, Type = 'Automated Email'));
                }

                if (isDupe) {
                    DMLManager.InsertSObject(new Task(Subject = 'Duplicate Receipt Emailed', Status = 'Completed', WhatId = receipt.Id, ActivityDate = Date.Today(), WhoId = receipt.Constituent__c, Type = 'Automated Email'));
                }

                if (!isDupe) {
                    receipt.RecordTypeId = rt.Id; receipt.Date_Issued__c = Date.Today(); receipt.Status__c = 'Issued';
                    DMLManager.UpdateSObject(receipt);
                }

                PageReference pgRef = new PageReference('/' + receipt.Id);
                pgRef.setRedirect(true);
                return pgRef;
            } catch (Exception ex) {
                ApexPages.addMessages(ex);
                return null;
            }
        } else {
            if (!isDupe) {
                DMLManager.InsertSObject(new Task(Subject = 'Receipt Exported for Mailing or Printing', Status = 'Completed', WhatId = receipt.Id, ActivityDate = Date.Today(), WhoId = receipt.Constituent__c, Type = 'Automated Email'));
            }

            if (isDupe) {
                DMLManager.InsertSObject(new Task(Subject = 'Duplicate Receipt Exported for Mailing or Printing', Status = 'Completed', WhatId = receipt.Id, ActivityDate = Date.Today(), WhoId = receipt.Constituent__c, Type = 'Automated Email'));
            }

            if (!isDupe == False) {
                receipt.RecordTypeId = rt.Id; receipt.Date_Issued__c = Date.Today(); receipt.Status__c = 'Issued';
                DMLManager.UpdateSObject(receipt);
            }

            PageReference pgRef = new PageReference('/' + receipt.Id);
            pgRef.setRedirect(true);
            return pgRef;
        }
    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('True', 'Send E-mail'));
        options.add(new SelectOption('False', 'Save and Print'));
        return options;
    }

    public ReceiptPrinter(ApexPages.StandardController controller) {
        SetNamespace();

        String receiptObject = namespaceFieldPrefix + 'Receipt__c';        
        List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectTemplateByName('Settings');
        rt = new RecordTypeSelector().SelectBysObjectNameAndRecordTypeName(receiptObject, 'Issued')[0];
        receipt = new ReceiptSelector().SelecRecieptById(ApexPages.currentPage().getParameters().get('id'));
        isDupe = false;
        giftRecordType = (new RecordTypeSelector().SelectRecordByRecordId(receipt.Gift__r.RecordTypeId))[0].Name;
        if (receipt.Date_Issued__c != null)
        { isDupe = true; }

        if (receipt.Email_subject__c != null)
            emailSubject =  receipt.Email_subject__c;

        //Check if Receipt is Consolidated.
        isConsolidatedReceipt = false;
        if (receipt.Receipt_Type__c == 'Consolidated')
        { isConsolidatedReceipt = true; }

        if (settingsRecords != null && settingsRecords.size() > 0) {
            if (isConsolidatedReceipt) {
                dupeTemplateId = settingsRecords[0].DupeConsolidatedReceiptEmailTempId__c;  templateId = settingsRecords[0].ConsolidatedReceiptEmailTemplateId__c;
            } else if (giftRecordType == 'Event Registration')
            {  dupeTemplateId = settingsRecords[0].Dupe_Event_Registration_Template_ID__c;  templateId = settingsRecords[0].Event_Registration_Email_Template_ID__c; }
            else {
                dupeTemplateId = settingsRecords[0].DupeEmailTemplateId__c;  templateId = settingsRecords[0].EmailTemplateId__c;
            }
            orgWideId = settingsRecords[0].Org_Wide_Email_ID__c;
        }
    }

    public ReceiptPrinter() {
        List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectTemplateByName('Settings');
        String receiptObject = namespaceFieldPrefix + 'Receipt__c';
        rt = new RecordTypeSelector().SelectBysObjectNameAndRecordTypeName(receiptObject, 'Issued')[0];
        receipt = new ReceiptSelector().SelecRecieptById(ApexPages.currentPage().getParameters().get('id'));
        isDupe = false;

        if (receipt.Date_Issued__c != null)
        { isDupe = true; }

        giftRecordType = (new RecordTypeSelector().SelectRecordByRecordId(receipt.Gift__r.RecordTypeId))[0].Name;


        if (receipt.Email_subject__c != null)
            emailSubject =  receipt.Email_subject__c;

        //Check if Receipt is Consolidated.
        isConsolidatedReceipt = false;
        if (receipt.Receipt_Type__c == 'Consolidated')
        { isConsolidatedReceipt = true; }

        if (settingsRecords != null && settingsRecords.size() > 0) {
            if (isConsolidatedReceipt) {
                dupeTemplateId = settingsRecords[0].DupeConsolidatedReceiptEmailTempId__c;  templateId = settingsRecords[0].ConsolidatedReceiptEmailTemplateId__c;
            } else if (giftRecordType == 'Event Registration')
            {  dupeTemplateId = settingsRecords[0].Dupe_Event_Registration_Template_ID__c;  templateId = settingsRecords[0].Event_Registration_Email_Template_ID__c; }
            else {
                dupeTemplateId = settingsRecords[0].DupeEmailTemplateId__c;  templateId = settingsRecords[0].EmailTemplateId__c;
            }
            orgWideId = settingsRecords[0].Org_Wide_Email_ID__c;
        }
    }

    private static void SetNamespace() {
        String namespace = Utilities.getCurrentNamespace();
        PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
    }
}