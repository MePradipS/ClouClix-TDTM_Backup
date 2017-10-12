/*This test class is for GiftControllerExtension apex class*/
@isTest
global with sharing class testNewGift{//test dev 10
    //This testMethod covers the code for Individual
    public testMethod static void testMe()
    {  
       
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        aNums__c cs1 = GLAllocationfieldUpdateTriggerTest.anumsSettings();
           
        BatchSettings__c cs2 = GLAllocationfieldUpdateTriggerTest.batchSettings();  
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        
        Contact c = new Contact(LastName = 'Smith', FirstName = 'John', AccountId = a.Id);
        insert c;      
        
        Gift__c g = testMapping.createGift(c);
        
        Payment__c p2 = new Payment__c();
        p2.CC_Reference__c = 'SSSESESE';
        p2.Donation__c = g.Id;
        p2.Amount__c = 100;
        p2.Status__c = 'Approved';
        p2.Payment_Type__c = 'Credit Card';
        insert p2;
        
        ApexPages.StandardController sc = new ApexPages.standardController(g);
        GiftControllerExtension.TestContactId = c.Id;
        GiftControllerExtension controller = new GiftControllerExtension(sc);
        controller.InitializeContact(c.Id);
       // controller.InitializeContact_url(c.Id,'45','test','test');


        Causeview_REST_API rapi = new Causeview_REST_API();
        rapi.GetActionpage('a');
        
        controller.getMonths();
        controller.getYears();
        controller.addGiftDetail();
        controller.removeGiftDetail();
        controller.addSoftCredit();
        controller.getGiftDetailstoUpdate();
        controller.getSotCreditsToUpdate();
        controller.thePayment.Amount__c = 34;
        controller.theGift.Gift_Type__c = 'One Time Gift';
        controller.thePayment.Payment_Type__c = 'Cash';
        //controller.Submit();
        controller.GoBack();
        
        controller.tryParseToInt('45');
        GiftControllerExtension.BatchAllocationSetting item = new GiftControllerExtension.BatchAllocationSetting('ss','dd');
        //GiftControllerExtension.GetAppealDefaults(null);

        //Test GeneratePaymentSched.
        controller.GeneratePaymentSched();

        controller.payment_structure = 'per payment amount';
        controller.per_payment_amount = '3';
        controller.theGift.Expected_Amount__c = 200;
        controller.GeneratePaymentSched();

        controller.payment_structure = '# of Payments';
        controller.theRecurring.of_Payments__c = 3;
        controller.GeneratePaymentSched();

        Fund__c fund = new Fund__c(Fund_Name__c = 'Test Fund001');
        insert fund;
        Letter__c letter = new Letter__c(Name__c = 'Test Letter001');
        insert letter;
        String RTQuery = 'SELECT Id FROM RecordType WHERE SobjectType = \'Campaign\' AND Name = \'Appeal\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> RT = database.query(RTQuery);
        if (RT.size() > 0)
        {
            Campaign cmp = new Campaign(Name = 'test', Fund__c = fund.id, Letter__c = letter.id);
            cmp.RecordTypeId = RT[0].Id;
            insert cmp;
            GiftControllerExtension.GetAppealDefaults(cmp.id);
            for(Gift_Detail__c gd : controller.theGiftDetails)
            {
                gd.New_Campaign__c = cmp.Id;
                gd.Description__c = cmp.Id;
                gd.Fund__c = fund.Id;
                gd.Amount__c = 200;
                gd.Allocation_Date__c = System.Today();
            }
        }
        Test.startTest();
        //controller.Submit();
        controller.theGift.Expected_Amount__c = 600;
        //Test Gift Type = 'Pledge'.
        controller.theGift.Gift_Type__c = 'Pledge';
        controller.GeneratePaymentSched();
        controller.Submit();

        //Test Gift Type = 'Recurring'.
        controller.theGift.Gift_Type__c = 'Recurring';
        controller.theRecurring.Start_Date__c = System.Today();
        controller.thePayment.Payment_Type__c = 'Credit Card';
        controller.thePayment.Credit_Card_Type__c = 'Visa';
        controller.thePayment.Credit_Card_Number__c = '4222222222222220';
        controller.theRecurring.Credit_Card_Expiry_Date__c = date.newinstance(2020, 2, 1);
        controller.theRecurring.Constituent__c = c.id;
       
        //controller.thePayment.Payment_Type__c = 'cash';
        controller.Submit();
        //Test SubmitPayment.        
        controller.SubmitPayment();
        controller.addPayment();
        
        String jsonData = '{"TransactionStatus_type_info":["TransactionStatus","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"TransactionStatus":"failure","TransactionId_type_info":["TransactionId","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"TransactionId":null,"TraceId_type_info":["TraceId","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"TraceId":"8d12784ad5f4960","SuccessUrl_type_info":["SuccessUrl","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"SuccessUrl":null,"RecurringProfileId_type_info":["RecurringProfileId","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"RecurringProfileId":"A10974272","IsErrorFatal_type_info":["IsErrorFatal","http://www.w3.org/2001/XMLSchema","boolean","1","1","false"],"IsErrorFatal":false,"InvoiceNumber_type_info":["InvoiceNumber","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"InvoiceNumber":"8d12784ae3ca940","field_order_type_info":["TransactionStatus","Errors","IsErrorFatal","TransactionId","ApprovalCode","RecurringProfileId","EncryptedRecurringProfileId","SuccessUrl","InvoiceNumber","TraceId"],"Errors_type_info":["Errors","http://giving-power.com/","ArrayOfErrorMessages","0","1","false"],"Errors":{"field_order_type_info":["ErrorMessages"],"ErrorMessages_type_info":["ErrorMessages","http://giving-power.com/","ErrorMessages","0","-1","true"],"ErrorMessages":[{"field_order_type_info":["Error","ErrorCode"],"ErrorCode_type_info":["ErrorCode","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"ErrorCode":"1","Error_type_info":["Error","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"Error":"Client code has not been set up on the authorization system.","apex_schema_type_info":["http://giving-power.com/","true","false"]}],"apex_schema_type_info":["http://giving-power.com/","true","false"]},"EncryptedRecurringProfileId_type_info":["EncryptedRecurringProfileId","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"EncryptedRecurringProfileId":"EYUmtfJ0tL6OkKfwRA92bw==","ApprovalCode_type_info":["ApprovalCode","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"ApprovalCode":null,"apex_schema_type_info":["http://giving-power.com/","true","false"]}';
        BatchGateway4.TransactionResult txResults = (BatchGateway4.TransactionResult)JSON.deserialize(jsonData, BatchGateway4.TransactionResult.class);
        String jsonData1 = '{"TransactionStatus_type_info":["TransactionStatus","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"TransactionStatus":"success","TransactionId_type_info":["TransactionId","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"TransactionId":null,"TraceId_type_info":["TraceId","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"TraceId":"8d128eba2341b20","SuccessUrl_type_info":["SuccessUrl","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"SuccessUrl":null,"RecurringProfileId_type_info":["RecurringProfileId","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"RecurringProfileId":"A10992881","IsErrorFatal_type_info":["IsErrorFatal","http://www.w3.org/2001/XMLSchema","boolean","1","1","false"],"IsErrorFatal":false,"InvoiceNumber_type_info":["InvoiceNumber","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"InvoiceNumber":"8d128eba1e0cb00","field_order_type_info":["TransactionStatus","Errors","IsErrorFatal","TransactionId","ApprovalCode","RecurringProfileId","EncryptedRecurringProfileId","SuccessUrl","InvoiceNumber","TraceId"],"Errors_type_info":["Errors","http://giving-power.com/","ArrayOfErrorMessages","0","1","false"],"Errors":null,"EncryptedRecurringProfileId_type_info":["EncryptedRecurringProfileId","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"EncryptedRecurringProfileId":"9NoVuy9Zlda0ruou5PJQ5A==","ApprovalCode_type_info":["ApprovalCode","http://www.w3.org/2001/XMLSchema","string","0","1","false"],"ApprovalCode":null,"apex_schema_type_info":["http://giving-power.com/","true","false"]}';
        BatchGateway4.TransactionResult txResults1 = (BatchGateway4.TransactionResult)JSON.deserialize(jsonData1, BatchGateway4.TransactionResult.class);
        
        Recurring_Donation__c theRecurring = new Recurring_Donation__c();
        theRecurring.Status__c = 'Active';
        theRecurring.Type__c = controller.thePayment.Payment_Type__c;
        theRecurring.Amount__c = controller.theGift.Expected_Amount__c;
        theRecurring.Constituent__c = c.id;
        theRecurring.Start_Date__c = system.today();
        theRecurring.Credit_Card_Expiry_Date__c = date.newinstance(2020, 2, 1);
        insert theRecurring;
        
        Recurring_Donation__c rgift = new Recurring_Donation__c(Constituent__c = c.id, Start_Date__c = system.today(), Credit_Card_Expiry_Date__c = date.newinstance(2020, 2, 1));
        insert rgift;

        controller.UpdatePaymentAndGift(controller.thePayment, controller.theGift, txResults);
        controller.getPicklistValues();
        controller.changeReceipttype();
        Test.stopTest();    
        
        controller.InitializeContact_url(c.Id,'45',c.Id,c.Id);
    
    }    
    //This testMethod covers the code for Organisation
    public testMethod static void testMeActionPage()
    { 
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        aNums__c cs1 = GLAllocationfieldUpdateTriggerTest.anumsSettings();
           
        BatchSettings__c cs2 = GLAllocationfieldUpdateTriggerTest.batchSettings();    
          Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        
        Contact c = new Contact(LastName = 'Smith', FirstName = 'John', AccountId = a.Id);
        insert c;      
        
        Gift__c g = testMapping.createGiftForAccount(a);
        
        ApexPages.StandardController sc = new ApexPages.standardController(g);
        GiftControllerExtension.TestContactId = a.Id;
        GiftControllerExtension controller = new GiftControllerExtension(sc);
        controller.InitializeContact(a.Id);
       
        
        
        Causeview_REST_API rapi = new Causeview_REST_API();
        rapi.GetActionpage('a');
        
        controller.getMonths();
        controller.getYears();
        controller.addGiftDetail();
        controller.removeGiftDetail();
        controller.addSoftCredit();
        controller.getGiftDetailstoUpdate();
        controller.getSotCreditsToUpdate();
        controller.thePayment.Amount__c = 34;
        controller.theGift.Gift_Type__c = 'One Time Gift';
        controller.thePayment.Payment_Type__c = 'Cash';
        controller.GoBack();
        
        controller.tryParseToInt('45');
        GiftControllerExtension.BatchAllocationSetting item = new GiftControllerExtension.BatchAllocationSetting('ss','dd');

        //Test GeneratePaymentSched.
        controller.GeneratePaymentSched();

        controller.payment_structure = 'per payment amount';
        controller.per_payment_amount = '3';
        controller.theGift.Expected_Amount__c = 200;
        controller.GeneratePaymentSched();

        controller.payment_structure = '# of Payments';
        controller.theRecurring.of_Payments__c = 3;
        controller.GeneratePaymentSched();
        controller.giftForContact.Constituent__c  = c.id;
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test Fund001');
        insert fund;
        Letter__c letter = new Letter__c(Name__c = 'Test Letter001');
        insert letter;
        String RTQuery = 'SELECT Id FROM RecordType WHERE SobjectType = \'Campaign\' AND Name = \'Appeal\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> RT = database.query(RTQuery);
        if (RT.size() > 0)
        {
            Campaign cmp = new Campaign(Name = 'test', Fund__c = fund.id, Letter__c = letter.id);
            cmp.RecordTypeId = RT[0].Id;
            insert cmp;
            GiftControllerExtension.GetAppealDefaults(cmp.id);
            for(Gift_Detail__c gd : controller.theGiftDetails)
            {
                gd.New_Campaign__c = cmp.Id;
                gd.Description__c = cmp.Id;
                gd.Fund__c = fund.Id;
                gd.Amount__c = 200;
                gd.Allocation_Date__c = System.Today();
            }
        }
        controller.softCredits.add(new Solicitor__c(Organization_Solicitor__c = a.id, Gift__c = g.id)); 
        Test.startTest();
        controller.theGift.Expected_Amount__c = 600;
        //Test Gift Type = 'One Time Gift'.
        controller.theGift.Gift_Type__c = 'Pledge';
        controller.per_payment_amount = null;
        controller.theRecurring.of_Payments__c = null;
        controller.payment_structure = '# of Payments';
        controller.per_payment_amount = '70';
        controller.payment_structure = 'per payment amount';
       
        controller.Submit();

        //Test Gift Type = 'Recurring'.
        controller.theGift.Gift_Type__c = 'Recurring';
        controller.theRecurring.Start_Date__c = System.Today();
        controller.thePayment.Payment_Type__c = 'cash';
        controller.theRecurring.of_Payments__c = 1;
        controller.theRecurring.Constituent__c = c.id;
        controller.Submit();
        //controller.SubmitPayment();
        controller.FirstName='www';
        controller.lastName='wwwd';
        controller.savecontact();
        controller.hiddenInputValue='dddd';       
        controller.hiddenInputId=c.id;
         controller.savecontact();
                
        Test.stopTest();      
    
    }
    
    public testMethod static void testMeInstallmentPledge()
    { 
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        aNums__c cs1 = GLAllocationfieldUpdateTriggerTest.anumsSettings();
 
        App_Settings__c appSetting = GLAllocationfieldUpdateTriggerTest.appSettings();
        appSetting.Enable_Pledge_Installment_Model__c = true;
        update appSetting;
        BatchSettings__c cs2 = GLAllocationfieldUpdateTriggerTest.batchSettings(); 
          Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        
        Contact c = new Contact(LastName = 'Smith', FirstName = 'John', AccountId = a.Id);
        insert c;      
        
        Gift__c g = testMapping.createGiftForAccount(a);
        
        ApexPages.StandardController sc = new ApexPages.standardController(g);
        GiftControllerExtension.TestContactId = a.Id;
        GiftControllerExtension controller = new GiftControllerExtension(sc);
        controller.InitializeContact(a.Id);

        Causeview_REST_API rapi = new Causeview_REST_API();
        rapi.GetActionpage('a');
             
        controller.getMonths();
        controller.getYears();
        controller.addGiftDetail();
        controller.removeGiftDetail();
        controller.addSoftCredit();
        controller.getGiftDetailstoUpdate();
        controller.getSotCreditsToUpdate();
        controller.thePayment.Amount__c = 34;
        controller.theGift.Gift_Type__c = 'Pledge';
        controller.thePayment.Payment_Type__c = 'Cash';
        //controller.Submit();
        controller.GoBack();
        
        controller.tryParseToInt('45');
        GiftControllerExtension.BatchAllocationSetting item = new GiftControllerExtension.BatchAllocationSetting('ss','dd');
        controller.theRecurring.Frequency__c = 'Monthly';
        controller.theRecurring.Start_Date__c = system.today();
        controller.payment_structure = '# of Installment';
        controller.fixedNumberInstallment = 2;
        controller.theGift.Expected_Amount__c = 600;
        controller.generateInstallments();
        controller.giftForContact.Constituent__c  = c.id;
        Fund__c fund = new Fund__c(Fund_Name__c = 'Test Fund001');
        insert fund;
        Letter__c letter = new Letter__c(Name__c = 'Test Letter001');
        insert letter;
        String RTQuery = 'SELECT Id FROM RecordType WHERE SobjectType = \'Campaign\' AND Name = \'Appeal\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> RT = database.query(RTQuery);
        if (RT.size() > 0)
        {
            Campaign cmp = new Campaign(Name = 'test', Fund__c = fund.id, Letter__c = letter.id);
            cmp.RecordTypeId = RT[0].Id;
            insert cmp;
            GiftControllerExtension.GetAppealDefaults(cmp.id);
            for(Gift_Detail__c gd : controller.theGiftDetails)
            {
                gd.New_Campaign__c = cmp.Id;
                gd.Description__c = cmp.Id;
                gd.Fund__c = fund.Id;
                gd.Amount__c = 200;
                gd.Allocation_Date__c = System.Today();
            }
        }
        controller.softCredits.add(new Solicitor__c(Organization_Solicitor__c = a.id, Gift__c = g.id)); 
        Test.startTest();
        controller.Submit();
     
        controller.payment_structure = 'Per Installment Amount';
        controller.per_payment_amount = '200';
        controller.generateInstallments();
        controller.Submit();
        controller.theGift.Gift_Type__c = 'One Time Gift';
        //controller.Submit();
        controller.addInstallment();
        Test.stopTest();      
    
    }
    
    public testMethod static void testMeForCustomLookUpPage(){
          Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        
        Contact c = new Contact(LastName = 'Smith', FirstName = 'John', AccountId = a.Id);
        insert c;   
        CustomContactLookupController controller1 = new CustomContactLookupController('sdd');
        
        controller1.performSearch('sss');
        controller1.getFormTag();
        controller1.getTextBox();
        controller1.search();       
        CustomContactLookupController.contactsWrapperClass cc1 = new CustomContactLookupController.contactsWrapperClass(c);
         CustomContactLookupController controller12 = new CustomContactLookupController(); 

        
    }
}