@isTest
public class AccountSelectorTest {
    public static Account CreateSObject() {
        Account accountObject = new Account(
            Name = 'Sample Account Name',
            Last_Payment_Amount__c = 1, 
            Last_Payment_Date__c = System.today(), 
            Largest_Gift__c = 100,
			Average_Gift__c = 50, 
            Total_Giving_Last_Year__c = 1000, 
            Total_Giving_Two_Years_Ago__c = 2000, 
            Date_of_Last_Gift__c = System.today(), 
            Date_of_First_Gift__c = System.today(),
			Date_of_First_Transaction__c = System.today(), 
            Date_of_Last_Transaction__c = System.today()
        );
        insert accountObject;
        return accountObject;
    }

    @isTest static void TestSelectIdNameByIdRecordTypeIdLimit() {
		Account expectedAccount = CreateSObject();
        List<String> excludedAccounts = new List<String>();

		Test.startTest();
        List<Account> accountList = new AccountSelector().SelectIdNameByIdRecordTypeIdLimit('FakeId', 'FakeRecordType', excludedAccounts, 10);
        Account actualAccount = accountList.size() > 0 ? accountList[0] : null;
		System.AssertEquals(expectedAccount.Id, actualAccount.Id);
		Test.stopTest();
    }

    @isTest static void TestSelectIdNameByNameIdRecordTypeIdLimit() {
		Account expectedAccount = CreateSObject();
        List<String> excludedAccounts = new List<String>();

		Test.startTest();
        List<Account> accountList = new AccountSelector().SelectIdNameByNameIdRecordTypeIdLimit('Sample', 'FakeId', 'FakeRecordType', excludedAccounts, 10);
        Account actualAccount = accountList.size() > 0 ? accountList[0] : null;
		System.AssertEquals(expectedAccount.Id, actualAccount.Id);
		Test.stopTest();
    }

    @isTest static void TestSelectAccountPaymentsById() {
		Account expectedAccount = CreateSObject();
        List<String> excludedAccounts = new List<String>();

		Test.startTest();
        List<Account> accountList = new AccountSelector().SelectAccountPaymentsById(new Set<Id> { expectedAccount.Id });
        Account actualAccount = accountList.size() > 0 ? accountList[0] : null;
		System.AssertEquals(expectedAccount.Id, actualAccount.Id);
		Test.stopTest();
    }
}