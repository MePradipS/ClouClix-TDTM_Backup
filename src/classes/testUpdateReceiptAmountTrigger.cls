@isTest
Public class testUpdateReceiptAmountTrigger{
                            
    static testMethod void testUpdateReceiptAmount() {

        String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' +Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> rtypes = database.query(rtypesQuery);
         
        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a; 
   
        Contact c = new Contact(lastName='testContact', Email='test@contact.com');
        Insert c;
        
        if (rtypes.size() > 0)
        {
            BatchSettings__c bs= new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id, BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
            insert bs;
        }

            
        Gift__c g = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null); 
        Insert g;

        Receipt__c receipt = new Receipt__c();
        receipt.Gift__c = g.Id;   
        Insert receipt;

        Payment__c payment = new Payment__c();
        payment.Amount__c = 200;
        payment.Receipt__c = receipt.Id;
        payment.Donation__c = g.Id;
        
        //When payment is added to consolidated receipt (via lookup field).
        System.assertEquals(receipt.Amount_Receipted__c, null);
        Insert payment;
        
        System.assertEquals(null, [Select Amount_Receipted__c From Receipt__c Where Id = :receipt.Id].Amount_Receipted__c);

        //When payment amount is Updated.
        payment.Amount__c = 500;
        Update payment;
        System.assertEquals(null, [Select Amount_Receipted__c From Receipt__c Where Id = :receipt.Id].Amount_Receipted__c);

        //When payment is removed from consolidated receipt (via lookup field).
        payment.Receipt__c = null;
        Update payment;
        System.assertEquals(null, [Select Amount_Receipted__c From Receipt__c Where Id = :receipt.Id].Amount_Receipted__c);
    }
}