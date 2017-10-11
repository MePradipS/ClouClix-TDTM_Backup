@isTest
public class GLfieldUpdateOnAllocationTriggerTest{

    public static testMethod void GLfieldUpdateOnAllocationTriggerTest(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'One Time Gift';
        insert g;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;

        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g.Id;
        insert p2;

        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;

        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;

        gd.Payment__c = p2.Id;
        update gd;

        p1.Payment_Type__c = 'Other';
        update p1;

        gd.Payment__c = p1.Id;
        update gd;

        g.Gift_Type__c = 'Pledge';
        update g;

        p2.Status__c = 'Written Off';
        update p2;

        gd.Payment__c = p2.Id;
        update gd;
        Test.StopTest();
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest1(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Event\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Matching Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;

        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g.Id;
        insert p2;

        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;

        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;

        gd.Payment__c = p2.Id;
        update gd;

        p1.Payment_Type__c = 'Stock';
        update p1;

        gd.Payment__c = p1.Id;
        update gd;

        p2.Payment_Type__c = 'Property';
        update p2;

        gd.Payment__c = p2.Id;
        update gd;
        Test.StopTest();
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest2(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Event\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;

        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g.Id;
        insert p2;

        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;

        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;

        gd.Payment__c = p2.Id;
        update gd;

        p1.Payment_Type__c = 'Stock';
        update p1;

        gd.Payment__c = p1.Id;
        update gd;

        p2.Payment_Type__c = 'Property';
        update p2;

        gd.Payment__c = p2.Id;
        update gd;
        Test.StopTest();
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest3(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Event\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

         App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Recurring';
        insert g;

        Gift__c g1= new Gift__c();
        g1.Constituent__c = c.Id;
        g1.Status__c = 'Active';
        g1.RecordTypeId = rtypes_Map.get('Matching Gift');
        g1.Gift_Type__c = 'Pledge';
        insert g1;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'In Kind';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Committed';
        p1.Donation__c = g.Id;
        insert p1;

        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g.Id;
        insert p2;

        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123',
                                    GL_Matching_Pledge_Current_Fiscal__c ='123', GL_Matching_Pledge_Current_Fiscal_Debit__c ='123', GL_Pledge_Current_Fiscal_Credit__c = '123',
                                    GL_Pledge_Current_Fiscal_Debit__c = '123');
        insert fund;

        Test.StartTest();

        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = camp.Id;
        gd1.Event_Level__c  = elev.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p2.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = fund.id;
        insert gd1;

        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g1.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;

        g.Gift_Type__c = 'Pledge';
        update g;
        gd.Gift__c = g.Id;
        update gd;
        Test.StopTest();
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest4(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Event\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

         App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Recurring';
        insert g;

        Gift__c g1= new Gift__c();
        g1.Constituent__c = c.Id;
        g1.Status__c = 'Active';
        g1.RecordTypeId = rtypes_Map.get('Matching Gift');
        g1.Gift_Type__c = 'Pledge';
        insert g1;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'In Kind';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Committed';
        p1.Donation__c = g.Id;
        insert p1;

        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123',
                                    GL_Matching_Pledge_Current_Fiscal__c ='123', GL_Matching_Pledge_Current_Fiscal_Debit__c ='123', GL_Pledge_Current_Fiscal_Credit__c = '123',
                                    GL_Pledge_Current_Fiscal_Debit__c = '123');
        insert fund;

        Test.StartTest();

        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = camp.Id;
        gd1.Event_Level__c  = elev.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p1.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = fund.id;
        gd1.Amount__c = 80;
        insert gd1;

        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'In Kind';
        p2.Cheque_Date__c = Date.today();
        p2.RecordTypeId = rtypes_Map.get('Refund');
        p2.Status__c = 'Refunded';
        p2.Donation__c = g.Id;
        p2.Payment_Refunded__c = p1.id;
        p2.Amount__c = 0;
        insert p2;
        Test.StopTest();
    }

	public static testMethod void GLfieldUpdateOnAllocationTriggerTest5(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = :Utilities.getCurrentNamespace()]){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'One Time Gift';
        insert g;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Stock';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;

        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'Property';
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g.Id;
        insert p2;



        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;

        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;


        Test.StopTest();
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerTest6(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = :Utilities.getCurrentNamespace()]){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'One Time Gift';
        insert g;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Property';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;


        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;

        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;


        Test.StopTest();
    }
     public static testMethod void GLfieldUpdateOnAllocationTriggerInstalmentTest(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = :Utilities.getCurrentNamespace()]){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;

        Gift__c g2= new Gift__c();
        g2.Constituent__c = c.Id;
        g2.Status__c = 'Active';
        g2.RecordTypeId = rtypes_Map.get('Gift');
        g2.Gift_Type__c = 'Pledge';
        insert g2;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Stock';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;

        Installment__c  inst=new Installment__c();
        inst.Pledge__c=g.Id;
        inst.Inst_No__c=2121;
        inst.Installment_Amount__c=10;
        inst.Installment_Date__c=Date.today();

        insert inst;
        Installment_Fulfillment__c  instful=new Installment_Fulfillment__c();
        instful.Installment__c=inst.Id;
        instful.Payment__c=p1.id;

        insert instful;

        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'Property';
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Approved';
        p2.Donation__c = g2.Id;
        insert p2;

        Installment__c  inst1=new Installment__c();
        inst1.Pledge__c=g2.Id;
        inst1.Inst_No__c=2121;
        inst1.Installment_Amount__c=10;
        inst1.Installment_Date__c=Date.today();

        insert inst1;
        Installment_Fulfillment__c  instful1=new Installment_Fulfillment__c();
        instful1.Installment__c=inst1.Id;
        instful1.Payment__c=p2.id;

        insert instful1;


        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;

        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;

        update gd;

        update p1;

        Test.StopTest();
    }

    public static testMethod void GLfieldUpdateOnAllocationTriggerInstalmentTest1(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = :Utilities.getCurrentNamespace()]){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Pledge';
        //Gift_Type__c
        insert g;

        Gift__c g2= new Gift__c();
        g2.Constituent__c = c.Id;
        g2.Status__c = 'Active';
        g2.RecordTypeId = rtypes_Map.get('Gift');
        g2.Gift_Type__c = 'Pledge';
        //Gift_Type__c
        insert g2;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Property';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;

        Installment__c  inst=new Installment__c();
        inst.Pledge__c=g.Id;
        inst.Inst_No__c=2121;
        inst.Installment_Amount__c=10;
        inst.Installment_Date__c=Date.today();

        insert inst;
        Installment_Fulfillment__c  instful=new Installment_Fulfillment__c();
        instful.Installment__c=inst.Id;
        instful.Payment__c=p1.id;

        insert instful;

        Payment__c p2 = new Payment__c();
        p2.Payment_Type__c = 'Property';
        p2.Cheque_Date__c = Date.today();
        p2.Amount__c = 80;
        p2.Status__c = 'Written Off';
        p2.Donation__c = g2.Id;
        insert p2;

        Installment__c  inst1=new Installment__c();
        inst1.Pledge__c=g2.Id;
        inst1.Inst_No__c=2121;
        inst1.Installment_Amount__c=10;
        inst1.Installment_Date__c=Date.today();

        insert inst1;
        Installment_Fulfillment__c  instful1=new Installment_Fulfillment__c();
        instful1.Installment__c=inst1.Id;
        instful1.Payment__c=p2.id;

        insert instful1;

        Payment__c p3 = new Payment__c();
        p3.Payment_Type__c = 'In Kind';
        p3.Cheque_Date__c = Date.today();
        p3.Amount__c = 80;
        p3.Status__c = 'Approved';
        p3.Donation__c = g.Id;
        insert p3;

        Installment__c  inst2=new Installment__c();
        inst2.Pledge__c=g2.Id;
        inst2.Inst_No__c=2121;
        inst2.Installment_Amount__c=10;
        inst2.Installment_Date__c=Date.today();

        insert inst2;
        Installment_Fulfillment__c  instful2=new Installment_Fulfillment__c();
        instful2.Installment__c=inst2.Id;
        instful2.Payment__c=p3.id;

        insert instful2;

        Payment__c p4 = new Payment__c();
        p4.Payment_Type__c = 'Cash';
        p4.Cheque_Date__c = Date.today();
        p4.Amount__c = 80;
        p4.Status__c = 'Approved';
        p4.Donation__c = g.Id;
        insert p4;

        Installment__c  inst3=new Installment__c();
        inst3.Pledge__c=g2.Id;
        inst3.Inst_No__c=2121;
        inst3.Installment_Amount__c=10;
        inst3.Installment_Date__c=Date.today();

        insert inst3;
        Installment_Fulfillment__c  instful3=new Installment_Fulfillment__c();
        instful3.Installment__c=inst3.Id;
        instful3.Payment__c=p4.id;

        insert instful3;

        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;

        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;

        Gift_Detail__c gd1 = new Gift_Detail__c();
        gd1.New_campaign__c = camp.Id;
        gd1.Event_Level__c  = elev.Id;
        gd1.Gift__c = g.Id;
        gd1.Payment__c = p2.Id;
        gd1.Quantity__c = 50;
        gd1.Fund__c = fund.id;
        insert gd1;

        Gift_Detail__c gd2 = new Gift_Detail__c();
        gd2.New_campaign__c = camp.Id;
        gd2.Event_Level__c  = elev.Id;
        gd2.Gift__c = g.Id;
        gd2.Payment__c = p3.Id;
        gd2.Quantity__c = 50;
        gd2.Fund__c = fund.id;
        insert gd2;

        Gift_Detail__c gd3 = new Gift_Detail__c();
        gd3.New_campaign__c = camp.Id;
        gd3.Event_Level__c  = elev.Id;
        gd3.Gift__c = g.Id;
        gd3.Payment__c = p4.Id;
        gd3.Quantity__c = 50;
        gd3.Fund__c = fund.id;
        insert gd3;

        update gd;

        update p1;

        Test.StopTest();
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerInstalmentTest2(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = :Utilities.getCurrentNamespace()]){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'One Time Gift';
        insert g;

        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Property';
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Approved';
        p1.Donation__c = g.Id;
        insert p1;

        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
        insert fund;

        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        gd.Fund__c = fund.id;
        insert gd;

        update gd;

        update p1;

        Test.StopTest();
    }
    public static testMethod void GLfieldUpdateOnAllocationTriggerPaymentTest(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        for(RecordType r : [Select Name, Id From RecordType where (Name = 'Gift' OR Name = 'Event' OR Name = 'Matching Gift' OR Name = 'Campaign' OR Name = 'Appeal' OR Name = 'Event' OR Name = 'Refund') AND NamespacePrefix = :Utilities.getCurrentNamespace()]){
            rtypes_Map.put(r.Name, r.Id);
        }
        aNums__c cs1 = new aNums__c( Name = 'Default', OrgPrefix__c = 'ORG', OrgLength__c = 8, OrgCount__c = 1, ContactPrefix__c = 'CON', ContactLength__c = 8, ContactCount__c = 1);
        insert cs1;

        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;

        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'),
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;

        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.Status__c = 'Active';
        g.RecordTypeId = rtypes_Map.get('Gift');
        g.Gift_Type__c = 'Pledge';
        insert g;

        Installment__c  inst=new Installment__c();
        inst.Pledge__c=g.Id;
        inst.Inst_No__c=2121;
        inst.Installment_Amount__c=10;
        inst.Installment_Date__c=Date.today();

        insert inst;
        Installment_Fulfillment__c  instful=new Installment_Fulfillment__c();
        instful.Installment__c=inst.Id;

        Campaign camp = new Campaign();
        camp.RecordTypeId = rtypes_Map.get('Event');
        camp.Name = 'sss';
        insert camp;

        Event_Level__c elev = new Event_Level__c();
        elev.Event__c = camp.Id;
        elev.Quantity_Available__c = 1000;
        insert elev;

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                    GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                    GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                    GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                    GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                    GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                    GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');

        Test.StartTest();
        Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Installment__c=inst.id;
        gd.Quantity__c = 50;
        insert gd;

        Test.StopTest();
    }
}