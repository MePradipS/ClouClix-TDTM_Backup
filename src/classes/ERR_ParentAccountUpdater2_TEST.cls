/**
* @description test trigger handler on Contact to throw an exception for error handling tests
* @group ErrorHandling
*/
@isTest
public with sharing class ERR_ParentAccountUpdater2_TEST extends TDTM_Runnable {
    
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
     TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
         
        DmlWrapper dmlWrapper = new DmlWrapper();
 
        //Querying the name in the parent account is only necessary if we are in a future.
        //It is necessary here because we are calling this class from TDTM_Runnable_TEST.
        if(System.isFuture()) {
            List<Contact> contactsWithParentId = [select AccountId from Contact where Id in :newList];
            List<Id> parentAccIds = new List<Id>();
            
            for(SObject o : contactsWithParentId) {
                Contact contact = (Contact)o;
                contact.FirstName = 'New First Name';
                dmlWrapper.objectsToUpdate.add(contact);
                parentAccIds.add(contact.AccountId);
            }

            List<Account> parentAccs = [select Id, Name from Account where Id in :parentAccIds];
            for(Account acc : parentAccs) {
                acc.Name = 'New Acc Name';
                dmlWrapper.objectsToUpdate.add(acc);
            }
        //If we are not in a future setting the name of the parent account does not throw a null pointer exception. 
        } else {
            List<Contact> contactsWithParentInfo = [select Account.Id, Account.Name from Contact where Id in :newList];
            for(SObject o : contactsWithParentInfo) {
                Contact contact = (Contact)o;
                contact.FirstName = 'New First Name';
                contact.Account.Name = 'New Acc Name';
                dmlWrapper.objectsToUpdate.add(contact.Account);
            }
        }

        return dmlWrapper;
    }
}