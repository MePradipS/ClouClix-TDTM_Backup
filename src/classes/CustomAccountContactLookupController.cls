public with sharing class CustomAccountContactLookupController {

	public List<Account> accountLookupResult { get; set; }
	public List<Contact> contactLookupResults { get; set; }
	public string searchString { get; set; }

	public CustomAccountContactLookupController() {
		searchString = System.currentPageReference().getParameters().get('lksrch');
		runsearchAccountContact();
	}

	public CustomAccountContactLookupController(String strSearchString) {
		searchString = strSearchString;
		runsearchAccountContact();
	}

	public PageReference searchAccountContact() {
		runsearchAccountContact();
		return null;
	}

	private void runsearchAccountContact() {
		accountLookupResult = performAccountSearch(searchString);
		contactLookupResults = performContactSearch(searchString);
	}

	private List<Account> performAccountSearch(string searchString) {
		String[] searchStringArray;
		String fields = 'id, name, Organization_ID__c, AccountNumber, Email__c, Phone, BillingCity, ShippingCity, BillingState, BillingPostalCode';
		String whereClause = '';
		String sObjectType = 'Account';

		if (searchString != '' && searchString != null) {
			if (searchString.contains('\\')) {
				searchString = searchString.replaceAll('\\\\', '\\\\\\\\');
			}
			if (searchString.contains('\'')) {
				searchString = searchString.replaceAll('\'', '\\\\\'');
			}
			searchString = '%' + searchString + '%';
			String searchStringEscapedSingleQuotes = '%' + string.escapeSingleQuotes(searchString) + '%';
			whereClause = ' where Name LIKE \'' + searchStringEscapedSingleQuotes + '\'';
			whereClause += ' or Organization_ID__c LIKE \'' + searchStringEscapedSingleQuotes + '\'';
			whereClause += ' or Email__c LIKE \'' + searchString + '\'';
			whereClause += ' or Phone LIKE \'' + searchString + '\'';
			whereClause += ' or BillingCity LIKE \'' + searchString + '\'';
			whereClause += ' or BillingStreet LIKE \'' + searchString + '\'';
			whereClause += ' or ShippingCity LIKE \'' + searchString + '\'';
			whereClause += ' or ShippingStreet LIKE \'' + searchString + '\'';
			whereClause += ' or BillingState LIKE \'' + searchString + '\'';
			whereClause += ' or BillingPostalCode LIKE \'' + searchStringEscapedSingleQuotes + '\'';
		}
		whereClause += ' limit 50';
		list<account> accountResultsTemp = new GenericQueryBuilder().ListQueryBuilderClause(sObjectType, fields, whereClause);

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

		return accountResultsTemp;

	}

	private List<Contact> performContactSearch(string searchString) {
		String[] searchStringArray;
		String fields = 'id, name, Constituent_ID__c, Email, AssistantName, LastName,FirstName , Phone, MailingCity , MailingState ,MailingPostalCode';
		String whereClause = '';
		String sObjectType = 'Contact';

		if (searchString != '' && searchString != null) {
			if (searchString.contains('\\')) {
				searchString = searchString.replaceAll('\\\\', '\\\\\\\\');
			}
			if (searchString.contains('\'')) {
				searchString = searchString.replaceAll('\'', '\\\\\'');
			}

			String likeSearchString = '%' + searchString + '%';
			String escapedLikeSearchString = '%' + string.escapeSingleQuotes(searchString) + '%';
			whereClause += ' where FirstName LIKE \'' + escapedLikeSearchString + '\'';
			whereClause += ' or LastName LIKE \'' + escapedLikeSearchString + '\'';
			whereClause += ' or FirstName LIKE \'' + likeSearchString + '\'';
			whereClause += ' or name LIKE \'' + likeSearchString + '\'';
			whereClause += ' or Constituent_ID__c LIKE \'' + likeSearchString + '\'';
			whereClause += ' or Email LIKE \'' + likeSearchString + '\'';
			whereClause += ' or Phone LIKE \'' + likeSearchString + '\'';
			whereClause += ' or MailingCity LIKE \'' + likeSearchString + '\'';
			whereClause += ' or MailingState LIKE \'' + likeSearchString + '\'';
			whereClause += ' or MailingPostalCode LIKE \'' + likeSearchString + '\'';
			whereClause += ' or MailingStreet LIKE \'' + likeSearchString + '\'';
			whereClause += ' or OtherCity LIKE \'' + likeSearchString + '\'';
			whereClause += ' or OtherStreet LIKE \'' + escapedLikeSearchString + '\'';
		}
		whereClause += ' limit 50';
		list<contact> contactResultsTemp = new GenericQueryBuilder().ListQueryBuilderClause(sObjectType, fields, whereClause);

		for (contact conactTemp : contactResultsTemp) {
			if (conactTemp.Name.contains('\'')) {
				conactTemp.AssistantName = conactTemp.Name;
				conactTemp.AssistantName = conactTemp.AssistantName.replaceAll('\\\\', '\\\\\\\\');
				conactTemp.AssistantName = conactTemp.AssistantName.replaceAll('\'', '\\\\\'');
			}
			else {
				conactTemp.AssistantName = conactTemp.Name;
			}

		}
		return contactResultsTemp;
	}

	public string getFormTag() {
		String formTag = System.currentPageReference().getParameters().get('frm');
		formTag = ESAPI.encoder().SFDC_HTMLENCODE(formTag);
		return formTag;
	}

	public string getTextBox() {
		String textBoxTxt = System.currentPageReference().getParameters().get('txt');
		textBoxTxt = ESAPI.encoder().SFDC_HTMLENCODE(textBoxTxt);
		return textBoxTxt;
	}


}