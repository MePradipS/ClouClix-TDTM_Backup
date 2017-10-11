public with sharing class ContactSummaryViewController extends ContactRedirectController {
    public ContactSummaryViewController(ApexPages.StandardController controller) {
        super(controller);
    }

    protected override String SetRedirectPage() {
        return 'SummaryView';
    }
}