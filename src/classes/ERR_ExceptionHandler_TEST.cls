/**
* @group ErrorHandling
* @description Tests exception handler
*/
@isTest
private with sharing class ERR_ExceptionHandler_TEST {

    /*********************************************************************************************************
    * @description Catches a required field exception, verifies it's an exception we can handle, applies 
    * exception handler method to beautify the error message, and verifies the results. Applies the method 
    * again, verifies the results are unchanged.
    */
    static testMethod void testHandleException() {
        Exception ex;
        try {
            insert new Opportunity();
        } catch (Exception oppException) {
            ex = oppException;
        }
        system.assertNotEquals(null, ex, 'An exception should be caught.');
        system.assert(ERR_ExceptionHandler.isHandledException(ex), 'The exception caught should be able to be beautified.');
        
        ERR_ExceptionHandler.beautifyExceptionMessage(ex);

        system.assert(ERR_ExceptionHandler.isHandledException(ex), 'After updating the message, we still detect it as handled.');
        //system.assert(ex.getMessage().contains(Label.exceptionRequiredField), 'The correct message is added.');

        String oldMessage = ex.getMessage();
        ERR_ExceptionHandler.beautifyExceptionMessage(ex);

        system.assertEquals(oldMessage, ex.getMessage(), 'Applying the method twice shouldn\'t change the results.');

    }

    /*********************************************************************************************************
    * @description Catches an invalid ID error, which we don't handle. Verifies it's not a handled exception,
    * and that applying the beautify method does nothing.
    */
    static testMethod void testUnhandledExceptionIsUnmodified() {
        Exception ex;
        try {
            Id foo = 'foo';
        } catch (Exception typeException) {
            ex = typeException;
        }
        
        system.assertNotEquals(null, ex, 'An exception should be caught.');
        system.assert(!ERR_ExceptionHandler.isHandledException(ex), 'The exception caught shouldn\'t be a handled exception.');
        
        String oldMessage = ex.getMessage();

        ERR_ExceptionHandler.beautifyExceptionMessage(ex);

        system.assertEquals(oldMessage, ex.getMessage(), 'Unhandled exception type should be unmodified.');
    }
}