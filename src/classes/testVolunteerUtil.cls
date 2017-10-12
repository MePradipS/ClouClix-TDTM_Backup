@isTest
private class testVolunteerUtil {

    static void createAutoNums() {
        aNums__c a = new aNums__c(Name = 'Default', ContactCount__c = 1, ContactLength__c = 8, ContactPrefix__c = 'CON-', OrgCount__c = 1, OrgLength__c = 8,  OrgPrefix__c = 'ORG-');
        insert a;
    }    
    
   /* static void createPortalSettings() {
        string groupId;
        string groupParentId;
        Contact unknown = new Contact(LastName = 'Unknown');
        insert unknown;
        User guest = [SELECT Id FROM User WHERE Alias = 'guest'];  
        List<RecordType > types = 
          [SELECT Id, Name 
             FROM RecordType 
            WHERE SObjectType = 'Volunteer_Application__c']; 
        for (RecordType rt : types)
        {
          if (rt.Name == 'Group Application') groupId = rt.Id;
          if (rt.Name == 'Parent Group Application') groupParentId = rt.Id;
        }      
        VolunteerPortalSettings__c vps = new VolunteerPortalSettings__c(Name = 'default', UnknownContactId__c = unknown.Id, GuestUserId__c = guest.Id, GroupRecordType__c = groupId, GroupParentRecordType__c = groupParentId);
        insert vps;
    } */
    
    @isTest static void test1() {
        createAutoNums();
        Contact c2 = new Contact(LastName = 'Test2', Email = 'test@test.com');
        VolunteerUtil.upsertContactOnEmail(c2);
        Contact c1 = new Contact(LastName = 'Test1', Email = 'test@test.com');
        VolunteerUtil.upsertContactOnEmail(c1);
        
        
    }  
  /*  
    @isTest static void test3() {
       // Program__c p = new Program__c(Name = 'TestProg');
      //  insert p;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c( Name = 'afas');
        insert vopp;
        Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved');
        insert vpd;
        Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos');
        insert vp;
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Role__c = vp.Id, Shift_Date__c = Date.Today(), Start_Time__c = DateTime.Now(), End_Time__c = DateTime.Now().addHours(2));
        insert shift;
        ShiftWrapper sw = new ShiftWrapper(shift);
       // HourWrapper hw = new HourWrapper(DateTime.Now(), DateTime.Now().addHours(2));
        VolunteerUtil.serializeShiftWrapper(sw);
      //  VolunteerUtil.serializeHourWrapper(hw);        
    }        
*/
 /*   @isTest static void test4() {
        createAutoNums();
     //   createPortalSettings();
        Account a = new Account(Name = 'sss');
        insert a;    
        Contact c = new Contact(AccountId = a.Id, LastName = 'Test', FirstName = 'Test', Email = 'email@email.com');
        insert c;
        User u2 = new User(contactId=c.Id, 
                           username=c.Email, 
                           firstname=c.FirstName,
                           lastname=c.LastName, 
                           email=c.Email,
                         //  communityNickname = c.LastName,
                           alias = string.valueof(c.FirstName.substring(0,1) + c.LastName.substring(0,1)), 
                           profileid = '00eJ0000000Hhp8', 
                           emailencodingkey='UTF-8',
                           languagelocalekey='en_US', 
                           localesidkey='en_US', 
                           timezonesidkey='America/Los_Angeles');
        insert u2;      
       // Program__c p = new Program__c(Name = 'TestProg');
       // insert p;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(Name = 'afas');
        insert vopp;
        Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved', Training_Provided__c = 'Program Specific Training');
        insert vpd;
        Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos');
        insert vp;
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Role__c = vp.Id, Shift_Date__c = Date.Today(), Start_Time__c = DateTime.Now(), End_Time__c = DateTime.Now().addHours(2));
        insert shift;   
        Volunteer_Hours__c vh = new Volunteer_Hours__c(Volunteer_Shift__c = shift.Id, Volunteer__c = c.Id);                 
        insert vh;
        Volunteer_Application__c app = new Volunteer_Application__c(Volunteer__c = c.Id, Volunteer_Role__c = vp.Id, Status__c = 'Placed', Date_of_Background_Check__c = Date.Today(), Date_of_Reference_Check__c = Date.Today());
        insert app;
       // Volunteer_Application__c parent = new Volunteer_Application__c();
       // insert parent;        
      //  Volunteer_Application__c child = new Volunteer_Application__c(Parent_Volunteer_Application__c = parent.Id);
      //  insert child;            
      //  VolunteerUtil.getShiftsFromUser(u2.Id);
      //  VolunteerUtil.getGroupAppsFromUser(u2.Id); 
      //  VolunteerUtil.getContactFromUser(u2.Id);   
      //  VolunteerUtil.getMostRecentAppFromUser(u2.Id);    
      //  VolunteerUtil.getScreeningLevelFromContact(c.Id);  
      //  VolunteerUtil.getAppsFromUser(u2.Id);
      //  VolunteerUtil.getScreeningLevel(u2.Id);
      //  VolunteerUtil.getGroupMembersFromParent(parent.Id);
        VolunteerUtil.isEmptyOrNull('');
    }*/
    
    
    @isTest static void test3()
     {
        String day1 = VolunteerUtil.getDayOfWeek(date.today());
        String day2 = VolunteerUtil.getDayOfWeek(date.today()-1);
        String day3 = VolunteerUtil.getDayOfWeek(date.today()-2);
        String day4 = VolunteerUtil.getDayOfWeek(date.today()-3);
        String day5 = VolunteerUtil.getDayOfWeek(date.today()-4);
        String day6 = VolunteerUtil.getDayOfWeek(date.today()-5);
        String day7 = VolunteerUtil.getDayOfWeek(date.today()-6);
    
    
     Account a23 = new Account();
      a23.Name = 'Indiv';
      insert a23;
      
      Contact uc = new Contact();
      uc.LastName = 'ssss';
      insert uc;

      BatchSettings__c settings = new BatchSettings__c();
      settings.Name = 'Default';
      settings.BatchFormID__c = 'sss';
      settings.BatchReportId__c = 'sss';
      settings.BucketAccountId__c = a23.Id;
      settings.CurrencyCode__c = 'sss';
      settings.GatewayUrl__c = 'sss';
      settings.RegularGiftRecordTypeId__c = 'sss';
      insert settings;
        aNums__c a2 = new aNums__c(Name = 'Default', ContactCount__c = 1, ContactLength__c = 8, ContactPrefix__c = 'CON-', OrgCount__c = 1, OrgLength__c = 8,  OrgPrefix__c = 'ORG-');
        insert a2;
        Contact unknown = new Contact(LastName = 'Unknown');
        insert unknown;
 
        Account a = new Account(Name = 'sss');
        insert a;    
        Contact c = new Contact(AccountId = a.Id, LastName = 'Test', FirstName = 'Test', Email = 'email@email.com');
        insert c;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c( Name = 'afas',  Status__c = 'Open');
        insert vopp;
        Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved', Training_Provided__c = 'Program Specific Training');
        insert vpd;
        Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos', Role_Status__c = 'Open' );
        insert vp;
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Role__c = vp.Id, Shift_Date__c = Date.Today(), Start_Time__c = datetime.newInstance(2014, 9, 15, 11, 30, 0), End_Time__c = datetime.newInstance(2014, 9, 15, 15, 30, 0));
        insert shift;    
        Volunteer_Application__c app = new Volunteer_Application__c(Volunteer__c = c.Id, Volunteer_Role__c = vp.Id, Status__c = 'Placed');
        insert app;
        Volunteer_Hours__c hour = new Volunteer_Hours__c(Volunteer_Shift__c = shift.Id, Volunteer__c = c.Id);
        insert hour;
        
      Set<String> oppIds = new Set<String>();
      oppIds.add(vp.Volunteer_Opportunity__c);
      VolunteerUtil.RecalculateOpportunityStatus(oppIds);
 
     /*Profile pr = [select id from profile where name='Partner Community Login User']; 
      User u = new User(alias = 'stadu', email='standard_user@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = pr.Id, 
            timezonesidkey='America/Los_Angeles', username='standard_user2@testorg.com');
       insert u;
*/
    Profile pr = [select id from profile where name='System Administrator']; 
       User u = new User(alias = 'stadu', email='standard_user@testorg.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = pr.Id, 
            timezonesidkey='America/Los_Angeles', username='standard_user2@testorg.com');
            
      System.runAs(u)
      { 
         List<Volunteer_Shift__c > vs = VolunteerUtil.getShiftsFromUser(Userinfo.getUserId());
         
         vopp.status__c = 'Filled';
         update vopp;
         
         vs = VolunteerUtil.getShiftsFromUser(Userinfo.getUserId());
    
         Volunteer_Application__c app1 = VolunteerUtil.getMostRecentAppFromUser(Userinfo.getUserId());
         Set<String> strData = VolunteerUtil.getProgramSet(Userinfo.getUserId());
         List<Volunteer_Application__c> vap =  VolunteerUtil.getAppsFromUser(Userinfo.getUserId());

         DateTime dt1 = VolunteerUtil.getDateTime('10', '20', 'AM');
         DateTime dt2 = VolunteerUtil.getDateTime(Date.Today(), '10', '10', 'AM');
         
         Contact c1 = VolunteerUtil.getContactFromUser(Userinfo.getUserId());
         
         Integer sid = VolunteerUtil.getScreeningLevel(Userinfo.getUserId());
    }

    Integer  dateCount = VolunteerUtil.getDuration(DateTime.Now(), DateTime.Now().addHours(2));
    shift.Start_Day__c =  Date.today();
    shift.End_Day__c = Date.today()+1;
    update shift;
    
    ShiftWrapper sw = new ShiftWrapper(shift);
    Integer cid = VolunteerUtil.getScreeningLevelFromContact(c.Id); 
    VolunteerUtil.serializeShiftWrapper(sw);   
    }
    
}