/*This trigger is to update credit card number and credit card type on
Credit Card Number, credit card type field on Gift record.
*/
trigger creditDetailUpdationOnGift on Payment__c (after Insert,before insert,after update) {

    set<Id> giftIds = new set<Id>();
    Set<Gift__c> giftSet = new Set<Gift__c>();
    set<ID> giftRecordsIds= new set<Id>();
    Set<Id> RdIds = new set<Id>();
    Set<Id> PaymentIds = new Set<Id>();


    //adding gift id to giftIds if the Payment_Type__c == 'Credit Card' and Credit_Card_Number__c != null
    //on insertion or updation of record

    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    Schema.SObjectType mcEnabled = gd.get('CurrencyType');
    Boolean MultiCurrencyEn = (mcEnabled !=  null)? true : false ;

    if(Trigger.isInsert){

         if(Trigger.isBefore && MultiCurrencyEn)
         {
           Map<String,String> CurrencyConversionRate = new Map<String,String>();
           for(Sobject c : new GenericQueryBuilder().ListQueryBuilderClause('CurrencyType', 'IsoCode,ConversionRate,Id', ''))
           {
               CurrencyConversionRate.put(String.ValueOf(c.get('IsoCode')), String.ValueOf(c.get('ConversionRate')));
           }

           for(Sobject payment : Trigger.new){

            //Payment.put('PaymentConversionRate__c',CurrencyConversionRate.get(String.valueOf(payment.get('CurrencyIsoCode'))));

            Payment.put('PaymentConversionRate__c',Decimal.valueof(CurrencyConversionRate.get(String.valueOf(payment.get('CurrencyIsoCode')))));

           }
         }

     }
     if(Trigger.isAfter && Trigger.isInsert){
          for(Payment__c payment : Trigger.new){

           if(payment.Status__c=='Approved' || payment.Status__c=='Declined'){
           giftRecordsIds.add(payment.Donation__c);
           }
           PaymentIds.add(payment.Id);

            if(payment.Payment_Type__c == 'Credit Card' && payment.Credit_Card_Number__c != null){
                giftIds.add(payment.Donation__c);
            }
        }
     }

     if(Trigger.isAfter && Trigger.IsUpdate){
        for(Payment__c payment : Trigger.new){

           if(payment.Status__c=='Approved' || payment.Status__c=='Declined'){
           giftRecordsIds.add(payment.Donation__c);
           }
           PaymentIds.add(payment.Id);
        }
     }
     if(giftIds.size() > 0){
        RollupHelper.creditDetailUpdationOnGiftMethod(giftIds);
     }


     if(giftRecordsIds.size() > 0 ) {
       String fields = 'id,name,'+ Utilities.PackageNamespace + 'Recurring_Donation__c';
       String inFields = Converter.ConvertListSetToString(giftRecordsIds);
       String clause = ' WHERE Id IN ('+ inFields +') AND  Gift_Date__c = THIS_YEAR';
       String subFields = 'Id,Name,'+ Utilities.PackageNamespace + 'Date__c,'+ Utilities.PackageNamespace + 'Status__c';
       String subClause = ' where (Status__c = \'Approved\' OR Status__c = \'Declined\') AND Recovered_Payment__c = null Order By Date__c DESC NULLS Last  limit 1';

       List<Recurring_Donation__c> RdupdateList = new List<Recurring_Donation__c>();

       List<Gift__c>  GiftList = new GenericQueryBuilder().QueryBuilderWithSubQuery(Gift__c.sObjectType, fields, clause, Payment__c.sObjectType, 'Recurring_Payments__r', subFields, subClause);
       for(Gift__c c: GiftList){
        RdIds.add(c.Recurring_Donation__c);
       }
       Map<Id,Recurring_Donation__c> RDmap = new Map<Id,Recurring_Donation__c>(new RecurringDonationSelector().SelectActiveDonationById(RdIds));

       if(GiftList.size() > 0) {

         for(Gift__c g: GiftList ) {

           if(RDmap.containsKey(g.Recurring_Donation__c)) {

             Recurring_Donation__c r = RDmap.get(g.Recurring_Donation__c);

             Integer addmm = 0;

             if(r.Frequency__c == 'Monthly') {

             addmm = 01;
             }
             else if (r.Frequency__c == 'Quarterly') {

             addmm = 03;
             }
             else {

             addmm = 12;
             }



             if(r.New_Payment_Start_Date__c != null){

                 payment__c p=g.Recurring_Payments__r;

                 r.Next_Payment_Date__c = Date.newinstance((p.Date__c).Year() , (p.Date__c).month()+addmm, (r.New_Payment_Start_Date__c).day());
                 r.Schedule_Date__c=(r.Next_Payment_Date__c).day();
                 RdupdateList.add(r);


                 }
                 else {
                         if(r.Start_Date__c > system.Today() ) {


                         r.Next_Payment_Date__c = r.Start_Date__c;
                         r.Schedule_Date__c=(r.Next_Payment_Date__c).day();

                         }
                         else {

                         payment__c p=g.Recurring_Payments__r;

                         r.Next_Payment_Date__c = Date.newinstance((p.Date__c).Year() , (p.Date__c).month()+addmm, (r.Start_Date__c).day());
                         r.Schedule_Date__c=(r.Next_Payment_Date__c).day();
                         }

                         RdupdateList.add(r);

                     }
           } // End of Recurring_Donation.
       } //End of Gift.

    }//End of if.

        if (RdupdateList != null && RdupdateList.size() > 0) {
            DMLManager.UpdateSObjects(RdupdateList);
        }
    }
}