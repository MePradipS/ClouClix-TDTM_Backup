trigger TotalGiftAidRollUp on Payment__c (after insert, after update, after delete, before insert, before update) {
    //new TriggerHandler()
    //    .bind(TriggerHandler.Evt.afterupdate, new PaymentAfterUpdateHandler())
    //    .manage();
    List<Payment__c> paymentsWithGiftAidUpdates = new List<Payment__c>();

    String fields = '';
    String subFields = '';
    String inFields = '';
    String clause = '';
    String subClause = '';

    App_Settings__c appSetting = App_Settings__c.getInstance();
    if (appSetting != null && appSetting.Gift_Aid_Enable__c) {
        if (Trigger.isBefore && (Validator_cls.HasGiftAidPaymentBeforeRunInsert() || Validator_cls.HasGiftAidPaymentBeforeRunUpdate())) {
            List<Id> idsForPaymentContacts = new List<Id>();
            for (Payment__c currentPayment : Trigger.new) {
                if (Utilities.IsPaymentGiftAidEligible(currentPayment, appSetting)) {
                    if (Validator_cls.HasGiftAidPaymentBeforeRunUpdate()) {
                        Payment__c oldPayment = (Trigger.oldMap.get(currentPayment.Id));
                        Utilities.PaymentStatus newPaymentStatus = Utilities.ResolvePaymentStatus(currentPayment.Status__c);
                        Utilities.PaymentStatus oldPaymentStatus = Utilities.ResolvePaymentStatus(oldPayment.Status__c);
                        if (oldPaymentStatus != newPaymentStatus || currentPayment.Amount__c != oldPayment.Amount__c || currentPayment.Gift_Aid_Declaration__c != oldPayment.Gift_Aid_Declaration__c || currentPayment.Gift_Aid_Declaration__c == null) {
                            idsForPaymentContacts.add(Utilities.DecodeHyperLinkedId(currentPayment.Constituent__c));
                            paymentsWithGiftAidUpdates.add(currentPayment);
                        }
                    } else if (Validator_cls.HasGiftAidPaymentBeforeRunInsert()) {
                        idsForPaymentContacts.add(Utilities.DecodeHyperLinkedId(currentPayment.Constituent__c));
                        paymentsWithGiftAidUpdates.add(currentPayment);
                    }
                } else {
                    currentPayment.Gift_Aid_Eligible__c = false;
                    currentPayment.Total_Gift_Aid_Eligible_Amount__c = null;
                    currentPayment.Gift_Aid_Declaration__c = null;
                }
            }

            if (idsForPaymentContacts.size() > 0) {
                fields = 'Id,FirstName,LastName,MailingPostalCode,MailingCountry,MailingCity,MailingState,MailingStreet';
                inFields = Converter.ConvertListSetToString(idsForPaymentContacts);
                clause = ' WHERE Id IN ('+ inFields +')';
                subClause = ' WHERE IsActive__c = TRUE';
                subFields = 'Id,'+ Utilities.PackageNamespace + 'IsActive__c,'+ Utilities.PackageNamespace + 'Effective_Date__c,'+ Utilities.PackageNamespace + 'End_Date__c';

                Map<Id, Contact> contactMap = new Map<Id, Contact>((List<Contact>)new GenericQueryBuilder().QueryBuilderWithSubQuery(Contact.sObjectType, fields, clause, Gift_Aid_Declaration__c.sObjectType, 'Gift_Aid_Declarations__r', subFields, subClause));
                Map<Id, Payment__c> paymentsWithGiftAidUpdatesMap;
                List<Gift_Detail__c> changedPaymentAllocationList = new List<Gift_Detail__c>();
                if (Validator_cls.HasGiftAidPaymentBeforeRunUpdate()){
                    changedPaymentAllocationList = new AllocationSelector().SelectGiftByTriggerSet(Trigger.newMap.keySet());
                }

                Map<Id, List<Gift_Detail__c>> changedPaymentAllocationMap = new Map<Id, List<Gift_Detail__c>>();
                for (Gift_Detail__c currentAllocation : changedPaymentAllocationList){
                    if (changedPaymentAllocationMap.containsKey(currentAllocation.Payment__c)) {
                        changedPaymentAllocationMap.get(currentAllocation.Payment__c).add(currentAllocation);
                    } else {
                        changedPaymentAllocationMap.put(currentAllocation.Payment__c, new List<Gift_Detail__c>{currentAllocation});
                    }
                }

                Map<Id, List<Gift_Aid_Declaration__c>> declarationsMappedByContact = new Map<Id, List<Gift_Aid_Declaration__c>>();
                Map<Id, Gift_Aid_Declaration__c> declarationsMap = new Map<Id, Gift_Aid_Declaration__c>();
                for(Contact currentContact : contactMap.values()){
                    declarationsMappedByContact.put(currentContact.Id, currentContact.Gift_Aid_Declarations__r);
                    declarationsMap.putAll(currentContact.Gift_Aid_Declarations__r);
                }

                for (Payment__c currentPayment : paymentsWithGiftAidUpdates) {
                    if(contactMap.get(Utilities.DecodeHyperLinkedId(currentPayment.Constituent__c)) != null){
                        Utilities.PaymentStatus paymentStatus = Utilities.ResolvePaymentStatus(currentPayment.Status__c);
                        if (paymentStatus == Utilities.PaymentStatus.Approved) {
                            currentPayment.Gift_Aid_Eligible__c = true;
                        } else {
                            currentPayment.Gift_Aid_Eligible__c = false;
                            currentPayment.Gift_Aid_Declaration__c = null;
                        }

                        if (Validator_cls.HasGiftAidPaymentBeforeRunUpdate() && changedPaymentAllocationList.size() > 0) {
                            if (currentPayment.Gift_Aid_Eligible__c){
                                currentPayment.Total_Gift_Aid_Eligible_Amount__c = 0;
                                List<Gift_Detail__c> allocationForCurrentPayment = changedPaymentAllocationMap.get(currentPayment.Id);
                                if(allocationForCurrentPayment != null){
                                    for(Gift_Detail__c currentAllocation : allocationForCurrentPayment){
                                        Payment__c oldPaymentForAllocation = (Trigger.oldMap.get(currentPayment.Id));
                                        if(oldPaymentForAllocation.Status__c != 'Approved' && currentPayment.Status__c == 'Approved'){
                                            if (currentAllocation.Amount__c == null) {
                                                currentPayment.Total_Gift_Aid_Eligible_Amount__c += 0;
                                            } else {
                                                currentPayment.Total_Gift_Aid_Eligible_Amount__c += currentAllocation.Amount__c;
                                            }
                                        } else {
                                            if (currentAllocation.Approved_Amount__c == null) {
                                                currentPayment.Total_Gift_Aid_Eligible_Amount__c += 0;
                                            } else {
                                                currentPayment.Total_Gift_Aid_Eligible_Amount__c += currentAllocation.Approved_Amount__c;
                                            }
                                        }
                                    }
                                } else {
                                    currentPayment.Total_Gift_Aid_Eligible_Amount__c = 0;
                                }
                            }
                        }

                        if(currentPayment.Gift_Aid_Declaration__c != null && declarationsMappedByContact.get(currentPayment.Gift_Aid_Declaration__c) != null){
                            if(declarationsMap.get(currentPayment.Gift_Aid_Declaration__c).isActive__c == false && currentPayment.Gift_Aid_Claim_Status__c == 'Not claimed'){
                                currentPayment.Gift_Aid_Declaration__c = null;
                            }
                        }

                        if(currentPayment.Gift_Aid_Declaration__c == null && currentPayment.Gift_Aid_Eligible__c == true){
                            Contact currentContact = contactMap.get(Utilities.DecodeHyperLinkedId(currentPayment.Constituent__c));
                            currentPayment.First_Name__c = (currentContact.FirstName != null) ? currentContact.FirstName : '';
                            currentPayment.Last_Name__c = (currentContact.LastName != null) ? currentContact.LastName : '';
                            currentPayment.House_Number__c = (currentContact.MailingStreet != null) ? currentContact.MailingStreet : '';
                            currentPayment.Postal_Code__c = (currentContact.MailingPostalCode != null) ? currentContact.MailingPostalCode : '';

                            if(declarationsMappedByContact.get(Utilities.DecodeHyperLinkedId(currentPayment.Constituent__c)) != null){
                                for (Gift_Aid_Declaration__c currentDeclaration : declarationsMappedByContact.get(Utilities.DecodeHyperLinkedId(currentPayment.Constituent__c))) {
                                    if (currentDeclaration.End_Date__c != null) {
                                        if (currentPayment.Date__c >= currentDeclaration.Effective_Date__c && currentPayment.Date__c < currentDeclaration.End_Date__c && currentPayment.Gift_Aid_Claim_Status__c == 'Not claimed') {
                                            currentPayment.Gift_Aid_Declaration__c = currentDeclaration.Id;
                                        }
                                    } else if (currentPayment.Date__c >= currentDeclaration.Effective_Date__c && currentPayment.Gift_Aid_Claim_Status__c == 'Not claimed') {
                                        currentPayment.Gift_Aid_Declaration__c = currentDeclaration.Id;
                                    } else if (currentPayment.Gift_Aid_Claim_Status__c == 'Not claimed') {
                                        currentPayment.Gift_Aid_Declaration__c = null;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if (Validator_cls.HasGiftAidPaymentBeforeRunInsert()) {
                Validator_cls.GiftAidPaymentBeforeRunInsert();
            } else if (Validator_cls.HasGiftAidPaymentBeforeRunUpdate()) {
                Validator_cls.GiftAidPaymentBeforeRunUpdate();
            }
        }



        list<Gift__c  > giftsToBeUpdated = new list<Gift__c >();
        list<string> paymentsIdsToUpdateAllocation = new list<string>();
        decimal totalAmountClaimed = 0;
        decimal totalAmountForEligibleAmount = 0;
        list<string> giftIds = new list<string>();

        if (Trigger.isAfter && (Validator_cls.HasGiftAidPaymentAfterRunInsert() || Validator_cls.HasGiftAidPaymentAfterRunUpdate())) {

            if (Trigger.isInsert ) {
                for (Payment__c tempPayment : trigger.new) {
                    giftIds.add(tempPayment.Donation__c );
                }
            }

            if (Trigger.isUpdate) {
                for (Payment__c tempPayment : trigger.new) {
                    giftIds.add(tempPayment.Donation__c );
                }
            }
            fields = ''+ Utilities.PackageNamespace + 'Total_GA_Claimed__c,'+ Utilities.PackageNamespace + 'Total_Gift_Aid_Eligible_Amount__c,name';
            subFields = 'name,'+ Utilities.PackageNamespace + 'Gift_Aid_Amount__c,'+ Utilities.PackageNamespace + 'Total_Gift_Aid_Eligible_Amount__c,'+ Utilities.PackageNamespace + 'Gift_Aid_Claim_Status__c';
            inFields = Converter.ConvertListSetToString(giftIds);
            clause = ' WHERE id IN ('+ inFields +')';

            giftsToBeUpdated = new GenericQueryBuilder().QueryBuilderWithSubQuery(Gift__c..sObjectType, fields, clause, Payment__c.sObjectType, 'Recurring_Payments__r', subFields, '');
            if (Trigger.isdelete ) {
                for (Payment__c tempPayment : trigger.old) {
                    giftIds.add(tempPayment.Donation__c );
                }
                inFields = Converter.ConvertListSetToString(giftIds);
                clause = ' WHERE id IN ('+ inFields +')';
                giftsToBeUpdated = new GenericQueryBuilder().QueryBuilderWithSubQuery(Gift__c.sObjectType, fields, clause, Payment__c.sObjectType, 'Recurring_Payments__r', subFields, '');
            }

            if (giftsToBeUpdated.size() > 0) {
                for (Gift__c tempGift : giftsToBeUpdated) {
                    totalAmountClaimed = 0;
                    totalAmountForEligibleAmount = 0;
                    for (Payment__c tempPayment :  tempGift.Recurring_Payments__r) {
                        if (tempPayment.Gift_Aid_Claim_Status__c != 'Not claimed' && tempPayment.Gift_Aid_Claim_Status__c != null) {
                            totalAmountClaimed += tempPayment.Gift_Aid_Amount__c;
                            if (tempPayment.Total_Gift_Aid_Eligible_Amount__c == null) {
                                totalAmountForEligibleAmount += 0;
                            } else {
                                totalAmountForEligibleAmount += tempPayment.Total_Gift_Aid_Eligible_Amount__c;
                            }
                        } else {
                            if (tempPayment.Total_Gift_Aid_Eligible_Amount__c == null) {
                                totalAmountForEligibleAmount += 0;
                            } else {
                                totalAmountForEligibleAmount += tempPayment.Total_Gift_Aid_Eligible_Amount__c;
                            }
                        }
                    }
                    tempGift.Total_GA_Claimed__c = totalAmountClaimed;
                    tempGift.Total_Gift_Aid_Eligible_Amount__c = totalAmountForEligibleAmount;
                }
            }


            if (giftsToBeUpdated.size() > 0) {
                update giftsToBeUpdated;
            }
            if (Validator_cls.HasGiftAidPaymentAfterRunInsert()) {
                Validator_cls.GiftAidPaymentAfterRunInsert();
            } else if (Validator_cls.HasGiftAidPaymentAfterRunUpdate()) {
                Validator_cls.GiftAidPaymentAfterRunUpdate();
            }

        }
    }
}