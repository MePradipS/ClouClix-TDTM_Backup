public with sharing class AccountSingleTransactionController extends ObjectRedirectController {
	public AccountSingleTransactionController(ApexPages.StandardController controller) {
        super(controller);
    }

    protected override String SetRedirectPage() {
        return 'SingleTransaction';
    }

	protected override String SetUrlParameters() {
        String urlParams = '?cid=' + ((Account)ObjectController.getRecord()).id;
		return urlParams;
	}
}