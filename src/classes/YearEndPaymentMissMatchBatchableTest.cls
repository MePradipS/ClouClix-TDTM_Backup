@isTest //(seeAllData = true)
private class YearEndPaymentMissMatchBatchableTest{
	//TO-DO: Test Multiple Allocations
	//TO-DO: Test Multiple Payments

	@isTest
	static void OnePaymentOneAllocation(){
  		ConfigureCauseview();

		// Given
		contact newContact = new contact(
				LastName = 'testContact'
			);
		insert newContact;

		//newContact = [SELECT Id, LastName FROM contact WHERE LastName = 'testContact'];

		Recurring_Donation__c newRecurringGift = new Recurring_Donation__c(
				Constituent__c = newContact.Id,
				Amount__c = 20,
				Frequency__c = 'Monthly',
				Status__c = 'Active',
				Start_Date__c = date.parse('07/03/2016'),
				Schedule_Date__c = 12
			);

		insert newRecurringGift;

		//newRecurringGift = [SELECT Id, Constituent__c, Amount__c, Frequency__c, Status__c, Start_Date__c, Schedule_Date__c FROM Recurring_Donation__c WHERE Constituent__c = :newContact.Id];

		Fund__c newFund = new Fund__c(
				Fund_Name__c = 'testFund'
			);

		insert newFund;

		Campaign newAppeal = new Campaign(
				Name = 'Test Appeal',
				Type = 'Email',
				Fund__c = newFund.Id,
				RecordTypeId = (new RecordTypeSelector().SelectByNameNamespacePrefixAndName(Utilities.getCurrentNamespace(), 'Appeal')).Id,
				Status = 'In Progress',
				IsActive = true,
				StartDate = date.parse('01/01/2016'),
				EndDate = date.parse('01/01/2018')
			);

		insert newAppeal;

		RD_Allocation__c newRecurringAllocation1 = new RD_Allocation__c(
				Recurring_Gift__c = newRecurringGift.Id,
				Active__c = true,
				Amount__c = 20,
				New_Campaign__c = newAppeal.Id,
				Fund__c = newFund.Id
			);

		insert newRecurringAllocation1;

		gift__c newGift1 = new gift__c(
				Constituent__c = newContact.Id,
				Gift_date__c = date.parse('07/03/2016'),
				Gift_Type__c = 'Recurring',
				Recurring_Donation__c = newRecurringGift.Id
			);

		gift__c newGift2 = new gift__c(
				Constituent__c = newContact.Id,
				Gift_date__c = date.parse('01/01/2017'),
				Gift_Type__c = 'Recurring',
				Recurring_Donation__c = newRecurringGift.Id
			);

		insert newGift1;
		insert newGift2;

		//newGift1 = [SELECT Id, Constituent__c, Gift_date__c, Gift_Type__c, Recurring_Donation__c FROM gift__c WHERE Gift_date__c = 2016-03-12];

		payment__c newPayment = new payment__c(
				Status__c = 'Approved',
				Date__c = date.parse('01/03/2017'),
				Amount__c = 20,
				Donation__c = newGift1.Id
			);

		insert newPayment;

		//newPayment = [SELECT Id, Status__c, Date__c, Amount__c, Donation__c FROM payment__c WHERE Date__c = 2017-01-01];


		gift_detail__c newAllocation = new gift_detail__c(
				New_Campaign__c = newRecurringAllocation1.New_Campaign__c,
				Fund__c = newRecurringAllocation1.Fund__c,
				Amount__c = newPayment.Amount__c,
				Allocation_Date__c = newPayment.Date__c,
				Gift__c = newGift1.Id,
				Payment__c = newPayment.Id
			);

		insert newAllocation;

		// When
		Test.startTest();
		database.executeBatch(new YearEndPaymentMissMatchBatchable(),100);
		Test.stopTest();

		// Then
		payment__c resultPayment = new PaymentSelector().SelectPaymentWhereIdIsPaymentId(newPayment.Id);
		List<Gift_Detail__c> resultAlloctionList = new AllocationSelector().SelectGiftDetailsWhereIdEqualsAllocationId(newAllocation.Id);
		gift_detail__c resultAlloction;
		
		 if (resultAlloctionList != null && resultAlloctionList.size() > 0){ 
            resultAlloction =  resultAlloctionList[0]; 
        } 
		
		system.assertEquals(newGift2.Id,resultPayment.Donation__c,'Transaction did not switch properly on payment.');
		system.assertEquals(newGift2.Id,resultAlloction.Gift__c,'Transaction did not switch properly on allocation.');
	}

	@isTest
	static void MultiplePaymentMultipleAllocation(){
		//TEST SETUP//
			//SET UP BATCH SETTINGS AND APPLICATION SETTINGS//
	  		ConfigureCauseview();
	  		//////////////////////////////////////////////////

	  		//LIST OF TEST RECORDS//
	  		List<RD_Allocation__c> recurringAllocationList = new List<RD_Allocation__c>();
	  		List<Gift__c> transactionList = new List<Gift__c>();
	  		List<Payment__c> paymentList = new List<Payment__c>();
	  		List<Gift_Detail__c> allocationList = new List<Gift_Detail__c>();
	  		////////////////////////

	  		//CREATE A TEST CONTACT//
			Contact newContact = new Contact(
					LastName = 'testContact'
				);
			insert newContact;
			/////////////////////////

			//CREATE A TEST RECURRING GIFT//
			Recurring_Donation__c newRecurringGift = new Recurring_Donation__c(
					Constituent__c = newContact.Id,
					Amount__c = 20,
					Frequency__c = 'Monthly',
					Status__c = 'Active',
					Start_Date__c = date.parse('07/03/2016'),
					Schedule_Date__c = 12
				);
			insert newRecurringGift;
			////////////////////////////////

			//CREATE A TEST FUND//
			Fund__c newFund = new Fund__c(
					Fund_Name__c = 'testFund'
				);
			insert newFund;
			//////////////////////

			//CREATE A TEST APPEAL//
			Campaign newAppeal = new Campaign(
					Name = 'Test Appeal',
					Type = 'Email',
					Fund__c = newFund.Id,
					RecordTypeId = (new RecordTypeSelector().SelectByNameNamespacePrefixAndName(Utilities.getCurrentNamespace(), 'Appeal')).Id,
					Status = 'In Progress',
					IsActive = true,
					StartDate = date.parse('01/01/2016'),
					EndDate = date.parse('01/01/2018')
				);
			insert newAppeal;
			////////////////////////

			//GENERATE i RECURRING GIFT ALLOCATIONS//
			for(Integer i = 0; i < 2; i++){
				RD_Allocation__c newRecurringAllocation = new RD_Allocation__c(
						Recurring_Gift__c = newRecurringGift.Id,
						Active__c = true,
						Amount__c = 20,
						New_Campaign__c = newAppeal.Id,
						Fund__c = newFund.Id
					);
				recurringAllocationList.add(newRecurringAllocation);
			}
			insert recurringAllocationList;
			/////////////////////////////////////////

			//GENERATE TRANSACTIONS//
				//GENERATE i 2016 TRANSACTIONS//
				Gift__c newGift;
				for(Integer i = 0; i < 2; i++){
					newGift = new Gift__c(
							Constituent__c = newContact.Id,
							Gift_date__c = date.parse('07/03/2016'),
							Gift_Type__c = 'Recurring',
							Recurring_Donation__c = newRecurringGift.Id
						);
					transactionList.add(newGift);
				}
				///////////////////////////

				//GENERATE i 2017 TRANSACTIONS//
				for(Integer i = 0; i < 2; i++){
					newGift = new Gift__c(
							Constituent__c = newContact.Id,
							Gift_date__c = date.parse('01/01/2017'),
							Gift_Type__c = 'Recurring',
							Recurring_Donation__c = newRecurringGift.Id
						);
					transactionList.add(newGift);
				}
				///////////////////////////
			insert transactionList;
			/////////////////////////

			//GENERATE PAYMENTS//
			Payment__c newPayment;
			newPayment = new Payment__c(
					Status__c = 'Approved',
					Date__c = date.parse('01/03/2017'),
					Amount__c = 20,
					Donation__c = transactionList[0].Id
				);
			paymentList.add(newPayment);

			newPayment = new Payment__c(
					Status__c = 'Approved',
					Date__c = date.parse('07/03/2016'),
					Amount__c = 20,
					Donation__c = transactionList[0].Id
				);
			paymentList.add(newPayment);

			newPayment = new Payment__c(
					Status__c = 'Approved',
					Date__c = date.parse('01/03/2017'),
					Amount__c = 20,
					Donation__c = transactionList[1].Id
				);
			paymentList.add(newPayment);

			newPayment = new Payment__c(
					Status__c = 'Approved',
					Date__c = date.parse('02/03/2017'),
					Amount__c = 20,
					Donation__c = transactionList[1].Id
				);
			paymentList.add(newPayment);
			insert paymentList;
			/////////////////////

			//GENERATE ALLOCATIONS//
			Gift_Detail__c newAllocation;
			newAllocation = new Gift_Detail__c(
					New_Campaign__c = recurringAllocationList[0].New_Campaign__c,
					Fund__c = recurringAllocationList[0].Fund__c,
					Amount__c = paymentList[0].Amount__c,
					Allocation_Date__c = paymentList[0].Date__c,
					Gift__c = transactionList[0].Id,
					Payment__c = paymentList[0].Id
				);
			allocationList.add(newAllocation);

			newAllocation = new Gift_Detail__c(
					New_Campaign__c = recurringAllocationList[1].New_Campaign__c,
					Fund__c = recurringAllocationList[0].Fund__c,
					Amount__c = paymentList[0].Amount__c,
					Allocation_Date__c = paymentList[0].Date__c,
					Gift__c = transactionList[0].Id,
					Payment__c = paymentList[0].Id
				);
			allocationList.add(newAllocation);

			newAllocation = new Gift_Detail__c(
					New_Campaign__c = recurringAllocationList[0].New_Campaign__c,
					Fund__c = recurringAllocationList[0].Fund__c,
					Amount__c = paymentList[1].Amount__c,
					Allocation_Date__c = paymentList[1].Date__c,
					Gift__c = transactionList[0].Id,
					Payment__c = paymentList[1].Id
				);
			allocationList.add(newAllocation);

			newAllocation = new Gift_Detail__c(
					New_Campaign__c = recurringAllocationList[0].New_Campaign__c,
					Fund__c = recurringAllocationList[0].Fund__c,
					Amount__c = paymentList[2].Amount__c,
					Allocation_Date__c = paymentList[2].Date__c,
					Gift__c = transactionList[1].Id,
					Payment__c = paymentList[2].Id
				);
			allocationList.add(newAllocation);

			newAllocation = new Gift_Detail__c(
					New_Campaign__c = recurringAllocationList[0].New_Campaign__c,
					Fund__c = recurringAllocationList[0].Fund__c,
					Amount__c = paymentList[3].Amount__c,
					Allocation_Date__c = paymentList[3].Date__c,
					Gift__c = transactionList[1].Id,
					Payment__c = paymentList[3].Id
				);
			allocationList.add(newAllocation);

			insert allocationList;
			////////////////////////
		//////////////

		//RUN THE JOB//
		Test.startTest();
		database.executeBatch(new YearEndPaymentMissMatchBatchable(),100);
		Test.stopTest();
		///////////////

		//TEST RESULT TESTING//
			//GET RESULTS//
			List<Payment__c> paymentResults = [SELECT Id, Donation__r.Gift_Date__c, Date__c FROM Payment__c];
			List<Gift_Detail__c> allocationResults = [SELECT Id, Gift__r.Gift_Date__c, Allocation_Date__c FROM Gift_Detail__c];
			///////////////

			//GET RESULTS//
			for(Payment__c p : paymentResults){
				if(p.Date__c >= date.parse('01/01/2017')){
					system.assertEquals(date.parse('01/01/2017'),p.Donation__r.Gift_Date__c,'Transaction did not switch properly on payment.');
				}else{
					system.assertNotEquals(date.parse('01/01/2017'),p.Donation__r.Gift_Date__c,'Transaction did not switch properly on payment.');
				}
			}

			for(Gift_Detail__c gd : allocationResults){
				if(gd.Allocation_Date__c >= date.parse('01/01/2017')){
					system.assertEquals(date.parse('01/01/2017'),gd.Gift__r.Gift_Date__c,'Transaction did not switch properly on allocation.');
				}else{
					system.assertNotEquals(date.parse('01/01/2017'),gd.Gift__r.Gift_Date__c,'Transaction did not switch properly on allocation.');
				}
			}
			///////////////
		///////////////////////
	}

	private static void ConfigureCauseview(){
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = getObjectId( 'RecordType' ,  'Appeal' ), Campaign_RecordType_Id__c = getObjectId( 'RecordType' ,  'Campaign' ),
            Event_RecordType_Id__c = getObjectId( 'RecordType' ,  'Event' ), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = getObjectId( 'RecordType' ,  'Individual Application' ), Enable_Recurring_Receipts__c = false);
        insert app;

        Map<string, decimal> conversionRates = new Map <string, decimal>();

        Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();

        Id rtypes = rtype_Map.get('Gift');
        Id rtypes1 = rtype_Map.get('Matching Gift');

        Account a = new Account(Name = 'sdsd', Organization_Id__c = 'ORG-11');
        insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', Data_Migration_Mode__c = false, BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes,Record_Type_Id_for_Rollups__c = rtypes, BucketAccountId__c = a.Id, CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');
        insert cs2;
    }

    private static String getObjectId(String ObjectName, String fieldValue)
    {
        String soql = 'SELECT ID FROM '+ObjectName+' WHERE Name = : fieldValue';

        if(ObjectName.equals('OrgWideEmailAddress'))
            soql = 'SELECT ID FROM OrgWideEmailAddress WHERE DisplayName = : fieldValue';

       if(ObjectName.equals('Document'))
            soql = 'SELECT ID FROM Document WHERE DeveloperName = : fieldValue';

        String ret = '';
           if(Database.query(soql).size() > 0)
           {
              ret = Database.query(soql)[0].Id;
           }

        return ret;
    }
}