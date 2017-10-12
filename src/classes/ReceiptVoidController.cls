public with sharing class ReceiptVoidController extends ReloadController {
	public ReceiptVoidController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetReloadPage() {
		String previousPageUrl = ApexPages.currentPage().getHeaders().get('Referer');
		return previousPageUrl;
	}

	public override void PreReload() {
		VoidReceipt();
	}

	private void VoidReceipt() {
		Receipt__c receiptObject = (Receipt__c)ObjectController.getRecord();
		if (receiptObject != null && Schema.sObjectType.RecordType.fields.Id.isAccessible()) {
			String sobjectType = Utilities.getCurrentNamespace();
			if(sobjectType != '' || sobjectType != null){
				sobjectType = Utilities.getCurrentNamespace() + '__Receipt__c';
			}else{
				sobjectType = 'Receipt__c';
			}

			String clause = 'Name=\'Void\' and SobjectType=\''+ sobjectType +'\' limit 1';
			RecordType voidRecordType = (RecordType)new GenericQueryBuilder().ObjectQueryBuilderWhere('RecordType', 'Id', clause);
			if (voidRecordType != null) {
				receiptObject.RecordTypeId = voidRecordType.Id;
				DMLManager.UpdateSObject(receiptObject);
			}
		}
	}
}