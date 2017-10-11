@isTest
global with sharing class testMapping {

    private static String NamespacePrefix = Utilities.getCurrentNamespace();
    private static String Namespace = NamespacePrefix + (String.isEmpty(NamespacePrefix) ? '' : '__');
    private static String NamespaceGift = Namespace + 'Gift__c';

  public static Contact createContact()
  {
    Boolean inserted = false;
    Double num = math.random();
    String email = 'test' + num + '@test.com';
    String lastName = 'test lastname' + num;

    Contact c = new Contact(LastName=lastName,Email=email);

    insert c;

    return c;
  }

  static testMethod string getGiftRecTypeId()
  {
    List<RecordType> rts = [Select r.SobjectType, r.Name, r.Id From RecordType r WHERE SobjectType= :NamespaceGift and isActive = true];
    String recTypeId = '';
    if (rts!=null && rts.size()>0)
    {
      recTypeId = rts[0].Id;
    }
    return recTypeId;
  }

  public static Gift__c createGift(Contact c)
  {

      Gift__c g = new Gift__c();
      g.Constituent__c = c.Id;
      //g.Amount__c = 80;
      g.Gift_Date__c = Date.today();
      g.Channel__c = 'Phone 2';
      g.Status__c = 'New';
      g.RecordTypeId = getGiftRecTypeId();
      //try
      //{
      insert g;
      //}
      //catch (exception ex)
      //{}
      return g;
  }
  public static Gift__c createGiftForAccount(Account c)
  {

      Gift__c g = new Gift__c();
      g.Organization__c = c.Id;
      //g.Amount__c = 80;
      g.Gift_Date__c = Date.today();
      g.Channel__c = 'Phone 2';
      g.Status__c = 'New';
      g.RecordTypeId = getGiftRecTypeId();
      //try
      //{
      insert g;
      //}
      //catch (exception ex)
      //{}
      return g;
  }

  static Payment__c createPayment(Gift__c g, decimal amount, string paymentType, string status)
  {
      Payment__c p2 = new Payment__c();
      p2.CC_Reference__c = 'SSSESESE';
      p2.Donation__c = g.Id;
      p2.Amount__c = amount;
      p2.Status__c = (RollupHelper.IsEmptyOrNull(status))? 'Approved' : status;
      p2.Payment_Type__c = (RollupHelper.IsEmptyOrNull(paymentType))? 'Credit Card' : paymentType;
      insert p2;

      return p2;
  }

  static void createRecurringRecords()
  {
       Contact c = createContact();

        Recurring_Donation__c rd = new Recurring_Donation__c();
        rd.Amount__c = 80;
        rd.Constituent__c = c.Id;
        rd.Credit_Card_Type__c = 'Credit Card';
        rd.Start_Date__c = Date.today();
        rd.Withdrawal_Date__c = '1';
        insert rd;

        Gift__c g = createGift(c);
        g.Gift_Type__c = 'Recurring';
        g.Recurring_Donation__c = rd.Id;
        //g.Next_Payment_Date__c = Date.today();
        update g;
  }

  static testMethod void testRollUpTotalGiving()
  {
    User u = getAdminUser();

      //System.runAs(u) {

        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();

      Test.StartTest();
     Contact c = createContact();
     Gift__c g = createGift(c);

     Payment__c p1 = new Payment__c();
     p1.CC_Reference__c = 'SESESE';
     p1.Donation__c = g.Id;
     p1.Amount__c = 65;
     p1.Status__c = 'Approved';
     insert p1;

     Receipt__c receipt = new Receipt__c();
     receipt.Constituent__c = c.Id;
     receipt.Gift__c = g.Id;
     receipt.Receipt_Date__c = Date.Today();
     receipt.Status__c = 'To Be Issued';
     receipt.Auto_Email_Receipt__c = true;
     insert receipt;


     Contact c3 = createContact();
     Solicitor__c s = new Solicitor__c();
     s.Solicitor__c = c3.Id;
     s.Gift__c = g.Id;
     s.Role__c = 'Volunteer Solicitor';

     insert s;

      Payment__c p2 = new Payment__c();
      p2.CC_Reference__c = 'SSSESESE';
      p2.Donation__c = g.Id;
      p2.Amount__c = 85;
      p2.Status__c = 'Approved';
      insert p2;

      Contact c2 = createContact();

      g.Primary_Solicitor__c = c2.Id;
      update g;

      List<Contact> ids = new List<Contact>();
      ids.add(c);
      ids.add(c3);
      //RollupHelper.RecalculateTotalGiving(ids);
      //RollupBatch.RecalculateGiftDates(ids);
      //RollupBatch.BuildContactQuery();
      RollupBatch rb = new RollupBatch();
      rb.BuildContactQuery();
      //rb.execute(null, ids);
      //rb.finish(null);
      test.stopTest();
      delete s;

      delete g;
      //}

  }

  static testMethod void testRollUpTotalGivingForOrg()
  {
    User u = getAdminUser();

      //System.runAs(u) {

     BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();

     Account c = new Account();
     c.Name = 'test1';
     insert c;
     Gift__c g = createGiftForAccount(c);

     Payment__c p1 = new Payment__c();
     p1.CC_Reference__c = 'SESESE';
     p1.Donation__c = g.Id;
     p1.Amount__c = 65;
     p1.Status__c = 'Approved';
     insert p1;

     Receipt__c receipt = new Receipt__c();
     receipt.Organization__c = c.Id;
     receipt.Gift__c = g.Id;
     receipt.Receipt_Date__c = Date.Today();
     receipt.Status__c = 'To Be Issued';
     receipt.Auto_Email_Receipt__c = true;
     insert receipt;



      Payment__c p2 = new Payment__c();
      p2.CC_Reference__c = 'SSSESESE';
      p2.Donation__c = g.Id;
      p2.Amount__c = 85;
      p2.Status__c = 'Approved';
      insert p2;


      List<Account> ids = new List<Account>();
      ids.add(c);
      //RollupHelper.RecalculateTotalGiving(ids);
      //RollupBatch.RecalculateGiftDates(ids);
      //RollupBatchForOrganization.GetQuery();
      RollupBatchForOrganization rb = new RollupBatchForOrganization();
      rb.execute(null, ids);
      //rb.finish(null);

      delete g;
      //}

  }

  static testMethod void testCC() {
    User u = getAdminUser();

        GiftBatchPresets gbp = new GiftBatchPresets(u);
        gbp.giftDetailPackage.isHidden = false;

        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();

      //System.runAs(u) {
        //BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();

        Account acc = new Account(Name='test');
        insert acc;

        Batch_Template__c bt123 = new Batch_Template__c();
        bt123.name = 'abc';
        insert bt123;

        Gift_Batch__c gb = new Gift_Batch__c();
        gb.Name__c = 'test834';
        gb.Template_Name__c = bt123.id;
        insert gb;

        Contact c = new Contact(LastName='test ln');
        c.AccountId = acc.Id;
        insert c;
        test.startTest();
        Gift__c g = new Gift__c();
        g.GiftBatch__c = gb.Id;
        g.Constituent__c = c.Id;
        g.Gift_Type__c = 'Gift in Kind';
        g.Gift_Date__c = Date.Today();
        g.Batch_Status__c = 'Pending';
        g.Receipt_Type__c = 'One Receipt per Gift';
        g.RecordTypeId = getGiftRecTypeId();
        //try {
        insert g;
        // }
     // catch (exception ex)
    //  {}
        Payment__c p = new Payment__c();
        p.Payment_Type__c = 'Cash';
        p.Amount__c = 80;
        p.Donation__c = g.Id;
        insert p;

        /*Gift_Detail__c gd = new Gift_Detail__c();
        gd.Amount__c = 80;
        gd.Gift__c = g.Id;
        gd.Payment__c = p.Id;
        insert gd;*/

        ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(gb);
        GiftBatchController cnt = new GiftBatchController(std);
        cnt.editBatch();
        cnt.saveBatch();
        cnt.newGift();
        cnt.FindContact();
        cnt.FindAccount();
        cnt.newBatchItemInterface();
        cnt.populateAmount();
        cnt.populateDate();
        cnt.cancel();
        cnt.saveItemAndNew();
        //cnt.MakePaymentsClicked();
        cnt.ValidateBeforeCommit();
        cnt.IsMoreCreditCardPending();
        cnt.commitBatch();
        cnt.addGiftDetail();
        cnt.UpdateRecurringUI();
        cnt.SelectedBatch = gb;
        //cnt.curr_wrapper.presets.giftDetailPackage.isHidden = false;
        cnt.selectedGiftId = g.Id;
        cnt.EditBatchItem();

        cnt.curr_wrapper.isIndividualGift = true;
        p.Payment_Type__c = 'Credit Card';
        cnt.curr_wrapper.CCName = 'sdsadsa';
        cnt.curr_wrapper.CCNumber = '';
        //cnt.saveItem();
        cnt.curr_wrapper.CCNumber = '23432423423784';
        cnt.curr_wrapper.payment.Credit_Card_Type__c = 'Visa';
        //cnt.saveItem();
        cnt.curr_wrapper.expirationDate = '1401';
        //cnt.saveItem();
        cnt.curr_wrapper.expirationDate = '132';
        //cnt.saveItem();
        cnt.curr_wrapper.expirationDate = '1212';
        cnt.curr_wrapper.presets = new GiftBatchPresets(u);
        cnt.curr_wrapper.presets.giftDetailPackage.isHidden = false;

        cnt.saveItem();

        //cnt.submit();
        test.stopTest();
      //}
    }

    static testMethod User getAdminUser()
    {
        List<Profile> p = [select id from profile where name='Causeview User'];
        if(p == null || p.size() == 0){
            p = [select id from profile where name='System Administrator'];
        }

        if (p.size() > 0)
        {
          User u = new User(alias = 'standt', email='standarduser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p[0].Id,
            timezonesidkey='America/Los_Angeles', username='standarduser2@testorg.com');
          return u;
        }
        return null;
    }

    static testMethod void testRecurring() {

      User u = getAdminUser();

      //System.runAs(u) {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();


        Account acc = new Account(Name='test');
        insert acc;

        Batch_Template__c bt123 = new Batch_Template__c();
        bt123.name = 'abc';
        insert bt123;

        Gift_Batch__c gb = new Gift_Batch__c();
        gb.Name__c = 'test187';
        gb.Open_Date__c = Date.today();
        gb.Template_Name__c = bt123.id;
        insert gb;

        Contact c2 = new Contact(LastName='test ln',FirstName='wewerwe');
        c2.AccountId = acc.Id;
        insert c2;

        //recurring
        Recurring_Donation__c rd = new Recurring_Donation__c();
        rd.Start_Date__c = Date.today();
        rd.Constituent__c = c2.Id;
        rd.Frequency__c = 'Monthly';
        rd.Amount__c = 80;
        insert rd;

        //second gift (recurring)
        Gift__c g2 = new Gift__c();
        g2.GiftBatch__c = gb.Id;
        g2.Constituent__c = c2.Id;
        g2.Recurring_Donation__c = rd.Id;
        g2.Gift_Type__c = 'Gift';
        g2.Gift_Date__c = Date.Today();
        g2.Batch_Status__c = 'Pending';
        g2.RecordTypeId = getGiftRecTypeId();
        g2.Expected_Amount__c = 80;
     //  try {
        insert g2;
    // }
    //  catch (exception ex)
     // {}
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'PAD';
        p1.Amount__c = 80;
        p1.Status__c = 'Pending';
        p1.Donation__c = g2.Id;
        insert p1;

        Gift_Detail__c gd = new Gift_Detail__c();
        gd.Amount__c = 80;
        gd.Gift__c = g2.Id;
        gd.Payment__c = p1.Id;
        insert gd;

        test.startTest();
        ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(gb);
        GiftBatchController cnt = new GiftBatchController(std);
        cnt.SelectedBatch = gb;
        cnt.updateReconciliation();

        cnt.selectedGiftId = g2.Id;
        cnt.EditBatchItem();

        cnt.curr_wrapper.isIndividualGift = true;
        cnt.curr_wrapper.recurringDonation.Frequency__c = null;
        cnt.saveItem();



        cnt.curr_wrapper.recurringDonation.Frequency__c = 'Monthly';
        cnt.curr_wrapper.recurringDonation.start_Date__c = null;
        cnt.saveItem();

        cnt.curr_wrapper.recurringDonation.Start_Date__c = Date.today();
        cnt.curr_wrapper.recurringDonation.of_Payments__c = 0;
        cnt.saveItem();

        cnt.curr_wrapper.recurringDonation.of_Payments__c = 5;
        cnt.saveItem();


        Gift_Detail__c gd2 = new Gift_Detail__c();
        gd2.Amount__c = 80;
        gd2.Gift__c = g2.Id;
        gd2.Payment__c = p1.Id;
        insert gd2;
        cnt.selectedGiftId = g2.Id;
        cnt.EditBatchItem();
        cnt.saveItem();

        cnt.curr_wrapper.isIndividualGift = true;
        cnt.curr_wrapper.recurringDonation.Frequency__c = 'Monthly';
        cnt.curr_wrapper.recurringDonation.Start_Date__c = Date.today();
        cnt.curr_wrapper.payment.Payment_Type__c = 'Credit Card';
        cnt.curr_wrapper.payment.Credit_Card_Type__c = 'Visa';
        cnt.curr_wrapper.payment.Amount__c = 65;
        cnt.curr_wrapper.CCNumber = '23432423423784';
        cnt.saveItem();
        cnt.curr_wrapper.expirationDate = '1212';
        cnt.saveItem();
        cnt.updateReconciliation();
        //cnt.submit();
        cnt.curr_wrapper.recurringDonation.Frequency__c = 'Quarterly';
        cnt.curr_wrapper.recurringDonation.Start_Date__c = Date.today();
        cnt.curr_wrapper.CCNumber = '23432423423784';
        cnt.curr_wrapper.expirationDate = '1212';
        //cnt.submit();
        cnt.curr_wrapper.recurringDonation.Frequency__c = 'Annually';
        cnt.curr_wrapper.recurringDonation.Start_Date__c = Date.today();
        cnt.curr_wrapper.CCNumber = '23432423423784';
        cnt.curr_wrapper.expirationDate = '1212';
        //cnt.submit();
        cnt.curr_wrapper.recurringDonation.Frequency__c = null;
        cnt.curr_wrapper.CCNumber = '23432423423784';
        cnt.curr_wrapper.expirationDate = '1212';
        cnt.saveItem();
        //cnt.submit();
        cnt.updateReconciliation();

        cnt.isTesting = true;
        cnt.removeGiftDetail();
        test.stopTest();
      //}
    }

    static testMethod void testGateWay()
    {

      BatchGateway4.BatchForm bform = new BatchGateway4.BatchForm();
      bform.payments = new BatchGateway4.ArrayOfPaymentInfo();

      BatchGateway4 bg = new BatchGateway4();
       BatchGateway4.GatewaySoap soap = new BatchGateway4.GatewaySoap();
       //soap.GetCountries();

       BatchGateway4.Form f = new BatchGateway4.Form();
       f.applicationStyle = 'asdas';
       f.formButtonStyle  = 'asdas';
       f.formLabelStyle = 'asdas';
       f.formPanelStyle  = 'asdas';
       f.formSectionStyle = 'asdas';
       f.globalStyle  = 'asdas';
       f.underMaintenanceMessage = 'asdas';
       f.sections = new BatchGateway4.ArrayOfFormSection();

       //soap.Submit(f, 'ghgjgjhgj', 'ghgjjhj');
       //soap.GetForm('sdsad', 'sdsadsadsa', 'sdsadsa');
       test.startTest();
       BatchGateway4.GatewaySoap batch = RollupHelper.newGPServiceInstance();
       test.stopTest();
    }

    static testMethod void testSchedulers()
    {
        //consolidated receipt
         Test.startTest();

         Contact c = createContact();
         Gift__c g = createGift(c);
         g.Receipt_Type__c = 'Consolidated Receipt';
         g.Gift_Type__c = 'Recurring';
         g.Gift_Date__c = Date.today().addYears(-1);
         update g;

         ConsolidatedRecieptScheduler crs = new ConsolidatedRecieptScheduler();
         System.schedule('testschedule', '0 0 0 3 9 ?', crs);

         ID batchprocessid = Database.executeBatch(new ConsolidatedReceiptBatch(), 500);


         //new year gift transactions
         Database.executeBatch(new NewYearTransactionsBatch());
         NewYearTransactionScheduler nyt = new NewYearTransactionScheduler();
         System.schedule('testschedule23', '0 0 0 3 9 ? 2022', nyt);

         Test.stopTest();
    }

  /*  static testMethod void testRollups()
    {
         Contact c = createContact();
         Gift__c g = createGift(c);


         g.Primary_Solicitor__c = createContact().Id;
         update g;

        RollupScheduler rollup = new RollupScheduler();
        test.startTest();
        System.schedule('testschedule345', '0 16 0 11 1 ? 2055', rollup);
        DateTime lastRun = DateTime.now().addDays(-1);
        Database.executeBatch(new RollupBatch(lastRun));

        test.stopTest();
    } */


        static testMethod void testRollupsSolicitor()
    {
         Contact c = createContact();
         Gift__c g = createGift(c);


         g.Primary_Solicitor__c = c.Id;
         update g;

        RollupScheduler rollup = new RollupScheduler();
        test.startTest();
        System.schedule('testschedule678', '0 16 0 11 1 ? 2055', rollup);
        DateTime lastRun = DateTime.now().addDays(-1);
        Database.executeBatch(new RollupSolicitorBatch(lastRun));

        test.stopTest();
    }


    static testMethod void testRecurringSubmits()
    {
        test.startTest();

        createRecurringRecords();

        RecurringScheduler scheduler = new RecurringScheduler();
        System.schedule('testschedule_78439574', '0 16 0 11 1 ? 2055', scheduler);

        Database.executeBatch(new RecurringProcessor());

        RollupHelper.CreateTodayRecurringBatch();

        test.stopTest();
    }

   static testMethod void testRefundPaymentController()
   {
      PageReference pageRef = Page.refundpayment;
      Test.setCurrentPage(pageRef);
      refundPaymentController cnt = new refundPaymentController();

      test.startTest();

      Contact c = createContact();
      Gift__c g = createGift(c);
      Payment__c p = createPayment(g, 50, null, null);

      cnt.paymentId = p.Id;
      cnt.init();
      cnt.refresh();
      cnt.submit();

      test.stopTest();
   }

   static testMethod void testRefundPaymentController2()
   {
        PageReference pageRef = Page.refundpayment;
        Test.setCurrentPage(pageRef);
      refundPaymentController cnt = new refundPaymentController();

      test.startTest();

      Contact c = createContact();
      Gift__c g = createGift(c);
      Payment__c p = createPayment(g, 50, null, 'Declined');

      cnt.paymentId = p.Id;
      cnt.init();

      cnt.cancel();

      test.stopTest();
   }

   static testMethod void testConsolidatedReceiptsManual()
  {
     Contact c = [SELECT Id, Name FROM Contact limit 1];
     if (c!=null)
     {
        Gift__c g = createGift(c);
        g.Receipt_Type__c = 'Consolidated Receipt';
        g.Gift_Type__c = 'Recurring';
        g.Gift_Date__c = Date.today().addYears(-1);
        update g;
     }
     String query = 'Select Id, Name, (Select Id, Amount__c, Receipt_Type__c, Status__c From Gifts__r WHERE Receipt_Type__c = \'Consolidated Receipt\'  AND Status__c != \'Acknowledged\''
                        + ' AND Status__c != \'Cancelled\' AND Gift_Date__c = LAST_YEAR) From Contact c WHERE '
                        + ' Id IN (SELECT Constituent__c FROM Gift__c WHERE Receipt_Type__c = \'Consolidated Receipt\' AND Status__c != \'Acknowledged\''
                        + ' AND Status__c != \'Cancelled\' AND Gift_Date__c = LAST_YEAR ) limit 5';
      List<sObject> scope = Database.query(query);
      RollupHelper.executeConsolidatedReceiptBatch(scope);


      String query2 = 'SELECT Id, Channel__c, Constituent__c, Gift_Date__c, Gift_Type__c, Last_Payment_Date__c, Recurring_Donation__c, Reference__c,'
                    + ' Recurring_Donation__r.Reference__c, Recurring_Donation__r.Constituent__c FROM Gift__c '
                    + ' WHERE Gift_Date__c = LAST_YEAR AND Gift_Type__c = \'Recurring\' limit 5';
      List<sObject> scope2 = Database.query(query2);
      RollupHelper.executeNewYearTransactionsBatch(scope2);
  }
   static testMethod void testMe()
    {
        Test.startTest();
         String tempDate = MappingUtil.formatDateForQuery(Date.today());
         String tempDateTime = MappingUtil.formatDateTimeForQuery(Date.today());
        Test.stopTest();
    }

    static testMethod void testSchedulers1()
    {
        //consolidated receipt
         Test.startTest();

         Contact c = createContact();
         Gift__c g = createGift(c);
         g.Receipt_Type__c = 'Consolidated Receipt';
         g.Gift_Type__c = 'Recurring';
         g.Gift_Date__c = Date.today();
         update g;


   Recurring_Donation__c rd = new Recurring_Donation__c(Constituent__c = c.Id, Amount__c = 10, Start_Date__c = Date.today(), Status__c = 'Active');
        insert rd;

        g.Status__c = 'Inactive';
            g.Recurring_Donation__c = rd.Id;
            update g;





         //new year gift transactions
         NewYearTransactionScheduler nyt = new NewYearTransactionScheduler();
         System.schedule('testschedule23', '0 0 0 3 9 ? 2022', nyt);

         Test.stopTest();
    }

    // static testMethod void testRollupIndividualBatchSubmits()
    // {
    //     test.startTest();
    //
    //     Database.executeBatch(new RollupIndividualBatch());
    //
    //     test.stopTest();
    // }

    static testMethod void testsysLastTransUpdatePaymentBatchSubmits()
    {
        Set<Id> setGiftIds = new Set<Id>();
        test.startTest();

        Database.executeBatch(new sysLastTransUpdatePaymentBatch(setGiftIds));

        test.stopTest();
    }

    static testMethod void testDMAccountRollupsBatchSubmits()
    {
        test.startTest();

        Database.executeBatch(new DMAccountRollups());

        test.stopTest();
    }

    static testMethod void testDMContactRollupsBatchSubmits()
    {
        test.startTest();

        Database.executeBatch(new DMContactRollups());

        test.stopTest();
    }

    static testMethod void testRollupBatchForConsecutiveYearsBatchSubmits()
    {
        test.startTest();

        Database.executeBatch(new RollupBatchForConsecutiveYears());

        test.stopTest();
    }

    static testMethod void testRollupBatchforgiftBatchSubmits()
    {
        RollupBatchforgift rollupBatchforgift = new RollupBatchforgift();
        rollupBatchforgift.query = 'Select Id, Amount__c, Solicitor__c, Gift_Date__c, Gift_Status__c From Solicitor__c';
        test.startTest();

        Database.executeBatch(rollupBatchforgift);

        test.stopTest();
    }

    static testMethod void testRollupBatchforSoftCreditBatchSubmits()
    {
        RollupBatchforSoftCredit rollupBatchforSoftCredit = new RollupBatchforSoftCredit();
        rollupBatchforSoftCredit.query = 'Select Id, Amount__c, Solicitor__c, Gift_Date__c, Gift_Status__c From Solicitor__c';
        test.startTest();

        Database.executeBatch(rollupBatchforSoftCredit);

        test.stopTest();
    }
}