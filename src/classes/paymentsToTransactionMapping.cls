/*Payment Reassign Script
Check all Payments belonging to Transactions that are linked to Recurring Gifts
Verify the Payment year matches with the Transaction year
If the years do not match, then reassign the Payment and Allocations to the correct Transaction
Payment in 2013 is linked to Transaction in 2013
Payment in 2014 is linked to Transaction in 2014
This only applies to Transactions with Recurring Gift lookup populated.
*/

global with sharing class paymentsToTransactionMapping implements Schedulable {
    global void execute(SchedulableContext SC)     
    {
        Database.executeBatch(new YearEndPaymentMissMatchBatchable(), 100);  
    }
}