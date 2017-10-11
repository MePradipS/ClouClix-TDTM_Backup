@isTest
public class TestDataTemplates {
    public static SObject createSObject(SObject sObj) {
        // Check what type of object we are creating and add any defaults that are needed.
        String objectName = String.valueOf(sObj.getSObjectType());
        // Construct the default values class. Salesforce doesn't allow '__' in class names
        String defaultClassName = 'TestDataTemplates.' + objectName.replaceAll('__c|' +  Utilities.getCurrentNamespace() + '__', '') + 'Defaults';
        // If there is a class that exists for the default values, then use them
        if (Type.forName(defaultClassName) != null) {
            sObj = createSObject(sObj, defaultClassName);
        }
        return sObj;
    }

    public static SObject createSObject(SObject sObj, Boolean doInsert) {
        SObject retObject = createSObject(sObj);
        if (doInsert) {
            insert retObject;
        }
        return retObject;
    }

    public static SObject createSObject(SObject sObj, String defaultClassName) {
        // Create an instance of the defaults class so we can get the Map of field defaults
        Type t = Type.forName(defaultClassName);
        if (t == null) {
            Throw new TestFactoryException('Invalid defaults class.');
        }
        FieldDefaults defaults = (FieldDefaults)t.newInstance();
        addFieldDefaults(sObj, defaults.getFieldDefaults());
        return sObj;
    }

    public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
        SObject retObject = createSObject(sObj, defaultClassName);
        if (doInsert) {
            insert retObject;
        }
        return retObject;
    }

    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
        return createSObjectList(sObj, numberOfObjects, (String)null);
    }

    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
        if (doInsert) {
            insert retList;
        }
        return retList;
    }

    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
        if (doInsert) {
            insert retList;
        }
        return retList;
    }

    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
        SObject[] sObjs = new SObject[] {};
        SObject newObj;

        // Get one copy of the object
        if (defaultClassName == null) {
            newObj = createSObject(sObj);
        } else {
            newObj = createSObject(sObj, defaultClassName);
        }

        // Get the name field for the object
        String nameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
        if (nameField == null) {
            nameField = 'Name';
        }

        // Clone the object the number of times requested. Increment the name field so each record is unique
        for (Integer i = 0; i < numberOfObjects; i++) {
            SObject clonedSObj = newObj.clone(false, true);
            clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
            sObjs.add(clonedSObj);
        }
        return sObjs;
    }

    private static void addFieldDefaults(SObject sObj, Map<String, Object> defaults) {
        // Loop through the map of fields and if they are null on the object, fill them.
        for (String field : defaults.keySet()) {
            if (sObj.get(field) == null) {
                sObj.put(field, defaults.get(field));
            }
        }
    }

    // When we create a list of SObjects, we need to
    private static Map<String, String> nameFieldMap = new Map<String, String> {
        'Contact' => 'LastName',
        'Case' => 'Subject'
    };

    public class TestFactoryException extends Exception {}

    // Use the FieldDefaults interface to set up values you want to default in for all objects.
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults();
    }

    // To specify defaults for objects, use the naming convention [ObjectName]Defaults.
    // For custom objects, omit the __c from the Object Name

    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Account',
                'Email__c' => 'test@test.com'
            };
        }
    }

    public class HouseholdWithNoAddress implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            Id householdRecordTypeId = Utilities.getObjectRecordTypeId(Account.SObjectType, 'Household');
            return new Map<String, Object> {
                'Name' => 'Test Household',
                'RecordTypeId' => householdRecordTypeId
            };
        }
    }

    public class BucketAccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Individual Bucket'
            };
        }
    }

    public class ContactDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'FirstName' => 'First',
                'LastName' => 'Last',
                'MailingStreet' => 'Test Street',
                'MailingCity' => 'Test City',
                'MailingState' => 'Test State',
                'MailingCountry' => 'Test Country',
                'MailingPostalCode' => 'T1T 4Y5',
                'Email' => 'test@test.com'
            };
        }
    }

    public class OpportunityDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Opportunity',
                'StageName' => 'Closed Won',
                'CloseDate' => System.today()
            };
        }
    }

    public class CaseDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Subject' => 'Test Case'
            };
        }
    }

    public class GiftDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Description__c' => 'Test',
                'Gift_Type__c' => 'One Time Gift',
                'Expected_Amount__c' => 10,
                'Gift_Date__c' => system.today(),
                'Receipt_Type__c' => 'Single Receipt'
            };
        }
    }

    public class PaymentDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Payment_Type__c' => 'Credit Card - Offline',
                'Status__c' => 'Approved',
                'Amount__c' => 10,
                'Date__c' => system.today()
            };
        }
    }

    public class PaymentWithTransactionWithContact implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            Contact testContact = (Contact)createSObject(new Contact(), true);
            Gift__c testGift = (Gift__c)createSObject(new Gift__c(Constituent__c = testContact.Id), true);
            return new Map<String, Object> {
                'Payment_Type__c' => 'Credit Card - Offline',
                'Status__c' => 'Approved',
                'Amount__c' => 10,
                'Date__c' => system.today(),
                'Donation__c' => testGift.Id
            };
        }
    }

    public class FundDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Fund_Name__c' => 'Test Fund',
                'Start_Date__c' => System.today()
            };
        }
    }

    public class FundWithGLCodes implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Fund_Name__c' => 'Test Fund',
                'Start_Date__c' => System.today(),
                'GL_Credit__c' => '1',
                'GL_Debit__c' => '2',
                'GL_In_Kind_Credit__c' => '3',
                'GL_In_Kind_Debit__c' => '4',
                'GL_Matching_Pledge_Cash_Credit__c' => '5',
                'GL_Matching_Pledge_Cash_Debit__c' => '6',
                'GL_Matching_Pledge_In_Kind_Credit__c' => '7',
                'GL_Matching_Pledge_In_Kind_Debit__c' => '8',
                'GL_Matching_Pledge_Property_Credit__c' => '9',
                'GL_Matching_Pledge_Property_Debit__c' => '10',
                'GL_Matching_Pledge_Stock_Credit__c' => '11',
                'GL_Matching_Pledge_Stock_Debit__c' => '12',
                'GL_Matching_Pledge_Write_off_Credit__c' => '13',
                'GL_Matching_Pledge_Write_off_Debit__c' => '14',
                'GL_Stock_Credit__c' => '15',
                'GL_Stock_Debit__c' => '16',
                'GL_Other_Credit__c' => '17',
                'GL_Other_Debit__c' => '18',
                'GL_Pledge_Credit__c' => '19',
                'GL_Pledge_Debit__c' => '20',
                'GL_Pledge_In_Kind_Credit__c' => '21',
                'GL_Pledge_In_Kind_Debit__c' => '22',
                'GL_Pledge_Property_Credit__c' => '23',
                'GL_Property_Credit__c' => '24',
                'GL_Property_Debit__c' => '25',
                'GL_Pledge_Property_Debit__c' => '26',
                'GL_Pledge_Stock_Credit__c' => '27',
                'GL_Pledge_Stock_Debit__c' => '28',
                'GL_Pledge_Write_off_Credit__c' => '29',
                'GL_Pledge_Write_off_Debit__c' => '30',
                'GL_Recurring_Credit__c' => '31',
                'GL_Recurring_Debit__c' => '32',
                'GL_Matching_Pledge_Current_Fiscal__c' => '33',
                'GL_Matching_Pledge_Current_Fiscal_Debit__c' => '34',
                'GL_Pledge_Current_Fiscal_Credit__c' => '35',
                'GL_Pledge_Current_Fiscal_Debit__c' => '36'
            };
        }
    }

    public class CampaignDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Appeal',
                'RecordTypeId' => Utilities.getObjectRecordTypeId(Campaign.SObjectType, 'Appeal'),
                'Status' => 'In Progress',
                'IsActive' => True,
                'StartDate' => Date.Today()
            };
        }
    }

    public class CampaignEventDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Event',
                'RecordTypeId' => Utilities.getObjectRecordTypeId(Campaign.SObjectType, 'Event'),
                'Status' => 'In Progress',
                'IsActive' => True,
                'Event_Start_Time__c' => Datetime.Now()
            };
        }
    }

    public class BatchSettingsDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            Account bucketAccount = (Account)createSObject(new Account(), 'TestDataTemplates.BucketAccountDefaults', true);
            String objectNamespace = (Utilities.getCurrentNamespace() != '')?Utilities.getCurrentNamespace() + '__':'';
            Id giftRecordTypeId = Utilities.getObjectRecordTypeId(Gift__c.SObjectType, 'Gift');
            return new Map<String, Object> {
                'Name' => 'Default',
                'BatchFormID__c' => 'TestFormId',
                'BatchReportId__c' => 'TestReportId',
                'BucketAccountId__c' => bucketAccount.Id,
                'CurrencyCode__c' => 'tst',
                'RegularGiftRecordTypeId__c' => giftRecordTypeId,
                'Data_Migration_Mode__c' => false
            };
        }
    }

    public class App_SettingsDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            Map<String, Id> CampaignRecordTypeMap = Utilities.getObjectRecordTypeId(Campaign.SObjectType);
            String indvApp = [SELECT Id FROM RecordType WHERE Name = 'Individual Application'].Id;
            return new Map<String, Object> {
                'Appeal_RecordType_Id__c' => CampaignRecordTypeMap.get('Appeal'),
                'Campaign_RecordType_Id__c' => CampaignRecordTypeMap.get('Campaign'),
                'Event_RecordType_Id__c' => CampaignRecordTypeMap.get('Event'),
                'Actionpages_URL__c' => 'www.example.com',
                'Appeal_Donate_Now_Form_Id__c' => 'sdfd',
                'Event_Registration_Form_Id__c' => 'dsf',
                'Form_URL__c' => 'www.example.com',
                'Free_Event_Registration_Form_Id__c' => 'gfdf',
                'CV_Account_Id__c' => indvApp,
                'Default_Actionpages_Campaign__c' => 'jdksf',
                'Individual_App_RecordtypeId__c' => Utilities.getObjectRecordTypeId(Volunteer_Application__c.SObjectType, 'Individual Application'), 
                'Enable_Recurring_Receipts__c' => false,
                'Gift_Aid_Enable__c' => true,
                'Gift_Aid_Eligible_Payment_Types__c' => 'Credit Card - Offline,Cash,Credit Card,UK Cheque,UK Direct Debit',
                'Fiscal_Start_Month__c' => 1
            };
        }
    }
}