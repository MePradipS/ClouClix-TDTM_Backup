public with sharing class PaymentRefundController extends ObjectRedirectController {
	public PaymentRefundController(ApexPages.StandardController controller) {
		super(controller);
	}

	protected override String SetRedirectPage() {
		return 'refundPayment';
	}

	protected override String SetUrlParameters() {
		String paymentId = ((Payment__c)ObjectController.getRecord()).id;
		String gatewayId = '';
		if (Schema.sObjectType.Payment__c.fields.Donation__c.isAccessible() && Schema.sObjectType.Gift__c.fields.Gateway__c.isAccessible()) {
			Payment__c paymentObject = new PaymentSelector().SelectPaymentWhereIdIsPaymentId(paymentId);
			List<Gift__c> giftList = new GiftSelector().SelectGatewayById(new Set<Id> { paymentObject.Donation__c });
			Gift__c transactionObject = (giftList != null && giftList.size() > 0) ? giftList[0] : null;
			gatewayId = transactionObject.Gateway__c;
		}
		String urlParams = '?id=' + paymentId + '&gateway=' + gatewayId;
		return urlParams;
	}
}