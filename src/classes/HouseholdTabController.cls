public with sharing class HouseholdTabController extends RedirectController {
	
    public HouseholdTabController() {
		super(true);
	}

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }
}