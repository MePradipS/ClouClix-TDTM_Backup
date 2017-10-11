global with sharing class CauseViewCustomSetting
{
  global static void defaultANumSettings()
  {
     if(aNums__c.getInstance('Default') == null)
       {
        aNums__c  aNum = new aNums__c();
        aNum.Name = 'Default';

            try
            {
                DMLManager.InsertSObject(aNum);
            }
            catch(System.DMLException e)
            {
            }
      }
      aNums__c s = aNums__c.getInstance('Default');
      List<Application_Setting__c> autonumberRecord = new List<Application_Setting__c>();
      autonumberRecord = new ApplicationSettingSelector().SelectSObjectsByNameLimit('Auto Number Setting', 1);
      if(s != null){
          if(s.OrgCount__c != 0){
              if(autonumberRecord.size() > 0){
                  for(Application_Setting__c appSetting : autonumberRecord){
                      if(appSetting.Org_Count__c == 0){
                          appSetting.Org_Count__c = s.OrgCount__c;
                      }
                  }
              }else
              {
                  Application_Setting__c app = new Application_Setting__c();
                  app.Name = 'Auto Number Setting';
                  app.Org_Count__c = s.OrgCount__c;
                  try
                  {
                      DMLManager.InsertSObject(app);
                  }
                  catch(System.DMLException e)
                  {
                  }
              }
          }else
          {
              if(!(autonumberRecord.size() > 0)){
                  Application_Setting__c app = new Application_Setting__c();
                  app.Name = 'Auto Number Setting';
                  app.Org_Count__c = s.OrgCount__c;
                  try
                  {
                      DMLManager.InsertSObject(app);
                  }
                  catch(System.DMLException e)
                  {
                  }
              }
          }
      }
  }

 global static void defaultBatchSettings()
  {
     if((BatchSettings__c.getInstance('Default') == null))
       {
        BatchSettings__c batchSettings = new BatchSettings__c ();
        batchSettings.Name = 'Default';
        batchSettings.CurrencyCode__c = UserInfo.getDefaultCurrency();
        batchSettings.BatchFormID__c = 'TBD';
        batchSettings.BatchReportId__c = getObjectId( 'Report' ,  'Gift Batch Summary Report' );
        batchSettings.BucketAccountId__c = createObject('Account', null , 'Individual');
        batchSettings.RegularGiftRecordTypeId__c = getObjectId( 'RecordType' ,  'Gift' );
        batchSettings.Record_Type_Id_for_Rollups__c = getObjectId( 'RecordType' ,  'Matching Gift' );
            try
            {
                DMLManager.InsertSObject(batchSettings);
            }
            catch(System.DMLException e)
            {
            }
        }
   }

    global static void defaultAppSettings()
     {
      App_Settings__c appSetting  = App_Settings__c.getInstance(UserInfo.getOrganizationId());

      if((appSetting.Name == null))
       {
        appSetting.Appeal_Donate_Now_Form_Id__c = 'TBD';
        appSetting.Appeal_RecordType_Id__c = getObjectId( 'RecordType' ,  'Appeal' );
        appSetting.Campaign_RecordType_Id__c = getObjectId( 'RecordType' ,  'Campaign' );
        appSetting.CV_Account_Id__c = 'TBD';
        appSetting.Default_Actionpages_Campaign__c = createObject('Campaign','Appeal', 'CV Forms');
        appSetting.Event_RecordType_Id__c =  getObjectId( 'RecordType' ,  'Event' );
        appSetting.Individual_App_RecordtypeId__c = getObjectId( 'RecordType' ,  'Individual Application' );
        appSetting.Event_Registration_Form_Id__c = 'TBD';
        appSetting.Free_Event_Registration_Form_Id__c = 'TBD';
        appSetting.Use_Workflows_for_Sending_Receipts__c = false;
        appSetting.Other_Address_Trigger_Setting__c = true;
            try
            {
                DMLManager.InsertSObject(appSetting);
            }
            catch(System.DMLException e)
            {
            }
        }
   }

   global static void defaultAppTemplateSettings()
    {

        if(givingpowerSettings__c.getInstance('Settings') == null)
        {
            givingpowerSettings__c givingpowerSettings= new givingpowerSettings__c();
            givingpowerSettings.Name = 'Settings';
            givingpowerSettings.DupeEmailTemplateId__c = getObjectId( 'EmailTemplate' ,  'Receipt Template (Dupe)' );
            givingpowerSettings.EmailTemplateId__c = getObjectId( 'EmailTemplate' ,  'Receipt Template');
            givingpowerSettings.X15_DAYS_CC_Expiry_Email_Template__c = getObjectId( 'EmailTemplate' ,  'Credit Card Expiry - 15 DAY Notification');
            givingpowerSettings.X30_DAYS_CC_Expiry_Email_Template__c = getObjectId( 'EmailTemplate' ,  'Credit Card Expiry - 30 DAY Notification');
            givingpowerSettings.consolidatedReceiptEmailTemplateId__c = getObjectId( 'EmailTemplate' ,  'Consolidated Receipt Email Template');
            givingpowerSettings.DupeConsolidatedReceiptEmailTempId__c = getObjectId( 'EmailTemplate' , 'Consolidated Receipt Email Template (Dupe)');

            givingpowerSettings.Org_Wide_Email_ID__c = getObjectId( 'OrgWideEmailAddress' ,  'HN Foundation');

            givingpowerSettings.ReceiptEmailDocId__c = getObjectId( 'Document' ,  'en_htm');
            givingpowerSettings.DupeDocumentTemplateId__c = getObjectId( 'Document' ,  'HTML_Template_for_Reciept_Email_Content_Dupe');
            givingpowerSettings.ReceiptPDFDocId__c = getObjectId( 'Document' ,  'HTMLPage2_htm');
            givingpowerSettings.DupeAttachTemplateId__c = getObjectId( 'Document' ,  'HTML_Template_for_Reciept_PDF_Dupe');
            givingpowerSettings.consolidatedReceiptPDFDocId__c = getObjectId( 'Document' ,  'HTML_Template_for_Consolidated_Receipt_PDF_Attachment');
            givingpowerSettings.DupeConsolidatedReceiptPDFDocId__c = getObjectId( 'Document' ,  'HTML_Template_for_Consolidated_Reciept_PDF_Dupe');


            givingpowerSettings.Event_Registration_Email_Doc_ID__c = getObjectId( 'Document' ,  'HTML_Template_for_Event_Registration_Email_Content');
            givingpowerSettings.Dupe_Event_Registration_Email_Doc_ID__c = getObjectId( 'Document' ,  'HTML_Template_for_Event_Registration_Email_Content_Dupe');
            givingpowerSettings.Event_Registration_Email_Template_ID__c = getObjectId( 'EmailTemplate' ,  'Event Registration Acknowledgement');
            givingpowerSettings.Dupe_Event_Registration_Template_ID__c = getObjectId( 'EmailTemplate' ,  'Event Registration Acknowledgement (Dupe)');


            givingpowerSettings.Consolidated_Receipt_Email_Document_Id__c= getObjectId( 'Document' ,  'HTML_Template_for_Consolidated_Receipt_Email_Content');
            givingpowerSettings.Consolidated_Duplicate_Receipt_Email_Doc__c= getObjectId( 'Document' ,  'HTML_Template_for_Consolidated_Receipt_Email_Content_Dupe');


         try
            {
                DMLManager.InsertSObject(givingpowerSettings);
            }
            catch(System.DMLException e)
            {
            }
        }
    }

    global static String getObjectId(String ObjectName, String fieldValue)
    {
        String sObjectType = ObjectName;
        String fields = 'ID';
        String whereClause = 'Name = \'' + fieldValue + '\'';

        if(ObjectName.equals('OrgWideEmailAddress')){
            sObjectType = 'OrgWideEmailAddress';
            whereClause = 'DisplayName = \'' + fieldValue + '\'';
        }

        if(ObjectName.equals('Document')){
            sObjectType = 'Document';
            whereClause = 'DeveloperName = \'' + fieldValue + '\'';
        }

        String ret = '';

        List<SObject> recordList =  new GenericQueryBuilder().ListQueryBuilderWhere(sObjectType, fields, whereClause);
        SObject record = recordList.size() > 0 ? recordList[0] : null;

        if(record != null) {
            ret = record.Id;
        }

        return ret;
    }

    global static Id createObject(String ObjectName,String recType, String RecordName)
    {
        sObject sObj ;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectName);

        if(targetType!=null)
        {
            sObj = targetType.newSObject();

            if(ObjectName != 'Contact')
                sObj.put('name' , RecordName) ;
            else
                sObj.put('LastName' , RecordName) ;

            if(recType!=null)
            {
                Id recordId = getObjectId('RecordType', recType);

                sObj.put('RecordTypeId' , recordId);
            }

            try
            {
                DMLManager.InsertSObject(sObj);
            }
            catch(Exception e)
            {
            }

            return sObj.Id;
        }
        else
           return null;
    }

    global static void emailUserAnError(String ex)
    {
    }

    public static Map<String, String> cronJobMethod()
    {
        Map<String, String> scheduleJobNamesMap = new Map<String, String>();
        List<CronJobDetail> cronJobDetailList = new CronJobDetailSelector().SelectSObjects();
        for(CronJobDetail scheduleJobNames : cronJobDetailList){
            scheduleJobNamesMap.put(scheduleJobNames.Name, scheduleJobNames.id);
        }
        return scheduleJobNamesMap;
    }

    public static void updateSeachKey(){
        List<Gift__c> newlist =new List<Gift__c> ();
        List<Gift__c>  giftlist= new GiftSelector().SelectWithCreatedDateNotNull();

        for(Gift__c gift:giftlist)
        {
            string ss=gift.Constituent_Name__c + '-' + gift.Gift_Type__c + '-' + gift.Amount__c ;
            gift.Search_Key__c=ss;
            newlist.add(gift);
        }

        if (newlist != null && newlist.size() > 0) {
            DMLManager.UpdateSObjects(newlist);
        }
    }
}