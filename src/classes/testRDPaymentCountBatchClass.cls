@isTest
  public class testRDPaymentCountBatchClass{  
   public  static testMethod void testRDPaymentCountBatch(){
              RDPaymentCountBatch e = new RDPaymentCountBatch();
           Database.executeBatch(e, 10); 
           
           //Database.executeBatch(new RollupBatchForConsecutiveYears(), 10); 
           
           BatchPresetController bpc = new BatchPresetController();           
           bpc.newBatchPreset();          
           bpc.getbatchTypeOptions();
           bpc.discribeObjects('account');
           
           
           
  }
  }