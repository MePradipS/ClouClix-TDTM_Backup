/**
* @group Utilities
* @description Utility class for debug statements to turn them off in a managed context, as well as to display relevant performance information.
*/
public class UTIL_Debug {

    //enable debug logs in all tests, otherwise get the setting
    //public static boolean enabled = test.isRunningTest() ? true : UTIL_CustomSettingsFacade.getErrorSettings().Enable_Debug__c;
    
    public static boolean enabled = true;

    /*******************************************************************************************************
    * @description Prints a debug message to the debug log, if debugging is enabled or a test is being run.
    * @param message The message to print.
    * @return void
    */
    public static void debug (string message) {
        if (enabled) {
            system.debug(message);
        }
    }

    /*******************************************************************************************************
    * @description Prints a debug message to the debug log, if debugging is enabled or a test is being run, at the specified
    *              logging level.
    * @param message The message to print.
    * @param level The level to output the message at.
    * @return void
    */
    public static void debug (System.LoggingLevel level, string message) {
        if (enabled) {
            system.debug(level, message);
        }
    }

    /*******************************************************************************************************
    * @description Prints a debug message to the debug log, if debugging enabled or a test is being run, with additional info, 
                   such as heap, cpu, query, and rows usage.
    * @param message The message to print.
    * @return void
    */
    public static void debugWithInfo (string message) {
        if (enabled) {
            system.debug(
                message + 
                ' Heap:' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() +
                ' CPU:' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime() + 
                ' Query:' + Limits.getQueries() + '/' + Limits.getLimitQueries() + 
                ' Qrows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows() +
                ' Rows:' + Limits.getDMLRows() + '/' + Limits.getLimitDMLRows()
            );
        }
    }

    /*******************************************************************************************************
    * @description Prints a debug message to the debug log, if debugging is enabled or a test is being run, at the specified logging
    *              level, with additional info, such as heap, cpu, query, and rows usage.
    * @param message The message to print.
    * @param level The level to output the message at.
    * @return void
    */
    public static void debugWithInfo (System.LoggingLevel level, string message) {
        if (enabled) {
            system.debug(
                level,
                message + 
                ' Heap:' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize() +
                ' CPU:' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime() + 
                ' Query:' + Limits.getQueries() + '/' + Limits.getLimitQueries() + 
                ' Rows:' + Limits.getDMLRows() + '/' + Limits.getLimitDMLRows()
            );
        }
    }

    /*******************************************************************************************************
    * @description Force the enabled static var to false regardless of the Test.isRunningTest() or custom
    * settings value to prevent all system.debug() logging through this class. Debug statements can be
    * expensive in terms of cpu time especially if they're called repitively in loops, through recursive
    * triggers, or repetitive operations. Disabling debug statements can help reduce the change of an apex
    * cpu time out in a unit test.
    */
    public static void disableDebugLogging() {
        enabled = false;
    }
}