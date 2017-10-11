public with sharing class leadConvertController extends RedirectController {

    public Lead selectedRecord { get; set; }
    public string leadId { get; set; }
    public List<Contact> dupeContacts { get; set; }
    public List<Account> dupeAccounts { get; set; }
    public boolean getDupes() { if (dupeContacts.size() > 0) { return true; } return false; }
    public boolean getAccDupes() { if (dupeAccounts.size() > 0) { return true; } return false; }
    public boolean sendEmail { get; set; }
    public boolean noOpp { get; set; }
    public boolean createAcc { get; set; }
    public Contact newContact { get; set; }
    public Opportunity newOpp { get; set; }
    public String selectedCId { get; set; }
    public String selectedAId { get; set; }
    public String templateId;
    public String orgWideId;
    public String bucketAccountId;
    public boolean isIndividual { get; set; }
    public Map<String, String> rt_map = new Map<String, String>();
    public Map<String, String> opp_rt_map = new Map<String, String>();

    public leadConvertController(ApexPages.StandardController controller) {
      super(controller, true);
       selectedRecord = (Lead)controller.getRecord();
       leadId = ApexPages.currentPage().getParameters().get('id');
       leadId = ESAPI.encoder().SFDC_HTMLENCODE(leadId);
       List<BatchSettings__c> settings = new BatchSettingsSelector().SelectBucketAccountById('Default');
       if (settings != null && settings.size() > 0)
       bucketAccountId = settings[0].BucketAccountId__c;
       List<RecordType> rts = new RecordTypeSelector().SelectByObjectTypeAndNameSpace('Lead', Utilities.getCurrentNamespace());
       List<RecordType> rts2 = new RecordTypeSelector().SelectByObjectTypeAndNameSpace('Opportunity', Utilities.getCurrentNamespace());
       for (RecordType rt : rts)
       {
           rt_map.put(rt.Id, rt.Name);
       }
       for (RecordType rt : rts2)
       {
           opp_rt_map.put(rt.Name, rt.Id);
       }
       List<Lead> leadList = new LeadSelector().SelectSObjectsById(new Set<Id> { leadId });
       if (leadList != null && leadList.size() > 0) {
           selectedRecord = leadList[0];
       }
       createAcc = True;
       isIndividual = False;
       if (selectedRecord.Company == 'Individual')
       { isIndividual = True; createAcc = False; }
       List<List<SObject>> searchList = [FIND :selectedRecord.Company IN NAME FIELDS RETURNING Account (Id, Name, Phone, BillingStreet, OwnerId )];
       dupeAccounts = (List<Account>)searchList[0];
       List<List<SObject>> contactList = [FIND :selectedRecord.LastName IN NAME FIELDS RETURNING Contact (AccountId, FirstName, LastName, MailingStreet, Phone, Email, OwnerId )];
       dupeContacts = (List<Contact>)contactList[0];
       newContact = new Contact(OwnerId = UserInfo.getUserId());
       newOpp = new Opportunity(Name = selectedRecord.FirstName + ' ' + selectedRecord.LastName + '-' + rt_map.get(selectedRecord.RecordTypeId) + '-' + Date.Today().Year(), CloseDate = Date.Today().addDays(90));
       selectedCId = '-1';
       selectedAId = '-1';
       List<givingpowerSettings__c> settingsRecords = new GivingPowerSettingsSelector().SelectTemplateIdAndEmailIdByName('Settings');
       if (settingsRecords != null && settingsRecords.size()>0)
       { templateId = settingsRecords[0].New_Lead_Template_Id__c; orgWideId = settingsRecords[0].Org_Wide_Email_ID__c; }
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

    public PageReference convert() {
       Savepoint sp = Database.setSavepoint();
       Database.LeadConvert lc = new database.LeadConvert();
       lc.setLeadId(leadId);
       lc.setDoNotCreateOpportunity(true);

       try
       {
           if (selectedCId == '-1')
           {
               lc.setOwnerId(newContact.OwnerId);
           }

           if (selectedAId != '-1' && isIndividual == False)
           {
               lc.setAccountId(selectedAId);
           }

           if (selectedAId == '-1' && isIndividual == True)
           {
               lc.setAccountId(bucketAccountId);
           }

           if (selectedCId != '-1')
           {
               List<Contact> newContactList = new ContactSelector().SelectOwnerAndAccountById(new Set<Id> { selectedCId });
               if (newContactList != null && newContactList.size() > 0) {
                   newContact = newContactList[0];
                   if (newContact.AccountId != selectedAId && selectedAId != '-1') {
                        newContact.AccountId = selectedAId;
                        DMLManager.UpdateSObject(newContact);
                    }
                lc.setContactId(newContact.Id);
                }
           }

           if (!noOpp)
           {
               lc.setDoNotCreateOpportunity(false);
               lc.setOpportunityName(newOpp.name);
           }

           if (sendEmail)
           {
               lc.setSendNotificationEmail(true);
           }

           LeadStatus convertStatus;
           List<LeadStatus> leadStatusList = new LeadStatusSelector().SelectByIsConverted(true, 1);
           if (leadStatusList != null && leadStatusList.size() > 0) {
               convertStatus = leadStatusList[0];
               lc.setConvertedStatus(convertStatus.MasterLabel);
           }

           Database.LeadConvertResult lcr = Database.convertLead(lc);

           if (lcr.isSuccess())
           {
               List<Contact> newContactList = new ContactSelector().SelectOwnerAndAccountById(new Set<Id> { lcr.getContactId() });
               if (newContactList != null && newContactList.size() > 0) {
                    newContact = newContactList[0];
                    if (!noOpp) {
                        List<Opportunity> oppList = new OpportunitySelector().SelectSObjectsById(new Set<Id> { lcr.getOpportunityId() });
                        if (oppList != null && oppList.size() > 0) {
                            Opportunity opp = oppList[0];
                            opp.RecordTypeId = opp_rt_map.get((rt_map.get(selectedRecord.RecordTypeId)));
                            DMLManager.UpdateSObject(opp);
                        }
                    }
               }
           }

           PageReference pr = new ApexPages.StandardController(newContact).view();
           pr.setRedirect(true);
           return pr;
       }
       catch(Exception ex)
       {
          Database.rollback(sp);
          ApexPages.addMessages(ex);
          return null;
       }
    }
}