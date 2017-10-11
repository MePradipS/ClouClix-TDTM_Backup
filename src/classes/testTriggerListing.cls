@isTest
private class testTriggerListing{
    @isTest static void test3() {
        String namespacePrefix = Utilities.getCurrentNamespace();
        String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
        aNums__c a2 = new aNums__c(Name = 'Default', ContactCount__c = 1, ContactLength__c = 8, ContactPrefix__c = 'CON-', OrgCount__c = 1, OrgLength__c = 8,  OrgPrefix__c = 'ORG-');
        insert a2;
        string groupId;
        string groupParentId;
        Contact unknown = new Contact(LastName = 'Unknown');
        insert unknown;
        String typesQuery = 'SELECT Id, Name FROM RecordType WHERE SObjectType = \'' + namespaceFieldPrefix + 'Volunteer_Application__c\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> types = database.query(typesQuery);
        for (RecordType rt : types)
        {
            if (rt.Name == 'Group Application') groupId = rt.Id;
            if (rt.Name == 'Parent Group Application') groupParentId = rt.Id;
        }      
        //VolunteerPortalSettings__c vps = new VolunteerPortalSettings__c(Name = 'default', UnknownContactId__c = unknown.Id, GuestUserId__c = guest.Id, GroupRecordType__c = groupId, GroupParentRecordType__c = groupParentId);
        //insert vps;
        Account a = new Account(Name = 'sss');
        insert a;    
        Contact c = new Contact(AccountId = a.Id, LastName = 'Test', FirstName = 'Test', Email = 'email@email.com');
        insert c;
        //Program__c p = new Program__c(Name = 'TestProg');
        //insert p;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(Name = 'afas');
        insert vopp;
        Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved', Training_Provided__c = 'Program Specific Training');
        insert vpd;
        Role_Template__c vpd2 = new Role_Template__c(Status__c = 'Approved', Training_Provided__c = 'Program Specific Training');
        insert vpd2;        
        Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos');
        insert vp;
        Volunteer_Role__c vp2 = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos', Role_Status__c = 'Open');
        insert vp2;
        Volunteer_Role__c vp3 = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd2.Id, Name = 'pos', Role_Status__c = 'Open');
        insert vp3;
        Volunteer_Role__c vp4 = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos', Role_Status__c = 'Open');
        insert vp4;                        
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Role__c = vp.Id, Shift_Date__c = Date.Today(), Start_Time__c = DateTime.Now(), End_Time__c = DateTime.Now().addHours(2));
        insert shift;    
        Volunteer_Application__c app = new Volunteer_Application__c(Volunteer__c = c.Id, Volunteer_Role__c = vp.Id, Status__c = 'Placed', Date_of_Background_Check__c = Date.Today());
        insert app;         
        app.Status__c = 'Screening Complete';
        update app;
        app.Status__c = 'Placed';
        update app;
        app.Status__c = 'Exited';
        update app;       
    }
}