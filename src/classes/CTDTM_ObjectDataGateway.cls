/**
 * @group TDTM
 * @description Class that queries custom object to retrieve classes to call for creation or modification
 * of a record of a specific object type.
 */
public without sharing class CTDTM_ObjectDataGateway implements CTDTM_iTableDataGateway {
    
    //private static List<ToRunOnObjectAction> classesQueried = new List<ToRunOnObjectAction>();
    private static Integer rowCount;
    
    /*******************************************************************************************************
     * @description Checks is any TDTM records exist.
     * @return Boolean True is there are no TDTM records. False otherwise.
     */
    public Boolean isEmpty() {
        if(rowCount == null) {
            List<Trigger_Handler__c> result = [select Id from Trigger_Handler__c limit 1];
            rowCount = result.size();
        }
        if(rowCount == 0) {
            return true;
        }
        return false;
    }

    /*******************************************************************************************************
     * @description Returns the classes that will be called for the specified ojbect and action. Returned list 
     *              is sorted by load order. Filters out in-active handlers and any where the list of 
     *              excluded usernames includes the current context user.
     * @param objectName The name of the object.
     * @param action The action (before insert, after insert,...). 
     * @return List<SObject> List of classes to call, sorted by load order.
     **/
    public static List<SObject> getClassesToCallForObject(String objectName, CTDTM_Runnable.Action action) {   
        string strAction = action.Name();
        string currUserName = UserInfo.getUserName();
        List<SObject> listClasses = new list<Sobject>();
        for (Trigger_Handler__c th : listTH) {
            Set<String> excludedUserNames = (th.Usernames_to_Exclude__c != null ?
                    new Set<String>(th.Usernames_to_Exclude__c.split(';')) : new Set<String>());
            if (th.Object__c == objectName && th.Trigger_Action__c.contains(strAction) && th.Active__c == true
                    && !excludedUserNames.contains(currUserName)) {
                listClasses.add(th);
            }
        }
        return listClasses;
    }

    /*******************************************************************************************************
     * @description to allow test code to modify the saved trigger handlers and have them reread into the cache.
     */ 
    public static void ClearCachedTriggerHandlersForTest() {
        listTH = null;
    }

    /*******************************************************************************************************
     * @description holds the trigger handlers cached in a list, to avoid repetitive soql calls.
     */
    public static list<Trigger_Handler__c> listTH {
        get {
            if (listTH == null) {
                listTH =  [select Asynchronous__c, Class__c, Load_Order__c, Object__c, Active__c, Usernames_to_Exclude__c, 
                    Trigger_Action__c from Trigger_Handler__c order by Load_Order__c];
            }
            return listTH;
        }
        set;
    }
}