public with sharing class ContactNewEventRegistrationController extends ContactRedirectController {
    public ContactNewEventRegistrationController(ApexPages.StandardController controller) {
        super(controller);
    }

    protected override String SetRedirectPage() {
        return 'NewCVEventRegistration';
    }
}