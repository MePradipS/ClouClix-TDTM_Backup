@RestResource(urlMapping='/EventsFieldSet')
global with sharing class RESTEventFieldSets {
    @HttpGet   
    global static String createNewCase() {
        List<string> retVal = new List<string>();
        for(Schema.FieldSetMember f : SObjectType.Event_Registration__c.FieldSets.iOSAppFields.getFields()) {
            retVal.add(f.getFieldPath());
        }
        return String.join(retVal, ',');
    }
}