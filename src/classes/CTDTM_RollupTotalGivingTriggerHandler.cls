public class CTDTM_RollupTotalGivingTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Gifts from trigger new. 
    * @param listOld the list of Gifts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Gifts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterUpdate) 
        {
            set<ID> ids = new set<ID>();    
            Set<Id> contactIds = new Set<Id>();
            Set<Id> orgIds = new Set<Id>();
            set<Id> hhIds = new Set<Id>();
            set<Id> giftId = new set<Id>();
            Set<String> receiptReadyGifts = new Set<String>();
            List<Gift__c> solicitsGifts = new List<Gift__c>();
            List<Gift__c> solicitsGiftsforOrganisation = new List<Gift__c>();
            List<Gift__c> solicitsGiftsforIndividual = new List<Gift__c>();
            List<Gift__c> updatedGifts = new List<Gift__c>();
            BatchSettings__c settings =  BatchSettings__c.getInstance('Default');
            list<Gift__c> TriggerNew = (list<Gift__c>)listNew;
            list<Gift__c> TriggerOld = (list<Gift__c>)listOld;
            
            if (settings != null)
            {
                if (!settings.Data_Migration_Mode__c)
                {
                    if(triggerAction == CTDTM_Runnable.Action.AfterUpdate) 
                    {    
                        for (Integer i = 0; i < TriggerNew.size(); i++) 
                        {
                            if (TriggerOld[i].Gift_Date__c != TriggerNew[i].Gift_Date__c || TriggerOld[i].Amount__c != TriggerNew[i].Amount__c) {
                                updatedGifts.add(TriggerNew[i]);
                                
                            }
                            //Story 110427988 
                            if(TriggerNew[i].Gift_Type__c != 'Recurring') {
                                if (TriggerNew[i].Amount__c > 0 && TriggerOld[i].Amount__c == 0) {
                                    if (TriggerNew[i].Recurring_Donation__c == null) { 
                                        receiptReadyGifts.add(TriggerNew[i].Id); 
                                    }
                                   
                                    if(TriggerNew[i].Organization__c != null){
                                        solicitsGiftsforOrganisation.add(TriggerNew[i]);
                                    }
                                    else{
                                       solicitsGiftsforIndividual.add(TriggerNew[i]);
                                    }
                                }
                            }
                            else
                            {
                                if (TriggerNew[i].Amount__c > 0 && TriggerOld[i].Amount__c == 0 && TriggerNew[i].Recurring_Donation__c != null && TriggerNew[i].Recurring_Donation__r.Start_Date__c < system.Today() ) 
                                {
                                    if (TriggerNew[i].Recurring_Donation__c == null) { 
                                       receiptReadyGifts.add(TriggerNew[i].Id); 
                                    }
                                   
                                    if(TriggerNew[i].Organization__c != null){
                                       solicitsGiftsforOrganisation.add(TriggerNew[i]);
                                    }
                                    else{
                                       solicitsGiftsforIndividual.add(TriggerNew[i]);
                                    }
                                }
                            }
                        } 
                    }
                    
                    if (solicitsGiftsforOrganisation.size()>0) {
                        if(!Validator_cls.isalreadyFiredRollupTotalGiving()){
                            Validator_cls.setalreadyFiredRollupTotalGiving();
                            RollupHelper.CreateOrganizationSoftCredits(solicitsGiftsforOrganisation); 
                        }
                     }
                     if (solicitsGiftsforIndividual.size()>0) {
                         if(!Validator_cls.isalreadyFiredRollupTotalGiving()){
                            Validator_cls.setalreadyFiredRollupTotalGiving();
                            RollupHelper.CreateIndividualSoftCredits(solicitsGiftsforIndividual);
                        }
                    }

                    //new receipts to be issued
                    if (receiptReadyGifts.size()>0)
                    {
                        
                        Map<id, Receipt__c> rs =new Map<id, Receipt__c>( new ReceiptSelector().SelectIdWhereGiftInReceiptReadyGifts(Utilities.ConvertStringSetToIdSet(receiptReadyGifts)));
                        
                        /*Set<Id> receiptIds = new Set<Id>();
                        receiptIds.
                        for(receipt__c r : rs)
                        receiptIds.add(r.Id);*/
                        if (rs.keyset().size()>0){
                            App_Settings__c appSetting = App_Settings__c.getInstance(UserInfo.getOrganizationId());
                            if(appSetting != null && !appSetting.Use_Workflows_for_Sending_Receipts__c){
                            RollupHelper.issueReceipts(rs.keyset());
                            }
                        }
                    }
                }
            }
        }
     return null;
    }
}