public with sharing class ContactSingleTransactionController extends ContactRedirectController {
    public ContactSingleTransactionController(ApexPages.StandardController controller) {
        super(controller);
    }

    protected override String SetRedirectPage() {
        return 'SingleTransaction';
    }
}