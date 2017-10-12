public with sharing class CVHealthCheckController extends RedirectController {
    public boolean send_Gift_Receipt_status{get;set;}
    public boolean SendEventRegistrationReceipt_status{get;set;}
    public boolean UpdatePaymentRT_RefundACH_status{get;set;}
    public App_Settings__c appSetting{get;set;}
    public integer total_Custom_Setting{get; set;}
    public integer total_Workflow_Setting{get; set;}
    public integer pass_Custom_Setting{get; set;}
    public integer pass_Workflow_Setting{get; set;}
    public integer waive_Custom_Setting{get; set;}
    public integer waive_Workflow_Setting{get; set;}
    public CVAdmin__c waiveSetting {get; set;}
    public Organization org {get; set;}
    public string orgAddress {get; set;}
    public boolean org_Name_check {get; set;}
    public boolean org_Address_check {get; set;}
    public boolean org_Phone_check {get; set;}
    public integer total_Org_Setting {get; set;}
    public integer pass_Org_Setting {get; set;}
    public integer waive_org_Setting {get; set;}
    
    public boolean PackageRollupBatch_check {get; set;}
    public boolean AppealUtilRollBatch_check {get; set;}
    public boolean CampaignRollupBatch_check {get; set;}
    public boolean AccountRollupBatch_check {get;set;}
    public boolean ContactRollupBatch_check {get; set;}
    public boolean PaymentRollupBatch_check {get;set;}
   
    public string PackageRollupBatch_status {get; set;}
    public string AppealUtilRollBatch_status {get; set;}
    public string CampaignRollupBatch_status {get; set;}
    public string AccountRollupBatch_status {get;set;}
    public string ContactRollupBatch_status {get; set;}
    public string PaymentRollupBatch_status {get; set;}
    
    public string PackageRollupBatch_failure {get; set;}
    public string AppealUtilRollBatch_failure {get; set;}
    public string CampaignRollupBatch_failure {get; set;}
    public string AccountRollupBatch_failure {get;set;}
    public string ContactRollupBatch_failure {get; set;}
    public string PaymentRollupBatch_failure {get; set;}
    
    public string PackageRollupBatch_completeDate {get; set;}
    public string AppealUtilRollBatch_completeDate {get; set;}
    public string CampaignRollupBatch_completeDate {get; set;} 
    public string AccountRollupBatch_completeDate {get;set;}
    public string ContactRollupBatch_completeDate {get; set;}
    public string PaymentRollupBatch_completeDate {get; set;}
    
    
    public string PackageRollupBatch_NextRunDate {get; set;}
    public string AppealUtilRollBatch_NextRunDate {get; set;}
    public string CampaignRollupBatch_NextRunDate {get; set;} 
    public string AccountRollupBatch_NextRunDate {get;set;}
    public string ContactRollupBatch_NextRunDate {get; set;}
    public string PaymentRollupBatch_NextRunDate {get; set;}
    
    
    public integer total_jobs {get; set;}
    public integer pass_jobs {get; set;}
    public integer waive_jobs {get; set;}
    public string job_name1{get; set;}
    public string job_name2{get; set;}
    public string job_name3{get; set;}
    public string job_name4{get; set;}
    public string job_name5{get; set;}
    public string job_name6{get; set;}
    
    public List<OrgWideEmailAddress> org_Email {get; set;}
    public boolean org_wide_Address {get; set;}
    public CVHealthCheckController(){
        super(true);

        appSetting = new App_Settings__c();
        waiveSetting = new CVAdmin__c();
        org = new Organization();
        org_Email = new List<OrgWideEmailAddress>();
        List<CVAdmin__c> cvAdminList = new CVAdminSelector().SelectSObjectsByNameLimit('Waive Settings', 1);
        if (cvAdminList != null && cvAdminList.size() > 0) {
            waiveSetting = cvAdminList[0];
        }
                        
        companyInformation();
        customSettingStatus();
        if(!Test.isRunningTest()) { 
            workflowStatus();
        }
        scheduledJobStatus();
        companyInformationWaive();
        customSettingWaive();
        workflowSettingWaive();
        scheduleJobresult();
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }  
    
    public void companyInformation(){
        List<Organization> orgList = new OrganizationSelector().SelectSObjects();
        if (orgList != null && orgList.size() > 0) {
            org = orgList[0];
            org_Email = new OrgWideEmailAddressSelector().SelectSObjects();
            org_Name_check = true;
            if(org.Street == null && org.City == null && org.State == null && org.PostalCode == null && org.Country == null){
                org_Address_check = false;
            }else {
                org_Address_check = true;
            }
            if(org.Phone == null){
                org_Phone_check = false;
            }else
            {
                org_Phone_check = true;
            }
            if(org_Email.size() > 0){
                org_wide_Address = true;
            }else
            {
                org_wide_Address = false;
            }
        }
    }
    
    public void customSettingStatus(){
        List<App_Settings__c> appSettingList = new AppSettingSelector().SelectSObjects();
        if (appSettingList != null && appSettingList.size() > 0) {
            appSetting = appSettingList[0];
        }
    }
    
    public void workflowStatus(){
        MetadataService.MetadataPort service = createService();
        MetadataService.Workflow wfa2 = (MetadataService.Workflow) service.readMetadata('Workflow', new String[] { 'CVA__Receipt__c' }).getRecords()[0];  
        MetadataService.Workflow wfa2_payment = (MetadataService.Workflow) service.readMetadata('Workflow',  new String[] { 'CVA__Payment__c' }).getRecords()[0];
        for(MetadataService.WorkflowRule w : wfa2.rules){
            if(w.fullName == 'SendGiftReceipt'){
                send_Gift_Receipt_status = w.active;
            }else
            if(w.fullName == 'SendEventRegistrationReceipt'){
                SendEventRegistrationReceipt_status = w.active;
            }
        }
        
        for(MetadataService.WorkflowRule w : wfa2_payment.rules) {
        if(w.fullName == 'UpdatePaymentRT_RefundACH'){
                UpdatePaymentRT_RefundACH_status = w.active;
            } 
        }
    }
    
    public void scheduledJobStatus(){
        boolean AppealRollupbatch1 = true;
        boolean AppealRollupbatch2 = true;
        boolean AppealRollupbatch3 = true;
        boolean AppealRollupbatch4 = true;
        boolean AppealRollupbatch5 = true;
        boolean AppealRollupBatch6 = true;
        boolean PackageRollupbatch1 = true;
        boolean AppealUtiRollupbatch2 = true;
        boolean CampaignRollupbatch3 = true; 
        boolean AccountRollupbatch4 = true;
        boolean ContactRollupbatch5 = true;
        boolean PaymentRollupbatch6 = true;
        
        job_name1 = '-';
        job_name2 = '-';
        job_name3 = '-';
        job_name4 = '-';
        job_name5 = '-';
        job_name6 = '-';
        
         PackageRollupBatch_status = '-';
         AppealUtilRollBatch_status = '-';
         CampaignRollupBatch_status = '-';
         AccountRollupBatch_status = '-';
         ContactRollupBatch_status = '-';
         PaymentRollupBatch_status = '-';
    
         PackageRollupBatch_failure = '-';
         AppealUtilRollBatch_failure = '-'; 
         CampaignRollupBatch_failure = '-';
         AccountRollupBatch_failure = '-';
         ContactRollupBatch_failure  = '-';
         PaymentRollupBatch_failure = '-';
    
         PackageRollupBatch_completeDate = '-';
         AppealUtilRollBatch_completeDate = '-';
         CampaignRollupBatch_completeDate = '-';
         AccountRollupBatch_completeDate = '-';
         ContactRollupBatch_completeDate = '-';   
         PaymentRollupBatch_completeDate = '-';
         
         
        PackageRollupBatch_NextRunDate = '-';
        AppealUtilRollBatch_NextRunDate = '-';
        CampaignRollupBatch_NextRunDate = '-';
        AccountRollupBatch_NextRunDate = '-';
        ContactRollupBatch_NextRunDate = '-';
        PaymentRollupBatch_NextRunDate = '-'; 
        
        
        Map<string, CronTrigger> schedulejobs_Map = new Map<string, CronTrigger>();
        List<String> apexClassNames = new List<String> {
            'AppealRollupBatch', 'AppealRollupBatch2', 'AppealRollupBatch3', 'AppealRollupScheduler', 'AppealRollupScheduler2', 'AppealRollupScheduler3',
            'PackageRollupBatch', 'AppealUtilRollBatch', 'CampaignRollupBatch', 'RollupBatch', 'RollupBatchForOrganization', 'RDPaymentCountBatch',
            'PackageRollupScheduler', 'AppealUtilRollupScheduler', 'CampaignRollupScheduler', 'RollupBatchScheduler', 'RollupBatchForOrganizationScheduler',
            'RDPaymentCountBatchScheduler'
        };
        List<AsyncApexJob> batchJob = new AsyncApexJobSelector().SelectByApexClassName(apexClassNames);
        for(CronTrigger cron : new CronTriggerSelector().SelectExtendedCronTriggers()){
            schedulejobs_Map.put(cron.CronJobDetail.Name, cron);
        }
        for(AsyncApexJob asyncJob : batchJob){
            if(PackageRollupbatch1 ){
                 if(asyncJob.ApexClass.Name == 'PackageRollupBatch'){
                    if(schedulejobs_Map.get('Package Rollup') != null && schedulejobs_Map.get('Package Rollup').NextFireTime != null && schedulejobs_Map.get('Package Rollup').PreviousFireTime != null){
                        CronTrigger cron = schedulejobs_Map.get('Package Rollup');
                        Long dt1Long = cron.NextFireTime.getTime();
                        Long dt2Long = cron.PreviousFireTime.getTime();
                        Long milliseconds = dt1Long - dt2Long;
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        Long hours = minutes / 60;
                        integer hour = (integer)hours + 1;
                        DateTime check = DateTime.valueOfGmt(System.now().format('yyyy-MM-dd HH:mm:ss')).addHours(-hour);
                        job_name1 = asyncJob.ApexClass.Name;
                        
                        PackageRollupBatch_status = asyncJob.Status;
                        PackageRollupBatch_failure = String.valueof(asyncJob.NumberOfErrors);
                        PackageRollupBatch_completeDate = String.valueof(asyncJob.CompletedDate);
                        PackageRollupBatch_NextRunDate = String.valueof(cron.NextFireTime);
                        PackageRollupbatch1 = false; 
                        
                        if(asyncJob.NumberOfErrors == 0 && asyncJob.Status == 'Completed' && asyncJob.CompletedDate > check){
                            PackageRollupBatch_check = true;
                        }else
                        {
                            PackageRollupBatch_check = false;
                        }
                    }else
                    {
                        PackageRollupBatch_check = false;
                    }
                }else
                {
                    PackageRollupBatch_check = false;
                }
            }
            
            if(AppealUtiRollupbatch2){
                if(asyncJob.ApexClass.Name == 'AppealUtilRollBatch'){
                    if(schedulejobs_Map.get('Appeal Rollup') != null && schedulejobs_Map.get('Appeal Rollup').NextFireTime != null && schedulejobs_Map.get('Appeal Rollup').PreviousFireTime != null){
                        CronTrigger cron = schedulejobs_Map.get('Appeal Rollup');
                        Long dt1Long = cron.NextFireTime.getTime();
                        Long dt2Long = cron.PreviousFireTime.getTime();
                        Long milliseconds = dt1Long - dt2Long;
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        Long hours = minutes / 60;
                        integer hour = (integer)hours + 1;
                        DateTime check = DateTime.valueOfGmt(System.now().format('yyyy-MM-dd HH:mm:ss')).addHours(-hour);
                        job_name2 = asyncJob.ApexClass.Name;
                        AppealUtilRollBatch_status = asyncJob.Status;
                        AppealUtilRollBatch_failure = String.valueof(asyncJob.NumberOfErrors);
                        AppealUtilRollBatch_completeDate = String.valueof(asyncJob.CompletedDate);
                        AppealUtilRollBatch_NextRunDate = String.valueof(cron.NextFireTime);
                        AppealUtiRollupbatch2 = false;
                        if(asyncJob.NumberOfErrors == 0 && asyncJob.Status == 'Completed' && asyncJob.CompletedDate > check){
                            AppealUtilRollBatch_check = true;
                        }else
                        {
                            AppealUtilRollBatch_check = false;
                        }
                    }else
                    {
                        AppealUtilRollBatch_check = false;
                    }
                }else
                {
                    AppealUtilRollBatch_check = false;
                }
            }
            if(CampaignRollupbatch3){
                if(asyncJob.ApexClass.Name == 'CampaignRollupBatch'){
                    if(schedulejobs_Map.get('Campaign Rollup') != null && schedulejobs_Map.get('Campaign Rollup').NextFireTime != null && schedulejobs_Map.get('Campaign Rollup').PreviousFireTime != null){
                        CronTrigger cron = schedulejobs_Map.get('Campaign Rollup');
                        Long dt1Long = cron.NextFireTime.getTime();
                        Long dt2Long = cron.PreviousFireTime.getTime();
                        Long milliseconds = (dt1Long - dt2Long);
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        Long hours = minutes / 60;
                        integer hour = (integer)hours + 1;
                        DateTime check = DateTime.valueOfGmt(System.now().format('yyyy-MM-dd HH:mm:ss')).addHours(-hour);
                        job_name3 = asyncJob.ApexClass.Name;
                        CampaignRollupBatch_status = asyncJob.Status;
                        CampaignRollupBatch_failure = String.valueof(asyncJob.NumberOfErrors);
                        CampaignRollupBatch_completeDate = String.valueof(asyncJob.CompletedDate);
                        CampaignRollupBatch_NextRunDate =String.valueof(cron.NextFireTime);
                        CampaignRollupbatch3 = false;
                        if(asyncJob.NumberOfErrors == 0 && asyncJob.Status == 'Completed' && asyncJob.CompletedDate > check){
                            CampaignRollupBatch_check = true;
                        }else
                        {
                            CampaignRollupBatch_check = false;
                        }
                    }else
                    {
                        CampaignRollupBatch_check = false;
                    }
                }else
                {
                    CampaignRollupBatch_check = false;
                }
            }
            
            if(ContactRollupbatch5){
                if(asyncJob.ApexClass.Name == 'RollupBatch'){
                    if(schedulejobs_Map.get('Contact Rollup') != null && schedulejobs_Map.get('Contact Rollup').NextFireTime != null && schedulejobs_Map.get('Contact Rollup').PreviousFireTime != null){
                        CronTrigger cron = schedulejobs_Map.get('Contact Rollup');
                        Long dt1Long = cron.NextFireTime.getTime();
                        Long dt2Long = cron.PreviousFireTime.getTime();
                        Long milliseconds = (dt1Long - dt2Long);
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        Long hours = minutes / 60;
                        integer hour = (integer)hours + 1;
                        DateTime check = DateTime.valueOfGmt(System.now().format('yyyy-MM-dd HH:mm:ss')).addHours(-hour);
                        job_name4 = asyncJob.ApexClass.Name;
                        ContactRollupBatch_status = asyncJob.Status;
                        ContactRollupBatch_failure = String.valueof(asyncJob.NumberOfErrors);
                        ContactRollupBatch_completeDate = String.valueof(asyncJob.CompletedDate);
                        ContactRollupBatch_NextRunDate = String.valueof(cron.NextFireTime);
                        ContactRollupbatch5 = false;
                        if(asyncJob.NumberOfErrors == 0 && asyncJob.Status == 'Completed' && asyncJob.CompletedDate > check){
                            ContactRollupBatch_check = true;
                        }else
                        {
                            ContactRollupBatch_check = false;
                        }
                    }else
                    {
                        ContactRollupBatch_check = false;
                    }
                }else
                {
                    ContactRollupBatch_check = false;
                }
            }
            
            
            if(AccountRollupbatch4){
                if(asyncJob.ApexClass.Name == 'RollupBatchForOrganization'){
                    if(schedulejobs_Map.get('Account Rollup') != null && schedulejobs_Map.get('Account Rollup').NextFireTime != null && schedulejobs_Map.get('Account Rollup').PreviousFireTime != null){
                        CronTrigger cron = schedulejobs_Map.get('Account Rollup');
                        Long dt1Long = cron.NextFireTime.getTime();
                        Long dt2Long = cron.PreviousFireTime.getTime();
                        Long milliseconds = (dt1Long - dt2Long);
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        Long hours = minutes / 60;
                        integer hour = (integer)hours + 1;
                        DateTime check = DateTime.valueOfGmt(System.now().format('yyyy-MM-dd HH:mm:ss')).addHours(-hour);
                        job_name5 = asyncJob.ApexClass.Name;
                        AccountRollupBatch_status = asyncJob.Status;
                        AccountRollupBatch_failure = String.valueof(asyncJob.NumberOfErrors);
                        AccountRollupBatch_completeDate = String.valueof(asyncJob.CompletedDate);
                        AccountRollupBatch_NextRunDate = String.valueof(cron.NextFireTime);
                        AccountRollupbatch4 = false;
                        if(asyncJob.NumberOfErrors == 0 && asyncJob.Status == 'Completed' && asyncJob.CompletedDate > check){
                            AccountRollupBatch_check = true;
                        }else
                        {
                            AccountRollupBatch_check = false;
                        }
                    }else
                    {
                        AccountRollupBatch_check = false;
                    }
                }else
                {
                    AccountRollupBatch_check = false;
                }
            }
            
            
            if(PaymentRollupbatch6){
                if(asyncJob.ApexClass.Name == 'RDPaymentCountBatch'){
                    if(schedulejobs_Map.get('Payment Rollup') != null && schedulejobs_Map.get('Payment Rollup').NextFireTime != null && schedulejobs_Map.get('Payment Rollup').PreviousFireTime != null){
                        CronTrigger cron = schedulejobs_Map.get('Payment Rollup');
                        Long dt1Long = cron.NextFireTime.getTime();
                        Long dt2Long = cron.PreviousFireTime.getTime();
                        Long milliseconds = (dt1Long - dt2Long);
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        Long hours = minutes / 60;
                        integer hour = (integer)hours + 1;
                        DateTime check = DateTime.valueOfGmt(System.now().format('yyyy-MM-dd HH:mm:ss')).addHours(-hour);
                        job_name6 = asyncJob.ApexClass.Name;
                        PaymentRollupBatch_status = asyncJob.Status;
                        PaymentRollupBatch_failure = String.valueof(asyncJob.NumberOfErrors);
                        PaymentRollupBatch_completeDate = String.valueof(asyncJob.CompletedDate);
                        PaymentRollupBatch_NextRunDate = String.valueof(cron.NextFireTime);
                        PaymentRollupbatch6 = false;
                        if(asyncJob.NumberOfErrors == 0 && asyncJob.Status == 'Completed' && asyncJob.CompletedDate > check){
                            PaymentRollupBatch_check = true;
                        }else
                        {
                            PaymentRollupBatch_check = false;
                        }
                    }else
                    {
                        PaymentRollupBatch_check = false;
                    }
                }else
                {
                    PaymentRollupBatch_check = false;
                }
            }
 
           
        }
           
    }
    
    public void companyInformationWaive(){
        total_Org_Setting = 4;
        pass_Org_Setting = 0;
        waive_org_Setting = 0;
        if(org_Name_check == true){
            pass_Org_Setting += 1;
        }
        if(org_Address_check == true){
            pass_Org_Setting += 1;
        }
        if(org_Phone_check == true){
            pass_Org_Setting += 1;
        }
        if(org_wide_Address == true){
            pass_Org_Setting += 1;
        }
        if(waiveSetting.Organisation_Name__c == true){
            waive_org_Setting += 1;
        }
        if(waiveSetting.Organization_Address__c == true){
            waive_org_Setting += 1;
        }
        if(waiveSetting.Organization_Phone__c == true){
            waive_org_Setting += 1;
        }
        if(waiveSetting.Org_Wide_Email_Address__c == true){
            waive_org_Setting += 1;
        }
        if(waiveSetting.Organisation_Name__c == true && org_Name_check == true){
            pass_Org_Setting -= 1;
        }
        if(waiveSetting.Organization_Address__c == true && org_Address_check == true){
            pass_Org_Setting -= 1;
        }
        if(waiveSetting.Organization_Phone__c == true && org_Phone_check == true){
            pass_Org_Setting -= 1;
        }
        if(waiveSetting.Org_Wide_Email_Address__c == true && org_wide_Address == true){
            pass_Org_Setting -= 1;
        }
        total_Org_Setting = total_Org_Setting - waive_org_Setting;
    }
    
    public void customSettingWaive(){
        total_Custom_Setting = 4;
        pass_Custom_Setting = 0;
        waive_Custom_Setting = 0;
        if(appSetting.Enable_Enhanced_Batch_Interface__c == true){
            pass_Custom_Setting += 1;
        }
        if(appSetting.Enable_Enhanced_Fund_Accounting__c == true){
            pass_Custom_Setting += 1;
        }
        if(appSetting.Enable_Pledge_Installment_Model__c == true){
            pass_Custom_Setting += 1;
        }
        if(appSetting.Use_Workflows_for_Sending_Receipts__c == true){
            pass_Custom_Setting += 1;
        }
        if(waiveSetting.Enable_Enhanced_Batch_Interface_Waive__c == true){
            waive_Custom_Setting += 1;
        }
        if(waiveSetting.Enable_Enhanced_Fund_Accounting_Waive__c == true){
            waive_Custom_Setting += 1;
        }
        if(waiveSetting.Enable_Pledge_Installment_Model_Waive__c == true){
            waive_Custom_Setting += 1;
        }
        if(waiveSetting.Disable_Workflows_for_Sending_Receipts__c == true){
            waive_Custom_Setting += 1;
        }
        if(waiveSetting.Enable_Enhanced_Batch_Interface_Waive__c == true && appSetting.Enable_Enhanced_Batch_Interface__c == true){
            pass_Custom_Setting -= 1;
        }
        if(waiveSetting.Enable_Enhanced_Fund_Accounting_Waive__c == true && appSetting.Enable_Enhanced_Fund_Accounting__c == true){
            pass_Custom_Setting -= 1;
        }
        if(waiveSetting.Enable_Pledge_Installment_Model_Waive__c == true && appSetting.Enable_Pledge_Installment_Model__c == true){
            pass_Custom_Setting -= 1;
        }
        if(waiveSetting.Disable_Workflows_for_Sending_Receipts__c == true && appSetting.Use_Workflows_for_Sending_Receipts__c == true){
            pass_Custom_Setting -= 1;
        }
        total_Custom_Setting = total_Custom_Setting - waive_Custom_Setting;
    }
    
    public void workflowSettingWaive(){
        total_Workflow_Setting = 3;
        pass_Workflow_Setting = 0;
        waive_Workflow_Setting = 0;  
        
        if(send_Gift_Receipt_status == true){
            pass_Workflow_Setting += 1;
        } 
        if(SendEventRegistrationReceipt_status == true){
            pass_Workflow_Setting += 1;
        } 
        if(UpdatePaymentRT_RefundACH_status == true){
             pass_Workflow_Setting += 1;
        }
        if(waiveSetting.Send_Gift_Receipt__c == true){
            waive_Workflow_Setting += 1;
        }
        if(waiveSetting.Send_Event_Registration_Receipt__c == true){
            waive_Workflow_Setting += 1;
        }
        if(waiveSetting.UpdatePaymentRT_RefundACH__c == true){
          waive_Workflow_Setting += 1;
        }
        if(waiveSetting.Send_Gift_Receipt__c == true && send_Gift_Receipt_status == true){
            pass_Workflow_Setting -= 1;
        }
        if(waiveSetting.Send_Event_Registration_Receipt__c == true && SendEventRegistrationReceipt_status == true){
            pass_Workflow_Setting -= 1;
        } 
        if(waiveSetting.UpdatePaymentRT_RefundACH__c == true && UpdatePaymentRT_RefundACH_status == true){
            pass_Workflow_Setting -= 1;
        }
             
        total_Workflow_Setting = total_Workflow_Setting - waive_Workflow_Setting;
    }
    
    public void scheduleJobresult(){
        total_jobs = 6;
        pass_jobs = 0;
        waive_jobs = 0;
        if(PackageRollupBatch_check == true){
            pass_jobs += 1;
        } 
        if(AppealUtilRollBatch_check == true){
            pass_jobs += 1;
        } 
        if(CampaignRollupBatch_check == true){
            pass_jobs += 1;
        }
         //for account & contact
         if(AccountRollupBatch_check == true){
            pass_jobs += 1;
        }
        if(ContactRollupBatch_check == true){
            pass_jobs += 1;
        }
        
        if(PaymentRollupBatch_check == true){
            pass_jobs += 1;
        }
        
        
         
        if(waiveSetting.PackageRollupBatch__c == true){
            waive_jobs += 1;
        }
        if(waiveSetting.AppealUtilRollBatch__c == true){
            waive_jobs += 1;
        }
        if(waiveSetting.CampaignRollupBatch__c == true){
            waive_jobs += 1;
        }
        
        if(waiveSetting.Account_Rollup_Batch__c == true){
            waive_jobs += 1;
        }
        
        if(waiveSetting.Contact_RollUp_Batch__c == true){
            waive_jobs += 1;
        }
        
        if(waiveSetting.Payment_Rollup_Batch__c == true)
        {
            waive_jobs += 1;
        }
        
        if(waiveSetting.PackageRollupBatch__c == true && PackageRollupBatch_check == true){
            pass_jobs -= 1;
        }
        if(waiveSetting.AppealUtilRollBatch__c == true && AppealUtilRollBatch_check == true){
            pass_jobs -= 1;
        } 
        if(waiveSetting.CampaignRollupBatch__c == true && CampaignRollupBatch_check == true){
            pass_jobs -= 1;
        } 
        
        if(waiveSetting.Account_Rollup_Batch__c == true && AccountRollupBatch_check == true){
            pass_jobs -= 1;
        }
        if(waiveSetting.Contact_RollUp_Batch__c == true && ContactRollupBatch_check == true){
            pass_jobs -= 1;
        }
        
        if(waiveSetting.Payment_Rollup_Batch__c == true && PaymentRollupBatch_check == true){
            pass_jobs -= 1;
        }
             
        total_jobs = total_jobs - waive_jobs;
    }
    
    public void updateOrgSetting(){
        DMLManager.UpdateSObject(waiveSetting);
        companyInformationWaive();
    }
    
    public void updateWaiveSetting(){
        DMLManager.UpdateSObject(waiveSetting);
        customSettingWaive();
    }
    
    public void updateWorkflowWaiveSetting(){
        DMLManager.UpdateSObject(waiveSetting);
        workflowSettingWaive();
    }
    
    public void updateRollupWaiveSetting(){
        DMLManager.UpdateSObject(waiveSetting);
        scheduleJobresult();
    }
    
     public static MetadataService.MetadataPort createService()
     { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
     }
     
     public void executeFullRollup()
     {
         Database.executeBatch(new RollupBatch('Full'),200);
     }
     
     public Boolean isSandbox {get{ return Utilities.runningInASandbox();}}
     public void configureSandbox()
     {
         Utilities.configureSandbox();
     }
}