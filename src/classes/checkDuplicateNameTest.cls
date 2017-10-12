@isTest
public class checkDuplicateNameTest{
    public static testMethod void checkDuplicateBatchTemplateName(){
        Batch_Template__c b = new Batch_Template__c(name = 'test123456');
        insert b;
        
        Batch_Template__c b1 = new Batch_Template__c(name = 'test123456');
        
        
        try
        {
        insert b1;
        }
        catch(Exception e)
        {
        Boolean expectedExceptionThrown =  e.getMessage().contains('Name already Exist!') ? true : false;
        } 
    }
    public static testMethod void checkDuplicateGiftBatchNameTrigger(){
        List<RecordType> rtype = new RecordTypeSelector().SelectByNameNamespacePrefixAndNameNoLimit(Utilities.getCurrentNamespace(), 'Parent');
        if (rtype.size() > 0)
        {
            Batch_Template__c b = new Batch_Template__c(name = 'test123456789', RecordTypeId = rtype[0].id);
            insert b;
            
            Gift_Batch__c g = new Gift_Batch__c(Name__c = 'Test123456789', Template_Name__c = b.id);
            insert g;
            
            Gift_Batch__c g1 = new Gift_Batch__c(Name__c = 'Test123456789', Template_Name__c = b.id);

            try
            {
                insert g1;
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('Name already Exist!') ? true : false;
            } 
        }
    }
}