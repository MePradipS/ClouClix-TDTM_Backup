@isTest
global with sharing class RecurringGiftManagementExtensionTest {

    public static testMethod void testNoIdInUrl() {
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        String nextPage = controller.updateProfile().getUrl();

        System.assertEquals('/null', nextPage);
    }
    
    public static testMethod void testRedirectInvalid() {
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        String actualRedirect = controller.redirect().getUrl();

        System.assertEquals('/null', actualRedirect, 'Redirect url was not correct');
    }

    public static testMethod void testRedirectValid() {
        Contact individual = InitializeContact();
        Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        PageReference actualRedirect = controller.redirect();

        System.assertEquals(null, actualRedirect, 'Redirect url was not correct');
    }

    public static testMethod void testAddValidationError() {
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        String validationMessage = 'Test';
        controller.AddValidationError(validationMessage);

        String[] validationErrors = controller.getValidationErrors();

        System.assertEquals(validationMessage, validationErrors[0], 'Validation Error was not the same.');
    }

    public static testMethod void testOfflineRecurringGift() {
        Contact individual = InitializeContact();
        Recurring_Donation__c offlineRecord = InitializeOffline(individual);
        RD_Allocation__c allocation = InitializeAllocation(offlineRecord);    

        ApexPages.currentPage().getParameters().put('id', offlineRecord.Id);   

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();         
        String actualRedirect = controller.redirect().getUrl();
        String expectedRedirect = '/' + offlineRecord.Id + '/e?nooverride=1&retURL=' + offlineRecord.Id;

        System.assertEquals(expectedRedirect, actualRedirect, 'Offline redirect urls were not the same.');
    }

    public static testMethod void testCancel() {
        Contact individual = InitializeContact();
        Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        String cancelPage = controller.cancel().getUrl();

        System.assertEquals('/' + ukDirectDebitRecord.Id, cancelPage, 'Cancel Url was not correct.');
    }

    public static testMethod void testGetErrors() {
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();

        // Test getErrors
        List<String> expectedErrors = new List<String>();
        expectedErrors.add('Gateway down.');
        expectedErrors.add('Incorrect Data');

        controller.errors = expectedErrors;
        String[] actualErrors = controller.getErrors();
        System.assertEquals(actualErrors[0], expectedErrors[0], 'Error 1 was not correct.');
        System.assertEquals(actualErrors[1], expectedErrors[1], 'Error 2 was not correct.');
    }

    public static testMethod void testUpdateRecurringGiftUkDirectDebit() {
        
        Decimal amount = 2.12;
        String sortCode = '000000';
        String accountNumber = '87654321';
        String status = 'On Hold';
                  
        Contact individual = InitializeContact();
        Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        // instantiate a new controller with updated amount
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.Allocations[0].Amount__c = amount;
        controller.accountNumber = accountNumber;
        controller.routingNumber = sortCode;
        controller.status = status;

        controller.UpdateRecurringGift();

        ukDirectDebitRecord = [SELECT Id, Amount__c, Account__c, Sort_Code__c, Status__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854'];

        String maskedAccountNumber = '****' + accountNumber.substring(accountNumber.length() - 4, accountNumber.length());
        sortCode = sortCode.substring(0, 4) + '**';

        System.assertEquals(amount, ukDirectDebitRecord.Amount__c, 'Amounts were not equal.');
        System.assertEquals(maskedAccountNumber, ukDirectDebitRecord.Account__c, 'Account numbers were not equal.');
        System.assertEquals(sortCode, ukDirectDebitRecord.Sort_Code__c, 'Sort Codes were not equal.');
        System.assertEquals(status, ukDirectDebitRecord.Status__c, 'Status was not equal.');
    }

    public static testMethod void testUpdateRecurringGiftAch() {
        
        Decimal amount = 2.12;
        String routingNumber = '111111111';
        String accountNumber = '12345678';
        String status = 'On Hold';
                  
        Contact individual = InitializeContact();
        Recurring_Donation__c achRecord = InitializeAch(individual);
        RD_Allocation__c allocation = InitializeAllocation(achRecord);
    
        ApexPages.currentPage().getParameters().put('id', achRecord.Id);

        // instantiate a new controller with updated amount
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.Allocations[0].Amount__c = amount;
        controller.accountNumber = accountNumber;
        controller.routingNumber = routingNumber;
        controller.status = status;

        controller.UpdateRecurringGift();

        achRecord = [SELECT Id, Amount__c, Account__c, Branch_Num__c, Status__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854'];

        String maskedAccountNumber = '****' + accountNumber.substring(accountNumber.length() - 4, accountNumber.length());
        String maskedRoutingNumber = routingNumber.substring(0, 4);

        for (Integer i = 0; i < routingNumber.length() - 4; i++) {
            maskedRoutingNumber += '*';
        }

        System.assertEquals(amount, achRecord.Amount__c, 'Amounts were not equal.');
        System.assertEquals(maskedAccountNumber, achRecord.Account__c, 'Account numbers were not equal.');
        System.assertEquals(maskedRoutingNumber, achRecord.Branch_Num__c, 'Routing numbers were not equal.');
        System.assertEquals(status, achRecord.Status__c, 'Status was not equal.');
    }

    public static testMethod void testUpdateRecurringGiftCreditCard() {
        
        Decimal amount = 2.12;
        String creditCardNumber = '5111111111111118';
        String cardType = 'MC';
        String frequency = 'Quarterly';
                  
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        RD_Allocation__c allocation = InitializeAllocation(ccRecord);

        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);

        // instantiate a new controller with updated amount
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.Allocations[0].Amount__c = amount;
        controller.accountNumber = creditCardNumber;
        controller.accountType = cardType;
        controller.frequency = frequency;

        controller.UpdateRecurringGift();

        ccRecord = [SELECT Id, Amount__c, Credit_Card_Type__c, Credit_Card__c, Credit_Card_Expiry_Date__c, Frequency__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854'];

        String maskedCreditCardNumber = '';
        String lastFourAccountNumber = creditCardNumber.substring(creditCardNumber.length() - 4, creditCardNumber.length());
        for (Integer i = 0; i < creditCardNumber.length() - 4; i++) {
            maskedCreditCardNumber += '*';
        }

        maskedCreditCardNumber = maskedCreditCardNumber + lastFourAccountNumber;

        cardType = 'MasterCard';

        System.assertEquals(amount, ccRecord.Amount__c, 'Amounts were not equal.');
        System.assertEquals(maskedCreditCardNumber, ccRecord.Credit_Card__c, 'Credit Card numbers were not equal.');
        System.assertEquals(cardType, ccRecord.Credit_Card_Type__c, 'Credit Card types were not equal.');
        System.assertEquals(frequency, ccRecord.Frequency__c, 'Frequency was not equal.');
    }

    public static testMethod void testUpdateRecurringGiftCancelledUkDirectDebit() {
        
        String status = 'Cancelled';
                  
        Contact individual = InitializeContact();
        Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        // instantiate a new controller with updated amount
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.status = status;

        controller.UpdateRecurringGift();

        ukDirectDebitRecord = [SELECT Id, Status__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854'];

        System.assertEquals(status, ukDirectDebitRecord.Status__c, 'Status was not equal.');
    }

    public static testMethod void testUpdateRecurringGiftNextPaymentDateUkDirectDebit() {
        
        Date scheduleDate = Date.newInstance(2016, 03, 14);
                  
        Contact individual = InitializeContact();
        Recurring_Donation__c ukDirectDebitRecord = InitializeUkDirectDebitGift(individual);
        RD_Allocation__c allocation = InitializeAllocation(ukDirectDebitRecord);

        ApexPages.currentPage().getParameters().put('id', ukDirectDebitRecord.Id);

        Date nextPaymentDate = scheduleDate.addMonths(1);

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.beginDate = nextPaymentDate;

        controller.UpdateRecurringGift();

        ukDirectDebitRecord = [SELECT Id, Next_Payment_Date__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854'];

        System.assertEquals(nextPaymentDate, ukDirectDebitRecord.Next_Payment_Date__c, 'Next payment date was not equal.');
    }

    public static testMethod void testUpdateProfile() {
        Decimal amount = 2.12;

        Contact individual = InitializeContact();
        Recurring_Donation__c achRecord = InitializeAch(individual);
        RD_Allocation__c allocation = InitializeAllocation(achRecord);

        ApexPages.currentPage().getParameters().put('id', achRecord.Id);     

        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.Allocations[0].Amount__c = amount;

        PageReference updateProfilePageReference = controller.updateProfile();
        controller.UpdateRecurringGift();

        achRecord = [SELECT Id, Amount__c, Account__c, Branch_Num__c, Status__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854'];

        System.assertEquals(amount, achRecord.Amount__c, 'Amounts were not equal.');
    }

    public static testMethod void testGetFundList() {
        
        Fund__c fund = InitializeFund();
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        RD_Allocation__c allocation = InitializeAllocation(ccRecord);
        
        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        
        List<Fund__c> fundList = new List<Fund__c>();
        fundList.add(fund);
        
        List<Fund__c> actualFundList = RecurringGiftManagementExtension.GetFunds('');
        
        System.assertEquals(fundList, actualFundList, 'Fund list was not the same');
    }

    public static testMethod void testGetAppealList() {
        
        Campaign appeal = InitializeCampaign();
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        RD_Allocation__c allocation = InitializeAllocation(ccRecord);
        
        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        
        List<Campaign> appealList = new List<Campaign>();
        appealList.add(appeal);

        List<Campaign> actualAppealList = RecurringGiftManagementExtension.GetAppeals('');
        
        System.assertEquals(appealList, actualAppealList, 'Appeal list was not the same');
    }

    public static testMethod void testGetDeclinedPayments() {
        
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        RD_Allocation__c allocation = InitializeAllocation(ccRecord);
        
        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
            
        List<Payment__c> expected = new List<Payment__c>();      
        List<Payment__c> actual = controller.GetDeclinedPayments('0033600000MQy0E');
        
        System.assertEquals(expected, actual, 'declined payments were not the same!');
    }

    public static testMethod void testAddAllocation() {
        
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        RD_Allocation__c allocation = InitializeAllocation(ccRecord);
        Campaign appeal = InitializeCampaign();
        Fund__c fund = InitializeFund();
        
        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.NewAllocation.aAllocation.New_Campaign__c = appeal.Id;
        controller.NewAllocation.aAllocation.Fund__c = fund.Id;
        PageReference pageRef = controller.AddAllocation();
        
        System.assertEquals(null, pageRef, 'add allocation page refs were not the same!');
        
    }

    public static testMethod void testDeleteAllocation() {
        
        Contact individual = InitializeContact();
        Recurring_Donation__c ccRecord = InitializeCreditCard(individual);
        RD_Allocation__c allocation = InitializeAllocation(ccRecord);
        Campaign appeal = InitializeCampaign();
        Fund__c fund = InitializeFund();
        
        ApexPages.currentPage().getParameters().put('id', ccRecord.Id);
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension();
        controller.idToDelete = allocation.Id;
        PageReference pageRef = controller.DeleteAllocation();
        
        System.assertEquals(null, pageRef, 'add allocation page refs were not the same!');
        
    }

    public static testMethod void NextPaymentDateNonMonthly() { 
         
        Contact individual = InitializeContact(); 
        Recurring_Donation__c creditCardRecord = InitializeCreditCard(individual); 
        RD_Allocation__c allocation = InitializeAllocation(creditCardRecord); 
 
        ApexPages.currentPage().getParameters().put('id', creditCardRecord.Id); 
 
        Date scheduleDate = Date.newInstance(2016, 03, 14); 
        Date nextPaymentDate = scheduleDate.addMonths(1); 
 
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension(); 
        controller.beginDate = nextPaymentDate; 
        controller.frequency = 'Annually'; 
 
        controller.UpdateRecurringGift(); 
 
        creditCardRecord = [SELECT Id, Next_Payment_Date__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854']; 
 
        System.assertEquals(nextPaymentDate, creditCardRecord.Next_Payment_Date__c, 'Next payment date was not equal.'); 
    } 
 
    public static testMethod void NextPaymentDateMonthlyDayLaterInMonth() { 
         
        Contact individual = InitializeContact(); 
        Recurring_Donation__c creditCardRecord = InitializeCreditCard(individual); 
        RD_Allocation__c allocation = InitializeAllocation(creditCardRecord); 
 
        ApexPages.currentPage().getParameters().put('id', creditCardRecord.Id); 
 
        Date nextPaymentDate = creditCardRecord.Start_Date__c.addDays(4); 
        Decimal newScheduleDate = nextPaymentDate.day(); 
 
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension(); 
        controller.scheduleDate = newScheduleDate; 
 
        controller.UpdateRecurringGift(); 
 
        creditCardRecord = [SELECT Id, Next_Payment_Date__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854']; 
 
        System.assertEquals(nextPaymentDate, creditCardRecord.Next_Payment_Date__c, 'Next payment date was not equal.'); 
    } 
 
    public static testMethod void NextPaymentDateMonthlyDayEarlierInMonth() { 
         
        Contact individual = InitializeContact(); 
        Recurring_Donation__c creditCardRecord = InitializeCreditCard(individual); 
        RD_Allocation__c allocation = InitializeAllocation(creditCardRecord); 
 
        ApexPages.currentPage().getParameters().put('id', creditCardRecord.Id); 
 
        Date nextPaymentDate = creditCardRecord.Start_Date__c.addDays(-4); 
        //nextPaymentDate = creditCardRecord.Start_Date__c.addMonths(1); 
        nextPaymentDate = creditCardRecord.Start_Date__c; 
        Decimal newScheduleDate = nextPaymentDate.day(); 
 
        RecurringGiftManagementExtension controller = new RecurringGiftManagementExtension(); 
        controller.scheduleDate = newScheduleDate; 
 
        controller.UpdateRecurringGift(); 
 
        creditCardRecord = [SELECT Id, Next_Payment_Date__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854']; 
 
        System.assertEquals(nextPaymentDate, creditCardRecord.Next_Payment_Date__c, 'Next payment date was not equal.'); 
    } 

    private static Contact InitializeContact() {
        Contact individual = new Contact(
            firstName = 'QA',
            lastName = 'Tester',
            MailingStreet = '355 Apple Creek Blvd.',
            MailingCity = 'Markham',
            MailingState = 'Ontario', 
            MailingPostalCode = 'L3R 9X7',
            MailingCountry = 'Canada'
            );

        insert individual;

        individual = [SELECT Id FROM Contact WHERE MailingCountry = 'Canada'];

        return individual;
    }

    private static Recurring_Donation__c InitializeAch(Contact individual) {
        Recurring_Donation__c achRecord = new Recurring_Donation__c(
            Amount__c = 1.00,
            Reference__c = 'A226854',
            Type__c = 'ACH/PAD',
            Start_Date__c = Date.newInstance(2016, 03, 14),
            Schedule_Date__c = 14,
            Frequency__c = 'Monthly', 
            Status__c = 'Active',
            Account__c = '**3456',
            Branch_Num__c = '12300000',
            Constituent__c = individual.Id
            );

        insert achRecord;

        achRecord = [SELECT Id FROM Recurring_Donation__c WHERE Reference__c = 'A226854'];

        return achRecord;
    }

    private static Recurring_Donation__c InitializeCreditCard(Contact individual) {
        Recurring_Donation__c ccRecord = new Recurring_Donation__c(
            Amount__c = 1.00,
            Reference__c = 'A226854',
            Type__c = 'Credit Card',
            Start_Date__c = Date.Today(),
            Schedule_Date__c = 14,
            Frequency__c = 'Monthly', 
            Status__c = 'Active',
            Credit_Card__c = '************2220',
            Credit_Card_Type__c = 'Visa',
            Credit_Card_Expiry_Date__c = Date.newInstance(Date.today().year() + 10, 1, 1),
            Constituent__c = individual.Id
            );

        insert ccRecord;

        ccRecord = [SELECT Id, Start_Date__c FROM Recurring_Donation__c WHERE Reference__c = 'A226854'];

        return ccRecord;
    }

    private static Recurring_Donation__c InitializeOffline(Contact individual) {
        Recurring_Donation__c ccRecord = new Recurring_Donation__c(
            Amount__c = 1.00,
            Reference__c = null,
            Type__c = 'Cash',
            Start_Date__c = Date.newInstance(2016, 03, 14),
            Schedule_Date__c = 14,
            Frequency__c = 'Monthly', 
            Status__c = 'Active',
            Constituent__c = individual.Id
            );

        insert ccRecord;

        ccRecord = [SELECT Id FROM Recurring_Donation__c WHERE Amount__c = 1.00];

        return ccRecord;
    }

    private static Recurring_Donation__c InitializeUkDirectDebitGift(Contact individual) {
        Recurring_Donation__c ukDirectDebitRecord = new Recurring_Donation__c(
            Amount__c = 1.00,
            Reference__c = 'A226854',
            Type__c = 'UK Direct Debit',
            Start_Date__c = Date.newInstance(2016, 03, 14),
            Schedule_Date__c = 14,
            Frequency__c = 'Monthly', 
            Status__c = 'Active',
            Account__c = '****4321',
            Sort_Code__c = '000000',
            Constituent__c = individual.Id
            );

        insert ukDirectDebitRecord;

        ukDirectDebitRecord = [SELECT Id FROM Recurring_Donation__c WHERE Reference__c = 'A226854'];

        return ukDirectDebitRecord;
    }

    private static RD_Allocation__c InitializeAllocation(Recurring_Donation__c gift) {
        RD_Allocation__c allocation = new RD_Allocation__c(
            Amount__c = 1.00,
            Recurring_Gift__c = gift.Id
            );

        insert allocation;

        return allocation;
    }
    
    private static Fund__c InitializeFund() {
        Fund__c fund = new Fund__c(
            Fund_Name__c = 'Test Fund',
            Inactive__c = false
        );
        
        insert fund;
        
        fund = [SELECT Id, Name, Fund_Name__c FROM Fund__c WHERE Fund_Name__c = 'Test Fund'];
        
        return fund;
    }
    
    private static Campaign InitializeCampaign() {
        
        String rtsQuery = 'SELECT Id FROM RecordType WHERE Name =\'Appeal\' AND SobjectType =\'Campaign\' AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\' LIMIT 1';
        List<RecordType> rts = database.query(rtsQuery);
        Id recordTypeId = rts.size() > 0 ? rts[0].Id : null;
        
        Campaign appeal = new Campaign(
            Name = 'Test Appeal',
            IsActive = true,
            RecordTypeId = recordTypeId
        );
        
        insert appeal;
        
        appeal = [SELECT Id, Name, IsActive, RecordTypeId FROM Campaign WHERE Name = 'Test Appeal'];
        
        return appeal;
    }
}