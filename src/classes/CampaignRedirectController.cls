public abstract with sharing class CampaignRedirectController extends RedirectController {
	protected String CampaignId { get; set; }
	protected App_Settings__c AppSettings { get; set; }
	protected String RedirectUrl { get; set; }

	public CampaignRedirectController(ApexPages.StandardController controller) {
		Initialize(controller);
	}

	protected void Initialize(ApexPages.StandardController controller) {
		AppSettings = Utilities.GetappSettings();
		CampaignId = ((Campaign)controller.getRecord()).id;
		RedirectUrl = GetRedirectUrl();
	}

	protected abstract String GetRedirectUrl();

	public PageReference RedirectCampaign() {
        PageReference redirectPageReference = new PageReference(RedirectUrl);
        redirectPageReference.setRedirect(true);
        return redirectPageReference;
	}

	@TestVisible
	protected override String SetRedirectPage() {
        return RedirectUrl;
    }
}