@isTest
private class testMyGroupsHome{

    private static String namespacePrefix = Utilities.getCurrentNamespace();
    private static String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');

    static void createAutoNums() {
        aNums__c a = new aNums__c(Name = 'Default', ContactCount__c = 1, ContactLength__c = 8, ContactPrefix__c = 'CON-', OrgCount__c = 1, OrgLength__c = 8,  OrgPrefix__c = 'ORG-');
        insert a;
    }    

    static void createPortalSettings() {
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
    }    
    
    @isTest static void test3() {
        createAutoNums();
        createPortalSettings();  
        String groupId;
        String groupParentId;
        String typesQuery = 'SELECT Id, Name FROM RecordType WHERE SObjectType = \'' + namespaceFieldPrefix + 'Volunteer_Application__c\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
        List<RecordType> types = database.query(typesQuery);
        for (RecordType rt : types)
        {
          if (rt.Name == 'Group Application') groupId = rt.Id;
          if (rt.Name == 'Parent Group Application') groupParentId = rt.Id;
        }              
        Account a = new Account(Name = 'sss');
        insert a;    
        Contact c = new Contact(AccountId = a.Id, LastName = 'Test', FirstName = 'Test', Email = 'email@email.com');
        insert c;
    } 
}