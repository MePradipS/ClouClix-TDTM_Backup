public with sharing class RDUpdateCreditCardController extends ObjectRedirectController {
	private String PreviousPageUrl { get; set; }
	
	public RDUpdateCreditCardController(ApexPages.StandardController controller) {
		super(controller);
		PreviousPageUrl = ApexPages.currentPage().getHeaders().get('Referer');
	}

	protected override String SetRedirectPage() {
		return 'recurringMaint';
	}

	protected override String SetUrlParameters() {
		String recurringDonationId = ((Recurring_Donation__c)ObjectController.getRecord()).id;
		Recurring_Donation__c recurringDonationObject = GetRecurringDonation(recurringDonationId);
		String urlParams = '';
		if (recurringDonationObject != null) {
			String gateway = recurringDonationObject.Orders__r.size() > 0 ? recurringDonationObject.Orders__r[0].Gateway__c : '';
			urlParams = '?id=' + recurringDonationObject.Id + '&fname=' + GetEncodedUri(recurringDonationObject.Constituent__r.FirstName)
				+ '&lname=' + GetEncodedUri(recurringDonationObject.Constituent__r.LastName) 
				+ '&Street=' + GetEncodedUri(recurringDonationObject.Constituent__r.MailingStreet)
				+ '&City=' + GetEncodedUri(recurringDonationObject.Constituent__r.MailingCity) 
				+ '&State' + GetEncodedUri(recurringDonationObject.Constituent__r.MailingState)
				+ '&Country=' + GetEncodedUri(recurringDonationObject.Constituent__r.MailingCountry) 
				+ '&Postal=' + recurringDonationObject.Constituent__r.MailingPostalCode
				+ '&Phone=' + recurringDonationObject.Constituent__r.Phone
				+ '&Email=' + recurringDonationObject.Constituent__r.Email
				+ '&Amount=' + recurringDonationObject.sysMergeAmountPaymentGateway__c
				+ '&Frequency=' + recurringDonationObject.Frequency__c + '&gateway=' + gateway;
		}
		return urlParams;
	}

	private Recurring_Donation__c GetRecurringDonation(String recurringDonationId) {
		Recurring_Donation__c recurringDonationObject;
		if (Schema.sObjectType.Recurring_Donation__c.fields.Id.isAccessible() && Schema.sObjectType.Recurring_Donation__c.fields.Name.isAccessible()
			&& Schema.sObjectType.Recurring_Donation__c.fields.Constituent__c.isAccessible() && Schema.sObjectType.Recurring_Donation__c.fields.sysMergeAmountPaymentGateway__c.isAccessible()
			&& Schema.sObjectType.Recurring_Donation__c.fields.Frequency__c.isAccessible() && Schema.sObjectType.Contact.fields.FirstName.isAccessible()
			&& Schema.sObjectType.Contact.fields.LastName.isAccessible() && Schema.sObjectType.Contact.fields.MailingCity.isAccessible()
			&& Schema.sObjectType.Contact.fields.MailingPostalCode.isAccessible() && Schema.sObjectType.Contact.fields.MailingState.isAccessible()
			&& Schema.sObjectType.Contact.fields.MailingStreet.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible()
			&& Schema.sObjectType.Contact.fields.Phone.isAccessible() && Schema.sObjectType.Gift__c.fields.Id.isAccessible()
			&& Schema.sObjectType.Gift__c.fields.Name.isAccessible() && Schema.sObjectType.Gift__c.fields.Gateway__c.isAccessible()
			&& Schema.sObjectType.Gift__c.fields.Recurring_Donation__c.isAccessible()) {
				
			List<Recurring_Donation__c> recurringDontationsList = new RecurringDonationSelector().SelectPaymentGatewayAndFrequencyAndContactsByRecurringDonationId(new Set<Id> { recurringDonationId });
			if (recurringDontationsList != null && recurringDontationsList.size() > 0) {
				recurringDonationObject = recurringDontationsList[0];
			}
		}
		return recurringDonationObject;
	}
}