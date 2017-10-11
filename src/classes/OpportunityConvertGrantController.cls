public with sharing class OpportunityConvertGrantController extends ObjectRedirectController {
	public OpportunityConvertGrantController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'ConvertOpp2';
	}

	protected override String SetUrlParameters() {
		String urlParams = '?id=' + ((Opportunity)ObjectController.getRecord()).id;
		return urlParams;
	}
}