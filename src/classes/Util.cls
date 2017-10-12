public class Util {

    @future
   public static void allocationUpdate(Set<id> allocIds) //user story #102396768
   {
    List<Gift_Detail__c> allocs = new List<Gift_Detail__c>();
    allocs= new AllocationSelector().SelectPostedToFinanceWhereIdInId(allocIds);
    for(Gift_Detail__c tempAllo : allocs){
        tempAllo.Posted_to_Finance__c = system.Today();
    }
    DMLManager.UpdateSObjects(allocs);
   }

  public class PieWedgeData {

        public String name { get; set; }
        public decimal data { get; set; }

        public PieWedgeData(String name, decimal data) {
            this.name = name;
            this.data = data;
        }
    }

    public static AggregateResult FindItem(List<AggregateResult> objects, object value, string property)
    {
         for(AggregateResult obj : objects)
          if (obj.get(property) == value)
           return obj;

         return null;
    }

    public static Sobject FindObject(List<Sobject> objects, object value, string property)
    {
         for(Sobject obj : objects)
          if (obj.get(property) == value)
           return obj;

         return null;
    }

    public static string GetRecordTypeId(string sobjecttype, string recordTypeName)
    {
        string SchoolRecType = '';
        for(RecordType rt: new RecordTypeSelector().SelectBySObject(sobjecttype))
          if (rt.name == recordTypeName) {
           SchoolRecType = rt.id;
           break;
          }

        return SchoolRecType;
   }

  public static double getDifferenceInSeconds(datetime firstDT, datetime secondDT){
   long dt1 = firstDT.getTime() / 1000;  //getTime gives us milliseconds, so divide by 1000 for seconds
   long dt2 = secondDT.getTime() / 1000;
   double d = dt1 - dt2;
   return d;
  }

  public static string SerializeRecurringItems(List<Recurring_Donation__c> recurrings)
  {
      List<RecurringWrapper> items = new List<RecurringWrapper>();
      for(Recurring_Donation__c rd : recurrings) {
            RecurringWrapper wrapper = new RecurringWrapper();
            wrapper.Id = rd.Id;
            wrapper.Token = rd.Reference__c;
            wrapper.Frequency = rd.Frequency__c;
            wrapper.Amount = rd.Amount__c;
            wrapper.Status = rd.Status__c;
            items.add(wrapper);
      }
      return Json.serialize(items);
  }

  @future(callout=true)
  public static void SubmitRecurringChanges(string rawData, string purpose)
  {
     BatchSettings__c settings = BatchSettings__c.getInstance('Default');
     string url = settings.GatewayUrl__c.replace('Gateway.asmx', 'RecurringUpdate.aspx');

     if(purpose == 'EnableDisableProfile')
        url = settings.GatewayUrl__c.replace('Gateway.asmx', 'EnableDisableProfile.aspx');

     String gatewayKey = GatewaySettingsManager.GetGatewaySettings('GatewayKey').Private_Key__c;
     Blob privateKey = EncodingUtil.base64Decode(gatewayKey);
     string iv = '@1B2c3D4e5F6g7H8';
     //Blob msg = EncodingUtil.base64Encode(pBlob) (rawData);

     string encrypted = EncodingUtil.urlEncode(EncodingUtil.base64Encode(Crypto.encrypt('AES256', privateKey, Blob.valueOf(iv), Blob.valueOf(rawData))),'UTF-8');

     Http h = new Http();
     HttpRequest req = new HttpRequest();
     req.setEndpoint(url);
     req.setMethod('POST');
     req.setTimeout(60000);
     req.setBody('data='+encrypted);
     HttpResponse res = h.send(req);
     string response = res.getBody();
  }

  public class RecurringWrapper
  {
      public string Id { get; set; }
      public string Token { get; set; }
      public string Frequency { get; set; }
      public decimal Amount { get; set; }
      public string Status { get; set; }
  }

  @isTest
  static void testMe()
  {
     Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
     insert a;
     List<RecordType> rtypes = new RecordTypeSelector().SelectByNameNamespacePrefixAndNameLimitList(Utilities.getCurrentNamespace(), 'Gift');
     List<RecordType> rtypesAppeal = new RecordTypeSelector().SelectByNameNamespacePrefixAndNameLimitList(Utilities.getCurrentNamespace(), 'Appeal');

     if (rtypes.size() > 0 && rtypesAppeal.size() > 0)
     {
       BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes[0].Id,Record_Type_Id_for_Rollups__c = rtypes[0].Id, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
       insert cs2;

       Util.getDifferenceInSeconds(DateTime.now(), DateTime.now());
       Util.RecurringWrapper wrapper = new Util.RecurringWrapper();
       wrapper.Amount = 44; wrapper.Id = 'ddd'; wrapper.Token = 'ddd'; wrapper.Frequency = 'ssss'; wrapper.Status = 'ddd';

       List<Recurring_Donation__c> recurrings = new  List<Recurring_Donation__c>();
       recurrings.add(new Recurring_Donation__c(Reference__c='ddd',Frequency__c='dsdsd', Amount__c=234,Status__c='AAS'));
       string result = Util.SerializeRecurringItems(recurrings);
       system.assertEquals('[{"Token":"ddd","Status":"AAS","Id":null,"Frequency":"dsdsd","Amount":234}]', result);
       List<RecurringWrapper>  m =(list<RecurringWrapper>)JSON.deserializeStrict(result, List<RecurringWrapper>.class);
       System.assertEquals(1, m.size());
       RecurringWrapper n=m[0];
       system.assertEquals(234, n.Amount);

       List<Contact> cons = new List<Contact>();
       Contact c = new Contact();
       c.FirstName = 'Test';
       cons.add(c);
       c = new Contact();
       c.FirstName = 'Sam';
       cons.add(c);
       c = new Contact();
       c.FirstName = 'Vahid';
       cons.add(c);
       c = new Contact();
       c.FirstName = 'Lee';
       c.Lastname = 'test';
       cons.add(c);
        insert c;

       Contact c2 = (Contact)FindObject(cons, 'Lee', 'FirstName');
       system.assertEquals('Lee', c2.FirstName);
       Contact c3 = (Contact)FindObject(cons, 'Lee', 'LastName');

       List<contact> clist= new List<contact>();
       clist.add(c);

       GetRecordTypeId('', '');
       string s5=GetRecordTypeId('Campaign', 'Appeal');
       system.assertEquals(s5, rtypesAppeal[0].id);

       List<AggregateResult> result1 = new ContactSelector().SelectSumOfIncome();
       FindItem(new List<AggregateResult>(), c, 'Name');
       AggregateResult g = FindItem(result1, 'Lee', 'FirstName');
       system.assertEquals('Lee', g.get('FirstName'));

       PieWedgeData pwd = new PieWedgeData('temp', 500);
       system.assertEquals('temp', pwd.name);

       BatchSettings__c settings = new BatchSettings__c();
       settings.Name = 'Default';

       //insert settings;

       //SubmitRecurringChanges('OBSDFNO');
       string s1 = 'test';
       string s2 = 'EnableDisableProfile';
       Contact contacts1 = new Contact(FirstName = 'Test1', LastName = 'Test12');
          insert contacts1;
       //Util.SubmitRecurringChanges(s1, s2);
           Campaign camp = new Campaign();
          camp.RecordTypeId = rtypesAppeal[0].id;
          camp.Name = 'sss';
          insert camp;

          Gift__c gift = new Gift__c();
          gift.Status__c = 'Active';
          gift.Constituent__c = contacts1.Id;
          gift.Gift_Date__c = system.today();
          gift.Gift_Type__c  = 'One Time Gift';
          gift.RecordTypeId  = rtypes[0].Id;
          insert gift;

          Fund__c fund = new Fund__c(Fund_Name__c = 'Test123', GL_Credit__c ='123', GL_Debit__c ='123', GL_In_Kind_Credit__c = '123', GL_In_Kind_Debit__c ='123',
                                      GL_Matching_Pledge_Cash_Credit__c ='123', GL_Matching_Pledge_Cash_Debit__c='123', GL_Matching_Pledge_In_Kind_Credit__c='123',
                                      GL_Matching_Pledge_In_Kind_Debit__c='123',GL_Matching_Pledge_Property_Credit__c='231',GL_Matching_Pledge_Property_Debit__c='123',
                                      GL_Matching_Pledge_Stock_Credit__c='123',GL_Matching_Pledge_Stock_Debit__c='123',GL_Matching_Pledge_Write_off_Credit__c='123',
                                      GL_Matching_Pledge_Write_off_Debit__c='123',GL_Other_Credit__c='123',GL_Other_Debit__c='123',GL_Pledge_Credit__c='123',GL_Pledge_Debit__c='123',
                                      GL_Pledge_In_Kind_Credit__c='123',GL_Pledge_In_Kind_Debit__c='123',GL_Pledge_Property_Credit__c='123',GL_Pledge_Stock_Credit__c='123',
                                      GL_Pledge_Stock_Debit__c='123',GL_Pledge_Write_off_Credit__c='123',GL_Pledge_Write_off_Debit__c='123',GL_Recurring_Credit__c='123',GL_Recurring_Debit__c='123');
          insert fund;

          Gift_Detail__c gd = new Gift_Detail__c();
          gd.New_campaign__c = camp.Id;
          gd.Posted_to_Finance__c =system.today();
          gd.Gift__c = gift.Id;
          //gd.Quantity__c = 50;
          gd.Fund__c = fund.id;
          insert gd;
          set<id> aids = new set<Id>();
          aids.add(gd.id);
          util.allocationUpdate(aids); //user story #102396768
          Gift_Detail__c  g11 = new AllocationSelector().SelectPostedToFinanceWhereIdIsId(gd.id);
          System.assertEquals(System.today(), g11.Posted_to_Finance__c );
     }
  }

}