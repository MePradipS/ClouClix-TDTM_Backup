public with sharing class CampaignActionpageDesignController extends CampaignRedirectController {
	public CampaignActionpageDesignController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String GetRedirectUrl() {
		String actionpagesUrl = '';
		Campaign campaignObject;
		List<Campaign> campaignList = new CampaignSelector().SelectIdNameFundLetterRecordTypeIdById(new Set<Id> { CampaignId });
		if (campaignList != null && campaignList.size() > 0) {
			campaignObject = campaignList[0];
			if (AppSettings != null && campaignObject != null) {
				String partnerServerUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/27.0/' + UserInfo.getOrganizationId();
				String campaignFundId = String.isEmpty(campaignObject.Fund__c) ? '' : campaignObject.Fund__c;
				String campaignLetterId = String.isEmpty(campaignObject.Letter__c) ? '' : campaignObject.Letter__c;
				List<String> urlParameters = new String[] {AppSettings.Actionpages_URL__c, UserInfo.getOrganizationId(), UserInfo.getSessionId(), 
					partnerServerUrl, campaignObject.Id, EncodingUtil.urlEncode(campaignObject.Name, 'UTF-8'), campaignFundId, campaignLetterId, 
					AppSettings.Appeal_Donate_Now_Form_Id__c, AppSettings.Event_Registration_Form_Id__c, AppSettings.Free_Event_Registration_Form_Id__c,
					UserInfo.getUserId(), campaignObject.RecordTypeId};
				actionpagesUrl = String.format('{0}?oid={1}&sid={2}&purl={3}&cid={4}&cname={5}&fid={6}&lid={7}&donateFID={8}&eventRegFID={9}&freeEventRegFID={10}&uid={11}&rtid={12}', urlParameters);
			}
		}

		return actionpagesUrl;
	}
}