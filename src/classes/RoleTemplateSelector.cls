public with sharing class RoleTemplateSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Role_Template__c.Id, Role_Template__c.Skills_And_Experience__c, Role_Template__c.Role_Description__c,
			Role_Template__c.Special_Requirements__c, Role_Template__c.Role_Tasks__c, Role_Template__c.Training_Provided__c};
	}

	public override Schema.SObjectType GetSObjectType() {
		return Role_Template__c.sObjectType;
	}

	public List<Role_Template__c> SelectVPDById(Set<String> vpdIds){
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> {
			Role_Template__c.Id, Role_Template__c.Skills_And_Experience__c, Role_Template__c.Role_Description__c,
			Role_Template__c.Special_Requirements__c, Role_Template__c.Role_Tasks__c, Role_Template__c.Training_Provided__c};
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id IN :vpdIds',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}
}