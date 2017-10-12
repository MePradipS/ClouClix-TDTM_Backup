public class DuplicateOrganisationIdUpdateBatch implements Database.Batchable<sObject>, Database.stateful {
    String logFileData ='Id, Old Constituent Id, New Constituent Id\n';
    public Database.queryLocator start(Database.BatchableContext BC){
        string fields ='Organization_ID__c, CreatedDate';
        string clause = 'order by CreatedDate ASC';
        return new GenericQueryBuilder().getQueryLocator(clause, fields, 'Account');
    }

    public void execute(Database.BatchableContext BC, List<Account> acc){
        Map<Id, Account> accountToUpdate = new Map<Id, Account>();
        Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();
        Map<String, List<Account>> accountMap = new  Map<String, List<Account>>();
        aNums__c s = aNums__c.getInstance('Default');
        if (s == null) { return; }
        Set<String> organisationIds = new Set<String>();
        Set<Id> accounttIds = new Set<Id>();
        for(Account a : acc){
            organisationIds.add(a.Organization_ID__c);
            accounttIds.add(a.id);
        }
        Application_Setting__c autoNumberSetting;
        List<Application_Setting__c> autoNumberSettingList = new ApplicationSettingSelector().SelectSObjectsByNameLimitForUpdate('Auto Number Setting', 1);
        if (autoNumberSettingList != null && autoNumberSettingList.size() > 0) {
            autoNumberSetting = autoNumberSettingList[0];
        }
        for(Contact duplicateCon : new ContactSelector().SelectConstituentIdByConstituentId(organisationIds)){
            if(!contactMap.containsKey(duplicateCon.Constituent_ID__c)){
                contactMap.put(duplicateCon.Constituent_ID__c, new List<Contact>());
            }
            contactMap.get(duplicateCon.Constituent_ID__c).add(duplicateCon);
        }
        for(Account accRecord : new AccountSelector().SelectOrganizationIdById(organisationIds)){
            if(!accountMap.containsKey(accRecord.Organization_ID__c)){
                accountMap.put(accRecord.Organization_ID__c, new List<Account>());
            }
            accountMap.get(accRecord.Organization_ID__c).add(accRecord);
        }
        if(contactMap.size() > 0 || accountMap.size() > 0){
            for(Account a : acc){
                String accountOrganisationID = a.Organization_ID__c;
                if(contactMap.get(accountOrganisationID) != null){
                    for(Contact cc : contactMap.get(accountOrganisationID)){
                        if(a.Organization_ID__c == cc.Constituent_ID__c){
                            if(a.CreatedDate >= cc.CreatedDate){
                                if(accountToUpdate.containsKey(a.id)){
                                    continue;
                                }
                                logFileData += a.Id + ', ' + a.Organization_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.Org_Count__c).length() < s.OrgLength__c) {
                                    for (Integer i = 0; i < (s.OrgLength__c - String.valueOf(autoNumberSetting.Org_Count__c).length()-2); i++) {
                                        prefix+= '0';
                                    }
                                }
                                a.Organization_ID__c = s.OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.Org_Count__c.round());
                                autoNumberSetting.Org_Count__c++;
                                logFileData += a.Organization_ID__c+ '\n';
                                accountToUpdate.put(a.id, a);
                            }
                        }
                    }
                }
                if(accountMap.get(accountOrganisationID) != null){
                    for(Account aa : accountMap.get(accountOrganisationID)){
                        if(a.Organization_ID__c == aa.Organization_ID__c && a.id != aa.id){
                            if(a.CreatedDate >= aa.CreatedDate){
                                if(accountToUpdate.containsKey(a.id)){
                                    continue;
                                }
                                logFileData += a.Id + ', ' + a.Organization_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.Org_Count__c).length() < s.OrgLength__c) {
                                    for (Integer i = 0; i < (s.OrgLength__c - String.valueOf(autoNumberSetting.Org_Count__c).length()-2); i++) {
                                        prefix+= '0';
                                    }
                                }
                                a.Organization_ID__c = s.OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.Org_Count__c.round());
                                autoNumberSetting.Org_Count__c++;
                                logFileData += a.Organization_ID__c+ '\n';
                                accountToUpdate.put(a.id, a);
                            }
                        }
                    }
                }
            }
            if(accountToUpdate.size() > 0) {
                List<Account> accountToUpdateList = new List<Account>();
                accountToUpdateList = accountToUpdate.values();
                DMLManager.UpdateSObjects(accountToUpdateList);
            }
        }
        DMLManager.UpdateSObject(autoNumberSetting);
    }

    public void finish(Database.BatchableContext BC){
        if (String.isNotBlank(logFileData) == true){
            Document doc = new Document (Name = 'AccountBatchLog'+DateTime.now().format() + '.txt');
            doc.Description = '';
            doc.FolderId = userInfo.getUserId();
            doc.Body = Blob.valueOf(logFileData);
            DMLManager.InsertSObject(doc);
        }
    }
}