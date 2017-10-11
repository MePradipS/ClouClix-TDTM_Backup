public with sharing class TaskSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Task.id, Task.Type, Task.WhoId};
	}

	public override Schema.SObjectType GetSObjectType() {
		return Task.sObjectType;
	}

	public AggregateResult[] SelectTaskByIds(Set<id> individualIds){
		List<Schema.SObjectField> taskFieldList = new List<Schema.SObjectField> {Task.Type, Task.WhoId};
        IsCustomAccessible(taskFieldList);

		String queryString = String.format('SELECT COUNT(Id) cnt, {0} FROM {1} WHERE WhoId IN :individualIds AND Type!=null AND IsClosed=true AND ActivityDate = THIS_FISCAL_YEAR GROUP BY WhoId,Type',
			new List<String> { GetFieldListString(taskFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Task> SelectTaskByIdOrderByCreatedDate(String contAccid){
		List<Schema.SObjectField> customTaskFieldList = new List<Schema.SObjectField> { Task.id, Task.Priority, Task.Subject, Task.WhoId,
			Task.CreatedDate, Task.Type, Task.ActivityDate };
		IsCustomAccessible(customTaskFieldList);


		String queryString = String.format('select {0} from {1} where WhoId =:contAccid order by CreatedDate DESC limit 5',
			new List<String> { GetFieldListString(customTaskFieldList), GetSObjectName() });
				return Database.query(queryString);
	}

	public List<Task> SelectTaskByAccountIdOrderByCreatedDate(String contAccid){
		List<Schema.SObjectField> customTaskFieldList = new List<Schema.SObjectField> { Task.id, Task.Priority, Task.Subject, Task.WhoId,
			Task.CreatedDate, Task.Type, Task.ActivityDate };
		IsCustomAccessible(customTaskFieldList);


		String queryString = String.format('select {0} from {1} where AccountId =:contAccid order by CreatedDate DESC limit 5',
			new List<String> { GetFieldListString(customTaskFieldList), GetSObjectName() });
				return Database.query(queryString);
	}
}