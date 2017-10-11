public abstract with sharing class ContactRedirectController extends ObjectRedirectController {
	protected String cidParameter { get; set; }

    public ContactRedirectController(ApexPages.StandardController controller) {
        super(controller);
    }

    protected override String SetUrlParameters() {
        String urlParams = '?cid=' + ((Contact)ObjectController.getRecord()).id;
				return urlParams;
	}
}