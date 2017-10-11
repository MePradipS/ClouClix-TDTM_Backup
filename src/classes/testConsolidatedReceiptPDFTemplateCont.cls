@isTest
Public class testConsolidatedReceiptPDFTemplateCont{
                            
    static testMethod void testContent() {
        Contact c = new Contact(lastName='testContact', Email='test@contact.com');
        Insert c;
        Map<String, String> rtypes_Map = new Map<String, String>();
        String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Event\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> rts = database.query(rtsQuery);
        for(RecordType r : rts){
            rtypes_Map.put(r.Name, r.Id);
        }
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtypes_Map.get('Appeal'), Campaign_RecordType_Id__c = rtypes_Map.get('Campaign'), 
            Event_RecordType_Id__c = rtypes_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;         
        
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
         
        Gift__c g = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert g;

        Receipt__c receipt = new Receipt__c();
        receipt.Gift__c = g.Id;
        receipt.Amount_Receipted__c = 200;
        receipt.Constituent__c = c.Id;
        Insert receipt;

        Payment__c payment = new Payment__c();
        payment.Amount__c = 200;
        payment.Receipt__c = receipt.Id;
        payment.Donation__c = g.Id;

        Insert payment;

        givingpowerSettings__c gps = new givingpowerSettings__c(
            DupeConsolidatedReceiptPDFDocId__c = '012A000000128DT', ConsolidatedReceiptPDFDocId__c = '012A000000128DA',
            Name = 'settings', EmailTemplateId__c = '012A000000128Ds', ReceiptEmailDocId__c = '012A000000128Df',
            ReceiptPDFDocId__c = '012A000000128Dr');
        Insert gps;

        Test.startTest();
        ConsolidatedReceiptPDFTemplateController controller = new ConsolidatedReceiptPDFTemplateController();
        System.assertEquals(controller.content, '');

        controller.relatedToType = 'Receipt__c';
        controller.recipientType = 'Contact';
        controller.isDupe = 'True';
        controller.relatedToId = receipt.Id;
        controller.recipientId = c.Id;
        System.assertEquals(controller.content, '');

        controller.isDupe = 'false';
        System.assertEquals(controller.content, '');

        Test.stopTest();
     }
}