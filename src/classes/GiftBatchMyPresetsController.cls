public with sharing class GiftBatchMyPresetsController extends ObjectRedirectController {
	public GiftBatchMyPresetsController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'BatchPresets_moc';
	}
}