public class DuplicateConstituentIdUpdateBatch implements Database.Batchable<sObject>, Database.stateful {
    String logFileData ='Id, Old Constituent Id, New Constituent Id\n';
    public Database.queryLocator start(Database.BatchableContext BC){
        string fields ='Constituent_ID__c, CreatedDate, LastModifiedDate';
        string clause = 'order by CreatedDate ASC';
        return new GenericQueryBuilder().getQueryLocator(clause, fields, 'Contact');
    }

    public void execute(Database.BatchableContext BC, List<Contact> con){
        Map<Id, Contact> contactToUpdate = new Map<Id, Contact>();
        Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();
        Map<String, List<Account>> accountMap = new  Map<String, List<Account>>();
        aNums__c s = aNums__c.getInstance('Default');
        if (s == null) { return; }
        Set<String> constituentIds = new Set<String>();
        Set<Id> contactIds = new Set<Id>();
        for(Contact c : con){
            constituentIds.add(c.Constituent_ID__c);
            contactIds.add(c.id);
        }
        Application_Setting__c autoNumberSetting;
        List<Application_Setting__c> appSettingsList = new ApplicationSettingSelector().SelectSObjectsByNameLimitForUpdate('Auto Number Setting', 1);
        if (appSettingsList != null && appSettingsList.size() > 0) {
            autoNumberSetting = appSettingsList[0];
        }
        for(Contact duplicateCon : new ContactSelector().SelectConstituentIdByConstituentId(constituentIds)){
            if(!contactMap.containsKey(duplicateCon.Constituent_ID__c)){
                contactMap.put(duplicateCon.Constituent_ID__c, new List<Contact>());
            }
            contactMap.get(duplicateCon.Constituent_ID__c).add(duplicateCon);
        }
        for(Account accRecord : new AccountSelector().SelectOrganizationIdById(constituentIds)){
            if(!accountMap.containsKey(accRecord.Organization_ID__c)){
                accountMap.put(accRecord.Organization_ID__c, new List<Account>());
            }
            accountMap.get(accRecord.Organization_ID__c).add(accRecord);
        }
        if(contactMap.size() > 0 || accountMap.size() > 0){
            for(Contact c : con){
                string contactConstitentId = c.Constituent_ID__c;
                if(contactMap.get(contactConstitentId) != null){
                    for(Contact cc : contactMap.get(contactConstitentId)){
                        if(c.Constituent_ID__c == cc.Constituent_ID__c && c.id != cc.id){
                            if(c.CreatedDate >= cc.CreatedDate){
                                if(contactToUpdate.containsKey(c.id)){
                                    continue;
                                }
                                logFileData += c.Id + ', ' + c.Constituent_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.Org_Count__c).length() < s.OrgLength__c) {
                                    for (Integer i = 0; i < (s.OrgLength__c - String.valueOf(autoNumberSetting.Org_Count__c).length()-2); i++) {
                                        prefix+= '0';
                                    }
                                }
                                c.Constituent_ID__c = s.OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.Org_Count__c.round());
                                autoNumberSetting.Org_Count__c++;
                                logFileData += c.Constituent_ID__c+ '\n';
                                contactToUpdate.put(c.id, c);
                            }
                        }
                    }
                }
                if(accountMap.get(contactConstitentId) != null){
                    for(Account aa : accountMap.get(contactConstitentId)){
                        if(c.Constituent_ID__c == aa.Organization_ID__c){
                            if(c.CreatedDate >= aa.CreatedDate){
                                if(contactToUpdate.containsKey(c.id)){
                                    continue;
                                }
                                logFileData += c.Id + ', ' + c.Constituent_ID__c +', ';
                                String prefix = '';
                                if (String.valueOf(autoNumberSetting.Org_Count__c).length() < s.OrgLength__c) {
                                    for (Integer i = 0; i < (s.OrgLength__c - String.valueOf(autoNumberSetting.Org_Count__c).length()-2); i++) {
                                        prefix+= '0';
                                    }
                                }
                                c.Constituent_ID__c = s.OrgPrefix__c + prefix + String.valueOf(autoNumberSetting.Org_Count__c.round());
                                autoNumberSetting.Org_Count__c++;
                                logFileData += c.Constituent_ID__c+ '\n';
                                contactToUpdate.put(c.id, c);
                            }
                        }
                    }
                }
            }
            if(contactToUpdate.size() > 0){
                List<Contact> contactToUpdateList = new List<Contact>();
                contactToUpdateList = contactToUpdate.values();
                DMLManager.UpdateSObjects(contactToUpdateList);
            }
        }
        DMLManager.UpdateSObject(autoNumberSetting);
    }

    public void finish(Database.BatchableContext BC){
        if (String.isNotBlank(logFileData) == true){
            Document doc = new Document (Name = 'ContactBatchLog'+DateTime.now().format() + '.txt');
            doc.Description = '';
            doc.FolderId = UserInfo.getUserId();
            doc.Body = Blob.valueOf(logFileData);
            DMLManager.InsertSObject(doc);
        }
    }
}