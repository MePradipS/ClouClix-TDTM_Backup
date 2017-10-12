public class recurringGiftFieldUpdateTriggerclass{
    @future
    public static void recurringGiftFieldUpdateForFuture(Set<Id> transactionIds){
        Set<Id> recurringGiftIds = new Set<Id>();
        Set<Id> transctionsIds = new Set<Id>();
        Map<Id, Map<Id, List<Payment__c>>> recurringGiftMap = new Map<Id, Map<Id, List<Payment__c>>>();
        if(transactionIds.size() > 0){
            for(Gift__c gift : new GiftSelector().SelectDonationStatusWhereIdInIdsAndDonationNotNull(transactionIds)){
                recurringGiftIds.add(gift.Recurring_Donation__c);
            }

            List<Recurring_Donation__c> recurringGifts = new RecurringDonationSelector().SelectRecurringGiftWhereIdInIds(recurringGiftIds);
            for(Recurring_Donation__c rg : recurringGifts){
                for(Gift__c gift : rg.Orders__r){
                    transctionsIds.add(gift.Id);
                }
            }

            Map<Id, List<Payment__c>> paymentRecordMap = new Map<Id, List<Payment__c>>();
            for(Payment__c paymentRecord : new PaymentSelector().SelectNewestGiftsByTransId(transctionsIds)){
                if(!paymentRecordMap.containsKey(paymentRecord.Donation__r.Recurring_Donation__c)){
                    paymentRecordMap.put(paymentRecord.Donation__r.Recurring_Donation__c, new List<Payment__c>());
                }
                paymentRecordMap.get(paymentRecord.Donation__r.Recurring_Donation__c).add(paymentRecord);
            }
            if(recurringGifts.size() > 0)
            {
                for(Recurring_Donation__c rgift : recurringGifts)
                {
                    rgift.Approved_Payments__c = 0;
                    rgift.Declined_Payments__c = 0;
                    rgift.Consecutive_Declined_Payments__c = 0;
                    boolean isConsecutive = true;
                    if(paymentRecordMap != null && paymentRecordMap.containsKey(rgift.Id))
                    {
                        List<payment__c> plist = paymentRecordMap.get(rgift.Id);
                        for(Payment__c payment : plist)
                        {
                            if(payment.Status__c == 'Approved' && payment.Amount__c > 0 && (payment.Donation__r.Status__c =='Active' || payment.Donation__r.Status__c =='Entered')){
                                rgift.Approved_Payments__c += 1;
                            }else
                            if(payment.Status__c == 'Declined'){
                                rgift.Declined_Payments__c += 1;
                            }
                            if(payment.Status__c == 'Declined' && isConsecutive){
                                rgift.Consecutive_Declined_Payments__c += 1;
                            }
                            else{
                                isConsecutive = false;
                            }
                        }
                    }
                }
             }
            try{
                if (recurringGifts != null && recurringGifts.size() > 0) {
                    DMLManager.UpdateSObjects(recurringGifts);
                }
            }
            catch(DmlException e) {
            }
        }

   }

    public static void recurringGiftFieldUpdate(Set<Id> transactionIds){
        Set<Id> recurringGiftIds = new Set<Id>();
        Set<Id> transctionsIds = new Set<Id>();
        Map<Id, Map<Id, List<Payment__c>>> recurringGiftMap = new Map<Id, Map<Id, List<Payment__c>>>();

        String fields = '';
        String inFields = '';
        String clause = '';

        if(transactionIds.size() > 0){
            for(Gift__c gift : new GiftSelector().SelectDonationStatusWhereIdInIdsAndDonationNotNull(transactionIds)){
                recurringGiftIds.add(gift.Recurring_Donation__c);
            }

            List<Recurring_Donation__c> recurringGifts = new RecurringDonationSelector().SelectRecurringGiftWhereIdInIds(recurringGiftIds);
            for(Recurring_Donation__c rg : recurringGifts){
                for(Gift__c gift : rg.Orders__r){
                    transctionsIds.add(gift.Id);
                }
            }

            Map<Id, List<Payment__c>> paymentRecordMap = new Map<Id, List<Payment__c>>();
            for(Payment__c paymentRecord : new PaymentSelector().SelectPaymentsByDoationOrderByDate(transctionsIds)){
                if(!paymentRecordMap.containsKey(paymentRecord.Donation__r.Recurring_Donation__c)){
                    paymentRecordMap.put(paymentRecord.Donation__r.Recurring_Donation__c, new List<Payment__c>());
                }
                paymentRecordMap.get(paymentRecord.Donation__r.Recurring_Donation__c).add(paymentRecord);
            }

            if(recurringGifts.size() > 0)
            {
                for(Recurring_Donation__c rgift : recurringGifts)
                {
                    rgift.Approved_Payments__c = 0;
                    rgift.Declined_Payments__c = 0;
                    rgift.Consecutive_Declined_Payments__c = 0;
                    boolean isConsecutive = true;

                    if(paymentRecordMap != null && paymentRecordMap.containsKey(rgift.Id))
                    {
                        List<payment__c> plist = paymentRecordMap.get(rgift.Id);
                        for(Payment__c payment : plist)
                        {
                            if(payment.Status__c == 'Approved' && payment.Amount__c > 0 && (payment.Donation__r.Status__c =='Active' || payment.Donation__r.Status__c =='Entered')){
                                rgift.Approved_Payments__c += 1;
                            }else
                            if(payment.Status__c == 'Declined'){
                                rgift.Declined_Payments__c += 1;
                            }
                            if(payment.Status__c == 'Declined' && isConsecutive){
                                rgift.Consecutive_Declined_Payments__c += 1;
                            }
                            else{
                                isConsecutive = false;
                            }
                        }
                    }
                }
            }
            try{
                if (recurringGifts != null && recurringGifts.size() > 0) {
                    DMLManager.UpdateSObjects(recurringGifts);
                }
            }
            catch(DmlException e) {
            }
        }
    }

    public static boolean CanUseFutureContext() {
        boolean callStackLimitExceeded = Limits.getFutureCalls() >= Limits.getLimitFutureCalls();

        if (!callStackLimitExceeded && !System.isFuture() && !System.isBatch()) {
            return GetNumFutureCallsInLast24Hours() < getMaxFutureCallsAllowed();
        } else return false;
    }

    public static Integer GetNumFutureCallsInLast24Hours() {
        return new AsyncApexJobSelector().SelectJobCountByCreatedDate(Datetime.now().addHours(-24));
    }

    public static Integer getMaxFutureCallsAllowed() {
        Integer usersCount = new UserSelector().SelectUserCountByLicenseKey('SFDC','AUL','PID_FDC_FREE');
        return Math.max(250000, usersCount*200);
    }

    public static void recurringGiftFieldUpdateSwitcher(Set<Id> transactionIds) {
    try{
        Utilities.isAsync = true;
        if(!Utilities.catchTestException){
            recurringGiftFieldUpdateForFuture(transactionIds);
        }else{
            throw new Utilities.MyTestException('recurringGIftFieldUpdateTrigger Failed');
        }
    } catch (exception e) {
        Utilities.isAsync = false;
        recurringGiftFieldUpdate(transactionIds);
    }
  }
}