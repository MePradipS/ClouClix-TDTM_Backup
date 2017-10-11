@isTest 
private class TestRD {

    static testMethod void test()
    {
        Contact c = new Contact(LastName = 'Contact');
        insert c;
        Recurring_Donation__c rd = new Recurring_Donation__c(Constituent__c = c.Id, Amount__c = 10, Start_Date__c = Date.today());
        insert rd;
        Gift__c g = new Gift__c(Constituent__c = c.Id, Recurring_Donation__c = rd.Id, Status__c = 'Active');
        insert g;
        //Payment__c p = new Payment__c(Amount__c = 10, Donation__c = g.Id, Date__c = Date.today(), Status__c = 'Approved', Payment_Type__c = 'Credit Card');
        //insert p;
        RD_Allocation__c rda = new RD_Allocation__c(Amount__c = 10, Recurring_Gift__c = rd.Id, Active__c = True);
        insert rda;
        rda.Amount__c = 15;
        update rda;
        delete rda;  
        Gift__c g2 = new Gift__c(Recurring_Donation__c = rd.Id, Status__c = 'Active');
try {        insert g2; }
catch (exception ex) {}
    }
}