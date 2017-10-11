public with sharing class RemoteQueryBuilder {

	public RemoteQueryBuilder(ApexPages.StandardController stdController) {	}

	public RemoteQueryBuilder(TransactionBatchPresetsController tbpController) {	}

	public RemoteQueryBuilder(HouseHoldLtng tbpController) {	}


	@RemoteAction
	public Static List<sObject> ListQueryBuilderWhere(String sObjectType, String commaDelimitedFields, String whereClause)
	{
			return new GenericQueryBuilder().ListQueryBuilderWhere(sObjectType,commaDelimitedFields,whereClause);
	}

	@RemoteAction
	public Static List<sObject> ConvertOppQueryFund(String whereClause)
	{
			return new FundSelector().ConvertOppQueryFund(whereClause);
	}

	@RemoteAction
	public Static List<sObject> CampaignAndFundQuery(String recordName, String searchKey)
	{
			return new CampaignSelector().SelectCampaignAndRelatedFund(recordName,searchKey);
	}
}