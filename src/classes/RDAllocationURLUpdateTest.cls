@isTest
private class RDAllocationURLUpdateTest {

	@isTest static void test_method_one()
	{
		// RD_Allocation__c rdAllocationObject = new RD_Allocation__c();
		// rdAllocationObject.Recurring_Gift__c = rd.Id;
		// rdAllocationObject.Amount__c = 1000;
		// insert rdAllocationObject;
		//
		// ApexPages.StandardController stdcontroller = new ApexPages.StandardController(rdAllocationObject);
		// RDAllocationURLUpdate testObject = new RDAllocationURLUpdate(stdcontroller);
	}

	@isTest static void test_method_two() {
		// Implement test code
	}

	public static Map<String, String> getrecordTypes(){
			Map<String, String> rtypes = new Map<String, String>();
			String rtsQuery = 'Select Name, Id From RecordType where (Name = \'Gift\' OR Name = \'Event\' OR Name = \'Matching Gift\' OR Name = \'Campaign\' OR Name = \'Appeal\' OR Name = \'Refund\') AND NamespacePrefix = \'' + Utilities.getCurrentNamespace() + '\'';
			List<RecordType> rts = database.query(rtsQuery);
			for(RecordType r : rts){
					rtypes.put(r.Name, r.Id);
			}
			return rtypes;
	}

}