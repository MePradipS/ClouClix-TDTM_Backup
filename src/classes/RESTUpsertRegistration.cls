@RestResource(urlMapping='/UpsertRegistration')
global with sharing class RESTUpsertRegistration {
    
    @HttpPost   
    global static Event_Registration__c UpsertRegistration(Event_Registration__c reg, Contact con) {
        
        DMLManager.UpsertSObject(con);
        
        if (reg != null) {
            reg.Individual__c = con.Id;
            DMLManager.UpdateSObject(reg);
        }
        
        return reg;
    }
}