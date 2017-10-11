public with sharing class VolunteerPlaceApplicantController extends ObjectRedirectController {
	public VolunteerPlaceApplicantController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'ManagePlacements';
	}

	protected override String SetUrlParameters() {
		String volunteerId = ((Volunteer_Application__c)ObjectController.getRecord()).id;
		String urlParams = '?id=' + volunteerId;
		return urlParams;
	}
}