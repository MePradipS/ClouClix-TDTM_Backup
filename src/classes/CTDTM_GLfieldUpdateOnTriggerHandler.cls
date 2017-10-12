public class CTDTM_GLfieldUpdateOnTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Allocations from trigger new. 
    * @param listOld the list of Allocations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Allocations 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if(triggerAction == CTDTM_Runnable.Action.BeforeInsert || triggerAction == CTDTM_Runnable.Action.BeforeUpdate)
        {
            if(!BatchSettings__c.getInstance('Default').Data_Migration_Mode__c)
            {
                String namespacePrefix = Utilities.getCurrentNamespace();
                String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
                set<id> giftIds = new set<id>();
                set<id> paymentIds = new set<id>();
                set<id> fundIds = new set<id>();
                set<Id> installment_Ids = new set<Id>();
                set<id> refundPaymentIds = new set<id>();
                Map<String, String> rtypes_Map = new Map<String, String>();
                String SobjectTypeName = namespaceFieldPrefix + 'Gift__c';
                List<RecordType> rts = new RecordTypeSelector().SelectRecordsByMultipleNamesNamespacePrefixAndName('Gift', 'Matching Gift', 'Pledge', SobjectTypeName, Utilities.getCurrentNamespace());
                for(RecordType r : rts){
                    rtypes_Map.put(r.name, r.id);
                }
                integer i = 0;
                for(Gift_Detail__c g : (List<Gift_Detail__c>)listNew){
                    if(triggerAction == CTDTM_Runnable.Action.BeforeInsert)
                    {
                        giftIds.add(g.Gift__c);
                        if(g.Payment__c != null)
                            paymentIds.add(g.Payment__c);
                        fundIds.add(g.Fund__c);
                        if(g.Installment__c != null)
                            installment_Ids.add(g.Installment__c);
                    }
                    if(triggerAction == CTDTM_Runnable.Action.BeforeUpdate && ((g.Gift__c <> listOld[i].get('Gift__c') || g.Payment__c <> listOld[i].get('Payment__c')|| g.Fund__c <> listOld[i].get('Fund__c'))||(g.fund__c == Null && listOld[i].get('Fund__c')!= Null))){
                        if(g.fund__c != null)
                        {
                            giftIds.add(g.Gift__c);
                            paymentIds.add(g.Payment__c);
                            fundIds.add(g.Fund__c);
                        }
                        else{
                            g.GL_Auto_Credit_Account__c = null;
                            g.GL_Auto_Debit_Account__c = null;
                        }
                    }
                    i++;
                }

                Map<Id, Payment__c> paymentRecordMap;
                Map<Id, Gift__c> giftRecordMap = new Map<Id, Gift__c>(new GiftSelector().SelectGiftTypeAndRecordWithDateWhereIdInIds(giftIds));
                if(paymentIds.size() > 0 && fundIds.size() > 0)
                {
                    paymentRecordMap = new Map<Id, Payment__c>(new PaymentSelector().SelectInstallmentFulfillmentById(paymentIds));
                    for(Payment__c p : paymentRecordMap.values()){
                        if(p.Status__c == 'Refunded' && p.Payment_Refunded__c != null){
                            refundPaymentIds.add(p.Payment_Refunded__c);
                        }
                    }
                 }
                 Map<Id, SObject> installment_Record_Map ;
                 Map<Id, Payment__c> refundedPaymentRecordMap;
                 Map<Id, Fund__c> fundRecordMap;
                 if(installment_Ids.size() > 0)
                    installment_Record_Map = new Map<Id, SObject>(new InstallmentSelector().SelectSObjectsById(installment_Ids));
                 if(refundPaymentIds.size() > 0){
                   String fields = 'Id, '+ Utilities.PackageNamespace + 'Payment_Type__c, '+ Utilities.PackageNamespace + 'Payment_Refunded__c, '+ Utilities.PackageNamespace + 'Status__c, '+ Utilities.PackageNamespace + 'Date__c, RecordTypeId';
                   String inFields = Converter.ConvertListSetToString(refundPaymentIds);
                   String subFields = ''+ Utilities.PackageNamespace + 'Fund__c, '+ Utilities.PackageNamespace + 'GL_Auto_Credit_Account__c, '+ Utilities.PackageNamespace + 'GL_Auto_Debit_Account__c';
                   String clause = ' WHERE Id IN ('+ inFields +')';

                   refundedPaymentRecordMap = new Map<Id, Payment__c>((List<Payment__c>)new GenericQueryBuilder().QueryBuilderWithSubQuery(Payment__c.sObjectType, fields, clause, Gift_Detail__c.sObjectType, 'Allocations__r', subFields, ''));
                 }
                 if(fundIds.size() > 0)
                    fundRecordMap = new Map<Id, Fund__c>( new FundSelector().SelectCreditAndDebitRecords(fundIds));

                for(Gift_Detail__c g : (List<Gift_Detail__c>)listNew)
                {
                    if(giftRecordMap.get(g.Gift__c) != null && (fundRecordMap != null && fundRecordMap.get(g.Fund__c) != null) && (paymentRecordMap!= null && paymentRecordMap.get(g.Payment__c) != null) || (installment_Record_Map != null && installment_Record_Map.get(g.Installment__c) != null)){
                        Gift__c giftRecord = giftRecordMap.get(g.Gift__c);
                        Fund__c fundRecord = fundRecordMap.get(g.Fund__c);
                        if(paymentRecordMap != null && paymentRecordMap.get(g.Payment__c) != null){
                            Payment__c paymentRecord = paymentRecordMap.get(g.Payment__c);
                            if(!(paymentRecord.Installment_Fulfillments__r.size() > 0)){
                                if(paymentRecord.RecordType.Name != 'Refund'){
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_In_Kind_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_In_Kind_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Other' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Other_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Other_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Stock_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Stock_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Property_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Property_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Cash_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Cash_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_In_Kind_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_In_Kind_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Stock_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Stock_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Property_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Property_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Write_off_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Write_off_Debit__c;
                                    }else
                                    if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge'))&& giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Write_off_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Write_off_Debit__c;
                                    }else
                                    if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Debit__c;
                                    }else
                                    if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_In_Kind_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_In_Kind_Debit__c;
                                    }else
                                    if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Stock_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Stock_Debit__c;
                                    }else
                                    if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Property_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Property_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'Recurring' && paymentRecord.Status__c == 'Approved'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Recurring_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Recurring_Debit__c;
                                    }else
                                    if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Committed'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal_Debit__c;
                                    }else
                                    if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Committed'){
                                        g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                        g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Debit__c;
                                    }
                                }

                                else{
                                    if(triggerAction == CTDTM_Runnable.Action.BeforeInsert)
                                    {
                                        if(refundedPaymentRecordMap.get(paymentRecord.Payment_Refunded__c) != null){
                                            Payment__c refundedPaymentRecord = refundedPaymentRecordMap.get(paymentRecord.Payment_Refunded__c);
                                            if(refundedPaymentRecord.Allocations__r.size() > 0){
                                                for(Gift_Detail__c gg:refundedPaymentRecord.Allocations__r) {
                                                    if(gg.Fund__c != null && gg.Fund__c == g.Fund__c)
                                                    {
                                                        g.GL_Auto_Credit_Account__c = gg.GL_Auto_Credit_Account__c;
                                                        g.GL_Auto_Debit_Account__c = gg.GL_Auto_Debit_Account__c;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }else
                            {
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_In_Kind_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Other' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Other_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Stock_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }else
                                if(giftRecord.RecordTypeId == rtypes_Map.get('Gift') && giftRecord.Gift_Type__c == 'One Time Gift' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Property_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }else
                                if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Approved' && (paymentRecord.Payment_Type__c == 'Cash' || paymentRecord.Payment_Type__c == 'Check' || paymentRecord.Payment_Type__c == 'Credit Card' || paymentRecord.Payment_Type__c == 'Credit Card - Offline' || paymentRecord.Payment_Type__c == 'ACH/PAD')){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }else
                                if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'In Kind' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_In_Kind_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }else
                                if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Stock' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Stock_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }else
                                if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Payment_Type__c == 'Property' && paymentRecord.Status__c == 'Approved'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Property_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }else
                                if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')|| giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge' && paymentRecord.Status__c == 'Written Off'){
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Write_off_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                }
                            }
                        }else
                        if(installment_Record_Map.get(g.Installment__c) != null){
                            if((giftRecord.RecordTypeId == rtypes_Map.get('Gift')||giftRecord.RecordTypeId == rtypes_Map.get('Pledge')) && giftRecord.Gift_Type__c == 'Pledge'){
                                if(g.Amount__c > 0) {
                                    g.GL_Auto_Credit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Credit__c;
                                    g.GL_Auto_Debit_Account__c = fundRecord.GL_Pledge_Current_Fiscal_Debit__c;
                                }
                                else {
                                        String Credit;
                                        String Debit;
                                        Credit = g.GL_Auto_Credit_Account__c;
                                        Debit = g.GL_Auto_Debit_Account__c;
                                        g.GL_Auto_Credit_Account__c = Debit;
                                        g.GL_Auto_Debit_Account__c = Credit;
                                    }
                            }else
                            if(giftRecord.RecordTypeId == rtypes_Map.get('Matching Gift') && giftRecord.Gift_Type__c == 'Pledge'){
                                g.GL_Auto_Credit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal__c;
                                g.GL_Auto_Debit_Account__c = fundRecord.GL_Matching_Pledge_Current_Fiscal_Debit__c;
                            }

                        }
                    }
                }
            }
        }
        return null;
    }
}