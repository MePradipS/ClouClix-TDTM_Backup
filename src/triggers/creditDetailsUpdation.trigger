trigger creditDetailsUpdation on Receipt__c (before Insert) {

    if(trigger.isInsert) {

        Boolean paymentState = false;
        set<Id> gids = new set<Id>();
        for (Receipt__c receipt: Trigger.New)
          {

              if( receipt.gift__r.Recurring_Payments__r  != null)
                gids.add(receipt.gift__c);
           }

           String inFields = Converter.ConvertListSetToString(gids);
           String clause = ' WHERE ID IN ('+ inFields +')';
           String subClause = ' WHERE Payment_Type__c = \'Credit Card\' ORDER BY CreatedDate DESC NULLS Last Limit 1';
           String subFields = ''+ Utilities.PackageNamespace + 'Credit_Card_Number__c, '+ Utilities.PackageNamespace + 'Credit_Card_Type__c';
           Map<Id,Gift__c > paymentDetails = new Map<Id, Gift__c >((List<Gift__c>)new GenericQueryBuilder().QueryBuilderWithSubQuery(Gift__c.sObjectType, 'Id', clause, Payment__c.sObjectType, 'Recurring_Payments__r', subFields, subClause));

    if(paymentDetails.size() >0)
    {
        for (Receipt__c receipt: Trigger.new)
        {
            Id giftId = receipt.Gift__c;
            if(receipt.Gift__r.Recurring_Payments__r != null)
             {
                Gift__c GiftObj = paymentDetails.get(giftId);

                if(giftObj != null && GiftObj.Recurring_Payments__r.size() > 0)
                {
                 Payment__c paymentObj =  GiftObj.Recurring_Payments__r;
                receipt.Credit_Card__c= paymentObj.Credit_Card_Number__c;
                receipt.Credit_Card_Type__c = paymentObj .Credit_Card_Type__c;
            }
          }
        }
    }
   }
}