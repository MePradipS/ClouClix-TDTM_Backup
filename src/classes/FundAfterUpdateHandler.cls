public class FundAfterUpdateHandler implements TriggerHandler.HandlerInterface {
	public void handle(){
		//GIFT AID FUND ELIGIBLE UPDATES//
		Fund__c fundBeforeChanges, fundAfterChanges;
		Set<Id> fundsUpdatedForGiftAid = new Set<Id>();
		for(Id f : trigger.newMap.keySet()){
			fundBeforeChanges = (Fund__c)Trigger.oldMap.get(f);
			fundAfterChanges = (Fund__c)Trigger.newMap.get(f);

			//CHECK IF GIFT AID FIELDS CHANGED//
			if(fundBeforeChanges.Gift_Aid_Eligible__c != fundAfterChanges.Gift_Aid_Eligible__c)
				fundsUpdatedForGiftAid.add(f);
			////////////////////////////////////
		}

		if(fundsUpdatedForGiftAid.size() > 0){
			FundTriggerHelper.updatePaymentTotalGiftAidEligableAmount(fundsUpdatedForGiftAid);
		}
		//////////////////////////////////
	}
}