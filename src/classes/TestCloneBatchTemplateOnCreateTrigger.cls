@isTest
public class TestCloneBatchTemplateOnCreateTrigger {
    private static string NamespacePrefix = Utilities.getCurrentNamespace();
    private static String NamespaceField = NamespacePrefix + (String.isEmpty(NamespacePrefix) ? '' : '__');
    private static String NamespaceBatchTemplate = NamespaceField + 'Batch_Template__c';

    static TestMethod void test() {
        RecordType RT = [SELECT Id FROM RecordType WHERE SobjectType = :NamespaceBatchTemplate AND Name = 'Parent'];
        Batch_Template__c temp = new Batch_Template__c();
        temp.Name = 'test';
        temp.RecordTypeId = RT.Id;
        Insert temp;

        Gift_Batch__c gb = new Gift_Batch__c();
        gb.Name__c = 'batch';
        gb.Template_Name__c = temp.Id;
        Insert gb;

        //System.assertNotEquals([Select Id, Template_Name__c From Gift_Batch__c Where Id =: gb.Id].Template_Name__c, temp.Id);
    }
}