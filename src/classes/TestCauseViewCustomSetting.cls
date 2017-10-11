@IsTest
public class TestCauseViewCustomSetting
{


 static testMethod  void testANumSettings()
 {
     CauseViewCustomSetting.defaultANumSettings();   
 }
 
 
 
  static testMethod  void testBatchSettings()
 {
     CauseViewCustomSetting.defaultBatchSettings();
 }
 
 
 
 static testMethod  void testAppSettings()
 {
     CauseViewCustomSetting.defaultAppSettings();
 }
 
 
 static testMethod  void testAppTemplateSettings()
 {
   CauseViewCustomSetting.defaultAppTemplateSettings();
 }
 
 static testMethod void testSearchKey(){
      Map<String, String> rtype_Map = new Map<String, String>();
        rtype_Map = GLAllocationfieldUpdateTriggerTest.getrecordTypes();
        aNums__c cs1 = GLAllocationfieldUpdateTriggerTest.anumsSettings();
        
        App_Settings__c appSetting = GLAllocationfieldUpdateTriggerTest.appSettings();
        
        Account a = GLAllocationfieldUpdateTriggerTest.acc();

        BatchSettings__c cs2 = GLAllocationfieldUpdateTriggerTest.batchSettings();        

        Contact c = GLAllocationfieldUpdateTriggerTest.con();
        Fund__c f = GLAllocationfieldUpdateTriggerTest.fundRecord();
        Campaign camp = new Campaign(Name = 'Campaign', RecordTypeId = rtype_Map.get('Campaign'));
        DMLManager.InsertSObject(camp);
        Campaign pAppeal = new Campaign(Name = 'Appeal', RecordTypeId = rtype_Map.get('Appeal'), ParentId = camp.Id);
        DMLManager.InsertSObject(pAppeal);
        Campaign event = new Campaign(Name = 'Event', RecordTypeId = rtype_Map.get('Event'), ParentId = pAppeal.Id);
        DMLManager.InsertSObject(event);
        Event_Level__c e = GLAllocationfieldUpdateTriggerTest.eventLevelRecord();
        e.Event__c = event.Id;
        DMLManager.InsertSObject(e);
        
        Gift__c g= GLAllocationfieldUpdateTriggerTest.giftRecord();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        DMLManager.InsertSObject(g);
        
        CauseViewCustomSetting.updateSeachKey();
  }



}