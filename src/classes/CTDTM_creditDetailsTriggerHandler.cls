public class CTDTM_creditDetailsTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Receipts from trigger new. 
    * @param listOld the list of Receipts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Receipts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.BeforeInsert)
        {

                Boolean paymentState = false;
                set<Id> gids = new set<Id>();
                for (Receipt__c receipt: (List<Receipt__c>)listNew)
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
                for (Receipt__c receipt: (List<Receipt__c>)listNew)
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
                
        return null;
   }    
    
}