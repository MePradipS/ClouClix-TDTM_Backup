public with sharing class EventSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Event.Id, Event.Type };
	}
	
	public override Schema.SObjectType GetSObjectType() {
		return Event.sObjectType;
	}

	public List<Event> SelectEventByWhoId(String contAccid) {
		List<Schema.SObjectField> customEventFieldList = new List<Schema.SObjectField> { Event.Id, Event.Type, Event.Subject,
			Event.WhoId, Event.CreatedDate };
		IsCustomAccessible(customEventFieldList);

		String queryString = String.format('select {0} from {1} where WhoId =:contAccid order by CreatedDate DESC limit 5',
			new List<String> { GetFieldListString(customEventFieldList), GetSObjectName() });
	    return Database.query(queryString);
	}

}