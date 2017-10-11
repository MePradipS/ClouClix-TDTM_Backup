public abstract with sharing class ObjectRedirectController extends RedirectController {
	protected ApexPages.StandardController ObjectController { get; set; }

	public ObjectRedirectController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override void SetController(ApexPages.StandardController controller) {
		ObjectController = controller;
	}
}