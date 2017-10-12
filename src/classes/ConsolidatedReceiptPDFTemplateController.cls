//Generates a Consolidated Receipt PDF, based on the given Consolidated Receipt PDF Template.


public with sharing class ConsolidatedReceiptPDFTemplateController {  
  public string relatedToType { get; set; }
  public string recipientType { get; set; }
  public String isDupe { get; set; }  
  public string relatedToId { get; set; }
  public string recipientId { get; set; }

  
  public string content { 
    get {
      string retVal = '';
      Id docId = null;
      
      // read custom settings to get the desired documents to generate Consolidated Receipt pdf.
      List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectSObjectsByName('settings');
      if (settingsRecords != null && settingsRecords.size()>0) {
         givingpowerSettings__c settings = settingsRecords[0];
         if (isDupe == 'True')
         { 
             docId = (Id)settings.DupeConsolidatedReceiptPDFDocId__c;     
         }
         else
         {
             docId = (Id)settings.ConsolidatedReceiptPDFDocId__c;
         }
      }
      
      
      try 
      {      
       retVal = DonationUtility.MergeDocument(docId, relatedToType, relatedToId, recipientType, recipientId);
      }
      catch(Exception ex)
      {
        String consolidatedRecipientId = ApexPages.currentPage().getParameters().get('cid');
        consolidatedRecipientId = ESAPI.encoder().SFDC_HTMLENCODE(consolidatedRecipientId);
        retVal = ex.getMessage() + ' doc id: ' + docId + ' recipientType=Contact' + ' recipientId=' + consolidatedRecipientId;
      }

      //return
      return retVal;
    }
  }
  
}