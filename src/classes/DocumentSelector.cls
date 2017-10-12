public with sharing class DocumentSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Document.Id, Document.Type, Document.ContentType, Document.BodyLength, Document.Body };
	}
	
	public override Schema.SObjectType GetSObjectType() {
		return Document.sObjectType;
	}


	public List<Document> SelectBySpecificName() {
		List<Schema.SObjectField> customDocumentFieldList = new List<Schema.SObjectField> { Document.Id, Document.Name, Document.BodyLength, Document.Body };
		IsCustomAccessible(customDocumentFieldList);

		String queryString = String.format('select {0} from {1} where Name = \'cv-log.txt\'',
			new List<String> { GetFieldListString(customDocumentFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}

	public List<Document> SelectUsingSpecificName(String searchName) {
		List<Schema.SObjectField> customDocumentFieldList = new List<Schema.SObjectField> { Document.Id, Document.Body };
		IsCustomAccessible(customDocumentFieldList);

		String queryString = String.format('select {0} from {1} where Name = :searchName',
			new List<String> { GetFieldListString(customDocumentFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}
}