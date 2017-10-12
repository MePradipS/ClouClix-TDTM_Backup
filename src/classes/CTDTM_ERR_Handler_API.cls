/**
* @group API
* @description API class that exposes error handling.
*/
global class CTDTM_ERR_Handler_API {
    
    global enum Context {
        /* @description Address context. */
        ADDR, 
        /* @description Affiliations context. */
        AFFL, 
        /* @description Allocations context. */
        ALLO, 
        /* @description Batch Data Entry context. */
        BDE, 
        /* @description Batch Data Import context. */
        BDI, 
        /* @description Contacts context. */
        CON, 
        /* @description Account Conversion context. */
        CONV, 
        /* @description Households context. */
        HH, 
        /* @description Lead Conversion context. */
        LD, 
        /* @description Level context. */
        LVL, 
        /* @description Opportunities context. */
        OPP, 
        /* @description Payments context. */
        PMT, 
        /* @description Relationships context. */
        REL, 
        /* @description Recurring Donations context. */
        RD,  
        /* @description Rollups context. */
        RLLP, 
        /* @description Schedulable context. */
        SCH, 
        /* @description Settings context. */
        STTG, 
        /* @description Table-Driven Trigger Management context. */
        TDTM,
        /* @description USERcontext. */
        USER
    }
     
    /*******************************************************************************************************
    * @description Creates an error record from an exception, stores it in the database (if enabled), and sends error
    *              notifications (if enabled).
    * @param e Exception to create error record from.
    * @return context The context the exception was raised on.
    */
    global static void processError(Exception e, String context) {
        CTDTM_ERR_Handler.processError(e, context);
    }
}