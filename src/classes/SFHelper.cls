/*****************************
 *****************************
 **  Common Methods Class   **
 *****************************
 ***************************** 
 */
public with sharing class SFHelper {
    /*** Fetching Custom Settings ***/
    // Batch Settings
    public static BatchSettings__c GetBatchSettings(string pName) {
        return BatchSettings__c.getInstance(pName);
    }
    
    public static BatchSettings__c GetDefaultBatchSettings() {
        return GetBatchSettings('Default');
    }
    
    // Causeview App Settings
    public static App_Settings__c GetCVAppSettings() {
        return App_Settings__c.getInstance();
    }
    
    // Causeview Templates
    public static givingpowerSettings__c GetCVTemplates(string pName) {
        return givingpowerSettings__c.getInstance(pName);
    }
    
    public static givingpowerSettings__c GetDefaultCVTemplates() {
        return GetCVTemplates('Settings');
    }
    
}