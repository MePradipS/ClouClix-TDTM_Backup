trigger RollupTotalGiving on Gift__c (after update) {//after delete, after insert, after undelete (Removed for optimization)
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
    
    if (settings != null)
    {
        if (!settings.Data_Migration_Mode__c)
        {
            if (trigger.isUpdate) 
            {    
                    for (Integer i = 0; i < Trigger.new.size(); i++) {
                        if (Trigger.old[i].Gift_Date__c != Trigger.new[i].Gift_Date__c || Trigger.old[i].Amount__c != Trigger.new[i].Amount__c) {
                            updatedGifts.add(Trigger.new[i]);
                            
                        }
                        //Story 110427988 
                         if(Trigger.new[i].Gift_Type__c != 'Recurring') {
                        if (Trigger.new[i].Amount__c > 0 && trigger.old[i].Amount__c == 0) {
                           if (Trigger.new[i].Recurring_Donation__c == null) { 
                               receiptReadyGifts.add(Trigger.new[i].Id); 
                           }
                           
                           if(Trigger.new[i].Organization__c != null){
                               solicitsGiftsforOrganisation.add(Trigger.new[i]);
                           }
                           else{
                               solicitsGiftsforIndividual.add(Trigger.new[i]);
                           }
                           
                           }
                           
                           }
                           else
                           {
                            if (Trigger.new[i].Amount__c > 0 && trigger.old[i].Amount__c == 0 && Trigger.new[i].Recurring_Donation__c != null && Trigger.new[i].Recurring_Donation__r.Start_Date__c < system.Today() ) {
                           if (Trigger.new[i].Recurring_Donation__c == null) { 
                               receiptReadyGifts.add(Trigger.new[i].Id); 
                           }
                           
                           if(Trigger.new[i].Organization__c != null){
                               solicitsGiftsforOrganisation.add(Trigger.new[i]);
                           }
                           else{
                               solicitsGiftsforIndividual.add(Trigger.new[i]);
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