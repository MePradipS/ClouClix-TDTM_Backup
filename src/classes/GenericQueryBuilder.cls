public with sharing class GenericQueryBuilder {

	public List<sObject> ListQueryBuilderWhere(String sObjectType, String commaDelimitedFields, String whereClause)
	{
	    SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
	    Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();

	    List<String> accessibleFields = QueryIsAccessible(sObjectType, fields, commaDelimitedFields);

	    String soql = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + sObjectType + ' WHERE ' + whereClause;
	    return Database.query(soql);
	}

	public List<sObject> ListQueryBuilderClause(String sObjectType, String commaDelimitedFields, String endClause )
	{
			SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
			Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();

			List<String> accessibleFields = QueryIsAccessible(sObjectType, fields, commaDelimitedFields);

			String soql = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + sObjectType + endClause;
			return Database.query(soql);
	}

	public sObject ObjectQueryBuilderWhere(String sObjectType, String commaDelimitedFields, String whereClause)
	{
			SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
			Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();

			List<String> accessibleFields = QueryIsAccessible(sObjectType, fields, commaDelimitedFields);

			String soql = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + sObjectType + ' WHERE ' + whereClause;
			return Database.query(soql);
	}

	public sObject ObjectQueryBuilderClause(String sObjectType, String commaDelimitedFields, String endClause )
	{
			SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
			Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();

			List<String> accessibleFields = QueryIsAccessible(sObjectType, fields, commaDelimitedFields);

			String soql = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + sObjectType + endClause;
			return Database.query(soql);
	}

	public List<sObject> QueryBuilderWithSubQuery(SObjectType sObjectType, String commaDelimitedFields, String clause, SObjectType subQueryType, String subQueryField, String subCommaDelimitedFields, String subQueryClause)
	{
		String objectName = sObjectType.getDescribe().getName();
		String subQueryObjectName = subQueryType.getDescribe().getName();
		SObjectType schemaType = Schema.getGlobalDescribe().get(objectName);
		SObjectType subSchemaType = Schema.getGlobalDescribe().get(subQueryObjectName);
		
		Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
		Map<String, SObjectField> subFields = subSchemaType.getDescribe().fields.getMap();

		List<String> accessibleFields = QueryIsAccessible(objectName, fields, commaDelimitedFields);
		List<String> accessibleSubFields = QueryIsAccessible(subQueryObjectName, subFields, subCommaDelimitedFields);

		String soql = 'SELECT ' + String.join(accessibleFields, ',') + ', (SELECT ' + String.join(accessibleSubFields, ',') + ' FROM ' + subQueryField + subQueryClause + ') FROM ' + objectName + clause;
		return Database.query(soql);
	}

	public List<sObject> QueryBuilderWithSubQueryWithDate(String sObjectType, String commaDelimitedFields, String clause, String subQueryType, String subQueryField, String subCommaDelimitedFields, String subQueryClause, Datetime dateTimeVal)
	{
			SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
			SObjectType subSchemaType = Schema.getGlobalDescribe().get(subQueryType);

			Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
			Map<String, SObjectField> subFields = subSchemaType.getDescribe().fields.getMap();

			List<String> accessibleFields = QueryIsAccessible(sObjectType, fields, commaDelimitedFields);
			List<String> accessibleSubFields = QueryIsAccessible(subQueryType, subFields, subCommaDelimitedFields);

			String soql = 'SELECT ' + String.join(accessibleFields, ',') + ', (SELECT ' + String.join(accessibleSubFields, ',') + ' FROM ' + subQueryField + subQueryClause + ') FROM ' + sObjectType + clause;
			return Database.query(soql);
	}

	public List<AggregateResult> AggregateListQueryBuilderWhere(String sObjectType, String commaDelimitedFields, String whereClause)
	{
			SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
			Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();

			List<String> accessibleFields = QueryIsAccessible(sObjectType, fields, commaDelimitedFields);

			String soql = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + sObjectType + ' WHERE ' + whereClause;
			return Database.query(soql);
	}

	public Database.queryLocator getQueryLocator(String clause, string commaDelimitedFields, string sObjectType)
	{
			SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
			Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
			List<String> accessibleFields = QueryIsAccessible(sObjectType, fields, commaDelimitedFields);

			string query = 'SELECT ' + String.join(accessibleFields, ',') + ' FROM ' + sObjectType + ' ' + clause;

			return Database.getQueryLocator(query);
	}

	public Database.queryLocator getQueryLocatorWithSubQuery(String clause, string commaDelimitedFields, string sObjectType, string subQueryFields, string subQueryType, string subVariableType, String subQueryClause)
	{
			SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
			Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
			List<String> accessibleFields = QueryIsAccessible(sObjectType, fields, commaDelimitedFields);

			SObjectType subSchemaType = Schema.getGlobalDescribe().get(subQueryType);
			Map<String, SObjectField> subFields = subSchemaType.getDescribe().fields.getMap();
			List<String> accessibleSubFields = QueryIsAccessible(subQueryType, subFields, subQueryFields);

			string query = 'SELECT ' + String.join(accessibleFields, ',') + ', (SELECT ' + String.join(accessibleSubFields, ',') + ' FROM ' + subVariableType + subQueryClause + ') FROM ' + sObjectType + clause;

			return Database.getQueryLocator(query);
	}

	public List<String> QueryIsAccessible(String sObjectType, Map<String, SObjectField> fields, String commaDelimitedFields)
	{
			List<String> accessibleFields = new List<String>();
			for (String field : commaDelimitedFields.split(',')){
				try{
					field = field.normalizeSpace();
					Schema.DescribeFieldResult desribeResult = fields.get(field).getDescribe();
					if (desribeResult.isAccessible())
					{
						accessibleFields.add(field.trim());
					}
				}catch(Exception ex){
					NoAccessException e = new NoAccessException();
					e.SetMessage('Cannot Access ' + field + ' in object ' + sObjectType);
					throw e;
				}
			}
			return accessibleFields;
	}
}