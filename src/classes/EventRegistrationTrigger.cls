public class EventRegistrationTrigger{
  @future
  public static void RollupNamesReceivedTrigger(Set<String> ContactIDs){
    Application_Setting__c eventTriggerSetting;
    List<Application_Setting__c> eventTriggerSettings = new ApplicationSettingSelector().SelectSObjectsByNameLimit('Event Registration Toggle', 1);
    if(eventTriggerSettings.size() > 0){
      eventTriggerSetting = eventTriggerSettings[0];
    }

    if((eventTriggerSetting == null) || eventTriggerSetting.Org_Count__c == 1){
      Set<Id> contactSetIds = Utilities.ConvertStringSetToIdSet(ContactIDs);
      List<Contact> Contacts = new ContactSelector().SelectEventAttendanceById(contactSetIds);

      for (Contact c : Contacts)
      {
          c.Event_Attended__c = False;
          c.Date_of_Last_Event_Attended__c = null;
          c.Name_of_Last_Event_Attended__c = '';
          
          if (c.Event_Registrations__r.size() != 0)
          {
              c.Event_Attended__c = True;
              // c.Date_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Registration_Date__c;
              // Date of Last Event Attended Not Calculating Correctly--https://www.pivotaltracker.com/story/show/99610876
              c.Date_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Event__r.StartDate;
              c.Name_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Event__r.Name;                
          }
      }

      DMLManager.UpdateSObjects(Contacts);
    }
  }

  //#137880635 --non-future method
  public static void RollupNamesReceivedTriggerSync(Set<String> ContactIDs){
    Application_Setting__c eventTriggerSetting;
    List<Application_Setting__c> eventTriggerSettings = new ApplicationSettingSelector().SelectSObjectsByNameLimit('Event Registration Toggle', 1);
    if(eventTriggerSettings.size() > 0){
      eventTriggerSetting = eventTriggerSettings[0];
    }

    if((eventTriggerSetting == null) || eventTriggerSetting.Org_Count__c == 1){
      Set<Id> contactIdSet = Utilities.ConvertStringSetToIdSet(ContactIDs);
      List<Contact> Contacts = new ContactSelector().SelectEventAttendanceById(contactIdSet);

      for (Contact c : Contacts)
      {
          c.Event_Attended__c = False;
          c.Date_of_Last_Event_Attended__c = null;
          c.Name_of_Last_Event_Attended__c = '';
          
          if (c.Event_Registrations__r.size() != 0)
          {
              c.Event_Attended__c = True;
              // c.Date_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Registration_Date__c;
              // Date of Last Event Attended Not Calculating Correctly--https://www.pivotaltracker.com/story/show/99610876
              c.Date_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Event__r.StartDate;
              c.Name_of_Last_Event_Attended__c = c.Event_Registrations__r[0].Event__r.Name;                
          }
      }

      DMLManager.UpdateSObjects(Contacts);
    }
  }
  
  @future
  public static void RollupNamesReceivedTrigger(Set<Id> transIds){
    Application_Setting__c eventTriggerSetting;
    List<Application_Setting__c> eventTriggerSettings = new ApplicationSettingSelector().SelectSObjectsByNameLimit('Event Registration Toggle', 1);
    if(eventTriggerSettings.size() > 0){
      eventTriggerSetting = eventTriggerSettings[0];
    }

    if((eventTriggerSetting == null) || eventTriggerSetting.Org_Count__c == 1){
      BatchSettings__c settings = BatchSettings__c.getInstance('Default');
      String guestId = '';
      List<Gift__c> trans = new GiftSelector().SelectAttendeesById(guestId, transIds);         
      List<Gift__c> updateGift = new List<Gift__c>();
      
      if(trans.size() > 0){
        for (Gift__c g : trans) {
          if(g.Attendee_Names_Received__c != g.Event_Registrations__r.size()){
            g.Attendee_Names_Received__c = g.Event_Registrations__r.size();
            updateGift.add(g); 
          }   
        }
        if(updateGift.size() > 0) {
          DMLManager.UpdateSObjects(updateGift);
        }
      }
    }
  }

  //#137880635 --non-future method
  public static void RollupNamesReceivedTriggersync(Set<Id> transIds){
    Application_Setting__c eventTriggerSetting;
    List<Application_Setting__c> eventTriggerSettings = new ApplicationSettingSelector().SelectSObjectsByNameLimit('Event Registration Toggle', 1);
    if(eventTriggerSettings.size() > 0){
      eventTriggerSetting = eventTriggerSettings[0];
    }

    if((eventTriggerSetting == null) || eventTriggerSetting.Org_Count__c == 1){
      BatchSettings__c settings = BatchSettings__c.getInstance('Default');
      String guestId = '';
      List<Gift__c> trans = new GiftSelector().SelectAttendeesById(guestId, transIds);  
      List<Gift__c> updateGift = new List<Gift__c>();
      
      if(trans.size() > 0){
        for (Gift__c g : trans) {
          if(g.Attendee_Names_Received__c != g.Event_Registrations__r.size()){
            g.Attendee_Names_Received__c = g.Event_Registrations__r.size();
            updateGift.add(g); 
          }   
        }
        if(updateGift.size() > 0) {
          DMLManager.UpdateSObjects(updateGift);
        }
      }
    }
  }
}