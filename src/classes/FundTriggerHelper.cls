public class FundTriggerHelper {
    @Future
    public static void updatePaymentTotalGiftAidEligableAmount(Set<Id> oldFundIds){
        //GET APP SETTINGS AND CHECK IF GIFT AID IS ENABLED//
        App_Settings__c appSetting = App_Settings__c.getInstance();
        if(appSetting != null){
            if (appSetting.Gift_Aid_Enable__c) {

                //CREATE A MAP FOR PAYMENT IDS AND A LIST OF ALLOCATIONS ATTACHED//
                Map<Id, List<Gift_Detail__c>> paymentToAllocationMap = new Map<Id, List<Gift_Detail__c>>();
                ///////////////////////////////////////////////////////////////////
                
                //CREATE A LIST OF PAYMENTS TO UPDATE LATER//
                List<Payment__c> paymentList = new List<Payment__c>();
                /////////////////////////////////////////////
                
                //CREATE A LIST OF ALLOCATIONS AND POPULATE IT WITH ALLOCATIONS ATTACHED TO THE TRIGGERING FUND//
                List<Gift_Detail__c> allocationList = new AllocationSelector().SelectApprovedAmountAndPaymentByFund(oldFundIds);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                
                //FOR EVERY ALLOCATION IN ALLOCATION LIST MAP IT//
                if (allocationList != null && allocationList.size() > 0) {
                    for (Gift_Detail__c gd : allocationList) {
                        if (paymentToAllocationMap.containsKey(gd.Payment__c)) {
                            paymentToAllocationMap.get(gd.Payment__c).add(gd);
                        } else {
                            paymentToAllocationMap.put(gd.Payment__c, new List<Gift_Detail__c>{gd});
                        }
                    }
                }
                //////////////////////////////////////////////////
                
                //FOR EVERY PAYMENT TOTAL THE ALLOCATION APPROVED AMOUNT AND APPLY IT TO THE PAYMENT LIST//
                for (Id i : paymentToAllocationMap.keySet()) {
                    decimal totalApprovedAmount = 0;
                    for (Gift_Detail__c gd : paymentToAllocationMap.get(i)) {
                        if (gd.Approved_Amount__c == null) {
                            totalApprovedAmount += 0;
                        } else {
                            totalApprovedAmount += gd.Approved_Amount__c;
                        }
                    }
                    Payment__c tempPayment = new Payment__c(
                            id = i,
                            Total_Gift_Aid_Eligible_Amount__c = totalApprovedAmount
                        );
                    paymentList.add(tempPayment);
                }
                ///////////////////////////////////////////////////////////////////////////////////////////
                
                //IF THERE ARE ANY PAYMENTS TO UPDATE THEN DO IT//
                if(paymentList.size() > 0) {
                    DMLManager.UpdateSObjects(paymentList);
                }
                //////////////////////////////////////////////////
            }
            /////////////////////////////////////////////////////
        }
    }
}