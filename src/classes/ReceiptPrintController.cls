public with sharing class ReceiptPrintController extends ObjectRedirectController {
	public ReceiptPrintController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'ReceiptPrinter';
	}

	protected override String SetUrlParameters() {
		String receiptId = ((Receipt__c)ObjectController.getRecord()).id;
		String urlParams = '?id=' + receiptId;
		return urlParams;
	}
}