public class PaymentTriggerHelper {
    //TODO: MOVE THIS TO BEFORE UPDATE TRIGGER HANDLER
    public static void updatePaymentTotalGiftAidEligableAmount(Map<Id,Payment__c> newPaymentsMap, List<Gift_Detail__c> allocationList){
        //CREATE A MAP FOR PAYMENT IDS AND A LIST OF ALLOCATIONS ATTACHED//
        Map<Id, List<Gift_Detail__c>> paymentToAllocationMap = new Map<Id, List<Gift_Detail__c>>();
        ///////////////////////////////////////////////////////////////////
        
        //ADD ALL PAYMENTS THAT WERE UPDATED TO A LIST//
        for(Id i : newPaymentsMap.keySet()){
            paymentToAllocationMap.put(i, new List<Gift_Detail__c>());
        }
        ////////////////////////////////////////////////
        
        //FOR EVERY ALLOCATION IN ALLOCATION LIST MAP IT//
        for (Gift_Detail__c gd : allocationList) {
            if (paymentToAllocationMap.containsKey(gd.Payment__c)) {
                paymentToAllocationMap.get(gd.Payment__c).add(gd);
            } else {
                paymentToAllocationMap.put(gd.Payment__c, new List<Gift_Detail__c>{gd});
            }
        }
        //////////////////////////////////////////////////
        
        //FOR EVERY PAYMENT TOTAL THE ALLOCATION APPROVED AMOUNT AND APPLY IT TO THE RESPECTIVE PAYMENT//
        for (Id i : paymentToAllocationMap.keySet()) {
            decimal totalApprovedAmount = 0;
            if(paymentToAllocationMap.get(i).size() > 0){
                for (Gift_Detail__c gd : paymentToAllocationMap.get(i)) {
                    if (newPaymentsMap.get(i).Gift_Aid_Eligible__c){
                        if (gd.Approved_Amount__c == null) {
                            totalApprovedAmount += 0;
                        } else {
                            totalApprovedAmount += gd.Approved_Amount__c;
                        }
                    }
                }
            }else{
                totalApprovedAmount = 0;
            }
            newPaymentsMap.get(i).Total_Gift_Aid_Eligible_Amount__c = totalApprovedAmount;
        }
        /////////////////////////////////////////////////////////////////////////////////////////////////
    }
}