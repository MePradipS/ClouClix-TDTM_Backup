public with sharing class LeadStatusSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			LeadStatus.Id, LeadStatus.MasterLabel, LeadStatus.IsConverted };
	}

	public override Schema.SObjectType GetSObjectType() {
		return LeadStatus.sObjectType;
	}

	public List<LeadStatus> SelectByIsConverted(Boolean isConverted, Integer recordLimit) {
		IsAccessible();

		String queryString = String.format('select {0} from {1} where IsConverted = :isConverted limit :recordLimit', new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}
}