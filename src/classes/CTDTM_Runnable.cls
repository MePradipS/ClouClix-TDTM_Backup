/**
 * @group TDTM
 * @description Abstract class that classes to be run from a trigger, according to the TDTM design,
 * need to extend.
 *
 * It will be the duty of the run method implementation to set a flag to prevent re-entrancy. We cannot do 
 * that for them in TDTM_TriggerHandler, even if it's after calling the future, because then it might get set 
 * before the future runs (and since the future method calls the non-future method, which checks the flag, 
 * the future method would have no effect.) Also, some classes might not want to prevent it.
 */
global abstract class CTDTM_Runnable {

    /*******************************************************************************************************
     * @description Calls the run method of the class, as a future. To be called dynamically from TDTM_TriggerHandler. 
     * We need this method because Apex won't let us call a non-static method from a separate object instance.
     * @param newIds The IDs of the records that were passed to the trigger as trigger.new.
     * @param oldIds The IDs of the records that were passed to the trigger as trigger.old.
     * @param action The event (before insert, after insert,...) that caused the class to run.
     * @param objectName The name of the SObject the class runs for.
     * @param classToRunName The name of the class to run.
     * @return void
     */
    public void runFutureNonStatic(Set<Id> newIds, Set<Id> oldIds, String action, String objectName, String classToRunName) {
        runFuture(newIds, oldIds, action, objectName, classToRunName);
    }
    
    /*******************************************************************************************************
     * @description Calls the run method of the class, as a future.
     * @param newIds The IDs of the records that were passed to the trigger as trigger.new.
     * @param oldIds The IDs of the records that were passed to the trigger as trigger.old.
     * @param action The event (before insert, after insert,...) that caused the class to run.
     * @param objectName The name of the SObject the class runs for.
     * @param classToRunName The name of the class to run.
     * @return void
     */
    @future
    public static void runFuture(Set<Id> newIds, Set<Id> oldIds, String action, String objectName, String classToRunName) {
        
        Schema.DescribeSObjectResult objResult = CTDTM_UTIL_Describe.getObjectDescribe(objectName);
        CTDTM_Runnable.Action triggerAction = CTDTM_TriggerActionHelper.getTriggerActionFromName(action);
        
        //Get all fields for the object
        List<Schema.SObjectField> allFields = objResult.fields.getMap().values();
        
        //Getting the records the IDs refer to
        String qn = 'select ';
        for(Integer i = 0; i < allFields.size() - 1; i++) //add all fields, except last, to query
            qn += ' ' + allFields[i] + ', ';
        qn += ' ' + allFields[allFields.size() - 1]; //add last field to query
        qn += ' from ' + objectName + ' where id IN ';

        List<SObject> newlist;
        if (newIds != null) 
            newlist = Database.query(qn + ':newIds order by Id');
        List<SObject> oldlist;
        if (oldIds != null)
            oldlist = Database.query(qn + ':oldIds order by Id');

        //Call the non-future method
        Type classType = Type.forName(classToRunName);
        Object classInstance; 
        if(classType != null)
            classInstance = classType.newInstance();
        if(classInstance instanceof CTDTM_Runnable) {
            CTDTM_Runnable runnable = (CTDTM_Runnable) classInstance;
            //WARNING: we have queried all the fields that would be available in the records themselves, but NOT the fields
            //from related (parent or child) records. Those would need to be queried independently in the class itself (see 
            //ERR_ParentAccountUpdater2_TEST class for an example on how to do that).
            DmlWrapper dmlWrapper = runnable.run(newlist, oldlist, triggerAction, objResult);
            
            //Process the result. In this case we cannot pass the original Trigger.new and Trigger.old, since we are
            //in a future
            CTDTM_TriggerHandler.processDML(dmlWrapper);
        }
    }
    
    /*******************************************************************************************************
     * @description Method to be implemented by the classes the extend this abstract class. This is the method
     * that will be called by the trigger handler.
     * @param newIds The records that were passed to the trigger as trigger.new.
     * @param oldIds The records that were passed to the trigger as trigger.old.
     * @param action The event (before insert, after insert,...) that caused the class to run.
     * @param objectResult The type of SObject the class runs for.
     * @return DmlWrapper A wrapper containing all the records to perform DML on.
     */
    global abstract DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, Action triggerAction, 
        Schema.DescribeSObjectResult objResult);
    
    /*******************************************************************************************************
    * @description Class that wraps records that need to have DML performed on them. One DML operation of each
    * kind will be performed at the end of the transaction.
    */     
    global class DmlWrapper {
        global List<SObject> objectsToInsert = new List<SObject>(); 
        global List<SObject> objectsToUpdate = new List<SObject>();
        global List<SObject> objectsToDelete = new List<SObject>();
        global List<SObject> objectsToUndelete = new List<SObject>();
        
        /*******************************************************************************************************
        * @description Groups the records in each of the property lists by object type.
        * @return void
        */
        public void groupByType() {
            objectsToInsert = groupSObjects(objectsToInsert);
            objectsToUpdate = groupSObjects(objectsToUpdate);
            objectsToDelete = groupSObjects(objectsToDelete);
            objectsToUndelete = groupSObjects(objectsToUndelete);
        }
        
        /*******************************************************************************************************
        * @description Groups records by object type.To avoid the "Cannot have more than 10 chunks in a single operation. 
        * Please rearrange the data to reduce chunking" error.
        * @param sobjects The records to group by type.
        * @return List<SObject> A list with the records passed as parameters ordered by type. Duplicates removed.
        */
        private List<SObject> groupSObjects(List<SObject> sobjects) {
                        
            map<string,list<SObject>> mapNameToListSObject = new map<string,list<SObject>>();
            list<SObject> sorted = new list<SObject>();

            //First remove duplicates to avoid the "Duplicate id in list" error
            sobjects = new list<SObject>(new set<SObject>(sobjects));

            for (SObject SObj : sobjects) {
                string objName = SObj.getSObjectType().getDescribe().getName();
                if (mapNameToListSObject.containsKey(objName)) {
                    mapNameToListSObject.get(objName).add(SObj);
                } else {
                    mapNameToListSObject.put(objName, new list<SObject>{SObj});
                }
            }


            for (list<SObject> groupedObjects : mapNameToListSObject.values())
                sorted.addAll(groupedObjects);

            return sorted;
        }
    }
    
    /*******************************************************************************************************
    * @description Different type of actions to run classes for from triggers. Equivalent to trigger events,
    * but used in our TDTM design.
    */
    global enum Action {   
        BeforeInsert, 
        BeforeUpdate, 
        BeforeDelete, 
        AfterInsert, 
        AfterUpdate, 
        AfterDelete,
        AfterUndelete
    }
}