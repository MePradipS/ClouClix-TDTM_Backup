public abstract with sharing class SObjectSelector {
    // Implement this method to inform the base class of the SObject (custom or standard) to be queried
    public abstract Schema.SObjectType GetSObjectType();

    // Implement this method to inform the base class of the common fields to be queried or listed by the
	// base class methods
    public abstract List<Schema.SObjectField> GetSObjectFieldList();

	protected String PackageNamespace {
		get {
			if (PackageNamespace == null) {
				String namespace = Utilities.getCurrentNamespace();
      			PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
			}
			return PackageNamespace;
		}
		set;
	}

	private Schema.SObjectType currentSObjectType {
		get {
			if (currentSObjectType == null) {
				currentSObjectType = GetSObjectType();
			}
			return currentSObjectType;
		}
		set;
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

	private Schema.DescribeSObjectResult sObjectDescribe {
		get {
			if (sObjectDescribe == null) {
				sObjectDescribe = currentSObjectType.getDescribe();
			}
			return sObjectDescribe;
		}
		set;
	}

    public String GetSObjectName() {
        return sObjectDescribe.getName();
    }

	public List<SObject> SelectSObjects() {
		IsAccessible();

		String queryString = String.format('select {0} from {1}', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }

	public List<SObject> SelectSObjectsByLimit(Integer recordLimit) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} limit :recordLimit', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }

    public List<SObject> SelectSObjectsById(Set<Id> idSet) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Id in :idSet', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }

	public List<SObject> SelectSObjectsByName(String name) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Name = :name', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }

	public List<SObject> SelectSObjectsByNameLimit(String name, Integer recordLimit) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Name = :name limit :recordLimit', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }

	public List<SObject> SelectSObjectByIdLimit(Set<Id> idSet, Integer recordLimit) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Id in :idSet limit :recordLimit', new List<String> { GetFieldListString(), GetSObjectName() });
		return Database.query(queryString);
	}

	public List<SObject> SelectSObjectsByNameLimitForUpdate(String name, Integer recordLimit) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Name = :name limit :recordLimit for update',
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }

	public List<SObject> SelectSObjectsByIdForUpdate(Set<Id> idSet) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where Id in :idSet for update', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
    }

    public void IsAccessible() {
		IsCustomAccessible(currentSObjectFieldList);
    }

	public void IsCustomAccessible(List<Schema.SObjectField> customSObjectFieldList) {
		IsRelatedSObjectAccessible(currentSObjectType, customSObjectFieldList);
	}

	public void IsRelatedSObjectAccessible(Schema.SObjectType relatedSObjectType, List<Schema.SObjectField> relatedFieldsList) {
		if(!relatedSObjectType.getDescribe().isAccessible()) {
			throw new SelectorException('Permission to access an ' + relatedSObjectType.getDescribe().getName() + ' denied.');
		}

		for (Schema.SObjectField objectField : relatedFieldsList) {
			if (!objectField.getDescribe().isAccessible()) {
				throw new SelectorException('Permission to access field ' + objectField.getDescribe().getName() + ' on '
					+ relatedSObjectType.getDescribe().getName() + ' denied.');
			}
		}
	}

	public String GetFieldListString() {
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

	public String GetRelatedFieldListString(List<String> relatedFieldList) {
		return String.join(relatedFieldList, ',');
	}

	public class SelectorException extends Exception { }
}