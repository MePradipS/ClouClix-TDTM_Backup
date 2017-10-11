@isTest
public class FulFillInstallmentPageControllerTest {

    public static testMethod void FulFillInstallmentPageControllerTest(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        aNums__c cs1 = anumsSettings();
           
        Account a = acc();

        BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Installment__c installment = installmentRecord();
        installment.Pledge__c = g.id;
        insert installment;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Installment__c = installment.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        ApexPages.currentPage().getParameters().put('ContactId',c.id);
        FulFillInstallmentPageController fullfillment = new FulFillInstallmentPageController(sc);
        fullfillment.Payment = paymentRecord();
        fullfillment.Payment.Donation__c = g.id;
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        fullfillment.saveAll();
        fullfillment.getMonths();
        fullfillment.getYears();
        
    }
    
    public static testMethod void FulFillInstallmentPageControllerTest1(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        aNums__c cs1 = anumsSettings(); 
           
        Account a = acc();

        BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
        
        Gift__c g1 = giftRecord();
        g1.Constituent__c = c.Id;
        g1.RecordTypeId = rtype_Map.get('Gift');
        insert g1;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Installment__c installment = installmentRecord();
        installment.Pledge__c = g.id;
        insert installment;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Installment__c = installment.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        Installment__c installment1 = installmentRecord();
        installment1.Pledge__c = g1.id;
        insert installment1;
        
        Gift_Detail__c gd2 = new Gift_Detail__c();
        gd2.New_campaign__c = cam.Id;
        gd2.Event_Level__c  = e.Id;
        gd2.Gift__c = g1.Id;
        gd2.Installment__c = installment1.Id;
        gd2.Quantity__c = 50;
        gd2.Fund__c = f.id;
        insert gd2;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        ApexPages.currentPage().getParameters().put('ContactId',c.id);
        FulFillInstallmentPageController fullfillment = new FulFillInstallmentPageController(sc);
        fullfillment.Payment = paymentRecord();
        fullfillment.Payment.Amount__c = 400;
        fullfillment.Payment.Donation__c = g.id;
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        fullfillment.saveAll();
    }
    
    public static testMethod void FulFillInstallmentPageControllerTest2(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        aNums__c cs1 = anumsSettings(); 
           
        Account a = acc();

        BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
        
        Gift__c g1 = giftRecord();
        g1.Organization__c = a.Id;
        g1.RecordTypeId = rtype_Map.get('Gift');
        insert g1;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Installment__c installment = installmentRecord();
        installment.Pledge__c = g.id;
        insert installment;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Installment__c = installment.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        Installment__c installment1 = installmentRecord();
        installment1.Pledge__c = g1.id;
        insert installment1;
        
        Gift_Detail__c gd2 = new Gift_Detail__c();
        gd2.New_campaign__c = cam.Id;
        gd2.Event_Level__c  = e.Id;
        gd2.Gift__c = g1.Id;
        gd2.Installment__c = installment1.Id;
        gd2.Quantity__c = 50;
        gd2.Fund__c = f.id;
        insert gd2;
                
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        ApexPages.currentPage().getParameters().put('ContactId',c.id);
        FulFillInstallmentPageController fullfillment = new FulFillInstallmentPageController(sc);
        fullfillment.Payment = paymentRecord();
        fullfillment.Payment.Amount__c = 400;
        fullfillment.Payment.Payment_Type__c = 'Credit Card';   
        fullfillment.Payment.Credit_Card_Type__c = 'Visa';
        fullfillment.Payment.Credit_Card_Number__c = '4222222222222220';
        fullfillment.ccExpM = '1';
        fullfillment.ccExpY = '2020';
        fullfillment.Payment.Donation__c = g.id;
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        fullfillment.accContId = a.id;
        
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        fullfillment.saveAll();
        
        fullfillment.submit(fullfillment.Payment, fullfillment.Payment.Donation__c);
    }
    public static testMethod void FulFillInstallmentPageControllerTest3(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        aNums__c cs1 = anumsSettings(); 
           
        Account a = acc();

        BatchSettings__c cs2 = batchSettings();        

        Contact c = con();
        Fund__c f = fundRecord();
        Campaign cam = campaignRecord();
        insert cam;
        Event_Level__c e = eventLevelRecord();
        e.Event__c = cam.Id;
        insert e;
        
        Gift__c g= giftRecord();
        g.Organization__c = a.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;
        
        Gift__c g1 = giftRecord();
        g1.Organization__c = a.Id;
        g1.RecordTypeId = rtype_Map.get('Gift');
        insert g1;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Installment__c installment = installmentRecord();
        installment.Pledge__c = g.id;
        insert installment;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Installment__c = installment.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        Installment__c installment1 = installmentRecord();
        installment1.Pledge__c = g1.id;
        insert installment1;
        
        Gift_Detail__c gd2 = new Gift_Detail__c();
        gd2.New_campaign__c = cam.Id;
        gd2.Event_Level__c  = e.Id;
        gd2.Gift__c = g1.Id;
        gd2.Installment__c = installment1.Id;
        gd2.Quantity__c = 50;
        gd2.Fund__c = f.id;
        insert gd2;
                
        ApexPages.StandardController sc = new ApexPages.StandardController(p1);
        ApexPages.currentPage().getParameters().put('ContactId',c.id);
        FulFillInstallmentPageController fullfillment = new FulFillInstallmentPageController(sc);
        fullfillment.Payment = paymentRecord();
        fullfillment.Payment.Amount__c = 300;
        fullfillment.Payment.Donation__c = g.id;
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 200;
        }
        fullfillment.accContId = a.id;
        
        for(FulFillInstallmentPageController.InstallmetnWrapperClass fIW : fullfillment.installmentWrapper){
            fIW.fullfilmentAmount = 100;
        }
        fullfillment.saveAll();
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
        p1.Amount__c = 200;
        p1.Status__c = 'Approved';
        return p1;
    }
    
    public static Gift_Detail__c giftDetailRecord(){
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.Quantity__c = 50;
        return gd1;
    }
    
    public static Map<String, String> getrecordTypes(){
        Map<String, String> rtypes = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Refund\' OR Name = \'Credit Card\' OR Name = \'Standard\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes.put(r.Name, r.Id);
        }
        return rtypes;
    }
    
    public static aNums__c anumsSettings(){
        aNums__c cs = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs; 
        return cs;
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
    
    public static BatchSettings__c batchSettings(){
        Account a = acc();
        Map<String, String> rtypes_Map = getrecordTypes();
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
        return cs2;
    }
    
    public static App_Settings__c appSettings(){
        Map<String, String> rtypes_Map = getrecordTypes();
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false, Enable_Enhanced_Fund_Accounting__c = True);
        insert app;
        return app;
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
    
    Public static Event_Level__c eventLevelRecord(){
        //Campaign camp = campaignRecord();
        Event_Level__c elev = new Event_Level__c();
        //elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        //insert elev; 
        return elev;
    }
    
    Public static Campaign campaignRecord(){
        Map<String, String> rtypes_Map = getrecordTypes();
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        //insert camp;  
        return camp;
    }
    
    public static Installment__c installmentRecord(){
        Installment__c installment = new Installment__c();
        installment.Name = 'Installment 1';
        installment.Inst_No__c = 1;
        installment.Installment_Date__c = system.today();
        installment.Installment_Amount__c = 200;
        installment.Status__c = 'Open';
        return installment;
    }
}