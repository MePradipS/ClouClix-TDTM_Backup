@isTest
public with sharing class UtilitiesTest {
	public static testMethod void RunningInAsSandbox() {
		 utilities.runningInASandbox();
	}

	public static testMethod void ConfigureSandbox() {
     App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123',
     Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
     Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
     Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
     insert app;
     RecordType retype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Household' Limit 1];
     Map<String, String> rtype_Map = new Map<String, String>();
     rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();

     Id rtypes = rtype_Map.get('Gift');
     Id rtypes1 = rtype_Map.get('Matching Gift');
     Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
     insert a;

     BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes1,Record_Type_Id_for_Rollups__c = rtypes, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
     insert cs2;

		 utilities.configureSandbox();
	}

	public static testMethod void RunConfigScripts() {
		 utilities.RunConfigScripts();
	}

	public static testMethod void SplitStringAtCommma() {
		 List<String> values = utilities.SplitStringAtCommma('one,two,three', false);
		 List<String> valuesTwo = utilities.SplitStringAtCommma('one, two, three', true);

	}

	public static testMethod void StackTraceTest() {
         utilities.StackTrace();
  }

  public static testMethod void SendingEmailTest() {

       utilities.SendingEmail(new string[] {'rcollins@causeview.com'},'Logger Error','test');
  }

   public static testMethod void SendingEmail2Test() {
       Blob blbVal = Blob.valueof('test');
       utilities.SendingEmail(new string[] {'rcollins@causeview.com'},'Logger Error','test','test','test',blbVal );
  }

  public static testMethod void GetOrganizationInfoTest() {

       utilities.GetOrganizationInfo();
  }

  public static testMethod void IsGiftAidEnabledTest() {

       utilities.IsGiftAidEnabled();
  }

  public static testMethod void GetInstanceTest() {

       utilities.GetInstance();
  }

  public static testMethod void GetAllRecordTypesTest() {

       utilities.GetAllRecordTypes('Contact');
  }

   public static testMethod void GetAllFieldsTest() {

       utilities.GetAllFields('Contact');
  }

   public static testMethod void getObjectRecordTypeIdTest() {

       utilities.getObjectRecordTypeId(Account.SObjectType);
  }

  public static testMethod void getPicklistValuesTest() {

       utilities.getPicklistValues('Contact','Donor_Status__c');
  }

  public static testMethod void IsListValidTest() {
       List<SObject> soList = (List<SObject>)(new List<Account>());

       utilities.IsListValid(soList);
  }

  public static testMethod void IsGatewayIatsOrEziDebitTest() {
       utilities.IsGatewayIatsOrEziDebit('soList');
  }

  public static testMethod void ListToCommaDelimitedStringTest() {
       List<SObject> soList = (List<SObject>)(new List<Account>());

       utilities.ListToCommaDelimitedString(soList);
  }

  public static testMethod void RemoveSquareBracketsFromStringTest() {
       utilities.RemoveSquareBracketsFromString('test');
  }

	//Test functions from fundraising, may be used in the future
  // public static testMethod void IsContactDataCompleteForGiftAidTest() {
  //      Contact con=new Contact();
	//
  //      utilities.IsContactDataCompleteForGiftAid(con);
  // }
  //
  // public static testMethod void FiveFiscalYearsBackTest() {
  //      Gift_Aid_Declaration__c gAid=new Gift_Aid_Declaration__c();
	//
  //      gAid.Next_Fiscal_Date__c=system.today();
  //      utilities.FiveFiscalYearsBack(gAid);
  // }
  //
  // public static testMethod void IsGiftAidDeclarationValidTest() {
  //       Gift_Aid_Declaration__c gAid=new Gift_Aid_Declaration__c();
  //       gAid.Next_Fiscal_Date__c=null;
  //       App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123',
  //       Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
  //       Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
  //       Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
  //       insert app;
	//
  //       utilities.IsGiftAidDeclarationValid(gAid,app);
  // }
  //
  // public static testMethod void IsGiftAidDeclarationValid1Test() {
  //       Gift_Aid_Declaration__c gAid=new Gift_Aid_Declaration__c();
	//
  //       App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123',Fiscal_Start_Month__c=13,
  //       Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
  //       Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
  //       Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
  //       insert app;
	//
  //       utilities.IsGiftAidDeclarationValid(gAid,app);
  // }
	//
  //  public static testMethod void IsGiftAidDeclarationValid2Test() {
  //        Contact contacts = new Contact(FirstName = 'Test', LastName = 'Test');
  //     insert contacts;
  //       Gift_Aid_Declaration__c gAid=new Gift_Aid_Declaration__c();
  //       gAid.Next_Fiscal_Date__c=null;
  //       gAid.Effective_Date__c=system.today();
  //       gAid.End_Date__c=system.today()+2;
  //       gAid.Donor__c=contacts.id;
  //       gAid.Type__c = 'This Donation Only';
  //       insert gAid;
  //       App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123',Fiscal_Start_Month__c=2,
  //       Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
  //       Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
  //       Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
  //       insert app;
	//
  //       utilities.IsGiftAidDeclarationValid(gAid,app);
  // }
	//
  // public static testMethod void IsGiftAidDeclarationValid3Test() {
  //        Contact contacts = new Contact(FirstName = 'Test', LastName = 'Test');
  //     insert contacts;
  //       Gift_Aid_Declaration__c gAid=new Gift_Aid_Declaration__c();
  //       gAid.Next_Fiscal_Date__c=system.today();
  //       gAid.Effective_Date__c=system.today();
  //       gAid.End_Date__c=system.today()+2;
  //       gAid.Donor__c=contacts.id;
  //       gAid.Type__c = 'This Donation Only';
  //       insert gAid;
  //       App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123',Fiscal_Start_Month__c=2,
  //       Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
  //       Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
  //       Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
  //       insert app;
	//
  //       utilities.IsGiftAidDeclarationValid(gAid,app);
  // }
	//
  // public static testMethod void ResolveGiftAidTypeTest() {
  //      utilities.ResolveGiftAidType('test');
  //      utilities.ResolveGiftAidType('This donation, and all future & historic');
  //      utilities.ResolveGiftAidType('This donation, and all future');
  //      utilities.ResolveGiftAidType('This Donation Only');
  // }
	//
  // public static testMethod void ResolvePaymentStatusTest() {
  //      utilities.ResolvePaymentStatus('test');
  //      utilities.ResolvePaymentStatus('Approved');
  //      utilities.ResolvePaymentStatus('Pending');
  //      utilities.ResolvePaymentStatus('Declined');
  // }

  public static testMethod void IsPaymentGiftAidEligibleTest() {
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = '123', Campaign_RecordType_Id__c = '123',Fiscal_Start_Month__c=2,
        Event_RecordType_Id__c = '123', Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
        Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
        Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false);
        insert app;

        RecordType retype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Household' Limit 1];
        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();

        Id rtypes = rtype_Map.get('Gift');

        Contact contacts = new Contact(FirstName = 'Test', LastName = 'Test');
        insert contacts;
        Gift__c gift = new Gift__c();
        gift.Status__c = 'Active';
        gift.Constituent__c = contacts.Id;
        gift.Gift_Date__c = system.today();
        gift.Gift_Type__c  = 'One Time Gift';
        gift.RecordTypeId  = rtypes;
        Insert gift;

        Payment__c payment = new Payment__c();
        payment.Date__c = System.Today();
        payment.Amount__c = 1000.00;
        payment.Payment_Type__c = 'other';
        payment.Donation__c = gift.Id;
        payment.Status__c = 'Approved';

        utilities.IsPaymentGiftAidEligible(payment,app);

  }
   public static testMethod void DecodeHyperLinkedIdTest() {
       utilities.DecodeHyperLinkedId('/http://tree_');
  }
  public static testMethod void InnerLoggerClassTest() {
       utilities.Logger  inLogger=new utilities.Logger();
       inLogger.info('Info');
       inLogger.error('error');
       inLogger.flush();

  }
  public static testMethod void InnerCsvClassTest() {
       utilities.csv  incsv=new utilities.csv();
       incsv.line(new string[] {'test'});
       incsv.format(system.today());
       incsv.format('test');
       incsv.format(2);
       incsv.format(2,3);

  }
   public static testMethod void InnerRemoteResponseClassTest() {
       utilities.RemoteResponse  incrm=new utilities.RemoteResponse();
  }

  public static testMethod void InnerRemoteResponseClass1Test() {

       utilities.RemoteResponse  incrm=new utilities.RemoteResponse();
       utilities uti=new utilities();

       incrm.status =null;
       List<Object> data =new List<Object>();
       data.add('Account');
       incrm.data=data;
       List<String>  str=new  List<String>();
       str.add('test');
       incrm.message=str;
  }
}