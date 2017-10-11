public with sharing class UserSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			User.Id, User.Payment_Gateway_Account_ID__c, User.Receive_CC_Updates__c, User.isActive, User.Payment_Filter__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return User.sObjectType;
	}

	public List<User> SelectByReceiveCCUpdatesAndIsActive() {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Receive_CC_Updates__c = True and isActive = true',
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }

	public List<User> SelectBatchById(Set<Id> idSet) {
		List<Schema.SObjectField> customUserFieldList = new List<Schema.SObjectField> {
			User.Id, User.BatchDefaults__c, User.BatchReadonlys__c, User.BatchHiddenFields__c };
		IsCustomAccessible(customUserFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customUserFieldList), GetSObjectName() });
        return Database.query(queryString);
    }

	public List<User> SelectContactIdById(String uId) {
		List<Schema.SObjectField> customUserFieldList = new List<Schema.SObjectField> { User.ContactId, User.Id };
		IsCustomAccessible(customUserFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE Id = :uId', 
			new List<String> { GetFieldListString(customUserFieldList), GetSObjectName() });
		return Database.query(queryString);
	}

	public Integer SelectUserCountByLicenseKey(String idOne, String idTwo, String idThree) {
		if (!Profile.sObjectType.getDescribe().isAccessible()) { 
			throw new SelectorException('Permission to access an ' + Profile.sObjectType.getDescribe().getName() + ' denied.'); 
		} 
	
		if (!UserLicense.sObjectType.getDescribe().isAccessible()) { 
			throw new SelectorException('Permission to access an ' + UserLicense.sObjectType.getDescribe().getName() + ' denied.'); 
		} 
	
		if (!Schema.sObjectType.UserLicense.fields.LicenseDefinitionKey.isAccessible()) { 
			throw new SelectorException('Permission to access field ' + Schema.sObjectType.UserLicense.fields.LicenseDefinitionKey.getName() + ' on ' 
				+ UserLicense.sObjectType.getDescribe().getName() + ' denied.'); 
		} 

		String queryString = String.format('SELECT COUNT() FROM {0} WHERE Profile.UserLicense.LicenseDefinitionKey IN (:idOne, :idTwo, :idThree)', 
			new List<String> { GetSObjectName() });
		return Database.countQuery(queryString);
	}
}