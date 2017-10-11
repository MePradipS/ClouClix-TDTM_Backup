public with sharing class CVAdminSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			CVAdmin__c.Name, CVAdmin__c.Disable_Workflows_for_Sending_Receipts__c, CVAdmin__c.Enable_Enhanced_Batch_Interface_Waive__c, 
			CVAdmin__c.Enable_Enhanced_Fund_Accounting_Waive__c, CVAdmin__c.Enable_Pledge_Installment_Model_Waive__c, 
			CVAdmin__c.Send_Event_Registration_Receipt__c, CVAdmin__c.Send_Gift_Receipt__c, CVAdmin__c.Organization_Address__c, 
			CVAdmin__c.Organisation_Name__c, CVAdmin__c.Organization_Phone__c, CVAdmin__c.Appeal_Rollup_1__c, CVAdmin__c.Appeal_Rollup_2__c, 
			CVAdmin__c.Appeal_Rollup_3__c, CVAdmin__c.Org_Wide_Email_Address__c, CVAdmin__c.AppealUtilRollBatch__c, CVAdmin__c.CampaignRollupBatch__c, 
			CVAdmin__c.PackageRollupBatch__c, CVAdmin__c.Account_Rollup_Batch__c, CVAdmin__c.Contact_RollUp_Batch__c, CVAdmin__c.UpdatePaymentRT_RefundACH__c, 
			CVAdmin__c.Payment_Rollup_Batch__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return CVAdmin__c.sObjectType;
	}
}