public with sharing class AccountHouseHoldController extends ObjectRedirectController {
	public AccountHouseHoldController(ApexPages.StandardController controller) {
		super(controller);
	}

	@TestVisible
	protected override String SetRedirectPage() {
        return 'HouseHold';
    }

	@TestVisible
	protected override String SetUrlParameters() {
		String previousPageUrl = ApexPages.currentPage().getHeaders().get('Referer');
        String urlParams = '?Url=' + previousPageUrl;
		return urlParams;
	}
}