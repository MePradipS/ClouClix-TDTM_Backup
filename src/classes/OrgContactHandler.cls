public class OrgContactHandler {
    public static void CascadeHouseholdAddress(List<Account> cOld, List<Account> cNew) {
        List<RecordType> rtypes = new RecordTypeSelector().SelectByNameSpaceObjectTypeAndIsActive('Account', Utilities.getCurrentNamespace(), true );
        Map<String, String> accountRecordTypes = new Map<String, String> {};
        for (RecordType rt : rtypes) {
            accountRecordTypes.put(rt.Name, rt.Id);
        }

        Set<Id> AIDs = new Set<Id>();
        for (Integer i = 0; i < Trigger.old.size(); i++) {
            if (cOld[i].BillingStreet == cNew[i].BillingStreet &&
                    cOld[i].BillingCity == cNew[i].BillingCity &&
                    cOld[i].BillingPostalCode == cNew[i].BillingPostalCode &&
                    cOld[i].BillingState == cNew[i].BillingState &&
                    cOld[i].BillingCountry == cNew[i].BillingCountry &&
                    cOld[i].Phone == cNew[i].Phone &&
                    cOld[i].Household_Addressee__c == cNew[i].Household_Addressee__c &&
                    cOld[i].Household_Salutation__c == cNew[i].Household_Salutation__c)
            { continue; }
            AIDS.add(cNew[i].Id);
        }


        List<Contact> ContactSet = new List<Contact>();
        List<Account> theAccounts = new AccountSelector().SelectBillingAndHouseholdContactsByIdAndRecordTypeId(AIDS, accountRecordTypes.get('Household'));

        for (Account a : theAccounts) {
            for (Contact c : a.HouseholdContacts__r) {
                if (c.Use_Household_Salutation_Addressee__c == True) {
                    c.Primary_Addressee__c = a.Household_Addressee__c;
                    c.Primary_Salutation__c = a.Household_Salutation__c;
                }

                if (c.Same_as_Household__c == True) {
                    c.HomePhone = a.Phone;
                    c.MailingStreet = a.BillingStreet;
                    c.MailingState = a.BillingState;
                    c.MailingCountry = a.BillingCountry;
                    c.MailingPostalCode = a.BillingPostalCode;
                    c.MailingCity = a.BillingCity;
                }

                ContactSet.add(c);
            }
        }

        if (ContactSet.size() > 0) {
            Validator_cls.setAlreadyDone1();
            DMLManager.UpdateSObjects(ContactSet);
        }
    }

    public static void PreventBucketDelete(List<Account> accounts) {
        BatchSettings__c settingList = BatchSettings__c.getInstance('Default');
        for (Account a : accounts) {
            if (a.Id == settingList.BucketAccountId__c && settingList.LockBucketAccount__c == True)
            { a.addError('Cannot delete the Guest Contact!'); }
        }
    }

    public static void PreventBucketModify(List<Account> aOld, List<Account> aNew) {
        BatchSettings__c settingList = BatchSettings__c.getInstance('Default');
        if (settingList != null) {
            for (Integer i = 0; i < aNew.size(); i++) {
                if (aNew[i].Id == settingList.BucketAccountId__c && settingList.LockBucketAccount__c == True && (aNew[i].Name != aOld[i].Name)) {
                    aNew[i].addError('Cannot modify the Guest Contact!');
                }
            }
        }
    }


    public static string GetNext(string type, aNums__c s) {
        Boolean stop = false;
        string prefix = '';
        string value = '';
        while (!stop) {
            prefix = '';
            if (type == 'Account') {
                if (String.valueOf(s.OrgCount__c).length() < s.OrgLength__c) {
                    for (Integer i = 0; i <= (s.OrgLength__c - String.valueOf(s.OrgCount__c).length()); i++) {
                        prefix += '0';
                    }
                }
                value = s.OrgPrefix__c + prefix + String.valueOf(s.OrgCount__c.round());
                s.OrgCount__c++;
                DMLManager.UpdateSObject(s);
            } else {
                if (String.valueOf(s.OrgCount__c).length() < s.OrgLength__c) {
                    for (Integer i = 0; i <= (s.OrgLength__c - String.valueOf(s.OrgCount__c).length()); i++) {
                        prefix += '0';
                    }
                }
                value = s.ContactPrefix__c + prefix + String.valueOf(s.OrgCount__c.round());
                s.OrgCount__c++;
                DMLManager.UpdateSObject(s);
            }
            stop = !IsAssigned(value, type, null);
        }

        return value;
    }
    public static boolean IsAssigned(string value, string type, string id) {
        return false;
    }

    public static void AutoNumber(List<sObject> constituents, string type) {
        Long BeginTime = DateTime.now().getTime();
        aNums__c s = aNums__c.getInstance('Default');
        if (s == null) { return; }
        if (!Test.isRunningTest()) {
            try {
                if (type == 'Account') {
                    List<Application_Setting__c> appList = new ApplicationSettingSelector().SelectSObjectsByNameLimitForUpdate('Auto Number Setting', 1);
                    Application_Setting__c app = (appList != null && appList.size() > 0) ? appList[0] : null;
                    List<Account> accountRec = (List<Account>)constituents;
                    Set<String> contOrgId = new Set<String>();
                    Set<Id> accID = new Set<Id>();
                    for (Account a : (List<Account>)constituents) {
                        if (a.Organization_ID__c == null) {
                            //next 8 lines uncommented and 9th line commented by nitin
                            String prefix = '';
                            if (String.valueOf(app.Org_Count__c).length() < s.OrgLength__c) {
                                for (Integer i = 0; i < (s.OrgLength__c - String.valueOf(app.Org_Count__c).length() - 2); i++) {
                                    prefix += '0';
                                }
                            }
                            a.Organization_ID__c = s.OrgPrefix__c + prefix + String.valueOf(app.Org_Count__c.round());
                            app.Org_Count__c++;
                        }
                        contOrgId.add(a.Organization_ID__c);
                        accID.add(a.id);
                    }

                    checkDuplicate(accountRec, contOrgId, accID, 'Account');
                    DMLManager.UpdateSObject(app);
                }
                if (type == 'Contact') {
                    List<Application_Setting__c> appList = new ApplicationSettingSelector().SelectSObjectsByNameLimitForUpdate('Auto Number Setting', 1);
                    Application_Setting__c app = (appList != null && appList.size() > 0) ? appList[0] : null;
                    List<Contact> conRec = (List<Contact>)constituents;
                    Set<String> contOrgId = new Set<String>();
                    Set<Id> conIds = new Set<Id>();
                    for (Contact c : (List<Contact>)constituents) {
                        if (c.Constituent_ID__c == null) {
                            //next 8 lines uncommented and 9th line commented by nitin
                            String prefix = '';
                            if (String.valueOf(app.Org_Count__c).length() < s.OrgLength__c) {
                                for (Integer i = 0; i < (s.OrgLength__c - String.valueOf(app.Org_Count__c).length() - 2); i++) {
                                    prefix += '0';
                                }
                            }
                            c.Constituent_ID__c = s.ContactPrefix__c + prefix + String.valueOf(app.Org_Count__c.round());
                            app.Org_Count__c++;
                        }
                        contOrgId.add(c.Constituent_ID__c);
                        conIds.add(c.id);
                    }

                    checkDuplicate(conRec, contOrgId, conIds, 'Contact');
                    DMLManager.UpdateSObject(app);
                }
            }
            catch (Exception ex) {
                Trigger.new[0].addError(ex); return;
            }

        }

        Long EndTime = DateTime.now().getTime();
        Long Difference = (EndTime - BeginTime);
    }

    public static void checkDuplicate(List<sObject> constituents, Set<string> conOrgIds, Set<Id> Ids, String type) {
        aNums__c s = aNums__c.getInstance('Default');
        if (type == 'Account') {
            List<Account> accountRecords = new AccountSelector().SelectOrganizationIdByOrganizationIdNotId(conOrgIds, Ids);
            if (accountRecords.size() > 0 ) {
                for (Account a : (List<Account>)constituents) {
                    String organization_Id = a.Organization_ID__c;
                    if (accountRecords.size() > 0) {
                        for (Account aa : accountRecords) {
                            if (organization_Id.equals(aa.Organization_ID__c)) {
                                a.addError('You have entered a duplicate Organziation ID');
                            }
                        }
                    }
                }
            }
        }
        if (type == 'Contact') {
            List<Contact> contactRecords = new ContactSelector().SelectConstituentIdByConstituentIdNotId(conOrgIds, Ids);
            if (contactRecords.size() > 0 ) {
                for (Contact c : (List<Contact>)constituents) {
                    String constituent_Id = c.Constituent_ID__c;
                    if (contactRecords.size() > 0) {
                        for (Contact cc : contactRecords) {
                            if (constituent_Id.equals(cc.Constituent_ID__c)) {
                                c.addError('You have entered a duplicate Constituent ID');
                            }
                        }
                    }
                }
            }
        }
    }

    public static void LegacyAddress(List<sObject> oldO, List<sObject> newO, string type) {
        List<Historical_Address__c> theAdds = new List<Historical_Address__c>();
        Historical_Address__c oldAdd;
        //if condition for type and Validator_cls.hasAlreadyDone() added by Nitin
        //To check record of contact object
        if (type == 'Contact') {
            //In few cases of contact records, trigger was firing twice. so it was creating two same
            //records of "other Address". To restrict on firing of trigger second time to create
            //record again I used this condition.
            if (!Validator_cls.hasAlreadyDone()) {
                Validator_cls.setAlreadyDone();
                //Validator_cls.setAlreadyDone1();
                List<Contact> cOld = (List<contact>)oldO;
                List<Contact> cNew = (List<contact>)newO;
                //Scott April-25-11: go through all the contact pairs
                for (Integer i = 0; i < cOld.size(); i++) {
                    //Scott April-25-11: all the address fields are identical, don't need to make any historical addies
                    if (cOld[i].MailingStreet == cNew[i].MailingStreet &&
                            cOld[i].MailingCity == cNew[i].MailingCity &&
                            cOld[i].MailingPostalCode == cNew[i].MailingPostalCode &&
                            cOld[i].MailingState == cNew[i].MailingState &&
                            cOld[i].MailingCountry == cNew[i].MailingCountry &&
                            cOld[i].OtherStreet == cNew[i].OtherStreet &&
                            cOld[i].OtherCity == cNew[i].OtherCity &&
                            cOld[i].OtherPostalCode == cNew[i].OtherPostalCode &&
                            cOld[i].OtherState == cNew[i].OtherState &&
                            cOld[i].OtherCountry == cNew[i].OtherCountry) {
                        continue;
                    }
                    //Scott April-25-11: there is a change to the Primary addie, lets archive the old one
                    if (cOld[i].MailingStreet != cNew[i].MailingStreet ||
                            cOld[i].MailingCity != cNew[i].MailingCity ||
                            cOld[i].MailingPostalCode != cNew[i].MailingPostalCode ||
                            cOld[i].MailingState != cNew[i].MailingState ||
                            cOld[i].MailingCountry != cNew[i].MailingCountry) {
                        if (cOld[i].MailingStreet != null ||
                                cOld[i].MailingCity != null ||
                                cOld[i].MailingCountry != null ||
                                cOld[i].MailingPostalCode != null ||
                                cOld[i].MailingState != null) {
                            oldAdd = new Historical_Address__c();
                            if (cOld[i].MailingStreet != null) {
                                if (cOld[i].MailingStreet.length() < 60) {
                                    if (cOld[i].MailingStreet.contains('\n')) {
                                        List<String> otheradd = cOld[i].MailingStreet.split('\n');
                                        oldAdd.Address_1__c = otheradd[0];
                                        oldAdd.Address_2__c = '';
                                        for (integer k = 1; k < otheradd.size(); k++) {
                                            oldAdd.Address_2__c += otheradd[k];
                                        }
                                    } else {
                                        oldAdd.Address_1__c = cOld[i].MailingStreet;
                                    }
                                }
                                if (cOld[i].MailingStreet.length() >= 60) {
                                    if (cOld[i].MailingStreet.contains('\n')) {
                                        List<String> otheradd = cOld[i].MailingStreet.split('\n');
                                        oldAdd.Address_1__c = otheradd[0];
                                        oldAdd.Address_2__c = '';
                                        for (integer k = 1; k < otheradd.size(); k++) {
                                            oldAdd.Address_2__c += otheradd[k];
                                        }
                                    } else {
                                        oldAdd.Address_1__c = cOld[i].MailingStreet.substring(0, 59);
                                    }
                                }
                            }
                            oldAdd.City__c = cOld[i].MailingCity;
                            oldAdd.Country__c = cOld[i].MailingCountry;
                            oldAdd.Postal_Code__c = cOld[i].MailingPostalCode;
                            oldAdd.Province__c = cOld[i].MailingState;
                            oldAdd.Date_To__c = Date.today();
                            oldAdd.Address_Type__c = 'Mailing';
                            oldAdd.Contact__c = cOld[i].Id;

                            //Scott April-25-11: Don't want to insert blank historical addies
                            theAdds.add(oldAdd);
                        }
                    }
                    //Scott April-25-11: there was a change to the secondary addie, lets archive the old one
                    if (cOld[i].OtherStreet != cNew[i].OtherStreet ||
                            cOld[i].OtherCity != cNew[i].OtherCity ||
                            cOld[i].OtherPostalCode != cNew[i].OtherPostalCode ||
                            cOld[i].OtherState != cNew[i].OtherState ||
                            cOld[i].OtherCountry != cNew[i].OtherCountry) {
                        if (cOld[i].OtherStreet != null ||
                                cOld[i].OtherCity != null ||
                                cOld[i].OtherCountry != null ||
                                cOld[i].OtherPostalCode != null ||
                                cOld[i].OtherState != null) {
                            oldAdd = new Historical_Address__c();
                            if (cOld[i].OtherStreet != null) {
                                if (cOld[i].OtherStreet.length() < 60) {
                                    if (cOld[i].OtherStreet.contains('\n')) {
                                        List<String> otheradd = cOld[i].OtherStreet.split('\n');
                                        oldAdd.Address_1__c = otheradd[0];
                                        oldAdd.Address_2__c = '';
                                        for (integer k = 1; k < otheradd.size(); k++) {
                                            oldAdd.Address_2__c += otheradd[k];
                                        }
                                    } else {
                                        oldAdd.Address_1__c = cOld[i].OtherStreet;
                                    }
                                }
                                if (cOld[i].OtherStreet.length() >= 60) {
                                    if (cOld[i].OtherStreet.contains('\n')) {
                                        List<String> otheradd = cOld[i].OtherStreet.split('\n');
                                        oldAdd.Address_1__c = otheradd[0];
                                        oldAdd.Address_2__c = '';
                                        for (integer k = 1; k < otheradd.size(); k++) {
                                            oldAdd.Address_2__c += otheradd[k];
                                        }
                                    } else {
                                        oldAdd.Address_1__c = cOld[i].OtherStreet.substring(0, 59);
                                    }
                                }
                            }
                            oldAdd.City__c = cOld[i].OtherCity;
                            oldAdd.Country__c = cOld[i].OtherCountry;
                            oldAdd.Postal_Code__c = cOld[i].OtherPostalCode;
                            oldAdd.Province__c = cOld[i].OtherState;
                            oldAdd.Date_To__c = Date.today();
                            oldAdd.Address_Type__c = 'Other';
                            oldAdd.Contact__c = cOld[i].Id;

                            //Scott April-25-11: Don't want to insert blank historical addies
                            theAdds.add(oldAdd);
                        }
                    }
                }
            }
        }
        //To create "other address" record for Account
        Map<ID, Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
        if (type == 'Account') {
            List<Account> acOld = (List<Account>)oldO;
            List<Account> acNew = (List<Account>)newO;
            //Scott April-25-11: go through all the contact pairs
            for (Integer i = 0; i < acOld.size(); i++) {
                //Scott April-25-11: all the address fields are identical, don't need to make any historical addies
                if (acOld[i].BillingStreet == acNew[i].BillingStreet &&
                        acOld[i].BillingCity == acNew[i].BillingCity &&
                        acOld[i].BillingPostalCode == acNew[i].BillingPostalCode &&
                        acOld[i].BillingState == acNew[i].BillingState &&
                        acOld[i].BillingCountry == acNew[i].BillingCountry &&
                        acOld[i].ShippingStreet == acNew[i].ShippingStreet &&
                        acOld[i].ShippingCity == acNew[i].ShippingCity &&
                        acOld[i].ShippingPostalCode == acNew[i].ShippingPostalCode &&
                        acOld[i].ShippingState == acNew[i].ShippingState &&
                        acOld[i].ShippingCountry == acNew[i].ShippingCountry) {
                    continue;
                }
                //Scott April-25-11: there is a change to the Primary addie, lets archive the old one
                if (acOld[i].BillingStreet != acNew[i].BillingStreet ||
                        acOld[i].BillingCity != acNew[i].BillingCity ||
                        acOld[i].BillingPostalCode != acNew[i].BillingPostalCode ||
                        acOld[i].BillingState != acNew[i].BillingState ||
                        acOld[i].BillingCountry != acNew[i].BillingCountry) {
                    if (acOld[i].BillingStreet != null || acOld[i].BillingStreet != '' ||
                            acOld[i].BillingCity != null || acOld[i].BillingCity != '' ||
                            acOld[i].BillingCountry != null || acOld[i].BillingCountry != '' ||
                            acOld[i].BillingPostalCode != null || acOld[i].BillingPostalCode != '' ||
                            acOld[i].BillingState != null || acOld[i].BillingState != '') {
                        oldAdd = new Historical_Address__c();
                        if (acOld[i].BillingStreet != null) {
                            if (acOld[i].BillingStreet.length() < 60) {
                                if (acOld[i].BillingStreet.contains('\n')) {
                                    List<String> otheradd = acOld[i].BillingStreet.split('\n');
                                    oldAdd.Address_1__c = otheradd[0];
                                    oldAdd.Address_2__c = '';
                                    for (integer k = 1; k < otheradd.size(); k++) {
                                        oldAdd.Address_2__c += otheradd[k];
                                    }
                                } else {
                                    oldAdd.Address_1__c = acOld[i].BillingStreet;
                                }
                            }
                            if (acOld[i].BillingStreet.length() >= 60) {
                                if (acOld[i].BillingStreet.contains('\n')) {
                                    List<String> otheradd = acOld[i].BillingStreet.split('\n');
                                    oldAdd.Address_1__c = otheradd[0];
                                    oldAdd.Address_2__c = '';
                                    for (integer k = 1; k < otheradd.size(); k++) {
                                        oldAdd.Address_2__c += otheradd[k];
                                    }
                                } else {
                                    oldAdd.Address_1__c = acOld[i].BillingStreet.substring(0, 59);
                                }
                            }
                        }
                        oldAdd.City__c = acOld[i].BillingCity;
                        oldAdd.Country__c = acOld[i].BillingCountry;
                        oldAdd.Postal_Code__c = acOld[i].BillingPostalCode;
                        oldAdd.Province__c = acOld[i].BillingState;
                        oldAdd.Date_To__c = Date.today();
                        //oldAdd.Address_Type__c = 'Billing';
                        //Scott April-25-11: attach the Historical_Address__c to the org
                        oldAdd.Organization__c = acOld[i].Id;

                        if (rt_map.get(acOld[i].recordTypeID) != null && rt_map.get(acOld[i].recordTypeID).getName() == 'Household') { //story:#106969638
                            oldAdd.Address_Type__c = 'Previous';
                        } else {
                            oldAdd.Address_Type__c = 'Billing';
                        }

                        //Scott April-25-11: Don't want to insert blank historical addies
                        theAdds.add(oldAdd);
                    }
                }

                //Scott April-25-11: there was a change to the secondary addie, lets archive the old one
                if (acOld[i].ShippingStreet != acNew[i].ShippingStreet ||
                        acOld[i].ShippingCity != acNew[i].ShippingCity ||
                        acOld[i].ShippingPostalCode != acNew[i].ShippingPostalCode ||
                        acOld[i].ShippingState != acNew[i].ShippingState ||
                        acOld[i].ShippingCountry != acNew[i].ShippingCountry) {
                    if (acOld[i].ShippingStreet != null ||
                            acOld[i].ShippingCity != null ||
                            acOld[i].ShippingCountry != null ||
                            acOld[i].ShippingPostalCode != null ||
                            acOld[i].ShippingState != null) {
                        oldAdd = new Historical_Address__c();
                        if (acOld[i].ShippingStreet != null) {
                            if (acOld[i].ShippingStreet.length() < 60) {
                                if (acOld[i].ShippingStreet.contains('\n')) {
                                    List<String> otheradd = acOld[i].ShippingStreet.split('\n');
                                    oldAdd.Address_1__c = otheradd[0];
                                    oldAdd.Address_2__c = '';
                                    for (integer k = 1; k < otheradd.size(); k++) {
                                        oldAdd.Address_2__c += otheradd[k];
                                    }
                                } else {
                                    oldAdd.Address_1__c = acOld[i].ShippingStreet;
                                }
                            }
                            if (acOld[i].ShippingStreet.length() >= 60) {
                                if (acOld[i].ShippingStreet.contains('\n')) {
                                    List<String> otheradd = acOld[i].ShippingStreet.split('\n');
                                    oldAdd.Address_1__c = otheradd[0];
                                    oldAdd.Address_2__c = '';
                                    for (integer k = 1; k < otheradd.size(); k++) {
                                        oldAdd.Address_2__c += otheradd[k];
                                    }
                                } else {
                                    oldAdd.Address_1__c = acOld[i].ShippingStreet.substring(0, 59);
                                }
                            }
                        }
                        oldAdd.City__c = acOld[i].ShippingCity;
                        oldAdd.Country__c = acOld[i].ShippingCountry;
                        oldAdd.Postal_Code__c = acOld[i].ShippingPostalCode;
                        oldAdd.Province__c = acOld[i].ShippingState;
                        oldAdd.Date_To__c = Date.today();
                        oldAdd.Address_Type__c = 'Shipping';
                        //Scott April-25-11: Attach the Historical_Address__c to the org
                        oldAdd.Organization__c = acOld[i].Id;

                        //Scott April-25-11: Don't want to insert blank historical addies
                        theAdds.add(oldAdd);
                    }
                }
            }
        }

        if (theAdds.size() > 0) {
            DMLManager.InsertSObjects(theAdds);
        }
    }

    public static void LegacyAddressOfHousehold(List<Contact> contNew) {  //story:#106969638

        if (!Validator_cls.hasAlreadyDone1()) {
            map<string, list<contact>> hhToContMap = new map<string, list<contact>>();
            for (contact con : contNew ) {
                if (con.Household__c != null && con.Same_as_Household__c == true && con.MailingStreet != null && con.MailingCity != null  && con.MailingPostalCode != null  && con.MailingState != null && con.MailingCountry != null) {
                    if (hhToContMap.containsKey(con.Household__c)) {
                        hhToContMap.get(con.Household__c).add(con);
                    } else {
                        list<contact> temp = new list<contact>();
                        temp.add(con);
                        hhToContMap.put(con.Household__c, temp);
                    }
                }
            }

            if (hhToContMap.size() > 0) { //story:#136743073
                list<account> accts = new AccountSelector().SelectBillingAndShippingById(Utilities.ConvertStringSetToIdSet(hhToContMap.keySet()));
                for (account acc : accts) {
                    acc.BillingStreet = hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size()) - 1].MailingStreet;
                    acc.BillingCity = hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size()) - 1].MailingCity;
                    acc.BillingPostalCode = hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size()) - 1].MailingPostalCode;
                    acc.BillingState = hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size()) - 1].MailingState;
                    acc.BillingCountry = hhToContMap.get(acc.id)[(hhToContMap.get(acc.id).size()) - 1].MailingCountry;

                }
                DMLManager.UpdateSObjects(accts);
            }
        }
    }

    public static void PopulateBucketAccount(List<sObject> constituents) {
        BatchSettings__c setting = BatchSettings__c.getInstance('Default');
        for (Contact c : (List<contact>)constituents) {
            if (c.AccountId == null && setting != null)
            { c.AccountId = setting.BucketAccountId__c; }
        }
    }

    //@future
    public static void CreateHouseholdupdate(List<sObject> constituents) {
        App_Settings__c cs = App_Settings__c.getInstance();
        BatchSettings__c setting = BatchSettings__c.getInstance('Default');
        List<RecordType> retype = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectType('Account', 'Household', Utilities.getCurrentNamespace());
        List<Account> households = new List<Account>();
        List<Contact> conList = new List<Contact>();
        Map<String, Account> contact_to_household = new Map<String, Account>();
        if (retype.size() > 0) {
            for (Contact c : (List<contact>) constituents) {
                if ((c.Household__c == null && ((cs.Auto_Create_Household__c == 'IND' && c.AccountId == setting.BucketAccountId__c) || cs.Auto_Create_Household__c == 'ALL')) && retype.size() > 0) {
                    String acName = '';
                    if (c.Salutation != null) {
                        acName += c.Salutation + ' ';
                    }
                    if (c.FirstName != null) {
                        acName += c.FirstName + ' ';
                    }
                    if (c.LastName != null) {
                        acName += c.LastName;
                    }

                    Account acObj = new Account (Name = acName + ' ' + 'Household',
                                                 BillingStreet = c.MailingStreet, Phone = c.HomePhone, BillingCity = c.MailingCity, BillingCountry = c.MailingCountry,
                                                 BillingPostalCode = c.MailingPostalCode, BillingState = c.MailingState, Household_Addressee__c = c.Primary_Addressee__c,
                                                 Household_Salutation__c = c.Primary_Salutation__c, Email__c = c.Email, RecordTypeId = retype[0].Id);
                    if (acObj.Household_Addressee__c == null) {
                        acObj.Household_Addressee__c = c.Salutation == null ? c.FirstName + ' ' + c.LastName : c.Salutation + ' ' + c.FirstName + ' ' + c.LastName;
                    }
                    if (acObj.Household_Salutation__c == null) {
                        acObj.Household_Salutation__c = c.Salutation == null ? c.FirstName + ' ' + c.LastName : c.Salutation + ' ' + c.LastName;
                    }
                    households.add(acObj);
                    c.Household_Primary_Contact__c = true;
                    //commented by nitin
                    contact_to_household.put(c.Id, acObj);
                    if (c.FirstName != null && c.Email != null) {
                        contact_to_household.put(c.FirstName + c.LastName + c.Email, acObj);
                    } else if (c.FirstName == null && c.Email != null) {
                        contact_to_household.put(c.LastName + c.Email, acObj);
                    } else if (c.FirstName != null && c.Email == null) {
                        contact_to_household.put(c.FirstName + c.LastName, acObj);
                    } else if (c.FirstName == null && c.Email == null) {
                        contact_to_household.put(c.LastName, acObj);
                    }
                }
            }
        }

        if (households.size() > 0) {
            DMLManager.InsertSObjects(households);
        }

        for (Contact c : (List<contact>) constituents) {
            //commented by nitin
            Account hh;
            if (contact_to_household.get(c.Id) != null) {
                hh = contact_to_household.get(c.Id);
            }

            //Account hh = new Account();
            if (c.FirstName != null && c.Email != null) {
                hh = contact_to_household.get(c.FirstName + c.LastName + c.Email);
            } else if (c.FirstName == null && c.Email != null) {
                hh = contact_to_household.get(c.LastName + c.Email);
            } else if (c.FirstName != null && c.Email == null) {
                hh = contact_to_household.get(c.FirstName + c.LastName);
            } else if (c.FirstName == null && c.Email == null) {
                hh = contact_to_household.get(c.LastName);
            }

            if (hh != null) {
                c.Household__c = hh.Id;
                c.Same_as_Household__c = true;
                c.Use_Household_Salutation_Addressee__c = true;
            }
        }
    }


    public static void UpdateHouseholdRollups(List<Contact> cOld, List<Contact> cNew) {
        Set<Id> cIds = new Set<Id>();
        if (cOld == null) {
            for (Contact c : cNew) {
                cIds.add(c.Household__c);
            }
        }
        if (cNew == null) {
            for (Contact c : cOld) {
                cIds.add(c.Household__c);
            }
        } else {
            for (Integer i = 0; i < cNew.size(); i++) {
                if (cOld[i].Household__c != cNew[i].Household__c) {
                    cIds.add(cNew[i].Household__c);
                }
            }
        }
        RollupHelper.RecalculateTotalHouseholdGiving(cIds);
    }
}