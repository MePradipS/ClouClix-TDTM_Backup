@isTest
public class paymentsToTransactionMappingTest{
    public static testMethod void paymentsToTransactionMappingTest(){
        Test.StartTest();
        paymentsToTransactionMapping p = new paymentsToTransactionMapping();     
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, p);
        Test.stopTest();
    }
}