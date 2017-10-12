public with sharing class CustomContactLookupController {

    public Fund__c Fund { get; set; }
    public List<Contact> contactResults { get; set; }
    public string searchString { get; set; }

    public List<Account> accountLookupResult { get; set; }
    public List<Contact> contactLookupResults { get; set; }
    public List<Campaign> CampaignResults { get; set; }
    public List<contactsWrapperClass> contactsWrapper { get; set; }
    public List<CampaignWrapperClass> CampaignWrapper { get; set; }

    public string objName { get; set; }
    public string nodeId { get; set; }

    public CustomContactLookupController() {

        String objName = System.currentPageReference().getParameters().get('objName');

        nodeId = System.currentPageReference().getParameters().get('nodeId');
        nodeId = ESAPI.encoder().SFDC_HTMLENCODE(nodeId);


        if (objName == 'Campaign') {
            objName = 'Campaign';
        } else
        {
            objName = 'contact';
        }
        contactsWrapper = new List<contactsWrapperClass> ();
        CampaignWrapper = new List<CampaignWrapperClass> ();
        searchString = System.currentPageReference().getParameters().get('lksearch');
        runSearch();
    }

    public CustomContactLookupController(String strSearchString) {
        objName = 'contact';
        contactsWrapper = new List<contactsWrapperClass> ();
        CampaignWrapper = new List<CampaignWrapperClass> ();
        searchString = strSearchString;
        runSearch();
    }

    public PageReference search() {
        runSearch();
        return null;
    }

    public void runSearch() {
        performSearch(searchString);
    }

    public List<Fund__c> performSearch(string searchString) {
        String soql = '';
        String objName = System.currentPageReference().getParameters().get('oName');
        String orgId = System.currentPageReference().getParameters().get('orgId');
        if (searchString != '' && searchString != null) {
            if (searchString.contains('\\')) {
                searchString = searchString.replaceAll('\\\\', '\\\\\\\\');
            }
            if (searchString.contains('\'')) {
                searchString = searchString.replaceAll('\'', '\\\\\'');
            }
        }

        if (objName == 'Campaign') {
          List<RecordType> rts = new RecordTypeSelector().SelectByNames(new List<String> { 'Appeal', 'Event' });
          List<Campaign> CampaignResultsTemp;

          if (searchString != '' && searchString != null) {
            CampaignResultsTemp = new CampaignSelector().SelectCampaignFundAndLetterBySearch(rts, searchString);
          }else{
            CampaignResultsTemp = new CampaignSelector().SelectCampaignFundAndLetterById(rts);
          }

            for (Campaign CampaignTemp : CampaignResultsTemp) {
                if (CampaignTemp.Name.contains('\'')) {
                    CampaignTemp.Name = CampaignTemp.Name;
                    CampaignTemp.Name = CampaignTemp.Name.replaceAll('\\\\', '\\\\\\\\');
                    CampaignTemp.Name = CampaignTemp.Name.replaceAll('\'', '\\\\\'');
                } else {
                    CampaignTemp.Name = CampaignTemp.Name;
                }
            }
            CampaignResults = CampaignResultsTemp;
            CampaignWrapper.clear();
            for (sobject c : CampaignResults) {
                CampaignWrapper.add(new CampaignWrapperClass(c));
            }

        }

        if (objName == 'Contact')
        {
            String[] orgIds = new String[] { orgId };

            String fields = 'id, name, Constituent_ID__c, AssistantName , Email, LastName,FirstName , Phone, MailingCity , MailingState ,MailingPostalCode';
            String inFields = Converter.ConvertListSetToString(orgIds);
            String clause = 'where AccountId IN (' + inFields + ')';

            if (searchString != '' && searchString != null) {
                String escapedLikeSearchString = '%' + string.escapeSingleQuotes(searchString) + '%';

                clause += ' and (FirstName LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or LastName LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or name LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or Constituent_ID__c LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or Email LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or Phone LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or MailingCity LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or MailingStreet LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or OtherCity LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or OtherStreet LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or MailingState LIKE \'' + escapedLikeSearchString + '\'';
                clause += ' or MailingPostalCode LIKE \'' + escapedLikeSearchString + '\')';
            }
            clause += ' limit 25';

            List<contact> contactResultsTemp = new GenericQueryBuilder().ListQueryBuilderWhere('Contact', fields, clause);
            for (contact conactTemp : contactResultsTemp) {
                if (conactTemp.Name.contains('\'')) {
                    conactTemp.AssistantName = conactTemp.Name;
                    conactTemp.AssistantName = conactTemp.AssistantName.replaceAll('\\\\', '\\\\\\\\');
                    conactTemp.AssistantName = conactTemp.AssistantName.replaceAll('\'', '\\\\\'');
                } else {
                    conactTemp.AssistantName = conactTemp.Name;
                }
            }

            contactResults = contactResultsTemp;
            contactsWrapper.clear();

            for (sobject c : contactResults) {
                contactsWrapper.add(new contactsWrapperClass(c));
            }

            clause = '';
            if (searchString != '' && searchString != null) {
                clause += ' and (hed__Contact__r.name LIKE \'%' + string.escapeSingleQuotes(searchString) + '%\'';
                clause += ' or hed__Role__c LIKE \'%' + string.escapeSingleQuotes(searchString) + '%\')';
            }

            list<hed__Affiliation__c> affiliationstResults = new hedAffiliationSelector().SelectAffiliationInfoByOrgId(orgIds, clause);
            for (hed__Affiliation__c affTemp : affiliationstResults) {
                if (affTemp.hed__Contact__r.Name.contains('\'')) {
                    affTemp.hed__Role__c = affTemp.hed__Contact__r.Name;
                    affTemp.hed__Role__c = affTemp.hed__Role__c.replaceAll('\\\\', '\\\\\\\\');
                    affTemp.hed__Role__c = affTemp.hed__Role__c.replaceAll('\'', '\\\\\'');
                } else {
                    affTemp.hed__Role__c = affTemp.hed__Contact__r.Name;
                }
            }
            for (sobject aff : affiliationstResults) {
                contactsWrapper.add(new contactsWrapperClass(aff));
            }
        }
        return null;
    }

    public PageReference save() {
        DMLManager.InsertSObject(Fund);
        Fund = new Fund__c();
        return null;
    }

    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }

    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }

    public class contactsWrapperClass {
        public contact contacts { get; set; }
        public hed__Affiliation__c affiliations { get; set; }
        public contactsWrapperClass(sObject newObj) {
            string obj = newObj.getSObjectType().getDescribe().getName();
            if (obj == 'contact') {
                contacts = (contact) newObj;
            } else {
                affiliations = (hed__Affiliation__c) newObj;
            }
        }
    }

    public class CampaignWrapperClass {
        public campaign campaigns { get; set; }
        public CampaignWrapperClass(sObject newObj) {
            campaigns = (Campaign) newObj;
        }
    }
}