@isTest
public class voidDetailUpdateOnReceiptTriggerTest{
    
    public static testMethod void voidDetailUpdateOnReceiptTriggerTest(){
        Map<String, String> rtypes_Map = new Map<String, String>();
        List<RecordType> rts = new RecordTypeSelector().SelectRecordsByMultipleNamesAndNamespacePrefix('Gift', 'Event', 'Matching Gift', 'Campaign', 'Appeal', 'Refund', 'Void', Utilities.getCurrentNamespace());
        for(RecordType r : rts){
            rtypes_Map.put(r.Name, r.Id);
        }
        Account a = new Account(name='testAccount', Email__c='test@account.com');
        Insert a;
        BatchSettings__c cs2 = new BatchSettings__c( Name = 'Default', BatchFormID__c = 'sadas',   BatchReportId__c = 'asdasd', RegularGiftRecordTypeId__c = rtypes_Map.get('Gift'), BucketAccountId__c = a.Id,    CurrencyCode__c = 'CAD', GatewayUrl__c = 'asdasd');        
        insert cs2;
        Contact c = new Contact();
        c.LastName = 'sss';
        insert c;
        
        Gift__c g= new Gift__c();
        g.Status__c = 'Active';
        g.Gift_Type__c = 'One Time Gift';
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtypes_Map.get('Gift');
        insert g;
        
        Payment__c p1 = new Payment__c();
        p1.Payment_Type__c = 'Cash';      
        p1.Cheque_Date__c = Date.today();
        p1.Amount__c = 80;
        p1.Status__c = 'Written Off';
        p1.Donation__c = g.Id;
        insert p1;
        
        Receipt__c receipt = new Receipt__c(Gift__c = g.Id, Amount_Not_Eligible__c =0);
        insert receipt;
        
        p1.Receipt__c = receipt.id;
        update p1;
        
        receipt.RecordTypeId = rtypes_Map.get('Void');
        update receipt;
    }
}