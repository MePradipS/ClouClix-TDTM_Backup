@isTest
private class OpportunityConvertTest {
    public static testMethod void testOppControllerExtension() {
        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();    
        Account a = new Account(Name = 'aaa');
        insert a;
        Opportunity theOpp = new Opportunity();
        theOpp.Amount = 270000;
        theOpp.Name = 'Test Opp';
        theOpp.StageName = 'StageName';
        theOpp.CloseDate = Date.TODAY();
        theOpp.AccountId = a.Id;
        insert theOpp;
        String oppID = theOpp.id;        
        PageReference pageRef = Page.ConvertOpp2;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', oppID);
        ApexPages.StandardController std = new ApexPages.StandardController(theOpp);
        OppControllerExtension2 controller = new OppControllerExtension2(std);
        controller.theWrappers[0].thePayment.Amount__c = 250;
        controller.theWrappers[0].thePayment.Status__c = 'Approved';
        controller.theWrappers[0].isRemind = false;
        controller.theWrappers[0].theGiftDetails[0].Amount__c = 250;        
        controller.submit();        
        
        
        
        controller.addPayment();  
        ApexPages.currentPage().getParameters().put('gdIndex', '1');           
        controller.addAllocation();        
        ApexPages.currentPage().getParameters().put('wrapperIndex', '0');         
        controller.removeAllocation();
        controller.removePayment();     
        ApexPages.currentPage().getParameters().put('Index3', '0');        
        controller.addTask();
        controller.removeTask();

        //controller.theWrappers.add(new OppControllerExtension2.PaymentWrapper(new Payment__c(Amount__c = 25)));
        /*controller.aPayment.Amount__c = 260000;
        controller.aPayment.Description__c = '270000';        
        controller.addPayment();
        controller.toTasks();
        controller.selectedPaymentIndex = 0;
        controller.deletePayment();
        controller.aPayment.Amount__c = 260000;
        controller.aPayment.Description__c = '270000';                
        controller.addPayment();
        controller.selectedPaymentIndex = 1;        
        controller.editPayment();
        controller.aPayment.Amount__c = 270000;
        controller.addPayment();
        controller.toTasks();
        controller.aTask.Subject = 'Subject';
        controller.aTask.Description = 'desc';        
        controller.aTask.ActivityDate = Date.Today();
        controller.addTask();
        controller.selectedTaskIndex = 0;
        controller.deleteTask();
        controller.aTask.Subject = 'Subject';
        controller.aTask.Description = 'desc';        
        controller.aTask.ActivityDate = Date.Today();
        controller.addTask();     
        controller.selectedTaskIndex = 1;        
        controller.editTask();
        controller.addTask();
        controller.toPayments();
        controller.toTasks();
        controller.toSummary();
        controller.convertToTrans(); */       
    }
}