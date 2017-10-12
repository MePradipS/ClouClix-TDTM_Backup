public with sharing class DocEmailTemplateController {

  public String relatedToType { get; set; }
  public String recipientType { get; set; }
  public String isDupe { get; set; }
  public Id relatedToId { get; set; }
  public Id recipientId { get; set; }
  public String emailTemplateType { get; set; }

  public string content {
    get {
      string retVal = '';
      Id docId = null;

      givingpowerSettings__c  settings = givingpowerSettings__c.getInstance('Settings');
      if(settings != null) {
         docId = getTemplateId(settings);
      }

      try
      {
         retVal = DonationUtility.MergeDocument(docId, relatedToType, relatedToId, recipientType, recipientId);
      }
      catch(Exception ex)
      {
         retVal = ex.getMessage() + ' doc id: ' + docId + ' recipientType='+ recipientType + ' recipientId=' + recipientId;
      }

      return retVal;
    }
  }

  private ID getTemplateId(givingpowerSettings__c settings)
  {
      if (emailTemplateType=='ConsolidatedReceipt')
      {
         return (isDupe == 'True') ? (Id)settings.Consolidated_Duplicate_Receipt_Email_Doc__c:(Id)settings.Consolidated_Receipt_Email_Document_Id__c;
      }
      else if (emailTemplateType=='EventRegistration')
      {
         return (isDupe == 'True') ? (Id)settings.Dupe_Event_Registration_Email_Doc_ID__c:(Id)settings.Event_Registration_Email_Doc_ID__c;
      }
      else
      {
         return (isDupe == 'True') ? (Id)settings.DupeDocumentTemplateId__c:(Id)settings.ReceiptEmailDocId__c;
      }
  }

  static testMethod void testMe()
  {
      List<Profile> profileList = new ProfileSelector().SelectSObjectsByName('System Administrator');
      Profile pr;
      if (profileList != null && profileList.size() > 0) {
        pr = profileList[0];
      }
       User u = new User(alias = 'stadu', email='standard_user@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = pr.Id,
            timezonesidkey='America/Los_Angeles', username='standard_user2@testorg.com');


      System.runAs(u) {

      BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();

      RecordType rtype = new RecordTypeSelector().SelectByNameNamespacePrefixAndName(Utilities.getCurrentNamespace(), 'Gift');

      if (rtype != null)
      {
        Contact c = new Contact(LastName='test lastname',Email='test@test.com');
        DMLManager.InsertSObject(c);

        Gift__c g = new Gift__c();
        g.Constituent__c = c.Id;
        g.Gift_Date__c = Date.today();
        g.Status__c = 'New';
        g.RecordTypeId = rtype.id;
        DMLManager.InsertSObject(g);

        Receipt__c r = new Receipt__c();
        r.Constituent__c = c.Id;
        r.Auto_Email_Receipt__c = true;
        r.Receipt_Address__c = 'sdajdhasdja dhas dhasjd sahd as';
        r.Date_Issued__c = Date.today();
        r.Gift__c = g.Id;
        DMLManager.InsertSObject(r);

        List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectReceiptsByName('settings');
        if (settingsRecords == null || settingsRecords.size()<=0)
        {
            Id folderId = null;
            List<Folder> folders = new FolderSelector().SelectByTypeAndLimit('Document', 5);
            if (folders != null && folders.size()>0)
              folderId = folders[0].Id;

            Document doc = new Document();
            doc.Body = Blob.valueOf(' hi {!recipient.Name} <br/> {!relatedTo.Receipt_Amount__c} ');
            doc.Name = 'test document';
            doc.IsPublic = true;
            doc.ContentType = 'text/html';
            doc.FolderId = folderId;
            DMLManager.InsertSObject(doc);

            string EmailTemplateId = 'sdfsdfdsfdsf';
            List<EmailTemplate> templates = new EmailTemplateSelector().SelectByNameAndTemplateType('Receipt Template 2', 'Visualforce');
            if (templates != null && templates.size()>0)
              EmailTemplateId = templates[0].Id;

            givingpowerSettings__c settings = new givingpowerSettings__c();
            settings.ReceiptEmailDocId__c = doc.Id;
            settings.ReceiptPDFDocId__c = doc.Id;
            settings.EmailTemplateId__c = EmailTemplateId;
            settings.Name = 'settings';
            DMLManager.InsertSObject(settings);
        }

        DocEmailTemplateController controller = new DocEmailTemplateController();
        controller.relatedToType = 'Receipt__c';
        controller.recipientType = 'Contact';
        controller.relatedToId = r.Id;
        controller.recipientId = c.Id;

        String result = controller.content;

        controller.relatedToType = 'Receipt__c';
        controller.recipientType = 'Contact';
        controller.relatedToId = null;
        controller.recipientId = null;

        result = controller.content;


        DocPDFTemplateController cnt = new DocPDFTemplateController();
        cnt.relatedToType = 'Receipt__c';
        cnt.recipientType = 'Contact';
        cnt.relatedToId = r.Id;
        cnt.recipientId = c.Id;

        result = cnt.content;

        cnt.relatedToId = null;
        cnt.recipientId = null;
      }
    }

  }

}