global with sharing class PostInstall implements InstallHandler {
    global void onInstall(InstallContext context) {
        if (context.previousVersion() == null) {
            try {
                // setup custom settings
                CauseViewCustomSetting.defaultANumSettings();
                CauseViewCustomSetting.defaultBatchSettings();
                CauseViewCustomSetting.defaultAppSettings();
                CauseViewCustomSetting.defaultAppTemplateSettings();

                // add task picklist items
                UpdateTaskTypePicklist();

                // configure receipt templates
                ModifyRecipientTemplates MRT = new ModifyRecipientTemplates();
                MRT.modify();

                // job management
                Map < String, String > scheduleJobNamesMap = new Map < String, String > ();
                // job names
                String contactJobName = 'Contact Rollup';
                String accountJobName = 'Account Rollup';
                String appealRollUpJobName = 'Appeal Rollup';
                String campaignRollUpJobName = 'Campaign Rollup';
                String packageRollUpJobName = 'Package Rollup';
                String paymentRollUpJobName = 'Payment Rollup';
                String newYearTransaction2016batchJobName = 'Year End Job';
                String yearEndPaymentMismatchJobName = 'Year End Payment Mismatch';
                String dailyCauseviewMetricsJobName = 'Daily Causeview Metrics';

                scheduleJobNamesMap = CauseViewCustomSetting.cronJobMethod();
                Set < Id > DeleteJobIds = new Set < Id > ();

                if (scheduleJobNamesMap.containskey(contactJobName)) {
                    DeleteJobIds.add(scheduleJobNamesMap.get(contactJobName));
                }
                if (scheduleJobNamesMap.containskey(accountJobName)) {
                    DeleteJobIds.add(scheduleJobNamesMap.get(accountJobName));
                }
                if (scheduleJobNamesMap.containskey(dailyCauseviewMetricsJobName)) {
                    DeleteJobIds.add(scheduleJobNamesMap.get(dailyCauseviewMetricsJobName));
                }

                List<CronTrigger> CronTriggerList = new CronTriggerSelector().SelectWhereCronJobDetailIdInIds(DeleteJobIds);

                for (CronTrigger ct: CronTriggerList) {
                    System.abortJob(ct.id);
                }

                Map < String, String > scheduleJobNamesMap1 = new Map < String, String > ();
                scheduleJobNamesMap1 = CauseViewCustomSetting.cronJobMethod();

                if (!scheduleJobNamesMap1.containskey(contactJobName)) {
                    RollupBatchScheduler batch = new RollupBatchScheduler();
                    //If there is a default value for batch size defined in the Custom setting use that, otherwise use 60 as default.
                    String sch = '0 0 0 ? * *';
                    //string cronId = System.scheduleBatch(batch, contactJobName, 30, 100);
                    System.schedule('Contact Rollup', sch, batch);
                }
                if (!scheduleJobNamesMap1.containskey(accountJobName)) {
                    RollupBatchForOrganizationScheduler batch1 = new RollupBatchForOrganizationScheduler();
                    //string cronId = System.scheduleBatch(batch, accountJobName, 30, 100);
                    String sch1 = '0 0 3 ? * *';
                    System.schedule('Account Rollup', sch1, batch1);
                }
                if (!scheduleJobNamesMap1.containskey(packageRollUpJobName)) {
                    String sh1 = '0 0 20 * * ?';
                    PackageRollupScheduler packagerollup = new PackageRollupScheduler();
                    system.schedule('Package Rollup', sh1, packagerollup);
                }
                if (!scheduleJobNamesMap1.containskey(appealRollUpJobName)) {
                    String sh2 = '0 0 22 * * ?';
                    AppealUtilRollupScheduler appealutilrollup = new AppealUtilRollupScheduler();
                    system.schedule('Appeal Rollup', sh2, appealutilrollup);
                }
                if (!scheduleJobNamesMap1.containskey(campaignRollUpJobName)) {
                    String sh3 = '0 0 0 * * ?';
                    CampaignRollupScheduler campaignrollup = new CampaignRollupScheduler();
                    system.schedule('Campaign Rollup', sh3, campaignrollup);
                }
                if (!scheduleJobNamesMap1.containskey(paymentRollUpJobName)) {
                    String sh4 = '0 0 1 * * ?';
                    RDPaymentCountBatchScheduler paymentRollup = new RDPaymentCountBatchScheduler();
                    system.schedule('Payment Rollup', sh4, paymentRollup);
                }
                if (!scheduleJobNamesMap1.containskey(dailyCauseviewMetricsJobName)) {
                    String sh5 = '0 30 1 * * ?';
                    MetricsSchedule RDMetricsJob = new MetricsSchedule();
                    system.schedule(dailyCauseviewMetricsJobName, sh5, RDMetricsJob);
                    if (test.isRunningTest() == false) {
                        Database.executeBatch(new MetricsBatchable(), 1);
                    }
                }
                // Link all historical payment records to existing receipts.
                Database.executeBatch(new linkPaymentsToReceiptsBatch(), 50);

                DMLManager.InsertSObject(new CVAdmin__c(Name = 'Waive Settings'));

                List<Organization> localeList = new OrganizationSelector().SelectFiscalYearStartMonthAndDefaultLocaleSidKeyByLimit(1);
                Organization locale = (localeList != null && localeList.size() > 0) ? localeList[0] : null;
                If(locale.DefaultLocaleSidKey.containsIgnoreCase('en_GB') || locale.DefaultLocaleSidKey.containsIgnoreCase('cy_GB')) {
                    App_Settings__c s = App_Settings__c.getInstance(UserInfo.getOrganizationId());
                    s.Gift_Aid_Enable__c = true;
                    s.Fiscal_Start_Month__c = Decimal.ValueOf(locale.FiscalYearStartMonth);
                    DMLManager.UpdateSObject(s);
                }
            } catch (Exception ex) {
                Utilities.SendingEmail(new String[] { 'devteam@causeview.com' }, 'PostInstall Failed On' + context.organizationId(), ex.getMessage() + '\n' + ex.getStackTraceString());
            }
        } else {
            if (context.isUpgrade()) {
                Utilities.SendingEmail(new String[] { 'devteam@causeview.com' }, 'Upgrade On' + context.organizationId(), '');
            }
            if (context.isPush()) {
                Utilities.SendingEmail(new String[] { 'devteam@causeview.com' }, 'Push On' + context.organizationId(), '');
            }
        }
    }

    private void UpdateTaskTypePicklist() {
        if (!Test.isRunningTest()) {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            MetadataService.CustomField customField =
                (MetadataService.CustomField) service.readMetadata('CustomField', new String[] { 'Task.Type' }).getRecords()[0];

            metadataservice.PicklistValue firstNewOption = new metadataservice.PicklistValue();
            firstNewOption.fullName = 'Personal Letter';
            firstNewOption.default_x = false;
            metadataservice.PicklistValue secondNewOption = new metadataservice.PicklistValue();
            secondNewOption.fullName = 'Personal Email';
            secondNewOption.default_x = false;
            customField.picklist.picklistValues.add(firstNewOption);
            customField.picklist.picklistValues.add(secondNewOption);
            service.updateMetadata(new MetadataService.Metadata[] { customField });
        }
    }
}