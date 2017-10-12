public with sharing class RecordTypeSelector {
	public List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			RecordType.Id, RecordType.Name, RecordType.SobjectType };
	}

	public String GetSObjectType() {
		return 'RecordType';
	}

	public void IsAccessible() {
        IsCustomAccessible(currentSObjectFieldList);
    }

    public void IsCustomAccessible(List<Schema.SObjectField> customSObjectFieldList) {
        IsRelatedSObjectAccessible(RecordType.sObjectType.getDescribe(), customSObjectFieldList);
    }

    public void IsRelatedSObjectAccessible(Schema.DescribeFieldResult relatedSObjectType, List<Schema.SObjectField> relatedFieldsList) {
        if(!relatedSObjectType.isAccessible()) {
            throw new SelectorException('Permission to access an ' + relatedSObjectType.getName() + ' denied.');
        }

        for (Schema.SObjectField objectField : relatedFieldsList) {
            if (!objectField.getDescribe().isAccessible()) {
                throw new SelectorException('Permission to access field ' + objectField.getDescribe().getName() + ' on '
                    + relatedSObjectType.getName() + ' denied.');
            }
        }
    }

	private List<Schema.SObjectField> currentSObjectFieldList {
		get {
			if (currentSObjectFieldList == null) {
				currentSObjectFieldList = GetSObjectFieldList();
			}
			return currentSObjectFieldList;
		}
		set;
	}

	public List<RecordType> SelectBySObject(String sObjectType) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where SobjectType = :sObjectType',
			new List<String> { GetFieldListString(), GetSObjectType() });
        return Database.query(queryString);
    }

	public List<SObject> SelectBySObjectAndNamespace(String sObjectType) {
		IsAccessible();

		String namespace = Utilities.getCurrentNamespace();

		String queryString = String.format('select {0} from {1} where SobjectType = :sObjectType and NamespacePrefix = :namespace',
			new List<String> { GetFieldListString(), GetSObjectType() });
        return Database.query(queryString);
    }

	public List<SObject> SelectBySObjectAndName(String sObjectType, String recordTypeName) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where SobjectType = :sObjectType and Name = :recordTypeName',
			new List<String> { GetFieldListString(), GetSObjectType() });
        return Database.query(queryString);
    }

	public List<RecordType> SelectRecordTypeBySObjectAndName(String sObjectType, String recordTypeName) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where SobjectType = :sObjectType and Name = :recordTypeName',
			new List<String> { GetFieldListString(), GetSObjectType() });
				return Database.query(queryString);
		}

	public List<SObject> SelectBySObjectNameAndIsActive(String sObjectType, String recordTypeName, Boolean active) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where SobjectType = :sObjectType and Name = :recordTypeName and isActive = :active',
			new List<String> { GetFieldListString(), GetSObjectType() });
        return Database.query(queryString);
    }

	public List<SObject> SelectByAccountSObjectAndIsActive(String sObjectType, Boolean active) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where SobjectType = :sObjectType and isActive = :active',
			new List<String> { GetFieldListString(), GetSObjectType() });
				return Database.query(queryString);
	}

	public List<SObject> SelectByNameSpaceObjectTypeAndIsActive(String sObjectType, String nameSpacePrefix, Boolean active) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where sObjectType = \'\':sObjectType\'\' AND isActive = :active AND NamespacePrefix = \'\':nameSpacePrefix\'\'',
			new List<String> { GetFieldListString(), GetSObjectType() });
				return Database.query(queryString);
	}

	public List<SObject> SelectByNameAndLimit(List<String> nameList, Integer recordLimit) {
		IsAccessible();

		String nameClause = '';
		for (String name : nameList) {
			nameClause = String.isEmpty(nameClause) ? ('where Name = \'' + name + '\'') : ( nameClause + ' or Name = \'' + name + '\'');
		}
		String queryString = String.format('select {0} from {1} {2} limit :recordLimit',
			new List<String> { GetFieldListString(), GetSObjectType(), nameClause });
        return Database.query(queryString);
    }

	public List<RecordType> SelectByNames(List<String> nameList) {
		IsAccessible();

		String nameClause = '';
		for (String name : nameList) {
			nameClause = String.isEmpty(nameClause) ? ('where Name = \'' + name + '\'') : ( nameClause + ' or Name = \'' + name + '\'');
		}
		String queryString = String.format('select {0} from {1} {2}',
			new List<String> { GetFieldListString(), GetSObjectType(), nameClause });
        return Database.query(queryString);
    }

	public List<RecordType> SelectGiftSObjectByNotName(String sObjectType, List<String> nameList) {
		IsAccessible();

		String nameClause = '';
		for (String name : nameList) {
			nameClause += ('and Name != \'' + name + '\' ');
		}
		String namespace = Utilities.getCurrentNamespace();
		String queryString = String.format('select {0} from {1} where SobjectType = :sObjectType {2} and NamespacePrefix = :namespace',
			new List<String> { GetFieldListString(), GetSObjectType(), nameClause });
        return Database.query(queryString);
    }

	private String GetFieldListString() {
		List<String> stringFieldList = new List<String>();
		for (Schema.SObjectField objectField : currentSObjectFieldList) {
			String fieldName = objectField.getDescribe().getName();
			stringFieldList.add(fieldName);
		}
		return String.join(stringFieldList, ',');
	}

	public String GetFieldListString(List<Schema.SObjectField> customSObjectFieldList) {
		List<String> stringFieldList = new List<String>();
		for (Schema.SObjectField objectField : customSObjectFieldList) {
			String fieldName = objectField.getDescribe().getName();
			stringFieldList.add(fieldName);
		}
		return String.join(stringFieldList, ',');
	}

	public RecordType SelectByNameNamespacePrefixAndSObjectType(String currentNamespace) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Name =\'Appeal\' AND NamespacePrefix = :currentNamespace AND sObjectType = \'Campaign\' LIMIT 1',
			new List<String> { GetFieldListString(), GetSObjectType() });
        return Database.query(queryString);
    }

	public RecordType SelectByNameNamespacePrefixAndName(String currentNamespace, String name) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Name = :name AND NamespacePrefix = :currentNamespace LIMIT 1',
			new List<String> { GetFieldListString(), GetSObjectType() });
        return Database.query(queryString);
    }

	public List<RecordType> SelectRecordByRecordId(String recordTypeId) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Id = :recordTypeId',
			new List<String> { GetFieldListString(), GetSObjectType() });
		return Database.query(queryString);
    }

	public List<RecordType> SelectBysObjectNameAndRecordTypeName(String sObjectName, String recordTypeName ) {
		IsAccessible();

		String queryString = String.format('SELECT {0} FROM {1} WHERE SobjectType = :sObjectName AND Name = :recordTypeName LIMIT 1',
			new List<String> { GetFieldListString(), GetSObjectType() });
        return Database.query(queryString);
    }

	public List<RecordType> SelectByObjectTypeAndNameSpace(String sObjectName, String nameSpace ) {
		IsAccessible();

		String queryString = String.format('SELECT {0} FROM {1} WHERE SobjectType = :sObjectName AND NamespacePrefix = :nameSpace',
			new List<String> { GetFieldListString(), GetSObjectType() });
				return Database.query(queryString);
	}

    public RecordType SelectRecordBySObjectTypeName(String sObjectName ) {
		List<Schema.SObjectField> recordTypeFieldList = new List<Schema.SObjectField> { RecordType.Id, RecordType.Name, RecordType.SobjectType,
		 RecordType.Description, RecordType.DeveloperName, RecordType.NamespacePrefix};
		IsCustomAccessible(recordTypeFieldList);

		String queryString = String.format('select {0} from {1} where SobjectType = :sObjectName',
			new List<String> { GetFieldListString(recordTypeFieldList), GetSObjectType() });
        return Database.query(queryString);
    }

	public List<RecordType> SelectRecordByNamePrefixNameAndSobjectType(String sObjectName, String recordTypeName, String namespacePrefix ) {
		IsAccessible();

	String queryString = String.format('SELECT {0} FROM {1} WHERE SobjectType = \':sObjectName\' AND Name = \':recordTypeName\' AND NamespacePrefix = \':namespacePrefix\'',
		new List<String> { GetFieldListString(), GetSObjectType() });
			return Database.query(queryString);
	}

	public List<RecordType> SelectRecordByNamePrefixNameAndSobjectTypeLimit(String sObjectName, String recordTypeName, String namespacePrefix ) {
		IsAccessible();

	String queryString = String.format('SELECT {0} FROM {1} WHERE SobjectType = \':sObjectName\' AND Name = \':recordTypeName\' AND NamespacePrefix = \':namespacePrefix\' LIMIT 1',
		new List<String> { GetFieldListString(), GetSObjectType() });
			return Database.query(queryString);
	}

    public List<RecordType> SelectRecordBySObjectAndNamespace(String sObjectType, String namespace) {
		List<Schema.SObjectField> recordTypeFieldList = new List<Schema.SObjectField> { RecordType.Id, RecordType.Name, RecordType.sObjectType,
		RecordType.NamespacePrefix };
		IsCustomAccessible(recordTypeFieldList);

		String queryString = String.format('select {0} from {1} where SobjectType = :sObjectType and NamespacePrefix = :namespace',
			new List<String> { GetFieldListString(recordTypeFieldList), GetSObjectType() });
        return Database.query(queryString);
    }

    public List<RecordType> SelectRecordsByNameNamespacePrefixAndName(String currentNamespace, String name) {
		List<Schema.SObjectField> recordTypeFieldList = new List<Schema.SObjectField> { RecordType.Id, RecordType.Name, RecordType.sObjectType,
		RecordType.NamespacePrefix };
		IsCustomAccessible(recordTypeFieldList);

		String queryString = String.format('select {0} from {1} where Name = :name AND NamespacePrefix = :currentNamespace LIMIT 1',
			new List<String> { GetFieldListString(recordTypeFieldList), GetSObjectType() });
        return Database.query(queryString);
    }

    public List<RecordType> SelectRecordsByMultipleNamesNamespacePrefixAndName(String nameA, String nameB, String nameC, String sObjectType,String currentNamespace) {
		List<Schema.SObjectField> recordTypeFieldList = new List<Schema.SObjectField> { RecordType.Id, RecordType.Name, RecordType.sObjectType,
		RecordType.NamespacePrefix };
		IsCustomAccessible(recordTypeFieldList);

		String queryString = String.format('Select {0} From {1} where ((Name = :nameA OR  Name = :nameB OR Name = :nameC) AND SobjectType = :sObjectType AND NamespacePrefix = :currentNamespace)',
			new List<String> { GetFieldListString(recordTypeFieldList), GetSObjectType() });
        return Database.query(queryString);
    }

    public List<RecordType> SelectRecordsByMultipleNamesAndNamespacePrefix(String nameA, String nameB, String nameC, String nameD, String nameE, String nameF, String nameG, String currentNamespace) {
		List<Schema.SObjectField> recordTypeFieldList = new List<Schema.SObjectField> { RecordType.Id, RecordType.Name, RecordType.NamespacePrefix };
		IsCustomAccessible(recordTypeFieldList);

		String queryString = String.format('Select {0} From {1} where (Name = :nameA OR Name = :nameB OR Name = :nameC OR Name = :nameD OR Name = :nameE OR Name = :nameF OR Name = :nameG) AND NamespacePrefix = :currentNamespace',
			new List<String> { GetFieldListString(recordTypeFieldList), GetSObjectType() });
        return Database.query(queryString);
    }

    public List<RecordType> SelectBySpecificNameNamespacePrefixAndSObjectType(String name, String namespace, string objectType) {
		List<Schema.SObjectField> recordTypeFieldList = new List<Schema.SObjectField> {
			RecordType.Id, RecordType.Name, RecordType.NamespacePrefix, RecordType.sObjectType };
        IsCustomAccessible(recordTypeFieldList);

		String queryString = String.format('Select {0} From {1} where Name =:name AND NamespacePrefix = :namespace AND sObjectType= :objectType',
			new List<String> { GetFieldListString(recordTypeFieldList), GetSObjectType() });
        return Database.query(queryString);
    }

    public List<RecordType> SelectRecordBySObjectTypeNameAndNamespacePrefix(String SetNamespacePrefix ) {
		List<Schema.SObjectField> recordTypeFieldList = new List<Schema.SObjectField> { RecordType.Id, RecordType.Name,
		 RecordType.NamespacePrefix };
		IsCustomAccessible(recordTypeFieldList);

		String queryString = String.format('SELECT {0} FROM {1} WHERE SobjectType=\'\'Campaign\'\' AND Name =\'\'Campaign\'\' AND NamespacePrefix = :SetNamespacePrefix',
			new List<String> { GetFieldListString(recordTypeFieldList), GetSObjectType() });
        return Database.query(queryString);
    }

    public List<RecordType> SelectByNameNamespacePrefixAndNameNoLimit(String currentNamespace, String name) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Name = :name AND NamespacePrefix = :currentNamespace',
			new List<String> { GetFieldListString(), GetSObjectType() });
        return Database.query(queryString);
    }

	public List<RecordType> SelectByTwoNamesAndPrefix(String name1, String name2, string namespacePrefix ) {
		IsAccessible();

		String queryString = String.format('SELECT {0} FROM {1} WHERE (Name = \':name1\' OR Name = \':name2\') AND NamespacePrefix = \':namespacePrefix\'',
			new List<String> { GetFieldListString(), GetSObjectType() });
				return Database.query(queryString);
	}

	public List<RecordType> SelectByThreeNamesPrefixAndType(String name1, String name2, String name3, string namespacePrefix, string sObjectType ) {
		IsAccessible();

		String queryString = String.format('SELECT {0} FROM {1} WHERE (Name = \':name1\' OR Name = \':name2\' OR Name = \':name3\') AND SobjectType =\':sObjectType\' AND NamespacePrefix = \':namespacePrefix\'',
			new List<String> { GetFieldListString(), GetSObjectType() });
				return Database.query(queryString);
	}

	public List<RecordType> SelectByTwoNamesPrefixAndType(String name1, String name2, string namespacePrefix, string sObjectName) {
		IsAccessible();

		String queryString = String.format('SELECT {0} FROM {1} WHERE (Name = \':name1\' OR Name = \':name2\') AND NamespacePrefix = \':namespacePrefix\' AND sObjectType = \':sObjectName\'',
			new List<String> { GetFieldListString(), GetSObjectType() });
				return Database.query(queryString);
	}

	public List<RecordType> SelectListByNameNamespacePrefix(String currentNamespace, String name) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Name = :name AND NamespacePrefix = :currentNamespace',
			new List<String> { GetFieldListString(), GetSObjectType() });
				return Database.query(queryString);
	}

	public List<RecordType> SelectByNameNamespacePrefixAndNameLimitList(String currentNamespace, String name) {
		List<Schema.SObjectField> recordTypeFieldList = new List<Schema.SObjectField> { RecordType.Id, RecordType.Name, RecordType.NamespacePrefix};
		IsCustomAccessible(recordTypeFieldList);

		String queryString = String.format('select Name, Id from {0} where Name = :name AND NamespacePrefix = :currentNamespace LIMIT 1',
			new List<String> { GetSObjectType() });
				return Database.query(queryString);
	}

	public class SelectorException extends Exception { }
}