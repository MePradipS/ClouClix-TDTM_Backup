@isTest
public class BatchPresetController_mocTest{
    public static String namespaceFieldPrefix { 
        get
        {
            if (namespaceFieldPrefix == null) {
                String namespace = Utilities.getCurrentNamespace();
                namespaceFieldPrefix = String.isEmpty(namespace) ? '' : namespace + '__';
            }
            return namespaceFieldPrefix;
        }
        set; 
    }

    public static Batch_Template__c createBatchTemplate(){
        String contactXml = '<Contact><fields Lable="Last Name" Name="LastName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="First Name" Name="FirstName" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></Contact>';
        String accountXml = '<Account><fields Lable="Organization Name" Name="Name" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Email" Name="' + namespaceFieldPrefix + 'Email__c" Type="EMAIL" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="true"></fields><fields Lable="Industry" Name="Industry" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Mailing City" Name="BillingCity" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Number of Locations" Name="' + namespaceFieldPrefix + 'CVA_NumberofLocations__c" Type="DOUBLE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Number" Name="AccountNumber" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Phone" Name="Phone" Type="PHONE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Record Type" Name="RecordTypeId" Type="REFERENCE" Value="012A00000012MG8IAM" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Parent Organization" Name="ParentId" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></Account>';
        String giftDetailXml = '<' + namespaceFieldPrefix + 'Gift_Detail__c><fields Lable="Appeal" Name="' + namespaceFieldPrefix + 'New_Campaign__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Fund" Name="' + namespaceFieldPrefix + 'Fund__c" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Allocated Amount" Name="' + namespaceFieldPrefix + 'Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></' + namespaceFieldPrefix + 'Gift_Detail__c>';
        string recurringGiftXml = '<' + namespaceFieldPrefix + 'Recurring_Donation__c><fields Lable="Start Date" Name="' + namespaceFieldPrefix + 'Start_Date__c" Type="DATE" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Frequency" Name="' + namespaceFieldPrefix + 'Frequency__c" Type="PICKLIST" Value="Monthly" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></' + namespaceFieldPrefix + 'Recurring_Donation__c>';
        String giftXml = '<' + namespaceFieldPrefix + 'Gift__c><fields Lable="Receipt Type" Name="' + namespaceFieldPrefix + 'Receipt_Type__c" Type="PICKLIST" Value="Single Receipt" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Gift Type" Name="' + namespaceFieldPrefix + 'Gift_Type__c" Type="PICKLIST" Value="One Time Gift" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields></' + namespaceFieldPrefix + 'Gift__c>';
        String paymentXml = '<' + namespaceFieldPrefix + 'Payment__c PTypes="Credit Card,"><fields Lable="Payment Type" Name="' + namespaceFieldPrefix + 'Payment_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Amount" Name="' + namespaceFieldPrefix + 'Amount__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="false"></fields><fields Lable="Credit Card Number" Name="' + namespaceFieldPrefix + 'Credit_Card_Number__c" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Credit Card Type" Name="' + namespaceFieldPrefix + 'Credit_Card_Type__c" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></' + namespaceFieldPrefix + 'Payment__c>';
        String receiptXml = '<' + namespaceFieldPrefix + 'Receipt__c><fields Lable="Amount Not Eligible" Name="' + namespaceFieldPrefix + 'Amount_Not_Eligible__c" Type="CURRENCY" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="true"></fields></' + namespaceFieldPrefix + 'Receipt__c>';
        String eventRegistrationXml = '<' + namespaceFieldPrefix + 'Event_Registration__c></' + namespaceFieldPrefix + 'Event_Registration__c>';
        Batch_Template__c bt = new Batch_Template__c(name = 'Test123', AccountFieldsXml__c = accountXml, ContactFieldXml__c = contactXml, 
            GiftDetailFieldsXml__c = giftDetailXml, PaymentFieldsXml__c = paymentXml, ReceiptFieldsXml__c = receiptXml, RecurringGiftFieldsXml__c = recurringGiftXml,
            TransactionFieldsXml__c = giftXml, EventRegistrationsFieldsXml__c = eventRegistrationXml);
        insert bt;
        return bt;
    }
	
    public static testMethod void BatchPresetController_mocTest(){
        String namespacePrefix = Utilities.getCurrentNamespace(); 
        String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
        Batch_Template__c bt = createBatchTemplate();
        
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',bt.id);
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        BatchPresetController_moc batchtemplate = new BatchPresetController_moc(sc);
        Batch_Template__c btemplate = new Batch_Template__c(name = 'test98765');
        insert btemplate;
        batchtemplate.paymentTypesToAdd = paymentType;
        batchtemplate.paymentTypesToRemove = removePaymentType;
        batchtemplate.getPaymentTypeFields();
        batchtemplate.IndexListStr0 = 'name:0,Email:1';
        batchtemplate.IndexListStr1 = 'name:0,Industry:1';
        batchtemplate.addPaymentTypes();
        batchtemplate.removePaymentTypes();
        batchtemplate.getPTypePickListOptionsToRemove();
        batchtemplate.getPTypePickListOptionsToAdd();
        batchtemplate.getPaymentTypePickListOptions();
        batchtemplate.getConPickListOptions();
        batchtemplate.getAccPickListOptions();
        batchtemplate.getRgfPickListOptions();
        batchtemplate.getTrnxPickListOptions();
        batchtemplate.getPymtPickListOptions();
        batchtemplate.getRcptPickListOptions();
        batchtemplate.getDGPickListOptions();
        batchtemplate.getEventPickListOptions();
        batchtemplate.showTemplate();
        //batchtemplate.getViewPresets();
        batchtemplate.CreateNewPresetTemplate();
        batchtemplate.newPresetTemplate();
        //batchtemplate.templateId = bt.id;
        //batchtemplate.editPresetTemplate();
        batchtemplate.clonePresetTemplate();
        batchtemplate.conSelected.add('Name');
        batchtemplate.conSelected.add('Email');
        ApexPages.currentPage().getParameters().put('ObjectType', 'Contact');
        batchtemplate.addInPreset();
        batchtemplate.accSelected.add('Name');
        batchtemplate.accSelected.add('NumberOfEmployees');
        ApexPages.currentPage().getParameters().put('ObjectType', 'Account');
        batchtemplate.addInPreset();
        batchtemplate.rgfSelected.add('Name');
        batchtemplate.rgfSelected.add(namespaceFieldPrefix + 'Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Recurring_Donation__c');
        batchtemplate.IndexListStr2 = 'Name:0,' + namespaceFieldPrefix + 'Credit_Card__c:1';
        batchtemplate.addInPreset();
        batchtemplate.trnxSelected.add('Name');
        batchtemplate.trnxSelected.add(namespaceFieldPrefix + 'Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Gift__c');
        batchtemplate.IndexListStr3 = 'Name:0,' + namespaceFieldPrefix + 'Amount__c:1';
        batchtemplate.addInPreset();
        batchtemplate.pymtSelected.add('Name');
        batchtemplate.pymtSelected.add(namespaceFieldPrefix + 'Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Payment__c');
        batchtemplate.IndexListStr4 = 'Name:0,' + namespaceFieldPrefix + 'Donation__c:1';
        batchtemplate.addInPreset();
        batchtemplate.pymtSelected.add('Name');
        batchtemplate.pymtSelected.add('RecordType');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Payment__c');
        batchtemplate.IndexListStr4 = 'Name:0,' + namespaceFieldPrefix + 'Donation__c:1';
        batchtemplate.addInPreset();
        batchtemplate.rcptSelected.add('Name');
        batchtemplate.rcptSelected.add('RecordType');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Receipt__c');
        batchtemplate.IndexListStr5 = 'Name:0';
        batchtemplate.addInPreset();
        batchtemplate.giftDetailSelected.add('Name');
        batchtemplate.giftDetailSelected.add(namespaceFieldPrefix + 'Gift__c');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Gift_Detail__c');
        batchtemplate.IndexListStr6 = 'Name:0,' + namespaceFieldPrefix + 'Fund__c:1';
        batchtemplate.addInPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'Contact');
        ApexPages.currentPage().getParameters().put('index', '1');
        batchtemplate.removalIndex1 = '1';
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'Account');
        ApexPages.currentPage().getParameters().put('index', '2');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Recurring_Donation__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Gift__c');
        ApexPages.currentPage().getParameters().put('index', '0');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Payment__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Gift_Detail__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Receipt__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        //batchtemplate.removeFromPreset();
        batchtemplate.template = btemplate;
        batchtemplate.templateId = bt.id;
        batchtemplate.saveBatchPreset();
        batchtemplate.template = btemplate;
        batchtemplate.saveBatchPreset();
        batchtemplate.cancel();
        batchtemplate.templateId = bt.id;
        batchtemplate.deletePreset();
        batchtemplate.createNewBatch();
    } 
    
    public static testMethod void BatchPresetController_newTest(){
        String namespacePrefix = Utilities.getCurrentNamespace(); 
        String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__'); 
        Batch_Template__c bt = createBatchTemplate();
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef);        
        
        ApexPages.currentPage().getParameters().put('id',bt.id);
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        BatchPresetController_New batchtemplate = new BatchPresetController_New(sc);
        Batch_Template__c btemplate = new Batch_Template__c(name = 'test98765');
        insert btemplate;
       // batchtemplate.paymentTypesToAdd = paymentType;
       // batchtemplate.paymentTypesToRemove = removePaymentType;
        /* batchtemplate.getPaymentTypeFields();
        batchtemplate.IndexListStr0 = 'name:0,Email:1';
        batchtemplate.IndexListStr1 = 'name:0,Industry:1';
        batchtemplate.addPaymentTypes();
        batchtemplate.removePaymentTypes();
        batchtemplate.getPTypePickListOptionsToRemove();
        batchtemplate.getPTypePickListOptionsToAdd();
        batchtemplate.getPaymentTypePickListOptions();
        batchtemplate.getConPickListOptions();
        batchtemplate.getAccPickListOptions();
        batchtemplate.getRgfPickListOptions();
        batchtemplate.getTrnxPickListOptions();
        batchtemplate.getPymtPickListOptions();
        batchtemplate.getRcptPickListOptions();
        batchtemplate.getDGPickListOptions();
        batchtemplate.getEventPickListOptions();
        batchtemplate.showTemplate();
        //batchtemplate.getViewPresets();
        batchtemplate.CreateNewPresetTemplate();
        batchtemplate.newPresetTemplate();
        //batchtemplate.templateId = bt.id;
        //batchtemplate.editPresetTemplate();
        batchtemplate.clonePresetTemplate();
        batchtemplate.conSelected.add('Name');
        batchtemplate.conSelected.add('Email'); */
        ApexPages.currentPage().getParameters().put('ObjectType', 'Contact');
        batchtemplate.addInPreset();
        batchtemplate.accSelected.add('Name');
        batchtemplate.accSelected.add('NumberOfEmployees');
        ApexPages.currentPage().getParameters().put('ObjectType', 'Account');
        batchtemplate.addInPreset();
        batchtemplate.rgfSelected.add('Name');
        batchtemplate.rgfSelected.add(namespaceFieldPrefix + 'Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Recurring_Donation__c');
       // batchtemplate.IndexListStr2 = 'Name:0,Credit_Card__c:1';
        batchtemplate.addInPreset();
        batchtemplate.trnxSelected.add('Name');
        batchtemplate.trnxSelected.add(namespaceFieldPrefix + 'Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Gift__c');
       // batchtemplate.IndexListStr3 = 'Name:0,Amount__c:1';
        batchtemplate.addInPreset();
        batchtemplate.pymtSelected.add('Name');
        batchtemplate.pymtSelected.add(namespaceFieldPrefix + 'Constituent__c');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Payment__c');
       // batchtemplate.IndexListStr4 = 'Name:0,Donation__c:1';
        batchtemplate.addInPreset();
        batchtemplate.pymtSelected.add('Name');
        batchtemplate.pymtSelected.add('RecordType');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Payment__c');
        //batchtemplate.IndexListStr4 = 'Name:0,Donation__c:1';
        batchtemplate.addInPreset();
        batchtemplate.rcptSelected.add('Name');
        batchtemplate.rcptSelected.add('RecordType');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Receipt__c');
       // batchtemplate.IndexListStr5 = 'Name:0';
        batchtemplate.addInPreset();
        batchtemplate.giftDetailSelected.add('Name');
        batchtemplate.giftDetailSelected.add(namespaceFieldPrefix + 'Gift__c');
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Gift_Detail__c');
        //batchtemplate.IndexListStr6 = 'Name:0,Fund__c:1';
        batchtemplate.addInPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'Contact');
        ApexPages.currentPage().getParameters().put('index', '1');
       // batchtemplate.removalIndex1 = '1';
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', 'Account');
        ApexPages.currentPage().getParameters().put('index', '2');
       batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Recurring_Donation__c');
        ApexPages.currentPage().getParameters().put('index', '1');
       batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Gift__c');
        ApexPages.currentPage().getParameters().put('index', '0');
        batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Payment__c');
        ApexPages.currentPage().getParameters().put('index', '1');
       batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Gift_Detail__c');
        ApexPages.currentPage().getParameters().put('index', '1');
       batchtemplate.removeFromPreset();
        ApexPages.currentPage().getParameters().put('ObjectType', namespaceFieldPrefix + 'Receipt__c');
        ApexPages.currentPage().getParameters().put('index', '1');
        //batchtemplate.removeFromPreset();
        batchtemplate.template = btemplate;
        //batchtemplate.templateId = bt.id;
        batchtemplate.saveBatchPreset();
        batchtemplate.template = btemplate;
        batchtemplate.saveBatchPreset();
        batchtemplate.cancel();
       // batchtemplate.templateId = bt.id;
        //batchtemplate.deletePreset();
        batchtemplate.createNewBatch();
        batchtemplate.cloneBatchPreset();
        batchtemplate.newBatchPreset();
        batchtemplate.openBatchPresetsTab();
        //batchtemplate.getConPickListOptions();
        //batchtemplate.getAccPickListOptions();
        //batchtemplate.getRgfPickListOptions();
        //batchtemplate.getTrnxPickListOptions();
        //batchtemplate.getPymtPickListOptions();
        //batchtemplate.getRcptPickListOptions();
        //batchtemplate.getDGPickListOptions();
        //batchtemplate.getEventPickListOptions();
        batchtemplate.getPresetTemplateOptions();
        batchtemplate.editBatchPreset();
    }
    
    public static testMethod void BatchPresetController_mocTest1(){
        String namespacePrefix = Utilities.getCurrentNamespace();
        String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
        Batch_Template__c bt = createBatchTemplate();
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef);        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('id', bt.id);
        BatchPresetController_moc batchtemplate = new BatchPresetController_moc(sc);
        batchtemplate.editAPresetTemplate();
        batchtemplate.templateId = bt.id;
        batchtemplate.saveBatchPreset();
    }
    
    public static testMethod void BatchPresetController_mocTest2(){
        String namespacePrefix = Utilities.getCurrentNamespace();
        String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
        Batch_Template__c bt = createBatchTemplate();
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef);                
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('id', bt.id);
        BatchPresetController_moc batchtemplate = new BatchPresetController_moc(sc);
        batchtemplate.editAPresetTemplate();
        batchtemplate.saveBatchPreset();
        
        batchtemplate.IndexListStr0 = 'name:0,Email:1';
        batchtemplate.IndexListStr1 = 'name:0,AccountNumber:1';
        batchtemplate.IndexListStr2 = 'Name:0,' + namespaceFieldPrefix + 'Credit_Card__c:1';
        batchtemplate.IndexListStr3 = 'Name:0,' + namespaceFieldPrefix + 'Amount__c:1';
        batchtemplate.IndexListStr4 = 'Name:0,' + namespaceFieldPrefix + 'Donation__c:1';
        batchtemplate.IndexListStr5 = 'Name:0';
        batchtemplate.IndexListStr6 = 'Name:0,' + namespaceFieldPrefix + 'Fund__c:1';
        batchtemplate.SaveOrderListForAll();
        
    }
    
    public static testMethod void BatchPresetControllerTest2(){
        String namespacePrefix = Utilities.getCurrentNamespace();
        String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
        Batch_Template__c bt = createBatchTemplate();
       
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');
        
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef);        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        BatchPresetController batchtemplate = new BatchPresetController();
        batchtemplate.newBatchPreset(); 
        batchtemplate.editBatchPreset();
        batchtemplate.getViewPresets();
        batchtemplate.presetTemplateData();   
        batchtemplate.newBatchPresetData();
        batchtemplate.saveBatchPreset();            
       /* batchtemplate.IndexListStr0 = 'name:0,Email:1';
        batchtemplate.IndexListStr1 = 'name:0,AccountNumber:1';
        batchtemplate.IndexListStr2 = 'Name:0,Credit_Card__c:1';
        batchtemplate.IndexListStr3 = 'Name:0,Amount__c:1';
        batchtemplate.IndexListStr4 = 'Name:0,Donation__c:1';
        batchtemplate.IndexListStr5 = 'Name:0';
        batchtemplate.IndexListStr6 = 'Name:0,Fund__c:1';
        batchtemplate.SaveOrderListForAll(); */
        
    }
 
    public static testMethod void BatchPresetLtngMethodTest() {
        String namespacePrefix = Utilities.getCurrentNamespace();
        String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
        Batch_Template__c bt = createBatchTemplate();
        List<string> paymentType = new List<string>();
        paymentType.add('cash');
        paymentType.add('Credit Card');
        List<string> removePaymentType = new List<string>();
        removePaymentType.add('cash');
        removePaymentType.add('Credit Card');        
        
        PageReference pageRef = Page.BatchPresets_mocLtng;
        Test.setCurrentPage(pageRef);   
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        BatchPresetController_moc batchtemplate = new BatchPresetController_moc(sc);
    }
	
	public static testMethod void getFundNameTest(){
        Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), True);
        Campaign testAppealWithFund = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id), true);
        Campaign testAppealNoFund = (Campaign)TestDataTemplates.createSObject(new Campaign(), true);

        Campaign getFundNameSuccessResult = BatchPresetController_moc.getFundName((String)testAppealWithFund.Id);
        System.assertEquals(testAppealWithFund.Id, getFundNameSuccessResult.Id);

        Id testId = '00000000000Z0ZZZZ0';
        Campaign getFundNameFailResult = BatchPresetController_moc.getFundName(testId);
        Campaign test = new Campaign();

        System.assertEquals(test, getFundNameFailResult);
    }

    public static testMethod void BuildQueryTest(){
        Batch_Template__c bt = createBatchTemplate();

        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef); 

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        BatchPresetController_moc batchController = new BatchPresetController_moc(sc);
        batchController.BuildQuery();

        batchController = new BatchPresetController_moc(sc);
        batchController.AlphaFilter = 'Other';
        batchController.BuildQuery();

        batchController = new BatchPresetController_moc(sc);
        batchController.AlphaFilter = null;
        batchController.BuildQuery();

        batchController = new BatchPresetController_moc(sc);
        batchController.AlphaFilter = 'Potato';
        batchController.BuildQuery();

        batchController = new BatchPresetController_moc(sc);
        batchController.temp.Type__c = 'Personal';
        batchController.BuildQuery();
    }

    public static testMethod void getNameByIdTest(){
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef); 

        Batch_Template__c bt = createBatchTemplate();
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
        Contact testContact = (Contact)TestDataTemplates.createSObject(new Contact(), true);
        Gift__c testGift = (Gift__c)TestDataTemplates.createSObject(new Gift__c(Constituent__c = testContact.Id), true);
        Fund__c testFund = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), True);
        Campaign testAppeal = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = testFund.Id), true);

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        BatchPresetController_moc batchController = new BatchPresetController_moc(sc);
        batchController.getNameById(namespaceFieldPrefix + 'Payment__c', testGift.Id, namespaceFieldPrefix + 'Donation__c');

        Payment__c testPayment = (Payment__c)TestDataTemplates.createsObject(new Payment__c(
            Status__c = 'Pending',
            Donation__c = testGift.Id), true);
        Gift_Detail__c testAllocation = (Gift_Detail__c)TestDataTemplates.createSObject(new Gift_Detail__c(
            Payment__c = testPayment.Id,
            New_Campaign__c = testAppeal.Id,
            Fund__c = testFund.Id,
            Gift__c = testGift.Id), true);

        sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        batchController = new BatchPresetController_moc(sc);
        batchController.getNameById(namespaceFieldPrefix + 'Payment__c', testGift.Id, namespaceFieldPrefix + 'Donation__c');

        sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        batchController = new BatchPresetController_moc(sc);
        batchController.getNameById(namespaceFieldPrefix + 'Payment__c', testGift.Id, namespaceFieldPrefix + 'Word__c');
    }

    public static testMethod void getSolicitCodesTest(){
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef); 
        Batch_Template__c bt = createBatchTemplate();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        BatchPresetController_moc batchController = new BatchPresetController_moc(sc);
        batchController.getSolicitCodes();
    }

    public static testMethod void getTemplateTypeTest(){
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef); 
        Batch_Template__c bt = createBatchTemplate();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        BatchPresetController_moc batchController = new BatchPresetController_moc(sc);
        batchController.getTemplateType();
    }

    public static testMethod void getPTypesTest(){
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef); 
        Batch_Template__c bt = createBatchTemplate();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        BatchPresetController_moc batchController = new BatchPresetController_moc(sc);
        batchController.getPTypes();
    }

    public static testMethod void getTemplateTranTypeTest(){
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef); 
        Batch_Template__c bt = createBatchTemplate();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        BatchPresetController_moc batchController = new BatchPresetController_moc(sc);
        batchController.getTemplateTranType();
    }
    
    public static testMethod void getConstituentCodesTest(){
        PageReference pageRef = Page.BatchPresets_moc;
        Test.setCurrentPage(pageRef); 
        Batch_Template__c bt = createBatchTemplate();
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bt);
        ApexPages.currentPage().getParameters().put('templateId', bt.id);
        BatchPresetController_moc batchController = new BatchPresetController_moc(sc);
        batchController.getConstituentCodes();
    }
}