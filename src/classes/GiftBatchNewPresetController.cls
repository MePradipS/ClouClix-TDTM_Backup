public with sharing class GiftBatchNewPresetController extends ObjectRedirectController {
	public GiftBatchNewPresetController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'EditBatchPreset_moc';
	}
}