public class testController {

  public string DocumentId {
     get
     {
        givingpowerSettings__c settings = new GivingPowerSettingsSelector().SelectSettingsByName('settings');
        return settings.ReceiptPDFDocId__c;
     }
  }

  static testMethod void testMe()
  {
  		testController test = new testController();
  		string val = test.DocumentId;

  }
}