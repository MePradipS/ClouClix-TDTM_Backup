public with sharing class EmailTemplateSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			EmailTemplate.Id, EmailTemplate.Name, EmailTemplate.TemplateType, EmailTemplate.Markup };
	}

	public override Schema.SObjectType GetSObjectType() {
		return EmailTemplate.sObjectType;
	}

	public List<EmailTemplate> SelectByTemplateType(String templateType) {
		IsAccessible();
		
		String queryString = String.format('select {0} from {1} where TemplateType = :templateType', 
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<EmailTemplate> SelectByNameAndTemplateType(String name, String templateType) {
		IsAccessible();
		
		String queryString = String.format('select {0} from {1} where Name = :name and TemplateType = :templateType', 
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}
}