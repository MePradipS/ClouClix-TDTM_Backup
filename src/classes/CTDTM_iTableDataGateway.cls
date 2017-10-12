/**
 * @group TDTM
 * @description Interface that data gateways used in the TDTM design need to implement.
 */
public interface CTDTM_iTableDataGateway {

    /*******************************************************************************************************
     * @description Checks is any TDTM records exist.
     * @return Boolean True is there are no TDTM records. False otherwise.
     */
    Boolean isEmpty();
    
    /*******************************************************************************************************
     * @description Returns the classes that will be called for the specified ojbect and action. Returned list 
     *              is sorted by load order.
     * @param objectName The name of the object.
     * @param action The action (before insert, after insert,...). 
     * @return List<SObject> List of classes to call, sorted by load order.
     **/ 
     List<SObject> getClassesToCallForObject(String objectName, CTDTM_Runnable.Action action);
}