public with sharing class CampaignCompRegController extends CampaignRedirectController {
	public CampaignCompRegController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String GetRedirectUrl() {
		String formUrl = '';
		Campaign campaignObject;
		List<Campaign> campaignList = new CampaignSelector().SelectIdNameById(new Set<Id> { CampaignId });
		if (campaignList != null && campaignList.size() > 0) {
			campaignObject = campaignList[0];
			if (AppSettings != null && campaignObject != null) {
				List<String> urlParameters = new String[] {AppSettings.Form_URL__c, AppSettings.Free_Event_Registration_Form_Id__c, 
					EncodingUtil.urlEncode(campaignObject.Name, 'UTF-8'), campaignObject.Id, UserInfo.getUserId()};
				formUrl = String.format('{0}{1}?EventName={2}&CID={3}&UID={4}', urlParameters);
			}
		}

		return formUrl;
	}
}