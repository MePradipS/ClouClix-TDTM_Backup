@isTest
private class CVHealthCheckControllerTest{
    @istest static void CVHealthCheckControllerTest(){
        CVAdmin__c cvAdmin = new CVAdmin__c(
            Name = 'Waive Settings', 
            Disable_Workflows_for_Sending_Receipts__c = true, 
            Enable_Enhanced_Batch_Interface_Waive__c = true,
            Enable_Enhanced_Fund_Accounting_Waive__c = true, 
            Enable_Pledge_Installment_Model_Waive__c = true, 
            Send_Event_Registration_Receipt__c = true,
            Send_Gift_Receipt__c = true);
        DMLManager.InsertSObject(cvAdmin);

        App_Settings__c app_setting = GLAllocationfieldUpdateTriggerTest.appSettings();
        app_setting.Enable_Enhanced_Batch_Interface__c = true;
        app_setting.Enable_Enhanced_Fund_Accounting__c = true;
        app_setting.Enable_Pledge_Installment_Model__c = true;
        app_setting.Use_Workflows_for_Sending_Receipts__c = true;
        
        DMLManager.UpdateSObject(app_setting);

        PageReference pageRef = Page.CVHealthCheck;
        Test.startTest();
            Test.setCurrentPage(pageRef);
            CVHealthCheckController cvhealth = new CVHealthCheckController();
            cvhealth.send_Gift_Receipt_status = true;
            cvhealth.SendEventRegistrationReceipt_status = true;
            cvhealth.updateWaiveSetting();
            //Test.startTest();
            //Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            cvhealth.updateWorkflowWaiveSetting();
            //cvhealth.workflowStatus();
        Test.stopTest();
    }
}