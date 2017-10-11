@isTest
global with sharing class testbenefits {
  
    
  @isTest
  public static void test1() {
      Account a = new Account();
      a.Name = 'Indiv';
      insert a;
      
      Contact uc = new Contact();
      uc.LastName = 'ssss';
      insert uc;

      BatchSettings__c settings = new BatchSettings__c();
      settings.Name = 'Default';
      settings.BatchFormID__c = 'sss';
      settings.BatchReportId__c = 'sss';
      settings.BucketAccountId__c = a.Id;
      settings.CurrencyCode__c = 'sss';
      settings.GatewayUrl__c = 'sss';
      settings.RegularGiftRecordTypeId__c = 'sss';
      insert settings;

      Benefit__c ben = new Benefit__c();
      insert ben;
      update ben;           
      
      Contact c = new Contact();
      c.LastName = 'sss';
      insert c;
      
      Gift__c trans = new Gift__c();
      trans.Constituent__c = c.Id;
      insert trans;
      
      Transaction_Benefit__c tben = new Transaction_Benefit__c();
      tben.Benefit__c = ben.Id;
      tben.Transaction__c = trans.id;
      insert tben;
      delete tben; 
      
      Campaign camp = new Campaign();
      camp.Name = 'sss';
      insert camp;
      
      Event_Level__c elev = new Event_Level__c();
      elev.Event__c = camp.Id;
      elev.Quantity_Available__c = 50;
      insert elev;    
  }
  
  //Event Benefit
   @isTest
  public static void test2() {

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
        
      Account a = new Account();
      a.Name = 'Indiv';
      insert a;
      
      Contact uc = new Contact();
      uc.LastName = 'ssss';
      insert uc;

      BatchSettings__c settings = new BatchSettings__c();
      settings.Name = 'Default';
      settings.BatchReportId__c = 'sss';
      settings.BucketAccountId__c = a.Id;
      settings.CurrencyCode__c = 'sss';
      settings.GatewayUrl__c = 'sss';
      settings.RegularGiftRecordTypeId__c = 'sss';
      settings.BatchFormID__c = 'TBD';
      insert settings;

      Benefit__c ben = new Benefit__c();
      insert ben;
      update ben;           
      
      
      Contact c = new Contact();
      c.LastName = 'sss';
      insert c;
      
      Gift__c trans = new Gift__c();
      trans.Constituent__c = c.Id;
      insert trans;
      RecordType recType=[SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND Name = 'Appeal' limit 1];
      Campaign camp = new Campaign(RecordTypeId=recType.id);
      camp.Name = 'sss';
      insert camp;
      
       Gift__c g1 = new Gift__c(Constituent__c = c.Id, Expected_Amount__c = 100, Gift_Type__c = 'One Time Gift', Gift_Date__c = Date.Today());
        insert g1;
        Payment__c p1 = new Payment__c(Donation__c = g1.Id, Amount__c = 100, Status__c = 'Approved');
        insert p1;
        Gift_Detail__c gd1 = new Gift_Detail__c(Payment__c = p1.Id, Gift__c = g1.Id, Allocation_Date__c = Date.Today()-5, New_Campaign__c = camp.Id, Amount__c = 100);
        insert gd1;

         
      Transaction_Benefit__c tben = new Transaction_Benefit__c();
      tben.Benefit__c = ben.Id;
      tben.Transaction__c = trans.id;
      insert tben;
      
      Event_Level__c elev1 = new Event_Level__c();
      elev1.Event__c = camp.Id;
      elev1.Quantity_Available__c = 50;
      insert elev1;  
      
        Event_Level_Benefit__c elev = new Event_Level_Benefit__c();
          elev.Benefit__c = ben.Id;
          elev.Event_Level__c  = elev1.Id;
          elev.Quantity__c = 2;
      insert elev;     
        
       Map<Gift_Detail__c, string> eventLevelToCreate = new Map<Gift_Detail__c, string>();
       eventLevelToCreate.put(gd1,''+elev1);
        eventLevelToCreate.put(gd1,''+elev);
      eventLevelToCreate.put(gd1,'');
      
     Test.startTest(); 
      List<Transaction_Benefit__c> tCreateBenefit = EventBenefitHelper.CreateTransactionBenefits(eventLevelToCreate);
      List<Transaction_Benefit__c> tDeleteBenefit  = EventBenefitHelper.DeleteTransactionBenefits(new Set<String>());
      
      Test.stopTest(); 
     
  
  }
  
}