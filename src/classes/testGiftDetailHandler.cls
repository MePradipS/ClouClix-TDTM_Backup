@isTest
public class testGiftDetailHandler {
    public testMethod static void testMe()
    {
     String rtypesQuery = 'Select Name, Id From RecordType where Name = \'Gift\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
     List<RecordType> rtypes = database.query(rtypesQuery);        
            
     Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        if (rtypes.size() > 0)
        {
            BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id, BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
            insert cs2;
        }
     
     Contact c = new Contact();
      c.LastName = 'sss';
      insert c;
    
      Gift__c g= new Gift__c();
      g.Constituent__c = c.Id;
      insert g;
      
       Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Check';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Pending';
        p1.Donation__c = g.Id;
        insert p1;

      RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
      Campaign camp = new Campaign(RecordTypeId=recType.id);
      camp.Name = 'sss';
      insert camp;
      
      Event_Level__c elev = new Event_Level__c();
      elev.Event__c = camp.Id;
      elev.Quantity_Available__c = 50;
      insert elev;    
      
      Gift_Detail__c gd = new Gift_Detail__c();
        gd.New_campaign__c = camp.Id;
        gd.Event_Level__c  = elev.Id;
        gd.Gift__c = g.Id;
        gd.Payment__c = p1.Id;
        gd.Quantity__c = 50;
        insert gd; 
        
            
       Benefit__c ben = new Benefit__c();
      insert ben;
      
      Transaction_Benefit__c tben = new Transaction_Benefit__c();
      tben.Benefit__c = ben.Id;
      tben.Transaction__c = g.id;
      insert tben; 
      
        List<Gift_Detail__c> records = new List<Gift_Detail__c>();
        records.add(gd);
        
        GiftDetailHandler.ManageTransactionBenefitsDelete(records);
    
    
      GiftDetailHandler.ManageTransactionBenefitsUpdate(records, records);
    
    }
}