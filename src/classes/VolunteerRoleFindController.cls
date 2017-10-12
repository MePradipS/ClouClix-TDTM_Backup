public with sharing class VolunteerRoleFindController extends ObjectRedirectController {
	public VolunteerRoleFindController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'searchPos';
	}

	protected override String SetUrlParameters() {
		String volunteerRoleId = ((Volunteer_Role__c)ObjectController.getRecord()).id;
		String urlParams = '?Id=' + volunteerRoleId;
		return urlParams;
	}
}