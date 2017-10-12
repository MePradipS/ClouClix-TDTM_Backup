public with sharing class PaymentFulfillInstallmentController extends ObjectRedirectController {
	public PaymentFulfillInstallmentController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'FulFillInstallmentPage';
	}

	protected override String SetUrlParameters() {
		String previousPageUrl = ApexPages.currentPage().getHeaders().get('Referer'); 
		String giftId = ((Gift__c)ObjectController.getRecord()).id;
		String urlParams = '?ContactId=' + giftId + '&Url=' + previousPageUrl;
		return urlParams;
	}
}