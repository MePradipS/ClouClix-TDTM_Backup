public with sharing class FolderSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Folder.Id, Folder.Type 
		};
	}

	public override Schema.SObjectType GetSObjectType() {
		return Folder.sObjectType;
	}

	public List<Folder> SelectByTypeAndLimit(String type, Integer recordLimit) {
		IsAccessible();
		
		String queryString = String.format('select {0} from {1} where Type = :type limit :recordLimit', 
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Folder> SelectBySpecificNameAndType() {
		List<Schema.SObjectField> customGiftFieldList = new List<Schema.SObjectField> { Folder.Id, Folder.Name, Folder.Type };
		IsCustomAccessible(customGiftFieldList);

		String queryString = String.format('SELECT {0} FROM {1} where Name = \'\'causeview\'\' AND Type = \'\'Document\'\' LIMIT 1',
			new List<String> { GetFieldListString(customGiftFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}
}