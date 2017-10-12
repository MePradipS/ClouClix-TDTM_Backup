public class CTDTM_GLAllocationfieldTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Payments from trigger new. 
    * @param listOld the list of Payments from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Payments 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate)
        {
            if(!BatchSettings__c.getInstance('Default').Data_Migration_Mode__c)
            {
                String namespacePrefix = Utilities.getCurrentNamespace();
                String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
                set<id> giftIds = new set<id>();
                set<id> paymentIds = new set<id>();
                set<id> fundIds = new set<id>();
                String SobjectTypeName = namespaceFieldPrefix + 'Gift__c';
                Map<String, String> rtypes_Map = new Map<String, String>();
                List<RecordType> rts = new RecordTypeSelector().SelectRecordsByMultipleNamesNamespacePrefixAndName('Gift', 'Matching Gift', 'Pledge', SobjectTypeName, Utilities.getCurrentNamespace());
                for(RecordType r : rts){
                    rtypes_Map.put(r.name, r.id);
                }
                integer i= 0;
                for(Payment__c g : (List<Payment__c>)listNew)
                {
                    if(triggerAction == CTDTM_Runnable.Action.AfterUpdate && g.Status__c <> listOld[i].get('Status__c'))
                    {
                        paymentIds.add(g.id);
                    }
                    i++;
                }

                if(paymentIds.size() > 0)
                {
                    Map<Id, List<Gift_Detail__c>> giftDetailRecordMap = new Map<Id, List<Gift_Detail__c>>();
                    List<Gift_Detail__c> giftDetailRecordListToUpdate = new List<Gift_Detail__c>();
                    for(Gift_Detail__c gd : new AllocationSelector().SelectGiftDetailsWherePaymentInPaymentIds(paymentIds))
                    {
                        if(!giftDetailRecordMap.containsKey(gd.Payment__c))
                            giftDetailRecordMap.put(gd.Payment__c, new List<Gift_Detail__c>());
                        
                        giftDetailRecordMap.get(gd.Payment__c).add(gd);
                        fundIds.add(gd.Fund__c);
                        giftIds.add(gd.Gift__c);
                    }
                    Map<Id, Gift__c> giftRecordMap = new Map<Id, Gift__c>(new GiftSelector().SelectGiftTypeAndRecordWhereIdInIds(giftIds));
                    Map<Id, Fund__c> fundRecordMap = new Map<Id, Fund__c>(new FundSelector().SelectCreditAndDebitRecords(fundIds));

                    Map<id, List<Installment_Fulfillment__c>> installmentmap=new map<id, List<Installment_Fulfillment__c>>();
                    for(Installment_Fulfillment__c fulfilment: new InstallmentFulfillmentSelector().SelectIdAndPaymentWherePaymentInPaymentIds(paymentIds))
                    {
                        if(!installmentmap.containsKey(fulfilment.Payment__c))
                            installmentmap.put(fulfilment.Payment__c, new List<Installment_Fulfillment__c>());
                            
                        installmentmap.get(fulfilment.Payment__c).add(fulfilment);
                    }


                    for(Payment__c paymentRecord : (List<Payment__c>)listNew)
                    {
                        if( giftDetailRecordMap.get(paymentRecord.Id) != null)
                        {
                            List<Gift_Detail__c> giftDetailRecordList = giftDetailRecordMap.get(paymentRecord.Id);
                            integer j = 0;
                            for(Gift_Detail__c g : giftDetailRecordList)
                            {
                                if(giftRecordMap.get(g.Gift__c) != null && fundRecordMap.get(g.Fund__c) != null)
                                {
                                    Gift__c giftRecord = giftRecordMap.get(paymentRecord.Donation__c);

                                    if(installmentmap.get(paymentRecord.Id) == null ||  !(installmentmap.get(paymentRecord.Id).size() > 0))
                                    {
                                        Fund__c fundRecord = fundRecordMap.get(g.Fund__c);
                                        if(paymentRecord.RecordType.Name != 'Refund')
                                        {
                                            if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD'))
                                            {
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending'){
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved')
                                            {
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_In_Kind_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_In_Kind_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending')
                                                {
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Other' && paymentRecord.Status__c == 'Approved')
                                            {
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Other_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Other_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending'){
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Stock_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Stock_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending'){
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved')
                                            {
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Property_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Property_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending'){
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Cash_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Cash_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending'){
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_In_Kind_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_In_Kind_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending'){
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Stock_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Stock_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending'){
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Property_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Property_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending'){
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Write_off_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Write_off_Debit__c;
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Write_off_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Write_off_Debit__c;
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if((giftRecord.RecordTypeId == rtypes_Map.get('Gift') || giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending'){
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if((giftRecord.RecordTypeId == rtypes_Map.get('Gift') || giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_In_Kind_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_In_Kind_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending')
                                                {
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if((giftRecord.RecordTypeId == rtypes_Map.get('Gift') || giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved')
                                            {
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Stock_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Stock_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending')
                                                {
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if((giftRecord.RecordTypeId == rtypes_Map.get('Gift') || giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Property_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Property_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending')
                                                {
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Recurring' && paymentRecord.Status__c == 'Approved')
                                            {
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Recurring_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Recurring_Debit__c;
                                                if(listOld[j].get('Status__c') == 'Committed' || listOld[j].get('Status__c') == 'Pending')
                                                {
                                                    g.Posted_to_Finance__c = null;
                                                }
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Committed')
                                            {
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal_Debit__c;
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                            else if((giftRecord.RecordTypeId == rtypes_Map.get('Gift') || giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Committed')
                                            {
                                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Debit__c;
                                                giftDetailRecordListToUpdate.add(g);
                                            }
                                        }
                                    }
                                }
                                j++;
                            }
                        }
                    }
                    if(giftDetailRecordListToUpdate.size() > 0)
                        DMLManager.UpdateSObjects(giftDetailRecordListToUpdate);
                }
            }
        }
        return null;
    }    
    
}