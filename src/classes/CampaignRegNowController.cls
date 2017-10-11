public with sharing class CampaignRegNowController extends CampaignRedirectController {
	public CampaignRegNowController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String GetRedirectUrl() {
		String formUrl = '';
		Campaign campaignObject;
		List<Campaign> campaignList = new CampaignSelector().SelectIdNameEventById(new Set<Id> { CampaignId });
		if (campaignList != null && campaignList.size() > 0) {
			campaignObject = campaignList[0];
			if (AppSettings != null && campaignObject != null) {
				String registrationFormId = campaignObject.Paid_Event__c ? AppSettings.Event_Registration_Form_Id__c : AppSettings.Free_Event_Registration_Form_Id__c;
				String eventFee = (campaignObject.Event_Fee_Formated__c != null) ? (campaignObject.Event_Fee_Formated__c).format() : '';
				List<String> urlParameters = new String[] {AppSettings.Form_URL__c, registrationFormId, EncodingUtil.urlEncode(campaignObject.Name, 'UTF-8'), 
					campaignObject.Id, eventFee};
				formUrl = String.format('{0}{1}?EventName={2}&CID={3}&Unit={4}', urlParameters);
			}
		}

		return formUrl;
	}
}