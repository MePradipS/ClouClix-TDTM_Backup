public class CTDTM_voidDetailUpdateTriggerHandler extends CTDTM_Runnable 
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
        if (triggerAction == CTDTM_Runnable.Action.BeforeInsert || triggerAction == CTDTM_Runnable.Action.BeforeUpdate)
        {
            set<Id> receiptIds = new set<Id>();
            Map<String, String> rtypes_Map = new Map<String, String>();
            List <RecordType> rtypeList = new RecordTypeSelector().SelectBySObjectAndName('Receipt__c', 'Void');
            for(RecordType recType : rtypeList){
                rtypes_Map.put(recType.Name, recType.Id);
            }
            for(Receipt__c r : (List<Receipt__c>)listNew)
            {
                if(r.RecordTypeId == rtypes_Map.get('Void'))
                {
                    r.Status__c = 'Void';
                    r.Amount_Receipted__c = r.Receipt_Amount__c;
                    receiptIds.add(r.id);
                }
            }

            List<Payment__c> paymentRecords = new PaymentSelector().SelectReciptByReciptId(receiptIds);
            if(paymentRecords.size() > 0)
            {
                for(Payment__c p : paymentRecords)
                {
                    p.Receipt__c = null;
                }
                DMLManager.UpdateSObjects(paymentRecords);
            }
        }       
        return null;
   }    
    
}