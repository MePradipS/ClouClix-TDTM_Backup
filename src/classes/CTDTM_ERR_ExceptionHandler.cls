/**
* @group ErrorHandling
* @description Exception handler for intercepting and modifying exception messages to be more user friendly,
* and to remove cruft.
*/
public with sharing class CTDTM_ERR_ExceptionHandler {
    /** @description Map of exception STATUS codes to friendly error message.
    */
    private static final Map<String, String> EXCEPTION_MESSAGES = new Map<String, String>{
        'FIELD_CUSTOM_VALIDATION_EXCEPTION' => Label.exceptionValidationRule,
        'REQUIRED_FIELD_MISSING' => Label.exceptionRequiredField
    };

    /** @description Map of exception STATUS codes to the string that defines the start and end of the useful part of the message
    */
    private static final Map<String, List<String>> SUBSTRINGS = new Map<String, List<String>>{
        'FIELD_CUSTOM_VALIDATION_EXCEPTION' => new List<String>{'FIELD_CUSTOM_VALIDATION_EXCEPTION,',':'},
        'REQUIRED_FIELD_MISSING' => new List<String>{': [',']'}
    };

    /*******************************************************************************************************
    * @description Updates an exception's message to a more friendly format.
    * @param ex Exception to update.
    * @return void This method modifies the exception message directly and has no return.
    */
    public static void beautifyExceptionMessage(Exception ex) {
        String message = ex.getMessage();
        for (String STATUS : EXCEPTION_MESSAGES.keySet()) {
            if (message.contains(STATUS)) {
                message = EXCEPTION_MESSAGES.get(STATUS) + message.substringBetween(SUBSTRINGS.get(STATUS)[0], SUBSTRINGS.get(STATUS)[1]);
                ex.setMessage(message);
                break;
            }
        }
    }

    /*******************************************************************************************************
    * @description Returns whether an exception has a message type that we can or already have modified.
    * @param ex Exception to verify.
    * @return Boolean Whether the exception's message can or has been modified.
    */
    public static Boolean isHandledException(Exception ex) {
        for (String STATUS : EXCEPTION_MESSAGES.keySet()) {
            if (ex.getMessage().contains(STATUS) || ex.getMessage().contains(EXCEPTION_MESSAGES.get(STATUS))) {
                return true;
            }
        }
        return false;
    }
}