@isTest
public class MatchingGiftConvertTest {
    public static testMethod void testMatchingGift() {
        String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> rtypes = database.query(rtypesQuery);
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;  
        Account buck = new Account(Name = 'aaa');
        insert buck;         

        if (rtypes.size() > 0)
        {
            BatchSettings__c cs2 = new BatchSettings__c ( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'aa', BatchReportId__c = 'aa', BucketAccountId__c = buck.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'aaa', RegularGiftRecordTypeId__c = rtypes[0].Id, Record_Type_Id_for_Rollups__c = rtypes[0].Id);
            insert cs2;
        }

        Account a = new Account(Name = 'aaa');
        insert a;
        Contact c = new Contact(LastName = 'ssss', AccountId = a.Id);
        insert c;
        Gift__c g1 = new Gift__c(Expected_Amount__c = 25, Constituent__c = c.Id, Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 25, Date__c = Date.Today());
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Gift__c = g1.Id, Payment__c = p1.Id, Amount__c = 25, Allocation_Date__c = Date.Today());
        insert gd1;
        
        PageReference pageRef = Page.MatchTransaction;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', g1.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(g1);
        MatchingControllerExtension controller = new MatchingControllerExtension(std);
    
        controller.getPTypes();
        controller.getMonths();            
        controller.getYears();
        controller.createReceipt = true; 
        controller.theGift.Organization__c = a.Id;
        controller.Submit();       
        ApexPages.currentPage().getParameters().put('gdIndex', '1');           

    }
}