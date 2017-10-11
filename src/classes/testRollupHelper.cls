//Test RollupHelper Class
@isTest
Public class testRollupHelper{
                            
    static testMethod void testRollupHelper() {
        RollupHelper RH = new RollupHelper();
        String rtQuery = 'Select Id From RecordType Where Name=\'Household\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> Rt = database.query(rtQuery);
        if (Rt.size() > 0)
        {
            EmailTemplate el = [SELECT Name FROM EmailTemplate WHERE Name = 'Receipt Template'];
            App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123', 
                Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
                Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
                Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = true);
            insert app;
                
            Account a = new Account(name='testAccount', Email__c='test@account.com', RecordTypeId=Rt[0].Id);
            Insert a;
            
            Account a1 = new Account(name='testAccount1', Email__c='test1@account.com', RecordTypeId=Rt[0].Id);
            Insert a1;
            
            givingpowerSettings__c givingpowerSetting = new givingpowerSettings__c(Name='Settings',EmailTemplateId__c = el.id,
                ReceiptEmailDocId__c = '1233', ReceiptPDFDocId__c = '123', ConsolidatedReceiptPDFDocId__c = '123', Recurring_Batch_Size__c = 5, Rollup_Batch_Size__c = 50);
            insert givingpowerSetting;
            
            BatchSettings__c bs = new BatchSettings__c(Name='Default', BatchFormID__c='123', BatchReportId__c='123',
               BucketAccountId__c=a.Id, CurrencyCode__c='123', RegularGiftRecordTypeId__c=Rt[0].Id);
            Insert bs; 
                  
            Contact c = new Contact(lastName='testContact', Email='test@contact.com', Household__c=a.Id, Total_Fiscal_Transaction_Amount__c=2000,
                                    Total_Lifetime_Transaction_Amount__c=2000, Total_Fiscal_Year_Giving__c=20, Total_Lifetime_Giving__c=10, Total_Lifetime_Fundraising__c=20);
            Insert c;
            hed__Affiliation__c affiliation = new hed__Affiliation__c(hed__Account__c = a.id, hed__Contact__c = c.id, Apply_Soft_Credit__c = true);
            Insert affiliation;
            
            hed__Affiliation__c affiliation1 = new hed__Affiliation__c(hed__Account__c = a1.id, hed__Contact__c = c.id, Apply_Soft_Credit__c = true);
            Insert affiliation1;
            
            hed__Relationship__c relationship = new hed__Relationship__c(hed__Contact__c = c.id, hed__RelatedContact__c = c.id, Apply_Soft_Credit__c = true);
            insert relationship;
            
            Recurring_Donation__c rd = new Recurring_Donation__c(Constituent__c = c.Id, Start_Date__c = system.today());
            Insert rd;
            
            RD_Allocation__c rdAllocation = new RD_Allocation__c(Recurring_Gift__c = rd.Id, Active__c = true, Amount__c = 100.00);
            Insert rdAllocation;
            
            Gift__c d1 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=c.Id, Organization__c=null, RecordType=Rt[0]); 
            Insert d1;
            Receipt__c r = new Receipt__c(Gift__c=d1.Id, Auto_Email_Receipt__c=true);
            Insert r;
            Gift__c d2 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today(), Constituent__c=null, Organization__c=a.Id, RecordType=Rt[0]); 
            Insert d2;
            Gift__c d3 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today().addYears(-1), Constituent__c=null, Organization__c=a.Id, RecordType=Rt[0]); 
            Insert d3;
            Gift__c d4 = new Gift__c(Gift_Type__c='One Time Gift', Gift_Date__c=System.today().addYears(-2), Constituent__c=null, Organization__c=a.Id, RecordType=Rt[0]); 
            Insert d4;
            Gift__c d5 = new Gift__c(Gift_Type__c='Recurring', Gift_Date__c=System.today().addYears(-2), Constituent__c=c.id, Organization__c=null, RecordType=Rt[0], Recurring_Donation__c = rd.id, Receipt_Type__c = 'No Receipt'); 
            Insert d5;

            campaign cn = new campaign(Name='campaign');
            Insert cn;
            Event_Registration__c e1 = new Event_Registration__c(Transaction__c=d1.Id, Registration_Date__c=System.Today(),Individual__c=c.id, Event__c=cn.Id);
            Insert e1;
           
            Payment__c p = new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='cash',
                                            Status__c='Approved', Donation__c = d1.Id, Receipt__c=null);
            Insert p;
            
            Payment__c p1 = new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='cash',
                                            Status__c='Approved', Donation__c = d2.Id, Receipt__c=null);
            Insert p1;
            
            Payment__c p2 = new Payment__c(Date__c=System.today(), Amount__c=200, Payment_Type__c='check',
                                            Status__c='Declined', Donation__c = d5.Id);
            Insert p2;
            List<sObject> listObject = new List<sObject>();
            
            Test.startTest();
            RollupHelper.GuestRegistrations(new Set<Gift__c>{d1, d2});

            RollupHelper.RecalculateTotalHouseholdGiving(new set<Id>());
            RollupHelper.RecalculateTotalHouseholdGiving(new set<Id>{a.Id});

            RollupHelper.RecalculateTotalGivingForOrg(new set<Id>());
            RollupHelper.RecalculateTotalGivingForOrg(new set<Id>{a.Id});

            RollupHelper.RecalculateTotalGiving(new set<Id>());
            RollupHelper.RecalculateTotalGiving(new set<Id>{c.Id});

            RollupHelper.CreateIndividualSoftCredits(new List<Gift__c>{d1, d2});
            RollupHelper.CreateOrganizationSoftCredits(new List<Gift__c>{d1, d2});

            RollupHelper.RecalculateGiftDatesForOrg(new set<Id>{a.Id});
            RollupHelper.RecalculateGiftDates(new set<Id>{c.Id});

            RollupHelper.issueReceipts(new set<Id>{r.Id});
            RollupHelper.issueReceipts(new set<Id>{c.id});

    //        Insert p;
           c = [Select Id, (Select Id, Status__c, Amount__c From Gifts__r) From Contact WHERE Id = :c.Id];
            RollupHelper.executeConsolidatedReceiptBatch(new List<Contact>{c});

            RollupHelper.executeNewYearTransactionsBatch(new List<Gift__C>{d1,d2});

            //RollupHelper.createGiftDetails(new set<String>{':'});
            //RollupHelper.createGiftDetails(new set<String>{'a:b'});
            RollupHelper.CreateTodayRecurringBatch();
            RollupHelper.newGPServiceInstance();
            RollupHelper.maskCardNumber('abcdefghijkl');
            RollupHelper.findItems('abc', 'abc', listObject);
            RollupHelper.UpdateGDs(c.id);
            Test.stopTest();
        }
    }
}