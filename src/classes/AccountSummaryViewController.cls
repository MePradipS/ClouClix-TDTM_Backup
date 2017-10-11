public with sharing class AccountSummaryViewController extends ObjectRedirectController {
	public AccountSummaryViewController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
        return 'SummaryView';
    }

	protected override String SetUrlParameters() {
        String urlParams = '?AccountId=' + ((Account)ObjectController.getRecord()).id + '&RecordTypeId=' + ((Account)ObjectController.getRecord()).RecordTypeId;
				return urlParams;
	}
}