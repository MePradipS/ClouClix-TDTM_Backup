public with sharing class CustomFundLookupController {

	public Fund__c Fund { get; set; }
	public List<Fund__c> results { get; set; }
	public List<Letter__c> letterResults { get; set; }
	public List<Account> accountResults { get; set; }
	public List<Contact> contactResults { get; set; }
	public string searchString { get; set; }
	public List<Account> accountLookupResult { get; set; }
	public List<Contact> contactLookupResults { get; set; }

	public CustomFundLookupController() {
		Fund = new Fund__c();
		searchString = System.currentPageReference().getParameters().get('lksrch');
		runSearch();
	}

	public CustomFundLookupController(String strSearchString) {
		Fund = new Fund__c();
		searchString = strSearchString;
		runSearch();
	}

	public PageReference search() {
		runSearch();
		return null;
	}

	private void runSearch() {
		results = performSearch(searchString);
	}

	private List<Fund__c> performSearch(string searchString) {
		String soql = '';
		String objName = System.currentPageReference().getParameters().get('objName');

		if (searchString != '' && searchString != null) {
			if (searchString.contains('\\')) {
				searchString = searchString.replaceAll('\\\\', '\\\\\\\\');
			}
			if (searchString.contains('\'')) {
				searchString = searchString.replaceAll('\'', '\\\\\'');
			}
		}
		if (objName == 'Letter') {
			String clause = '';
			String fields = 'id, name, Fund_Name__c, Description__c, Name__c';

			if (searchString != '' && searchString != null) {
				clause = ' where Name LIKE \'%' + string.escapeSingleQuotes(searchString) + '%\'';
				clause += ' or Name__c LIKE \'%' + string.escapeSingleQuotes(searchString) + '%\'';
				clause += ' or Description__c LIKE \'%' + string.escapeSingleQuotes(searchString) + '%\'';
			}
			clause += ' limit 25';
			list<Letter__c> letterResultsTemp = new GenericQueryBuilder().ListQueryBuilderClause('Letter__c', fields, clause);
			for (Letter__c letterTemp : letterResultsTemp) {
				if (letterTemp.Name.contains('\'')) {
					letterTemp.Fund_Name__c = letterTemp.Name;
					letterTemp.Fund_Name__c = letterTemp.Fund_Name__c.replaceAll('\\\\', '\\\\\\\\');
					letterTemp.Fund_Name__c = letterTemp.Fund_Name__c.replaceAll('\'', '\\\\\'');
				} else {
					letterTemp.Fund_Name__c = letterTemp.Name;
				}
			}
			letterResults = letterResultsTemp;
			return null;
		}

		if (objName == 'Account') {
			Map<String, String> rtypes_Map = new Map<String, String> ();
			List<RecordType> rts = new RecordTypeSelector().SelectListByNameNamespacePrefix(Utilities.getCurrentNamespace(), 'Household');
			for (RecordType r : rts) {
				rtypes_Map.put(r.name, r.id);
			}
			String recordid = rtypes_Map.get('Household');

			String fields = 'id, name, AccountNumber, Organization_ID__c, Email__c, Phone, BillingCity, ShippingCity, BillingState, BillingStreet, BillingPostalCode , RecordTypeId';
			String clause = '(RecordTypeId != \'' + recordid + '\')';
			if (searchString != '' && searchString != null) {
				String likeSearchString = '%' + searchString + '%';
				String escapedLikeSearchString = '%' + string.escapeSingleQuotes(searchString) + '%';

				clause += ' AND' + '(' + 'Name LIKE \'' + escapedLikeSearchString + '\'';
				clause += ' or Organization_ID__c LIKE \'' + escapedLikeSearchString + '\'';
				clause += ' or Email__c LIKE \'' + likeSearchString + '\'';
				clause += ' or  Phone LIKE \'' + likeSearchString + '\'';
				clause += ' or BillingCity LIKE \'' + likeSearchString + '\'';
				clause += ' or BillingStreet LIKE \'' + likeSearchString + '\'';
				clause += ' or ShippingCity LIKE \'' + likeSearchString + '\'';
				clause += ' or ShippingStreet LIKE \'' + likeSearchString + '\'';
				clause += ' or BillingState LIKE \'' + likeSearchString + '\'';
				clause += ' or BillingPostalCode LIKE \'' + escapedLikeSearchString + '\')';
			}
			clause += ' limit 25';
			List<account> accountResultsTemp = new GenericQueryBuilder().ListQueryBuilderWhere('Account', fields, clause);

			for (account accountTemp : accountResultsTemp) {
				if (accountTemp.Name.contains('\'')) {
					accountTemp.AccountNumber = accountTemp.Name;
					accountTemp.AccountNumber = accountTemp.AccountNumber.replaceAll('\\\\', '\\\\\\\\');
					accountTemp.AccountNumber = accountTemp.AccountNumber.replaceAll('\'', '\\\\\'');
				}
				else {
					accountTemp.AccountNumber = accountTemp.Name;
				}
			}
			accountResults = accountResultsTemp;
			return null;
		}

		if (objName == 'Contact') {
			String clause = '';
			String fields = 'id, name, Constituent_ID__c, AssistantName , Email, LastName,FirstName , Phone, MailingCity , MailingState , MailingStreet , MailingPostalCode';

			if (searchString != '' && searchString != null) {
				String likeSearchString = '%' + searchString + '%';
				String escapedLikeSearchString = '%' + string.escapeSingleQuotes(searchString) + '%';

				clause = ' where FirstName LIKE \'' + escapedLikeSearchString + '\'';
				clause += ' or LastName LIKE \'' + escapedLikeSearchString + '\'';
				clause += ' or name LIKE \'' + likeSearchString + '\'';
				clause += ' or Constituent_ID__c LIKE \'' + likeSearchString + '\'';
				clause += ' or Email LIKE \'' + likeSearchString + '\'';
				clause += ' or Phone LIKE \'' + likeSearchString + '\'';
				clause += ' or MailingCity LIKE \'' + likeSearchString + '\'';
				clause += ' or MailingStreet LIKE \'' + likeSearchString + '\'';
				clause += ' or OtherCity LIKE \'' + likeSearchString + '\'';
				clause += ' or OtherStreet LIKE \'' + likeSearchString + '\'';
				clause += ' or MailingState LIKE \'' + likeSearchString + '\'';
				clause += ' or MailingPostalCode LIKE \'' + escapedLikeSearchString + '\'';
			}
			clause += ' limit 25';

			list<contact> contactResultsTemp = new GenericQueryBuilder().ListQueryBuilderClause('Contact', fields, clause);
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
			return null;
		}

		String clause = '';
		String fields = 'id, name, Fund_Name__c, Notes__c, Fund_Code__c';

		if (searchString != '' && searchString != null) {
			clause += ' where Name LIKE \'%' + string.escapeSingleQuotes(searchString) + '%\'';
			clause += ' or Fund_Name__c LIKE \'%' + string.escapeSingleQuotes(searchString) + '%\'';
			clause += ' or Fund_Code__c LIKE \'%' + string.escapeSingleQuotes(searchString) + '%\'';
		}
		clause += ' limit 25';
		return new GenericQueryBuilder().ListQueryBuilderClause('Fund__c', fields, clause);

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

}