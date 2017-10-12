public with sharing class CampaignCreateAppealAPController extends CampaignRedirectController {
	public CampaignCreateAppealAPController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String GetRedirectUrl() {
		String actionpagesUrl = '';
		Campaign campaignObject;
		List<Campaign> campaignList = new CampaignSelector().SelectIdNameLetterAutoEmailAndURLsById(new Set<Id> { CampaignId });
		if (campaignList != null && campaignList.size() > 0) {
			campaignObject = campaignList[0];
			if (AppSettings != null && campaignObject != null) {
				String campaignLetterId = String.isEmpty(campaignObject.Letter__c) ? '' : campaignObject.Letter__c;
				String campaignActionpageAutoEmailAck = campaignObject.Actionpage_Auto_Email_Acknowledgement__c ? '1' : '0';
				String campaignFailureUrl = '';
				if (!String.isEmpty(campaignObject.Failure_URL__c)) {
					// Old logic would perform add a protocol prefix to the url: "http://"&Campaign.Failure_URL__c
					campaignFailureUrl = HasProtocol(campaignObject.Failure_URL__c) ? campaignObject.Failure_URL__c : '';
				}
				String campaignSuccessUrl = '';
				if (!String.isEmpty(campaignObject.Success_URL__c)) {
					// Old logic would perform add a protocol prefix to the url: "http://"&Campaign.Success_URL__c
					campaignSuccessUrl = HasProtocol(campaignObject.Success_URL__c) ? campaignObject.Success_URL__c : '';
				}
				List<String> urlParameters = new String[] {AppSettings.Actionpages_URL__c, campaignObject.Id, EncodingUtil.urlEncode(campaignObject.Name, 'UTF-8'),
					campaignLetterId, campaignActionpageAutoEmailAck, AppSettings.Appeal_Donate_Now_Form_Id__c, AppSettings.CV_Account_Id__c, campaignFailureUrl,
					campaignSuccessUrl};
				actionpagesUrl = String.format('{0}SnippetGenerator.aspx?CID={1}&cname={2}&letter={3}&autoemail={4}&__fid={5}&__orgId={6}&__furl={7}&__surl={8}', urlParameters);
			}
		}

		return actionpagesUrl;
	}

	private Boolean HasProtocol(String url) {
		return (url.startsWithIgnoreCase('http://') || url.startsWithIgnoreCase('https://'));
	}
}