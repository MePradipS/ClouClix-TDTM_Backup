public with sharing class RecurringDonationCancelController extends ObjectRedirectController {
	private String PreviousPageUrl { get; set; }
	public RecurringDonationCancelController(ApexPages.StandardController controller) {
		super(controller);
		PreviousPageUrl = ApexPages.currentPage().getHeaders().get('Referer');
	}

	protected override String SetRedirectPage() {
		return 'recurringMaint';
	}

	protected override String SetUrlParameters() {
		String recurringDonationId = ((Recurring_Donation__c)ObjectController.getRecord()).id;
		String recurringDonationGateway = GetRecurringDonationGateway(recurringDonationId);
		String urlParams = '?id=' + recurringDonationId + '&action=cancel&gateway=' + recurringDonationGateway;
		return urlParams;
	}

	private String GetRecurringDonationGateway(String recurringDonationId) {
		String gateway = '';
		if (Schema.sObjectType.Gift__c.fields.Gateway__c.isAccessible()) {
			List<Gift__c> giftObjectList = new GiftSelector().SelectGatewayByRecurringDonationId(recurringDonationId);
			if (giftObjectList != null && giftObjectList.size() > 0) {
				gateway = giftObjectList[0].Gateway__c;
			}
		}
		return gateway;
	}

	public PageReference ReloadRecurringDonation() {
		PageReference previousPageReference = new PageReference(PreviousPageUrl);
        previousPageReference.setRedirect(true);
        return previousPageReference;
	}
}