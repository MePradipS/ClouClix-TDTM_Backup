@isTest
public class DuplicateConstituentIdUpdateTest{
    public static testMethod void DuplicateConstituentIdUpdatescheduledMethod(){
        DuplicateConstituentIdUpdatescheduled d = new DuplicateConstituentIdUpdatescheduled();
        String CRON_EXP = '0 0 0 1 1 ? 2025';  
        String jobId = System.schedule('testScheduledApex54321'+system.Now(), CRON_EXP, d );
        DuplicateOrganisationIdUpdatescheduled dd = new DuplicateOrganisationIdUpdatescheduled();
        System.schedule('testScheduledApex12345'+system.Now(), CRON_EXP, dd );
    }
    
    public static testMethod void DuplicateConstituentIdUpdateBatchTest(){
        aNums__c s = new aNums__c(Name='Default', OrgPrefix__c = '1', ContactPrefix__c ='1', ContactLength__c=8, OrgLength__c=5);
        insert s;
        Application_Setting__c appsetting = new Application_Setting__c(Name = 'Auto Number Setting', Org_Count__c=100);
        insert appsetting;
        List<Account> accRec = new List<Account>();
        List<Contact> contRec = new List<Contact>();
        for(Integer i = 0; i < 5; i++){
        Account a = new Account(name = 'Nitin Test'+i, Organization_ID__c='11111');
        Account aa = new Account(name = 'Nitin Test'+i, Organization_ID__c='22222');
        accRec.add(aa);
        accRec.add(a);
        }
        insert accRec;
        for(Integer i = 0; i < 5; i++){
        contact c = new Contact(LastName = 'Khunal Test'+i, Constituent_ID__c='11111');
        contact cc = new Contact(LastName = 'Khunal Test'+i, Constituent_ID__c='22222');
        contRec.add(c);
        contRec.add(cc);
        }
        insert contRec;
        Account aaa = new Account(name = 'Nitin Test', Organization_ID__c='12345678');
        insert aaa;
        contact ccc = new Contact(LastName = 'Khunal Test Duplicate', Constituent_ID__c='12345678');
        insert ccc;
        DuplicateConstituentIdUpdateBatch d = new DuplicateConstituentIdUpdateBatch();
        Database.executeBatch(d);
       
    }
    
    public static testMethod void DuplicateOrganisationIdUpdateBatchTest(){
        String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> rtypes = database.query(rtypesQuery);

        Account acc = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert acc; 

        if (rtypes.size() > 0)
        {
            BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id, BucketAccountId__c = acc.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
            insert cs2;    
        } 
        
        aNums__c s = new aNums__c(Name='Default', OrgPrefix__c = '1', ContactPrefix__c ='1', ContactLength__c=5, OrgLength__c=5);
        insert s;
        Application_Setting__c appsetting = new Application_Setting__c(Name = 'Auto Number Setting', Org_Count__c=100);
        insert appsetting;
        List<Account> accRec = new List<Account>();
        List<Contact> contRec = new List<Contact>();
        for(Integer i = 0; i < 5; i++){
        Account a = new Account(name = 'Nitin Test'+i, Organization_ID__c='33333');
        Account aa = new Account(name = 'Nitin Test'+i, Organization_ID__c='44444');
        accRec.add(aa);
        accRec.add(a);
        }
        insert accRec;
        for(Integer i = 0; i < 5; i++){
        contact c = new Contact(LastName = 'Khunal Test'+i, Constituent_ID__c='66666');
        contact cc = new Contact(LastName = 'Khunal Test'+i, Constituent_ID__c='44444');
        contRec.add(c);
        contRec.add(cc);
        }
        insert contRec;
        DuplicateOrganisationIdUpdateBatch dd = new DuplicateOrganisationIdUpdateBatch();
        Database.executeBatch(dd);        
    }
}