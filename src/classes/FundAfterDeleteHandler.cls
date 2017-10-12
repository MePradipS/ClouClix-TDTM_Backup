public class FundAfterDeleteHandler implements TriggerHandler.HandlerInterface {
	public void handle(){
		FundTriggerHelper.updatePaymentTotalGiftAidEligableAmount(trigger.oldMap.keySet());
	}
}