public with sharing class ReceiptAttachExportController {

    public string content { 
        get {
                string retVal = '';
                Id docId = null;
                String receiptId = ApexPages.currentPage().getParameters().get('rid');
                receiptId = ESAPI.encoder().SFDC_HTMLENCODE(receiptId);

                String isDupeParam = ApexPages.currentPage().getParameters().get('isdupe');
                isDupeParam = ESAPI.encoder().SFDC_HTMLENCODE(isDupeParam);

                String contactId = ApexPages.currentPage().getParameters().get('cid');
                contactId = ESAPI.encoder().SFDC_HTMLENCODE(contactId);
                
                // read custom settings
                List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectReceiptPDFsByName('settings');
                if (settingsRecords != null && settingsRecords.size()>0) {
                    givingpowerSettings__c settings = settingsRecords[0];
                    List<Receipt__c> receiptList = new ReceiptSelector().SelectReceiptTypeById(new Set<Id> { receiptId });
                    if (receiptList != null && receiptList.size() > 0) {
                        //If Receipt is of type "Consolidated" set docId with Consolidated doc Ids.
                        if(receiptList[0].Receipt_Type__c == 'Consolidated') {
                            if (isDupeParam == 'True')
                            { docId = (Id)settings.DupeConsolidatedReceiptPDFDocId__c; }
                            else
                            { docId = (Id)settings.ConsolidatedReceiptPDFDocId__c; }
                        } else {
                            if (isDupeParam == 'True')
                            { docId = (Id)settings.DupeAttachTemplateId__c; }
                            else
                            { docId = (Id)settings.ReceiptPDFDocId__c; }                    
                        }
                    }
                }

            // load document
            try {
                retVal = DonationUtility.MergeDocument(docId, 'Receipt__c', receiptId, 'Contact', contactId);
            }
            catch(Exception ex)
            {
                retVal = ex.getMessage() + ' doc id: ' + docId + ' recipientType=Contact' + ' recipientId=' + contactId;
            }
            return retVal;
        }
    }
    
    public ReceiptAttachExportController () {
 
    }
}