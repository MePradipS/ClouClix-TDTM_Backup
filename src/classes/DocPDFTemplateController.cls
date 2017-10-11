public with sharing class DocPDFTemplateController {
  
  public string relatedToType { get; set; }
  public string recipientType { get; set; }
  public String isDupe { get; set; }  
  public string relatedToId { get; set; }
  public string recipientId { get; set; }

  
  public string content { 
    get {
      string retVal = '';
      Id docId = null;
      
      // read custom settings
      List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectReceiptsByName('settings');
      if (settingsRecords != null && settingsRecords.size()>0) {
         givingpowerSettings__c settings = settingsRecords[0];
         if (isDupe == 'True')
         { docId = (Id)settings.DupeAttachTemplateId__c; }
         else
         { docId = (Id)settings.ReceiptPDFDocId__c; }         
      }
      
      
      try 
      {
       retVal = DonationUtility.MergeDocument(docId, relatedToType, relatedToId, recipientType, recipientId);
      }
      catch(Exception ex)
      {
      }
      
      //return
      return retVal;
    }
  }
  
}