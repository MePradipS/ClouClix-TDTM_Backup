@isTest
public with sharing class TestRDAllocationsTrigger {

	public testMethod static void test(){
		
		Contact c = new Contact();
		c.FirstName = 'Juan';
		c.LastName = 'Sanchez';
		insert c;
		c = [SELECT Id FROM Contact LIMIT 1];
		
		Date startDate = Date.today();
		
		Recurring_Donation__c rd = new Recurring_Donation__c();
		rd.Constituent__c = c.Id;
		rd.Start_Date__c = startDate;
		rd.Amount__c = 3000;
		insert rd;
		rd = [SELECT Id FROM Recurring_Donation__c WHERE Amount__c = 3000];
		RD_Allocation__c alloc = new RD_Allocation__c();
		alloc.Recurring_Gift__c = rd.Id;
		alloc.Amount__c = 1000;
		insert alloc;
		
		alloc = new RD_Allocation__c();
		alloc.Recurring_Gift__c = rd.Id;
		alloc.Amount__c = 1500;
		insert alloc;
		
		alloc = new RD_Allocation__c();
		alloc.Recurring_Gift__c = rd.Id;
		alloc.Amount__c = 500;
		insert alloc;
		
		// Test second recurring donation and allocations
		
		rd = new Recurring_Donation__c();
		rd.Constituent__c = c.Id;
		rd.Start_Date__c = startDate;
		rd.Amount__c = 1500;
		insert rd;
		rd = [SELECT Id FROM Recurring_Donation__c WHERE Amount__c = 1500];
		alloc = new RD_Allocation__c();
		alloc.Recurring_Gift__c = rd.Id;
		alloc.Amount__c = 750;
		insert alloc;
		
		alloc = new RD_Allocation__c();
		alloc.Recurring_Gift__c = rd.Id;
		alloc.Amount__c = 250;
		insert alloc;
		
		alloc = new RD_Allocation__c();
		alloc.Recurring_Gift__c = rd.Id;
		alloc.Amount__c = 500;
		insert alloc;
		
		// test third
		
		rd = new Recurring_Donation__c();
		rd.Constituent__c = c.Id;
		rd.Start_Date__c = startDate;
		rd.Amount__c = 20;
		insert rd;
		rd = [SELECT Id FROM Recurring_Donation__c WHERE Amount__c = 20];
		alloc = new RD_Allocation__c();
		alloc.Recurring_Gift__c = rd.Id;
		alloc.Amount__c = 10;
		insert alloc;
		
		alloc = new RD_Allocation__c();
		alloc.Recurring_Gift__c = rd.Id;
		alloc.Amount__c = 5;
		insert alloc;
		
		alloc = new RD_Allocation__c();
		alloc.Recurring_Gift__c = rd.Id;
		alloc.Amount__c = 5;
		insert alloc;
		
		List<Recurring_Donation__c> donations = [SELECT Id, Amount__c FROM Recurring_Donation__c WHERE Amount__c != null LIMIT 1];
		
		for(Recurring_Donation__c donation : donations){
		
			if(donation.Amount__c != null)
				donation.Amount__c = 50;
		}
		
		update donations;
		donations = [SELECT Id, Amount__c FROM Recurring_Donation__c WHERE Amount__c != null LIMIT 1];
		
		for(Recurring_Donation__c donation : donations){
		
			if(donation.Amount__c != null)
				donation.Amount__c = 1250;
		}
		update donations;
	}
}