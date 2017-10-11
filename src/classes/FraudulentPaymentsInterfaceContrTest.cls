@isTest
public class FraudulentPaymentsInterfaceContrTest {
    public static testMethod void FPIControllertest(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
         BatchSettings__c cs2 = batchSettings();   
        
        Account a = acc();
        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
        
        Gift__c g2= giftRecord();
        g2.Constituent__c = c.Id;
        g2.RecordTypeId = rtype_Map.get('Gift');
        insert g2;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        p1.iATS_Potentially_Fraudulent_Payment__c = true;
        insert p1;
        
        Payment__c p2 = paymentRecord();
        p2.Donation__c = g2.Id;
        p2.iATS_Potentially_Fraudulent_Payment__c = true;
        insert p2;
        Payment__c p3 = paymentRecord();
        p3.Donation__c = g2.Id;
        p3.iATS_Potentially_Fraudulent_Payment__c = true;
        insert p3;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;        
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;       
        gd1.Fund__c = f.id;
        gd1.Allocation_Date__c = system.today();
        gd1.Amount__c=20;
        insert gd1;
        
        PageReference pageRef = Page.FraudulentPaymentsInterface;
        Test.setCurrentPage(pageRef);
        FraudulentPaymentsInterfaceController fPC = new FraudulentPaymentsInterfaceController();                
        fPC.obj.setPageSize=0;                
        fPC.lastPage();
        fPC.fistPage();
        fPC.next();
        fPC.previous();
        fPC.obj.hasPrevious();
        fPC.obj.hasNext();
        fPC.deleteSelected();
         
        
    }
    public static Map<String, String> getrecordTypes(){
        Map<String, String> rtypes = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes.put(r.Name, r.Id);
        }
        return rtypes;
    }
    public static Account acc(){
        Account a1 = new Account(name='testAccount', Email__c='test@account.com');
        Insert a1;
        return a1;
    }
    
    public static Contact con(){
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
        return c;
    }
    public static Gift__c giftRecord(){
        Gift__c g= new Gift__c();
        g.Status__c = 'Active';
        g.Gift_Type__c = 'One Time Gift';
        return g;
    }
    
    public static Payment__c paymentRecord(){
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Written Off';
        return p1;
    }
    
    public static Gift_Detail__c giftDetailRecord(){
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.Quantity__c = 50;
        return gd1;
    }
    public static Fund__c fundRecord(){
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;
        return fund;
    }
    Public static Campaign campaignRecord(){
        Map<String, String> rtypes_Map = getrecordTypes();
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        //insert camp;  
        return camp;
    }
    public static BatchSettings__c batchSettings(){
        Account a = acc();
        Map<String, String> rtypes_Map = getrecordTypes();
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
        return cs2;
    }
}