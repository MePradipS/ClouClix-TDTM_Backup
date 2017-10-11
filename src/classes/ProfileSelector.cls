public with sharing class ProfileSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Profile.Id, Profile.Name };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Profile.sObjectType;
	}

	public Profile SelectIdByName(String profileName) {
 		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Profile.id };
 		IsCustomAccessible(customGiftFieldList);

		IsCustomAccessible(new List<Schema.SObjectField> { Profile.Name });

 		String queryString = String.format('select {0} from {1} where name = :profileName',
 			new List<String> { GetFieldListString(GetSObjectFieldList()), GetSObjectName() });
         return Database.query(queryString);
 	}
}