public class DonationCustomMapping {
    
   public List<DonationMapping.MappingObjectResult> execute(List<DonationMapping.MappingObjectResult> results, DonationMapping.MappingSettings settings)
   {
       //Savepoint sp = Database.setSavepoint();
       return results;
   }
   
   static testMethod void testMe()
   {
      DonationCustomMapping dcm = new DonationCustomMapping();
      
      List<DonationMapping.MappingObjectResult> results = dcm.execute(null, null);
      
      System.assertEquals(results, null);
   }
}