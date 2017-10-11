public class CTDTM_TrasactionBenifitsTriggerHandler extends CTDTM_Runnable 
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
        App_Settings__c appSetting = App_Settings__c.getInstance();
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert) 
        {
            GiftDetailHandler.ManageTransactionBenefitsInsert((List<Gift_Detail__c>)listNew);
            GiftDetailHandler.RollupTotals((List<Gift_Detail__c>)listNew);
        }

        if(triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterUndelete) 
        {
            GiftDetailHandler.ManageTransactionBenefitsUpdate((List<Gift_Detail__c>)listNew, (List<Gift_Detail__c>)listOld);
            GiftDetailHandler.RollupTotals((List<Gift_Detail__c>)listNew);
        }

        if (triggerAction == CTDTM_Runnable.Action.AfterDelete)
        {
            GiftDetailHandler.ManageTransactionBenefitsDelete((List<Gift_Detail__c>)listOld);
            GiftDetailHandler.RollupTotals((List<Gift_Detail__c>)listOld);
        }


        if(appSetting.Gift_Aid_Enable__c) 
        {
            if((triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate || triggerAction == CTDTM_Runnable.Action.AfterUndelete || triggerAction == CTDTM_Runnable.Action.AfterDelete) && (Validator_cls.HasGiftAidAllocationAfterRunInsert() || Validator_cls.HasGiftAidAllocationAfterRunUpdate()))
            {
                list<Payment__c> paymentsToBeUpdated = new list<Payment__c>();
                decimal totalApprovedAmount=0;
                list<string> paymentIds = new list<string>();

                String fields = '';
                String inFields = '';
                String clause = '';
                String subClause = '';

                if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate)
                {
                    integer i = 0;
                    for(Gift_Detail__c tempAllocation : (List<Gift_Detail__c>)listNew)
                    {
                        if((triggerAction == CTDTM_Runnable.Action.AfterUpdate && tempAllocation.Approved_Amount__c != listOld[i].get('Approved_Amount__c')||
                        (triggerAction == CTDTM_Runnable.Action.AfterUpdate && tempAllocation.Exclude_From_Gift_Aid__c != listOld[i].get('Exclude_From_Gift_Aid__c')||
                        (triggerAction == CTDTM_Runnable.Action.AfterUpdate && tempAllocation.Fund__c != listOld[i].get('Fund__c')))))
                        {
                            paymentIds.add(tempAllocation.Payment__c);
                        }
                        else if(triggerAction != CTDTM_Runnable.Action.AfterUpdate)
                        {
                            paymentIds.add(tempAllocation.Payment__c);
                        }
                        i++;
                    }
                    fields = ''+ Utilities.PackageNamespace + 'Total_Gift_Aid_Eligible_Amount__c,name,'+ Utilities.PackageNamespace + 'Gift_Aid_Declaration__c';
                    inFields = Converter.ConvertListSetToString(paymentIds);
                    clause = ' WHERE id IN (' + inFields + ')';
                    subClause = ' WHERE Exclude_From_Gift_Aid__c = FALSE AND Allocation_GA_Eligible__c = TRUE';
                    paymentsToBeUpdated = new GenericQueryBuilder().QueryBuilderWithSubQuery(Payment__c.sObjectType, fields, clause, Gift_Detail__c.sObjectType, 'Allocations__r', 'name,'+ Utilities.PackageNamespace + 'Approved_Amount__c', subClause);
                }
                if (triggerAction == CTDTM_Runnable.Action.AfterDelete)
                {
                    for(Gift_Detail__c tempAllocation : (List<Gift_Detail__c>)listOld)
                    {
                        paymentIds.add(tempAllocation.Payment__c);
                    }
                    fields = ''+ Utilities.PackageNamespace + 'Total_Gift_Aid_Eligible_Amount__c,name,'+ Utilities.PackageNamespace + 'Gift_Aid_Declaration__c';
                    inFields = Converter.ConvertListSetToString(paymentIds);
                    clause = ' WHERE id IN (' + inFields + ') AND Gift_Aid_Declaration__c != null';
                    subClause = ' WHERE Exclude_From_Gift_Aid__c = FALSE AND Allocation_GA_Eligible__c = TRUE';
                    paymentsToBeUpdated = new GenericQueryBuilder().QueryBuilderWithSubQuery(Payment__c.sObjectType, fields, clause, Gift_Detail__c.sObjectType, 'Allocations__r', 'name,'+ Utilities.PackageNamespace + 'Approved_Amount__c', subClause);
                }

                if(paymentsToBeUpdated.size()!=null)
                {
                    for(Payment__c tempPayment : paymentsToBeUpdated)
                    {
                        totalApprovedAmount=0;
                        if(tempPayment.Allocations__r.size()>0)
                        {
                            for(Gift_Detail__c tempAllocation :  tempPayment.Allocations__r)
                            {
                                if(tempAllocation.Approved_Amount__c == null)
                                   totalApprovedAmount = 0;
                                else
                                    totalApprovedAmount+=tempAllocation.Approved_Amount__c;
                            }
                        }
                        else
                        {
                            totalApprovedAmount=0;
                        }
                        tempPayment.Total_Gift_Aid_Eligible_Amount__c=totalApprovedAmount;
                    }
                }

                if(paymentsToBeUpdated.size() > 0)
                    DMLManager.UpdateSObjects(paymentsToBeUpdated);
                if(Validator_cls.HasGiftAidAllocationAfterRunInsert())
                    Validator_cls.GiftAidAllocationAfterRunInsert();
                else if(Validator_cls.HasGiftAidAllocationAfterRunUpdate())
                    Validator_cls.GiftAidAllocationAfterRunUpdate();
            }
        }
        return null;
    }
}