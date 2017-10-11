@isTest(seeAllData=true)
public with sharing class TestUpdateRecurringProfile {

	public static testMethod void testUpdateRecurringProfileTrigger(){
		
		Contact con = new Contact();
		con.LastName = 'Testerson';
		insert con;
		
		Account account = new Account();
		account.Name = 'Test Account';
		insert account;
		
		Recurring_Donation__c rd = new Recurring_Donation__c();
		rd.Constituent__c = con.Id;	
		rd.Organization__c = account.Id;
		rd.Start_Date__c = Date.today();
		rd.Status__c = 'Active';
		insert rd;
		
		rd.Status__c = 'On Hold';
		update rd;
		
		rd.Status__c = 'Active';
		update rd; 
	}	
}