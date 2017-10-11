public with sharing class VolunteerRoleManageShiftsController extends ObjectRedirectController {
	public VolunteerRoleManageShiftsController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'shiftentry';
	}

	protected override String SetUrlParameters() {
		String volunteerRoleId = ((Volunteer_Role__c)ObjectController.getRecord()).id;
		String urlParams = '?pid=' + volunteerRoleId;
		return urlParams;
	}
}