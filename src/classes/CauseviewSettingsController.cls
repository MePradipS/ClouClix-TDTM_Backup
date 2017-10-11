public with sharing class CauseviewSettingsController {

    private static BatchSettings__c batchStaticSettings { get{
            return BatchSettings__c.getInstance('Default');
        }
    }

    private static App_Settings__c appStaticSettings { get{
            return App_Settings__c.getInstance();
        }
    }

    private static Id AccountHouseholdRecordTypeId { get; set; }
    private static Id AccountOrganizationRecordTypeId { get; set; }

    // list of Accont Record Types
    private static void getAccountRecordTypes() {
        List<RecordType> AccountRecordTypesList = new RecordTypeSelector().SelectBySObjectAndNamespace('Account');
        for (RecordType rt : AccountRecordTypesList) {
            if ( rt.Name == 'Household' ) {  AccountHouseholdRecordTypeId =  rt.Id; }
            if ( rt.Name == 'Organization' ) { AccountOrganizationRecordTypeId = rt.Id; }
        }
    }

    public CauseviewSettingsController() {
        init();
        settings = BatchSettings__c.getInstance('Default');
        activeBucketAccount = settings.BucketAccountId__c;
        historicalBucketAccountsString = settings.Historical_Bucket_Account_IDs__c;

        if (historicalBucketAccountsString != null)
            historicalBucketStringList = Utilities.SplitStringAtCommma(historicalBucketAccountsString, true);
            
        if (historicalBucketStringList != null)
            historicalBucketAccounts = new List<Account>(new AccountSelector().SelectIdNameById(Utilities.ConvertStringListToIdSet(historicalBucketStringList)));

        recordTypesToRollup = new List<String>();
        sortRecordTypes();
        sortPaymentTypes();
    }

    public void init() {
        getAccountRecordTypes();
    }

    private BatchSettings__c settings;

    private BatchSettings__c batchSettings { get{
            return BatchSettings__c.getInstance('Default');
        }
    }

    private String recordTypeIdsForRollups;
    public List<String> recordTypesToRollup {Get; Set;}
    private List<RecordType> selectRecordTypeList { Get; Set; }
    private List<RecordType> unselectRecordTypeList { Get; Set; }
    public List<SelectOption> unselectedPaymentTypesList {get; set;}
    public List<SelectOption> selectedPaymentTypesList {get; set;}
    public String recordTypesToUpdate { Get; Set; }
    public String paymentTypesToUpdate { Get; Set; }
    public String activeBucketAccount { Get; Set; }
    private String historicalBucketAccountsString { Get; Set; }
    public List<String> historicalBucketStringList { Get; Set; }
    public List<Account> historicalBucketAccounts { Get; Set;}
    public String newHistoricalBucketAccount { Get; Set; }
    public String bucketAccountIdToDelete { Get; Set; }
    public Static boolean jobProcess {Get; Set;}

    public Account currentBucketAccount { 
        get {
            Account cba = null;
            List<Account> currentBucketAccountList = new AccountSelector().SelectSObjectsById(new Set<Id> { batchSettings.BucketAccountId__c });
            if (currentBucketAccountList != null && currentBucketAccountList.size() > 0) {
                cba = currentBucketAccountList[0];
            }
            return cba;
        } set;
    }

    @RemoteAction
    public static Account currentStaticBucketAccount(String queryFields) {
        Account csba;
        List<Account> currentStaticBucketAccountList = new AccountSelector().SelectSObjectsById(new Set<Id> { batchStaticSettings.BucketAccountId__c });
        if (currentStaticBucketAccountList != null && currentStaticBucketAccountList.size() > 0) {
            csba = currentStaticBucketAccountList[0];
        }
        return csba;
    }

    @RemoteAction
    public static Account resetActiveBucketAccount(String currentId) {
        Account raba;
        List<Account> resetActiveBucketAccountList = new AccountSelector().SelectSObjectsById(new Set<Id> { currentId });
        if (resetActiveBucketAccountList != null && resetActiveBucketAccountList.size() > 0) {
            raba = resetActiveBucketAccountList[0];
        }
        return raba;
    }

    @RemoteAction
    public static Account getHistoricalBucketAccounts(String queryFields) {
        Account hba;
        Set<Id> idSet = Utilities.ConvertStringListToIdSet(Utilities.SplitStringAtCommma(batchStaticSettings.Historical_Bucket_Account_IDs__c, true));
        List<Account> historicalBucketAccountsList = new AccountSelector().SelectSObjectsById(idSet);
        if (historicalBucketAccountsList != null && historicalBucketAccountsList.size() > 0) {
            hba = historicalBucketAccountsList[0];
        }
        return hba;
    }

    // TODO: put in utility class, paramter list of any sObject
    public static String convertToCommaDelimitedString( List<Account> accountList ) {
        String collegeString = '';
        List<String> collegeList = new List<String>();
        for (String s : collegeList) {
            collegeString += (collegeString == '' ? '' : ',') + s;
        }
        return collegeString;
    }

    @RemoteAction
    public static List<Account> addNewHistroicalAccount(String accountId) {
        // TODO: method to serialize historicalBucketAccounts to List<Account>
        // TODO: method to add to Comma Delimited String
        try {
            if ( accountId != null ) {
                Account newHistoricalAccount;
                List<Account> newHistroicalAccountList = new AccountSelector().SelectSObjectsById(new Set<Id> { accountId });
                if (newHistroicalAccountList != null && newHistroicalAccountList.size() > 0) {
                    newHistoricalAccount = newHistroicalAccountList[0];
                }
                if (batchStaticSettings.Historical_Bucket_Account_IDs__c == '' || batchStaticSettings.Historical_Bucket_Account_IDs__c == null)
                    batchStaticSettings.Historical_Bucket_Account_IDs__c = newHistoricalAccount.Id;
                else
                    batchStaticSettings.Historical_Bucket_Account_IDs__c += ',' + newHistoricalAccount.Id;

                DMLManager.UpdateSObject(batchStaticSettings);

                //get new list
                return getHistoricalBucketAccountList(null);
            }
        } catch (DMLException e) {
            
        }
        return new List<Account>();
    }

    public static List<String> getHistoricalBucketAccountsAsList() {
        String settingsString = batchStaticSettings.Historical_Bucket_Account_IDs__c;
        List<String> stringList = new List<String>();
        List<Account> historicalBucketAccountList = new List<Account>();
        if (settingsString != null)
            stringList = Utilities.SplitStringAtCommma(settingsString, true);
        return stringList;
    }

    @RemoteAction
    public static List<Account> DeleteHistroicalAccount(String accountId) {
        List<String> historicalBucketStringList = getHistoricalBucketAccountsAsList();
        String random = '';
        try {
            if ( accountId != null ) {
                for (String the : historicalBucketStringList) {
                    if ( the != accountId )
                        random += the + ',';
                }
                random = random.removeEnd(',');
                batchStaticSettings.Historical_Bucket_Account_IDs__c = random;
                DMLManager.UpdateSObject(batchStaticSettings);
            }
        } catch (DMLException e) {
            
        }
        
        Set<Id> idSet = Utilities.ConvertStringListToIdSet(historicalBucketStringList);
        return new AccountSelector().SelectSObjectsById(idSet);
    }

    @RemoteAction
    public static List<Account> getHistoricalBucketAccountList(String s) {
        String settingsString = batchStaticSettings.Historical_Bucket_Account_IDs__c;
        List<String> stringList = new List<String>();
        List<Account> historicalBucketAccountList = new List<Account>();
        if (settingsString != null)
            stringList = Utilities.SplitStringAtCommma(settingsString, true);

        if (stringList != null)
            historicalBucketAccountList = new List<Account>(new AccountSElector().SelectIdNameById(Utilities.ConvertStringListToIdSet(stringList)));

        return historicalBucketAccountList;
    }

    @RemoteAction
    public static List<Account> getHistoricalBAccounts(String keyword) {
        getAccountRecordTypes();
        List<String> HistoricalBucketAccountsList = getHistoricalBucketAccountsAsList();
        // TODO: where account not historical bucket account list
        List<Account> a = new List<Account>();
        if (keyword != null && keyword.trim() != '') {
            a = new AccountSelector().SelectIdNameByNameIdRecordTypeIdLimit(keyword, batchStaticSettings.BucketAccountId__c, AccountHouseholdRecordTypeId, HistoricalBucketAccountsList, 10);
        } else {
            // TODO: fix this
            a = new AccountSelector().SelectIdNameByIdRecordTypeIdLimit(batchStaticSettings.BucketAccountId__c, AccountHouseholdRecordTypeId, HistoricalBucketAccountsList, 10);
        }
        return a;
    }

    @RemoteAction
    public static String updateActiveBucketAccount(String id) {
        try {
            BatchSettings__c batchSettings = BatchSettings__c.getInstance('Default');
            batchSettings.BucketAccountId__c = id;
            DMLManager.UpdateSObject(batchSettings);
        } catch (System.DmlException e) {
            return 'ERROR';
        }
        return 'SUCCESS';
    }

    private void sortRecordTypes() {
        recordTypeIdsForRollups = settings.Record_Type_Id_for_Rollups__c;
        selectRecordTypeList = new List<RecordType>();
        unselectRecordTypeList = new List<RecordType>();
        for (RecordType r : new RecordTypeSelector().SelectGiftSObjectByNotName('Gift__c', new List<String> { 'Gift', 'Pledge' })) {
            if ( recordTypeIdsForRollups != null && recordTypeIdsForRollups.contains( String.valueOf(r.Id) ) ) {
                selectRecordTypeList.add(r);
            } else {
                unselectRecordTypeList.add(r);
            }
        }
    }

    private void sortPaymentTypes() {
        Schema.DescribeFieldResult fieldResult = Payment__c.Payment_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        selectedPaymentTypesList = new List<SelectOption>();
        unselectedPaymentTypesList = new List<SelectOption>();
        for ( Schema.PicklistEntry f : ple) {
            if (appStaticSettings.Gift_Aid_Eligible_Payment_Types__c != null && appStaticSettings.Gift_Aid_Eligible_Payment_Types__c.contains(f.getValue())) {
                unselectedPaymentTypesList.add(new SelectOption(f.getLabel(), f.getValue()));
            } else {
                selectedPaymentTypesList.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }
    }

    public String getUnselectedRecordTypes() {
        JSONGenerator gen = JSON.createGenerator(true);
        if (unselectRecordTypeList.isEmpty() && unselectRecordTypeList == null) {
            gen.writeStartObject();
            gen.writeEndObject();
        } else {
            gen.writeStartArray();
            for (RecordType t : unselectRecordTypeList) {
                gen.writeStartObject();
                gen.writeStringField('id', t.ID);
                gen.writeStringField('label', t.Name);
                gen.writeEndObject();
            } gen.writeEndArray();
        } return gen.getAsString();
    }

    public String getSelectedRecordTypes() {
        JSONGenerator gen = JSON.createGenerator(true);
        if (selectRecordTypeList.isEmpty() && selectRecordTypeList == null) {
            gen.writeStartObject();
            gen.writeEndObject();
        } else {
            gen.writeStartArray();
            for (RecordType t : selectRecordTypeList) {
                gen.writeStartObject();
                gen.writeStringField('id', t.ID);
                gen.writeStringField('label', t.Name);
                gen.writeEndObject();
            } gen.writeEndArray();
        } return gen.getAsString();
    }

    public void updateRecordTypes() {
        JSONParser parser = JSON.createParser( recordTypesToUpdate );
        String ids = '';
        while (parser.nextToken() != null) {
            if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id') ) {
                parser.nextToken();
                ids += parser.getText() + ',';
                parser.nextToken(); parser.nextToken();
            }
        }
        ids = ids.removeEnd(',');
        try {
            if ( ids == null ) {
                settings.Record_Type_Id_for_Rollups__c = '';
            } else {
                settings.Record_Type_Id_for_Rollups__c = ids;
            }
            DMLManager.UpdateSObject(settings);
        } catch (DMLException e) {
            
        }
    }

    public String getUnselectedPaymentTypes() {
        JSONGenerator gen = JSON.createGenerator(true);
        if (unselectedPaymentTypesList.isEmpty() && unselectedPaymentTypesList == null) {
            gen.writeStartObject();
            gen.writeEndObject();
        } else {
            gen.writeStartArray();
            Integer i = 0;
            for (SelectOption t : unselectedPaymentTypesList) {
                i++;
                gen.writeStartObject();
                gen.writeStringField('id', string.valueof(i));
                gen.writeStringField('label', t.getValue());
                gen.writeEndObject();
            } gen.writeEndArray();
        } return gen.getAsString();
    }

    public String getSelectedPaymentTypes() {
        JSONGenerator gen = JSON.createGenerator(true);
        if (selectedPaymentTypesList.isEmpty() && selectedPaymentTypesList == null) {
            gen.writeStartObject();
            gen.writeEndObject();
        } else {
            gen.writeStartArray();
            Integer i = 100;
            for (SelectOption t : selectedPaymentTypesList) {
                i++;
                gen.writeStartObject();
                gen.writeStringField('id', string.valueof(i));
                gen.writeStringField('label', t.getValue());
                gen.writeEndObject();
            } gen.writeEndArray();
        } return gen.getAsString();
    }

    public void updatePaymentTypes() {
        App_Settings__c appSettings = App_Settings__c.getInstance(UserInfo.getOrganizationId());
        JSONParser parser = JSON.createParser( paymentTypesToUpdate );
        String paymentTypes = '';
        while (parser.nextToken() != null) {
            if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'label') ) {
                parser.nextToken();
                paymentTypes += parser.getText() + ',';
                parser.nextToken(); parser.nextToken();
            }
        }
        paymentTypes = paymentTypes.removeEnd(',');
        try {
            if ( paymentTypes == null ) {
                appSettings.Gift_Aid_Eligible_Payment_Types__c = '';
            } else {
                appSettings.Gift_Aid_Eligible_Payment_Types__c = paymentTypes;
            }
            DMLManager.UpdateSObject(appSettings);
        } catch (DMLException e) {
            
        }
    }

    @RemoteAction
    public static String staticExecuteFullRollup() {
        Database.executeBatch(new RollupBatch('Full'), 200);
        return 'Starting Job';
    }

    public void updateAccounts() {
        try {
            if ( newHistoricalBucketAccount != null ) {
                if (settings.Historical_Bucket_Account_IDs__c == '' || settings.Historical_Bucket_Account_IDs__c == null)
                    settings.Historical_Bucket_Account_IDs__c = newHistoricalBucketAccount;
                else
                    settings.Historical_Bucket_Account_IDs__c += ',' + newHistoricalBucketAccount;

                DMLManager.UpdateSObject(settings);
            }
        } catch (DMLException e) {

        }
    }

    // delete bucket account id from custom setting
    public void deleteAccount() {
        // remove id from list
        for (Integer i = 0; i < historicalBucketAccounts.size(); i++) {
            if (historicalBucketAccounts[i].Id == Id.valueOf(bucketAccountIdToDelete)) {
                historicalBucketAccounts.remove(i);
            }
        }

        String random = '';
        try {
            if ( bucketAccountIdToDelete != null ) {
                for (String the : historicalBucketStringList) {
                    if (the != bucketAccountIdToDelete)
                        random += the;
                }
                settings.Historical_Bucket_Account_IDs__c = random;
                DMLManager.UpdateSObject(settings);
            }
        } catch (DMLException e) {
            
        }
    }

    // Sandbox Config
    public Boolean isSandbox { get{ return Utilities.runningInASandbox();} }
    public void configureSandbox() { Utilities.configureSandbox(); }

    // Gift Aid
    public Boolean IsGiftAidEnabled { get{ return Utilities.IsGiftAidEnabled();} }

    public class multiSelect {
        public String id;
        public String name;
        public Boolean selected;
        public multiSelect(String i, String n, Boolean s) {
            id = i;
            name = n;
            selected = s;
        }
    }

    @RemoteAction
    public static List<SelectOption> getGiftAidPaymentTypePicklist() {
        List<SelectOption> options = new List<SelectOption>();
        List<multiSelect> custWrapper = new List<multiSelect>();

        Schema.DescribeFieldResult fieldResult = Payment__c.Payment_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for ( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

    @RemoteAction
    public static String staticScheduleFullRollup(String dateString) {
        DateTime dt;
        try {
            dt = DateTime.parse(dateString);
        } catch (exception e) {
            return String.valueOf(e);
        }
        String mon = String.valueOf(dt.month());
        String day = String.valueOf(dt.day());
        String hour = String.valueOf(dt.hour());
        String min = String.valueOf(dt.minute());
        String ss = String.valueOf(dt.second());

        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + mon + ' ?';

        FullContactRollupScheduler s = new FullContactRollupScheduler();
        try {
            if (dt > DateTime.now()) {
                System.schedule('Full Contact Rollup Job', nextFireTime, s);
                return 'Success';
            } else if (dt <= DateTime.now()) {
                return 'Date Too Low';
            } else {
                return 'Unknown Error';
            }

        } catch (exception e) {
            return String.valueOf(e);
        }
    }

    @RemoteAction
    public static String batchJobRunning(String batchJob) {
        List<AsyncApexJob> job = new AsyncApexJobSelector().SelectByApexClassIdOrderByCreatedDate('RollupBatch');
        if (job.size() > 0) {
            JSONGenerator gen = JSON.createGenerator(true);
            if (job.isEmpty() && job == null) {
                gen.writeStartObject();
                gen.writeEndObject();
            } else {
                gen.writeStartObject();
                gen.writeStringField('Status', string.valueof(job[0].Status));
                gen.writeStringField('TotalJobItems', string.valueof(job[0].TotalJobItems));
                gen.writeStringField('JobItemsProcessed', string.valueof(job[0].JobItemsProcessed));
                gen.writeStringField('NumberOfErrors', string.valueof(job[0].NumberOfErrors));
                gen.writeEndObject();
            } return gen.getAsString();
        }
        return 'false';
    }

    @RemoteAction
    public static String abortBatchJob(String batchJob) {
        List<AsyncApexJob> job = new AsyncApexJobSelector().SelectByApexClassIdAndStatusOrderByCreatedDate('RollupBatch', new List<String> { 'Completed', 'Aborted' });
        if (job.size() > 0) {
            System.AbortJob(job[0].Id);
            System.AbortJob(job[1].Id);

            List<AsyncApexJob> jobAfterAbort = new AsyncApexJobSelector().SelectByApexClassIdOrderByCreatedDate('RollupBatch');
            if (jobAfterAbort.size() > 0) {
                JSONGenerator gen = JSON.createGenerator(true);
                if (jobAfterAbort.isEmpty() && jobAfterAbort == null) {
                    gen.writeStartObject();
                    gen.writeEndObject();
                } else {
                    gen.writeStartObject();
                    gen.writeStringField('Status', string.valueof(jobAfterAbort[0].Status));
                    gen.writeStringField('TotalJobItems', string.valueof(jobAfterAbort[0].TotalJobItems));
                    gen.writeStringField('JobItemsProcessed', string.valueof(jobAfterAbort[0].JobItemsProcessed));
                    gen.writeStringField('NumberOfErrors', string.valueof(jobAfterAbort[0].NumberOfErrors));
                    gen.writeEndObject();
                } return gen.getAsString();
            }
        }
        return 'failed';
    }
}