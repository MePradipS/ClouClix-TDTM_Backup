public with sharing class RDUpdateProfileController extends ObjectRedirectController {
	public RDUpdateProfileController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'recurringMaint';
	}

	protected override String SetUrlParameters() {
		String recurringDonationId = ((Recurring_Donation__c)ObjectController.getRecord()).id;
		Gift__c giftObject = GetGift(recurringDonationId);
		Recurring_Donation__c recurringDonationObject = GetRecurringDonation(recurringDonationId);
		String urlParams = '';
		if (recurringDonationObject != null) {
			String gateway = giftObject != null ? giftObject.Gateway__c : '';
			urlParams = '?id=' + recurringDonationObject.Id + '&action=shortupdate' + '&frequency=' + recurringDonationObject.Frequency__c
				+ '&status=' + recurringDonationObject.Status__c + '&gateway=' + gateway;
		}
		return urlParams;
	}

	private Recurring_Donation__c GetRecurringDonation(String recurringDonationId) {
		Recurring_Donation__c recurringDonationObject;
		if (Schema.sObjectType.Recurring_Donation__c.fields.Frequency__c.isAccessible()
			&& Schema.sObjectType.Recurring_Donation__c.fields.Status__c.isAccessible()) {

			List<Recurring_Donation__c> recurringDontationsList = new RecurringDonationSelector().SelectFrequencyAndStatusById(new Set<Id> { recurringDonationId });
			if (recurringDontationsList != null && recurringDontationsList.size() > 0) {
				recurringDonationObject = recurringDontationsList[0];
			}
		}
		return recurringDonationObject;
	}

	private Gift__c GetGift(String recurringDonationId) {
		Gift__c giftObject;
		if (Schema.sObjectType.Gift__c.fields.Id.isAccessible() && Schema.sObjectType.Gift__c.fields.Name.isAccessible()
			&& Schema.sObjectType.Gift__c.fields.Gateway__c.isAccessible() && Schema.sObjectType.Gift__c.fields.Recurring_Donation__c.isAccessible()) {

			List<Gift__c> giftList = new GiftSelector().SelectGatewayByRecurringGiftId(new Set<Id> { recurringDonationId });
			if (giftList != null && giftList.size() > 0) {
				giftObject = giftList[0];
			}
		}
		return giftObject;
	}
}