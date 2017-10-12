public with sharing class ReceiptBodyExportController {

    public string content { 
        get {
                string retVal = '';
                Id docId = null;
                
                // read custom settings
                List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectDocumentsByName('settings');
                if (settingsRecords != null && settingsRecords.size()>0) {
                givingpowerSettings__c settings = settingsRecords[0];
                if (ApexPages.currentPage().getParameters().get('isdupe') == 'True')
                { docId = (Id)settings.DupeDocumentTemplateId__c; }
                else
                { docId = (Id)settings.ReceiptEmailDocId__c; }
            }
            
            // load document
            try {
                retVal = DonationUtility.MergeDocument(docId, 'Receipt__c', ApexPages.currentPage().getParameters().get('rid'), 'Contact', ApexPages.currentPage().getParameters().get('cid'));
            }
            catch(Exception ex)
            {
                retVal = ex.getMessage() + ' doc id: ' + docId + ' recipientType=Contact' + ' recipientId=' + ApexPages.currentPage().getParameters().get('cid');
            }
            //return
            return retVal;
        }
    }
    
    /*public Receipt__c recipient { get; set; }    
    public Contact relatedTo { get; set; } 
    */
    
    public ReceiptBodyExportController () {
        
    }
}