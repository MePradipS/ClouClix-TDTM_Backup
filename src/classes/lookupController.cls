public with sharing class lookupController {

   public List<Contact> Contacts { get; set; }
   public List<Account> Accounts { get; set; }
   public string viewType { get; set; }
   public boolean hasRecords {
     get {
       if (Contacts != null && Contacts.size() > 0)
         return true;
       else if (Accounts != null && Accounts.size()>0)
         return true;
       else
        return false;
     }
   }
   
   public lookupController() {
    String component = ApexPages.currentPage().getParameters().get('component');
     viewType = ApexPages.currentPage().getParameters().get('type');
    if (component != null)
    { 
        searchValue = ApexPages.currentPage().getParameters().get(component + '_text');
        if (searchValue != null && searchValue != '')
           doSearch();
    }
   
   }
   
   public String searchValue { get; set; }
   public void doSearch()
   {
       if (viewType == 'Account')
         searchAccounts();
       else
         searchContacts();
   }
   
   private void searchContacts() { 
     String search = ESAPI.encoder().SFDC_HTMLENCODE(searchValue);
    Contacts = new ContactSelector().SelectLastModifiedContactBySearch(search);      
   }
   
   private void searchAccounts() {
      String search = ESAPI.encoder().SFDC_HTMLENCODE(searchValue);
      Accounts = new AccountSelector().SelectLastModifiedAccountBySearch(search);
   }
}