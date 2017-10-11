public class Utilities {
    //  TODO: add link to HMRC Gift Aid Schedule web page
    //      https://www.gov.uk/government/publications/gift-aid-schedule-spreadsheets-to-claim-back-tax-on-donations
    //  TODO: create a batch controller that can take in query, dml operation (insert, update, delete) as string, value
    //  TODO: get payment types
    //  TODO: get months
    //  TODO: get year

    // TODO: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_limits.htm
    public static Boolean catchTestException = false;
    public static Boolean isAsync = null;
    public class MyTestException extends Exception{}
    public static String PackageNamespace {
        get {
            if (PackageNamespace == null) {
                String namespace = getCurrentNamespace();
                PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
            }
            return PackageNamespace;
        }
        private set;
    }

    public class Logger {
        private String text = '';

        public void info(String message) {
            text += datetime.now() + ' | ' + Utilities.StackTrace() + ' | ' + ' INFO:  ' + message + '\n';
        }

        public void error(String message) {
            text += datetime.now() + ' | ' + Utilities.StackTrace() + ' | ' + ' ERROR: ' + message + '\n';
        }

        public void flush() {
            try {
                Document[] docs = new DocumentSelector().SelectBySpecificName();
                Document doc;
                if (docs.size() == 1) {
                    doc = docs[0];
                } else if (docs.size() > 1) {
                    // there are multiple cv-log.txt files...combine them
                    doc = new Document(
                        FolderId = UserInfo.getUserId(),
                        Name = 'cv-log.txt',
                        Body = Blob.valueOf(''),
                        ContentType = 'text/plain',
                        Type = 'txt'
                    );

                    String combinedLogs = '';
                    for (Document d : docs) {
                        combinedLogs += d.Body.toString();
                    }

                    doc.Body = Blob.valueOf(combinedLogs);
                } else {
                    doc = new Document(
                        FolderId = UserInfo.getUserId(),
                        Name = 'cv-log.txt',
                        Body = Blob.valueOf(''),
                        ContentType = 'text/plain',
                        Type = 'txt'
                    );
                }
                if (doc.BodyLength > 5242880) {
                    // TODO: grab 50 most recent lines.
                    // SendingEmail(new string[]{'rcollins@causeview.com'}, 'CV Debug Log - OrgName', 'Log size over 5MB limit. Flushing Logs.', 'clientName - logDateTime.txt', doc.Body);
                    doc.Body = Blob.valueOf(text);
                } else {
                    doc.Body = Blob.valueOf(doc.Body.toString() + text);
                }

                DMLManager.UpsertSObject(doc);
                DMLManager.DeleteSObjects(docs);

                text = '';
            } catch (Exception e) {
                SendingEmail(new string[] {'rcollins@causeview.com'}, 'Logger Error', 'Client: ' + e);
                // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_exception_methods.htm
            }
        }
    }

    // http://salesforce.stackexchange.com/questions/96151/is-it-possible-to-get-current-line-number-in-apex
    public static String StackTrace() {
        try {
            Integer x = 0 / 0;
        } catch (Exception e) {
            String[] linearray = e.getStackTraceString().split('\n');
            Pattern patt = Pattern.compile('([a-zA-Z0-9_.]+): line (\\d+)');
            Matcher match = patt.matcher(linearray[linearray.size() - 1]);
            match.find();
            return  String.valueOf(match.group(1)) + ' [' + String.valueOf(match.group(2)) + '] ';
        }
        return null;
    }

    public static void SendingEmail(String[] emailAddress, String subject, String message) {
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        // string[] sendingTo = new string[]{emailAddress};

        semail.setToAddresses(emailAddress);
        semail.setSubject(subject);
        // semail.setPlainTextBody(‘Hello!!!!!!!!!!This is a test email to test single email message program’);
        semail.setPlainTextBody(message);
        Messaging.SendEmail(new Messaging.SingleEmailMessage[] {semail});
    }

    public static void SendingEmail(String[] emailAddress, String subject, String plainText, String htmlBody, String attachmentName, Blob attachmentBody) {
        try {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attachmentName);
            efa.setBody(attachmentBody);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new string[]{toAddresses};
            email.setSubject( subject );
            email.setToAddresses( emailAddress );
            if (plainText != '' || plainText != null) {
                email.setPlainTextBody( plainText );
            }
            if (htmlBody != '' || htmlBody != null) {
                email.setHtmlBody( htmlBody );
            }
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            // Sends the email
            Messaging.SendEmailResult [] r =
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        } catch ( System.Exception e ) {

        }
    }

    public static Organization GetOrganizationInfo() {
        try {
            return (Organization)new GenericQueryBuilder().ObjectQueryBuilderClause('Organization', Utilities.GetAllFields('Organization'), ' LIMIT 1');
        } catch ( Exception e ) {
            return null;
        }
    }

    public static Boolean IsGiftAidEnabled() {
        List<App_Settings__c> ASList = new AppSettingSelector().SelectGiftAidEnable();
        App_Settings__c AppSetting;

        if (ASList != null && ASList.size() > 0){
            AppSetting = ASList[0];
        }
        try {
            return (AppSetting).Gift_Aid_Enable__c;
        } catch ( Exception e ) {
            return null;
        }
    }

    public static Boolean RunningInASandbox() {
        try {
            return (new OrganizationSelector().SelectIsSandbox()).IsSandbox;
        } catch ( Exception e ) {
            return null;
        }
    }

    // https://stackoverflow.com/questions/9369653/retrieve-salesforce-instance-url-instead-of-visualforce-instance
    // TODO: Determine how to get instance when domain name is set
    public static String GetInstance() {
        // Possible Scenarios:
        //
        // (1) ion--test1--nexus.cs0.visual.force.com  --- 5 parts, Instance is 2nd part
        // (2) na12.salesforce.com      --- 3 parts, Instance is 1st part
        // (3) ion.my.salesforce.com    --- 4 parts, Instance is not determinable
        String Instance = '';
        // Split up the hostname using the period as a delimiter
        List<String> parts = System.URL.getSalesforceBaseUrl().getHost().replace('-api', '').split('\\.');
        if (parts.size() == 3) Instance = parts[0];
        else if (parts.size() == 5) Instance = parts[1];
        else Instance = null;

        return Instance;
    }

    public static App_Settings__c GetAppSettings() {
        try {
            return App_Settings__c.getInstance(UserInfo.getOrganizationId());
        } catch ( Exception e ) {
            return null;
        }
    }

    public static BatchSettings__c GetBatchSettings() {
        try {
            return (BatchSettings__c)new GenericQueryBuilder().ObjectQueryBuilderClause('BatchSettings__c', Utilities.GetAllFields('BatchSettings__c'), ' LIMIT 1');
        } catch ( Exception e ) {
            return null;
        }
    }

    public static givingpowerSettings__c GetTemplateSettings() {
        try {
            return (givingpowerSettings__c)new GenericQueryBuilder().ObjectQueryBuilderClause('givingpowerSettings__c', Utilities.GetAllFields('givingpowerSettings__c'), ' LIMIT 1');
        } catch ( Exception e ) {
            return null;
        }
    }

    public static String GetAllFields(String sObjectName) {
        try {
            String fieldList = '';
            Map<String, Schema.SObjectType> globaldesc = Schema.getGlobalDescribe();
            Set<String> fields = globaldesc.get(sObjectName).getDescribe().fields.getMap().keySet();
            for (string s : fields) { fieldList += s + ','; }
            fieldList = fieldList.removeEnd(',');
            return fieldList;
        } catch ( Exception e ) {
            return null;
        }
    }

    public class RecordTypeException extends Exception{}

    // String recordTypeId = ObjectUtil.getObjectRecordTypeId(Account.SObjectType, 'Household');
    // Map<String, Id> giftRecordTypeMap = Utilities.getObjectRecordTypeId(Gift__c.SObjectType);
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName) {
        Map<String, recordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

        if(!recordTypeInfo.containsKey(recordTypeName))
            throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');

        return recordTypeInfo.get(recordTypeName).getRecordTypeId();
    }

    public static Map<String, Id> getObjectRecordTypeId(SObjectType sObjectType) {
        Map<String, recordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();
        Map<String, Id> recordTypeMap = new Map<String, Id>();

        for(recordTypeInfo rt : recordTypeInfo.values()){
            recordTypeMap.put(rt.getName(), rt.getRecordTypeId());
        }

        if(recordTypeMap.size() <= 1)
            throw new RecordTypeException('The sObject requested does not have any custom record types.');

        return recordTypeMap;
    }
    public static Id GetRecordTypeId(String sObjectName, String recordTypeName) {
        try {
            List<RecordType> RTList = new RecordTypeSelector().SelectBysObjectNameAndRecordTypeName(sObjectName, recordTypeName);
            RecordType rtVariable;
            if (rtList != null && rtList.size() > 0) {
               rtVariable = RTList[0];
               return rtVariable.id;
            }
            return null;

        } catch ( Exception e ) {
            return null;
        }
    }

    public static List<RecordType> GetAllRecordTypes(String sObjectName) {
        try {
            String fields = 'Id,Name,Description,DeveloperName,NamespacePrefix,SobjectType';
            String clause = 'SobjectType = \''+ sObjectName + '\'';
            return new GenericQueryBuilder().ListQueryBuilderWhere('RecordType', fields, clause);
        } catch ( Exception e ) {
            return null;
        }
    }

    // public List<SelectOption> getYOURMETHODNAME(){ return getPickValues(YOUROBJECTNAME, 'YOURPICKLISTFIELDNAME', NULL)); }
    // todo: get record type specific picklist values
    //      ref: http://bobbuzzard.blogspot.ca/2012/01/record-type-picklist-values.html
    //      http://salesforce.stackexchange.com/questions/4992/how-to-get-a-picklist-all-values-in-apex-controller
    // https://success.salesforce.com/ideaView?id=08730000000bBlSAAU
    //
    //
    public List<selectOption> GetPicklist(Sobject sObjectName, String fieldName, String first_val) {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        if (first_val != null) { //if there is a first value being provided
            options.add(new selectOption(first_val, first_val)); //add the first option
        }
        Schema.sObjectType sobject_type = sObjectName.getSObjectType(); //grab the sobject t hat was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            options.add(new selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
        }
        return options; //return the List
    }

    public static List<String> getPicklistValues(String ObjectApiName, String FieldApiName) {
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApiName);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(FieldApiName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return lstPickvals;
    }

    //public static String GetObjectId(String objectName){}?

    //public static String GetFieldId(String objectName){}?

    public static Boolean IsListValid(List<sObject> listToValidate) {
        return (listToValidate != null && listToValidate.size() > 0);
    }

    public static Boolean IsGatewayIatsOrEziDebit(String customerCode) {
        if (customerCode != null && customerCode != '') {
            Boolean match = Pattern.matches('[A-Z][0-9]+', customerCode);
            if (!match) {
                BatchSettings__c settingObj = BatchSettings__c.getInstance('Default');
                if (settingObj != null) {
                    String paymentGateway = settingObj.Payment_Gateway__c;
                    return (paymentGateway != null && paymentGateway.toLowerCase() == 'ezidebit');
                }
            }
            return match;
        } else {
            return false;
        }
    }

    // FINAL!
    public static List<String> CommaDelimitedStringToList(String stringWithCommas, Boolean clearWhitespace) {
        if (String.isNotBlank(stringWithCommas)) {
            if (stringWithCommas.containsWhitespace() && clearWhitespace == true)
                stringWithCommas = (String)stringWithCommas.deleteWhitespace();
            return stringWithCommas.Split(',');
        }
        return null;
    }

    // ???
    public static String ListToCommaDelimitedString( List<SObject> sObjectList ) {
        String commaDelimitedstring = '';
        for (SObject s : sObjectList) {
            commaDelimitedstring += (commaDelimitedstring == '' ? '' : ',') + s;
        }
        return commaDelimitedstring;
    }

    //TODO: delete method, new method CommaDelimitedStringToList
    public static String[] ConvertStringToList(string str) {
        String[] listToReturn = new List<String>();
        if (String.isNotBlank(str)) {
            for (String eachStr : str.split(',')) {
                listToReturn.add(eachStr);
            }
        }
        return listToReturn;
    }

    //TODO: delete method, new method CommaDelimitedStringToList
    public static List<String> SplitStringAtCommma(String stringWithCommas, Boolean clearWhitespace) {
        if (stringWithCommas.containsWhitespace() && clearWhitespace == true)
            stringWithCommas = (String)stringWithCommas.deleteWhitespace();
        return stringWithCommas.Split(',');
    }

    public static String RemoveSquareBracketsFromString(String str) {
        if (str != null || str != '') {
            str = str.removeStart('[');
            str = str.removeEnd(']');
        }
        return str;
    }

    public static void ConfigureSandbox() {
        try {
            RunConfigScripts();

            App_Settings__c appSettings = GetAppSettings();
            BatchSettings__c batchSettings = GetBatchSettings();
            givingpowerSettings__c templateSettings = GetTemplateSettings();

            Id CampaignAppealRecordTypeId = GetRecordTypeId('Campaign', 'Appeal');
            Id AccountOrganizationRecordTypeId = GetRecordTypeId('Account', 'Organization');
            Id TransactionMatchingGiftRecordTypeId = GetRecordTypeId('Gift__c', 'Matching Gift');

            //App Settings
            Campaign cvformsAppeal = new Campaign(Name = 'CV Forms', RecordTypeId = CampaignAppealRecordTypeId, IsActive = True, Status = 'In Porgress', StartDate = Date.Today());
            DMLManager.InsertSObject(cvformsAppeal);

            appSettings.Default_Actionpages_Campaign__c = cvformsAppeal.Id;

            //Batch Settings
            Account individualAccount = new Account(Name = 'Individual');
            DMLManager.InsertSObject(individualAccount);

            batchSettings.BucketAccountId__c = individualAccount.id;
            batchSettings.Record_Type_Id_for_Rollups__c = TransactionMatchingGiftRecordTypeId;

            DMLManager.UpdateSObject(appSettings);
            DMLManager.UpdateSObject(batchSettings);

            //Create Test Records
            Fund__c testFund = new Fund__c(Fund_Name__c = 'Test Fund', Start_Date__c = Date.Today());
            DMLManager.InsertSObject(testFund);

            Campaign testAppeal = new Campaign(Name = 'Test Appeal', Fund__c = testFund.Id,  RecordTypeId = CampaignAppealRecordTypeId, IsActive = True, Status = 'In Porgress', StartDate = Date.Today());
            DMLManager.InsertSObject(testAppeal);
        } catch ( Exception e ) {

        }
    }

    public static void RunConfigScripts() {
        CauseViewCustomSetting.defaultANumSettings();
        CauseViewCustomSetting.defaultBatchSettings();
        CauseViewCustomSetting.defaultAppSettings();
        CauseViewCustomSetting.defaultAppTemplateSettings();
    }

    public static String getCurrentNamespace() {
        return Utilities.class.getName().substringBefore('Utilities').substringBefore('.');
    }

    public class csv {
        public String line(String[] cells) {
            return String.join(cells, ',') + '\n';
        }
        public String format(Date d)    {
            return d != null ? '"' + d.format().escapeCsv() + '"' : '""';
        }
        public String format(String s) {
            return s != null ? s.escapeCsv() : '""';
        }
        public String format(Decimal d, Integer scale) {
            return d != null ? String.valueOf(d.setScale(scale)) : '';
        }
        public String format(Decimal d) {
            return format(d, 2);
        }
    }

    public enum ResponseStatus { SUCCESS, ERROR }
    public with sharing class RemoteResponse {
        public ResponseStatus status { get; set; }
        public List<Object> data { get; set; }
        public List<String> message { get; set; }
        public RemoteResponse() {
            this.status = null;
            this.data = new List<Object>();
            this.message = new List<String>();
        }
        public RemoteResponse(ResponseStatus status, List<Object> data, List<String> message) {
            this.status = status;
            this.data = data;
            this.message = message;
        }
    }

    public static Integer run = 0;
    public static Integer runContact = 0;

    //GIFT AID PAYMENT TRIGGER//
    Public Enum PaymentStatus {
        Undefined,
        Approved,
        Declined,
        Pending
    }

    Public Static PaymentStatus ResolvePaymentStatus(String status) {
        if (status == 'Approved'){
            return PaymentStatus.Approved;
        } else if (status == 'Declined') {
            return PaymentStatus.Declined;
        } else if (status == 'Pending') {
            return PaymentStatus.Pending;
        } else {
            return PaymentStatus.Undefined;
        }
    }

    Public Static Boolean IsPaymentGiftAidEligible(Payment__c currentPayment, App_Settings__c appSettings){
        return appSettings.Gift_Aid_Eligible_Payment_Types__c != null && appSettings.Gift_Aid_Eligible_Payment_Types__c.contains(currentPayment.Payment_Type__c);
    }

    Public Static String DecodeHyperLinkedId(String hyperLink){
        String trimmedHyperLink = hyperLink.substring(hyperLink.indexOf('/') + 1);
        return trimmedHyperLink.substring(0, trimmedHyperLink.indexOf('_'));
    }

    public static Set<Id> ConvertStringSetToIdSet(Set<String> stringSet) {
        Set<Id> idSet = new Set<Id>();
        if (stringSet != null && stringSet.size() > 0) {
            idSet = (Set<Id>)JSON.deserialize(JSON.serialize(stringSet), Set<Id>.class);
        }
        return idSet;
    }

    public static Set<Id> ConvertStringListToIdSet(List<String> stringList) {
        Set<Id> idSet = new Set<Id>();
        if (stringList != null && stringList.size() > 0) {
            idSet = (Set<Id>)JSON.deserialize(JSON.serialize(stringList), Set<Id>.class);
        }
        return idSet;
    }

    public static Set<Id> ConvertIdListToIdSet(List<Id> idList) {
        Set<Id> idSet = new Set<Id>();
        if (idList != null && idList.size() > 0) {
            idSet = (Set<Id>)JSON.deserialize(JSON.serialize(idList), Set<Id>.class);
        }
        return idSet;
    }
    ////////////////////////////
}