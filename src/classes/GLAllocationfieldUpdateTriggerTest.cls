@isTest
global with sharing class GLAllocationfieldUpdateTriggerTest{
    public static testMethod void GLAllocationfieldUpdateTrigger(){
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
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger1(){
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
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Payment_Type__c = 'In Kind'; 
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger2(){
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
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Payment_Type__c = 'Other'; 
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger3(){
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
        g.RecordTypeId = rtype_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Status__c = 'Approved';
        update p1;
        
        p1.Status__c = 'Written Off';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger4(){
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
        g.RecordTypeId = rtype_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;
        
        p1.Payment_Type__c = 'In Kind';
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger5(){
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
        g.RecordTypeId = rtype_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = paymentRecord();
        p2.Donation__c = g.Id;
        insert p2;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'Stock';
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger6(){
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
        g.RecordTypeId = rtype_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = paymentRecord();
        p2.Donation__c = g.Id;
        insert p2;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'Property';
        p1.Status__c = 'Approved';
        update p1;
        
        p1.Status__c = 'Committed';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger7(){
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
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = paymentRecord();
        p2.Donation__c = g.Id;
        insert p2;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Status__c = 'Approved';
        update p1;
        p1.Status__c = 'Written Off';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger8(){
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
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Payment__c p2 = paymentRecord();
        p2.Donation__c = g.Id;
        insert p2;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'In Kind';
        p1.Status__c = 'Approved';
        update p1;
        
        p1.Status__c = 'Committed';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger9(){
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
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'Stock';
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger10(){
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
        g.Gift_Type__c = 'Pledge';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        insert gd1;

        p1.Payment_Type__c = 'Property';
        p1.Status__c = 'Approved';
        update p1;
    }
    
    public static testMethod void GLAllocationfieldUpdateTrigger11(){
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = getrecordTypes();
        aNums__c cs1 = anumsSettings();
           
        Account a = acc();

        BatchSettings__c cs2 = batchSettings();        
        App_Settings__c app = appSettings();
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
        g.Gift_Type__c = 'Recurring';
        insert g;
      
        Payment__c p1 = paymentRecord();
        p1.Donation__c = g.Id;
        insert p1;
        
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = cam.Id;
        gd1.Event_Level__c  = e.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = f.id;
        gd1.Posted_to_Finance__c = system.today();
        insert gd1;

        p1.Status__c = 'Approved';
        update p1;
        try{
            delete gd1;
        }
        catch(dmlexception err){
            system.assert(err.getMessage().contains('You can not delete this record because \'Enable Enhanced Fund Accounting\' is enabled in custom setting and \'Posted to Finance\' field is not blank!'), err.getMessage() );
        }
    }
    
    global static Gift__c giftRecord(){
        Gift__c g= new Gift__c();
        g.Status__c = 'Active';
        g.Gift_Type__c = 'One Time Gift';
        return g;
    }
    
    global static Payment__c paymentRecord(){
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Written Off';
        return p1;
    }
    
    global static Gift_Detail__c giftDetailRecord(){
        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.Quantity__c = 50;
        return gd1;
    }
    
    global static Map<String, String> getrecordTypes(){
        Map<String, String> rtypes = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Refund\' OR Name =\'Issued\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes.put(r.Name, r.Id);
        }
        return rtypes;
    }
    
    global static aNums__c anumsSettings(){
        aNums__c cs = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs; 
        return cs;
    }
    
    global static Account acc(){
        Account a1 = new Account(name='testAccount', Email__c='test@account.com');
        Insert a1;
        return a1;
    }
    
    global static Contact con(){
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
        return c;
    }
    
    global static BatchSettings__c batchSettings(){
        Account a = acc();
        Map<String, String> rtypes_Map = getrecordTypes();
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
        return cs2;
    }
    
    global static App_Settings__c appSettings(){
        Map<String, String> rtypes_Map = getrecordTypes();
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false, Enable_Enhanced_Fund_Accounting__c = True, Enable_Pledge_Installment_Model__c = false);
        insert app;
        return app;
    }
    
    global static Fund__c fundRecord(){
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
    
    global static Event_Level__c eventLevelRecord(){
        //Campaign camp = campaignRecord();
        Event_Level__c elev = new Event_Level__c();
        //elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        //insert elev; 
        return elev;
    }
    
    global static Campaign campaignRecord(){
        Map<String, String> rtypes_Map = getrecordTypes();
        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        //insert camp;  
        return camp;
    }
}