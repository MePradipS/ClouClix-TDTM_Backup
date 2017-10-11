public with sharing class OrganizationRelationshipSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Organization_Relationship__c.Id, Organization_Relationship__c.Related_Account__c, Organization_Relationship__c.Account__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Organization_Relationship__c.sObjectType;
	}

    public List<Organization_Relationship__c> SelectByRelatedAccount(String relatedAccount) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Related_Account__c = :relatedAccount', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }
}