global without sharing class TDTM_Handler extends TDTM_Runnable {

    private static final String THIS_CLASS_NAME = 'TDTM_Handler';
    private static final Integer TRIGGER_LOAD_ORDER = 2;

    // Custom TDTM Trigger details used to recreate TDTM records for Unit Tests or in a Sandbox
    private static final map<string,string> TDTMconfig = new map<string,string> {
            'Account' => 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate',
            'Contact' => 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete',
            'Opportunity' => 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete'
        };

    /*
    * Main method called by the TDTM trigger
    */
    global override DmlWrapper run(List<sObject> listNew, List<sObject> listOld,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        triggerInfo trgr = new triggerInfo(triggerAction, objResult);

        if (trgr.sObjectName == 'Contact') {
            if (trgr.isBefore && trgr.isInsert) {
                //TDTM_Processes.Contact_DoSomethingOnBeforeInsert(trgr, listNew);
            }
        } else if (trgr.sObjectName == 'Account') {
            if (trgr.isAfter && trgr.isUpdate) {
                //TDTM_Processes.Account_DoSomethingOnAfterUpdate(trgr, listNew, makeMapFromSObjectList(listOld));
            }
        } else if (trgr.sObjectName == 'Opportunity') {
            if (trgr.isUpdate) {
                //TDTM_Processes.Opportunity_DoSomethingOnUpdate(trgr, listNew, makeMapFromSObjectList(listOld));
            }
        }

        return null;
    }

    /*
    * Initialize the TDTM configuration.
    * Helpful in Unit Tests to ensure that the "triggers" are in place for tests
    * Also helps to document & rebuild the trigger configuration in case the TDTM
    * records are deleted or for new/refreshed Config/Dev Sandboxes.
    */
    global static integer initTDTM() {

        // Find any existing TDTM config records related to THIS class
        // and match against the ones to be created
        for (Trigger_Handler__c th : [SELECT ID, Class__c, Object__c,
                Trigger_Action__c FROM Trigger_Handler__c
                WHERE Active__c = True AND Class__c = :THIS_CLASS_NAME]) {
            if (TDTMconfig.containsKey(th.Object__c)) {
                TDTMconfig.remove(th.Object__c);
            }
        }

        // Create TDTM records that did not exist before
        list<Trigger_Handler__c> tdtm = new list<Trigger_Handler__c>();
        for (String obj : TDTMconfig.keySet()) {
            tdtm.add(new Trigger_Handler__c(
                Class__c = THIS_CLASS_NAME,
                Object__c = obj,
                Active__c = true,
                User_Managed__c = true,
                Load_Order__c  = TRIGGER_LOAD_ORDER,
                Trigger_Action__c = TDTMconfig.get(obj)
            ));
        }
        if (tdtm.size() > 0) {
            database.insert(tdtm, false);
        }
        return tdtm.size();
    }

    /*
    * Utility Method:
    * Convert a list of sObjects into a map by Id (returns null if list is null)
    */
    private static Map<Id, SObject> makeMapFromSObjectList(List<SObject> lstSobject) {
        if (lstSobject == null) return null;
        Map<Id, SObject> theMap = new Map<Id, SObject>();
        for (sObject s : lstSobject) {
            theMap.put((Id)s.get('Id'), s);
        }
        return theMap;
    }

    /* 
    * Holds the trigger context variables as an instance to pass to the processing methods
    * if required. This ensures that the specific vars are tied to the context in which they're
    * being run. Using static class vars in this class will not work because they're overwritten
    * in the case of nested trigger calls in a single context.
    */
    public class triggerInfo {
        public Boolean isInsert = false; // These mimic the properties in 
        public Boolean isUpdate = false; // standard Salesforce Triggers
        public Boolean isBefore = false;
        public Boolean isAfter  = false;
        public Boolean isDelete = false;
        public Boolean isUndelete = false;
        public String sObjectName;

        public triggerInfo(TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
            this.isInsert = (triggerAction == TDTM_Runnable.Action.BeforeInsert
                || triggerAction == TDTM_Runnable.Action.AfterInsert);
            this.isUpdate = (triggerAction == TDTM_Runnable.Action.BeforeUpdate
                || triggerAction == TDTM_Runnable.Action.AfterUpdate);
            this.isBefore = (triggerAction == TDTM_Runnable.Action.BeforeInsert
                || triggerAction == TDTM_Runnable.Action.BeforeUpdate
                || triggerAction == TDTM_Runnable.Action.BeforeDelete);
            this.isAfter = !isBefore;
            this.isDelete = (triggerAction == TDTM_Runnable.Action.BeforeDelete
                || triggerAction == TDTM_Runnable.Action.AfterDelete);
            this.isUndelete = (triggerAction == TDTM_Runnable.Action.AfterUndelete);
            this.sObjectName = objResult.getName();
        }
    }
}