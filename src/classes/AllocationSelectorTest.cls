@isTest
public class AllocationSelectorTest {
    private static Campaign CreateCampaignSObject() {
        Campaign campaignObject = new Campaign(
            Name = 'Sample Campaign',
            RecordTypeId = Utilities.getObjectRecordTypeId(Campaign.SObjectType, 'Appeal'),
            Status = 'In Progress',
            IsActive = True,
            StartDate = Date.Today()
        );
        insert campaignObject;
        return campaignObject;
    }

    public static Gift_Detail__c CreateSObject(Campaign campaignObject) {
        Fund__c fundObject = (Fund__c)TestDataTemplates.createSObject(new Fund__c(), 'TestDataTemplates.FundWithGLCodes', true);
        Campaign newCampaignObject = (Campaign)TestDataTemplates.createSObject(new Campaign(Fund__c = fundObject.Id, ParentId = campaignObject.Id), true);
        Contact contactObject = (Contact)TestDataTemplates.createSObject(new Contact(), true);
        Gift__c giftObject = (Gift__c)TestDataTemplates.createSObject( new Gift__c(
            Constituent__c = contactObject.Id,
            Gift_Type__c = 'Recurring'), true);
        Payment__c paymentObject = (Payment__c)TestDataTemplates.createsObject(new Payment__c(
            Status__c = 'Pending',
            Donation__c = giftObject.Id), true);
        Gift_Detail__c allocationObject = new Gift_Detail__c(
            Amount__c = 1,
            Allocation_Date__c = Date.today(),
            Campaign__c = campaignObject.Id,
            Payment__c = paymentObject.Id,
            New_Campaign__c = newCampaignObject.Id,
            Fund__c = fundObject.Id,
            Gift__c = giftObject.Id
        );
        insert allocationObject;
        return allocationObject;
    }

    @testSetup static void SetupBatchSettings() {
        BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
        //App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
    }

    @isTest static void TestSelectSumAmountAndMonthByIdAndCurrentYearByCampaignId() {
        Campaign campaignObject = CreateCampaignSObject();
        Gift_Detail__c expectedAllocation = CreateSObject(campaignObject);

        Test.startTest();
            AggregateResult[] results = new AllocationSelector().SelectSumAmountAndMonthByIdAndCurrentYearByCampaignId(campaignObject.Id);
            AggregateResult actualAllocation = results.size() > 0 ? results[0] : null;
        System.AssertEquals(expectedAllocation.Amount__c, (decimal)actualAllocation.get('total'));
        Test.stopTest();
    }

    @isTest static void TestSelectSumAmountAndFundByConstituent() {
      Gift_Detail__c expectedAllocation = CreateSObject(CreateCampaignSObject());
      String contactId = [SELECT Id from Contact].Id;

      Test.startTest();
          AggregateResult[] results = new AllocationSelector().SelectSumAmountAndFundByConstituent(contactId);
          AggregateResult actualAllocation = results.size() > 0 ? results[0] : null;
      System.AssertEquals(expectedAllocation.Amount__c, (decimal)actualAllocation.get('total'));
      Test.stopTest();
    }

    @isTest static void TestSelectIdAndFundByConstituent() {
      Gift_Detail__c expectedAllocation = CreateSObject(CreateCampaignSObject());
      String contactId = [SELECT Id from Contact].Id;

      Test.startTest();
          List<Gift_Detail__c> results = new AllocationSelector().SelectIdAndFundByConstituent(contactId);
          Gift_Detail__c actualAllocation = results.size() > 0 ? results[0] : null;
      System.AssertEquals(expectedAllocation.Id, actualAllocation.Id);
      Test.stopTest();
    }

    @isTest static void TestSelectMaxFundAndAmountByPayments() {
      Gift_Detail__c expectedAllocation = CreateSObject(CreateCampaignSObject());
      List<Payment__c> paymentList = new List<Payment__c>{new Payment__c(id = expectedAllocation.Payment__c)};

      Test.startTest();
          AggregateResult[] results = new AllocationSelector().SelectMaxFundAndAmountByPayments(paymentList);
          AggregateResult actualAllocation = results.size() > 0 ? results[0] : null;
      System.AssertEquals(expectedAllocation.Amount__c, (decimal)actualAllocation.get('totalFundAmount'));
      Test.stopTest();
    }

    @isTest static void TestSelectApprovedAmountAndPaymentByFund() {
      Gift_Detail__c expectedAllocation = CreateSObject(CreateCampaignSObject());
      Set<Id> fundList = new Set<Id>{expectedAllocation.Fund__c};

      Test.startTest();
          List<Gift_Detail__c> results = new AllocationSelector().SelectApprovedAmountAndPaymentByFund(fundList);
          Gift_Detail__c actualAllocation = results.size() > 0 ? results[0] : null;
      System.AssertEquals(expectedAllocation.Id, actualAllocation.Id);
      Test.stopTest();
    }

    @isTest static void TestSelectIdByPaymentId() {
      Gift_Detail__c expectedAllocation = CreateSObject(CreateCampaignSObject());
      List<String> paymentIds = new List<String>{expectedAllocation.Payment__c};

      Test.startTest();
          List<Gift_Detail__c> results = new AllocationSelector().SelectIdByPaymentId(paymentIds);
          Gift_Detail__c actualAllocation = results.size() > 0 ? results[0] : null;
      System.AssertEquals(expectedAllocation.Id, actualAllocation.Id);
      Test.stopTest();
    }
}