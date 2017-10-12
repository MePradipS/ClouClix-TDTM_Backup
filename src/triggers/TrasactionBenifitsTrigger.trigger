trigger TrasactionBenifitsTrigger on Gift_Detail__c (after insert, after update, after delete, after undelete) {
    App_Settings__c appSetting = App_Settings__c.getInstance();
    if (Trigger.IsInsert) {
        GiftDetailHandler.ManageTransactionBenefitsInsert(Trigger.new);
        GiftDetailHandler.RollupTotals(Trigger.new);
    }

    if (Trigger.IsUpdate || Trigger.IsUndelete) {
        GiftDetailHandler.ManageTransactionBenefitsUpdate(Trigger.new, Trigger.old);
        GiftDetailHandler.RollupTotals(Trigger.new);
    }

    if (Trigger.IsDelete) {
        GiftDetailHandler.ManageTransactionBenefitsDelete(Trigger.old);
        GiftDetailHandler.RollupTotals(Trigger.old);
    }


    if(appSetting.Gift_Aid_Enable__c) {
        if(Trigger.isAfter && (Validator_cls.HasGiftAidAllocationAfterRunInsert() || Validator_cls.HasGiftAidAllocationAfterRunUpdate())) {
            list<Payment__c  > paymentsToBeUpdated = new list<Payment__c >();
            decimal totalApprovedAmount=0;
            list<string> paymentIds = new list<string>();

            String fields = '';
            String inFields = '';
            String clause = '';
            String subClause = '';

            if(Trigger.isInsert  || Trigger.isupdate){
                for(Gift_Detail__c tempAllocation : trigger.new){
                    if((Trigger.isupdate && tempAllocation.Approved_Amount__c != Trigger.oldMap.get(tempAllocation.Id).Approved_Amount__c) ||
                        (Trigger.isupdate && tempAllocation.Exclude_From_Gift_Aid__c != Trigger.oldMap.get(tempAllocation.Id).Exclude_From_Gift_Aid__c) ||
                        (Trigger.isupdate && tempAllocation.Fund__c != Trigger.oldMap.get(tempAllocation.Id).Fund__c)){
                        paymentIds.add(tempAllocation.Payment__c);
                    }else if(!Trigger.isUpdate){
                        paymentIds.add(tempAllocation.Payment__c);
                    }
                }
                fields = ''+ Utilities.PackageNamespace + 'Total_Gift_Aid_Eligible_Amount__c,name,'+ Utilities.PackageNamespace + 'Gift_Aid_Declaration__c';
                inFields = Converter.ConvertListSetToString(paymentIds);
                clause = ' WHERE id IN (' + inFields + ')';
                subClause = ' WHERE Exclude_From_Gift_Aid__c = FALSE AND Allocation_GA_Eligible__c = TRUE';
                paymentsToBeUpdated = new GenericQueryBuilder().QueryBuilderWithSubQuery(Payment__c.sObjectType, fields, clause, Gift_Detail__c.sObjectType, 'Allocations__r', 'name,'+ Utilities.PackageNamespace + 'Approved_Amount__c', subClause);
            }
            if(Trigger.isdelete ){
                for(Gift_Detail__c tempAllocation : trigger.old){
                    paymentIds.add(tempAllocation.Payment__c);
                }
                fields = ''+ Utilities.PackageNamespace + 'Total_Gift_Aid_Eligible_Amount__c,name,'+ Utilities.PackageNamespace + 'Gift_Aid_Declaration__c';
                inFields = Converter.ConvertListSetToString(paymentIds);
                clause = ' WHERE id IN (' + inFields + ') AND Gift_Aid_Declaration__c != null';
                subClause = ' WHERE Exclude_From_Gift_Aid__c = FALSE AND Allocation_GA_Eligible__c = TRUE';
                paymentsToBeUpdated = new GenericQueryBuilder().QueryBuilderWithSubQuery(Payment__c.sObjectType, fields, clause, Gift_Detail__c.sObjectType, 'Allocations__r', 'name,'+ Utilities.PackageNamespace + 'Approved_Amount__c', subClause);
            }

            if(paymentsToBeUpdated.size()!=null){
                for(Payment__c tempPayment : paymentsToBeUpdated){
                    totalApprovedAmount=0;
                    if(tempPayment.Allocations__r.size()>0){
                        for(Gift_Detail__c tempAllocation :  tempPayment.Allocations__r){
                            if(tempAllocation.Approved_Amount__c == null) {
                               totalApprovedAmount = 0;
                            }else{
                            totalApprovedAmount+=tempAllocation.Approved_Amount__c;}
                        }
                    }else{
                        totalApprovedAmount=0;
                    }
                    tempPayment.Total_Gift_Aid_Eligible_Amount__c=totalApprovedAmount;
                }
            }

            if(paymentsToBeUpdated.size() > 0){
                DMLManager.UpdateSObjects(paymentsToBeUpdated);
            }
            if(Validator_cls.HasGiftAidAllocationAfterRunInsert()) {
                Validator_cls.GiftAidAllocationAfterRunInsert();
            } else if(Validator_cls.HasGiftAidAllocationAfterRunUpdate()) {
                Validator_cls.GiftAidAllocationAfterRunUpdate();
            }
        }
    }
}