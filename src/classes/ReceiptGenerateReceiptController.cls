public with sharing class ReceiptGenerateReceiptController extends RedirectController {
	public ReceiptGenerateReceiptController() {
		super();
	}

	protected override String SetRedirectPage() {
		return 'ConsolidatedReceipt';
	}

	protected override String SetUrlParameters() {
		String objectId = ApexPages.CurrentPage().getparameters().get('id');
		String urlParams = '?cid=' + objectId;
		return urlParams;
	}
}