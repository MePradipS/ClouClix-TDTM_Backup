@isTest
public with sharing class TestClass {

    public static testMethod void testGivingPowerUtility(){
        
        GivingPowerUtility gpu = new GivingPowerUtility();
        GivingPowerUtility.ConseqFiscalYears(new List<Date>(), 1);
        
        List<Date> dates = new List<Date>();
        dates.add(Date.today());
        dates.add(Date.today().addDays(1));
        GivingPowerUtility.ConseqFiscalYears(dates, 1);
            
        dates = new List<Date>();
        dates.add(Date.today().addDays(-365));
        dates.add(Date.today().addDays(-395));
        dates.add(Date.today().addDays(-465));
        GivingPowerUtility.ConseqFiscalYears(dates, 1);
        
        dates = new List<Date>();
        dates.add(Date.today().addDays(-366));
        dates.add(Date.today().addDays(-732));
        dates.add(Date.today().addDays(-1098));
        GivingPowerUtility.ConseqFiscalYears(dates, 1);
        
        GivingPowerUtility.findSobjectType('Temp');
        GivingPowerUtility.setFieldValue(new Gift__c(), 'Anonymous__c', 'Boolean', 'true');
        GivingPowerUtility.setFieldValue(new Contact(), 'Birthdate', 'Date', '10/10/1988');
        //GivingPowerUtility.setFieldValue(new Contact(), 'Name', 'DateTime', '10/10/1988');
        //GivingPowerUtility.setFieldValue(new Gift__c(), 'No_of_Expected_Payments__c', 'Double', '6');
        //GivingPowerUtility.setFieldValue(new Gift__c(), 'No_of_Expected_Payments__c', 'Int', '3');
        //GivingPowerUtility.setFieldValue(new Contact(), 'Name', 'String', 'Juan');
        
        GivingPowerUtility.IsEmptyOrNull('');
        
        Date currentDate = Date.today();
        DateTime currentDateTime = DateTime.now();
        
        GivingPowerUtility.formatDateForQuery(currentDate);
        GivingPowerUtility.formatDateTimeForQuery(currentDateTime);
        BatchSettings__c bs = new BatchSettings__c ();
        bs.Name = 'Default';
        bs.GatewayUrl__c = '';
        bs.BatchFormID__c = 'a';
        bs.BatchReportId__c = 'a';
        bs.BucketAccountId__c = 'a';
        bs.CurrencyCode__c = 'USD';
        bs.Data_Migration_Mode__c = false;
        bs.GatewayUrl__c = 'http://localhost/';
        bs.RegularGiftRecordTypeId__c = 'a';
        insert bs;
        //Util.SubmitRecurringChanges('bcg', 'dfszf');
    }
    
    public static testMethod void testGiftBatchController(){
        
        //GiftBatchController cbg = new GiftBatchController();
        
    }
    public static testMethod void testPayment()
    {
        Map<String, String> rtypes_Map = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Event\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes_Map.put(r.Name, r.Id);
        }
        
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test fund123');
        insert fund;
        Letter__c letter = new Letter__c(Name__c = 'Letter test123');
        insert letter;
         Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        Contact c = new Contact(LastName = 'asagafgh', AccountId = a.Id);
        insert c; 
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
        Gift__c g1 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'One Time Gift', Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 100, Status__c = 'Approved');
        insert p1;
        apexpages.currentpage().getparameters().put('id' , p1.id);
        PageReference pageRef = Page.Payment;
        Test.setCurrentPage(pageRef);
        Payment pay = new Payment(g1.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        Payment p = new Payment(sc);
        Payment.BatchAllocationSetting batchAlloc = new Payment.BatchAllocationSetting();
        Payment.BatchAllocationSetting batchAlloc1 = new Payment.BatchAllocationSetting(fund.id, letter.id);
        //pay.submitPayment();
        pay.setKeyPrefix();
        pay.tryParseToInt('2');
        pay.setPaymentFieldList();
        pay.setAllocationFieldList();
        pay.setPayment();
        pay.setAllocationList();
        pay.getGiftDetailstoUpdate();
        pay.setAllocationOperationList();
        pay.saveAll();
    }
    public static testMethod void CampaignDashboardControllerTest()
    {
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test fund123');
        insert fund;
        Letter__c letter = new Letter__c(Name__c = 'Letter test123');
        insert letter;
        RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
        Campaign appeal = new Campaign(Name = 'Campaign Test123', Fund__c = fund.id, Letter__c = letter.id, RecordTypeId=recType.id );
        insert appeal;
        Contact con = new COntact(LastName = 'Test Contact123');
        insert con;
        ApexPages.StandardController sc = new ApexPages.StandardController(appeal);
        apexpages.currentpage().getparameters().put('id' , appeal.id);
        CampaignDashboardController campDash = new CampaignDashboardController(sc);
        
        CustomFundLookupController CFL = new CustomFundLookupController();
        CustomFundLookupController CFL1 = new CustomFundLookupController('Fund');
        system.currentPageReference().getParameters().put('objName','Account');
        CFL1.search();
    }

}