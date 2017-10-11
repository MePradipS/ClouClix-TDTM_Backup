public with sharing class LeadConvertRedirectController extends ObjectRedirectController {
	public LeadConvertRedirectController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'LeadConvertContact';
	}

	protected override String SetUrlParameters() {
		String urlParams = '?id=' + ((Lead)ObjectController.getRecord()).id;
		return urlParams;
	}
}