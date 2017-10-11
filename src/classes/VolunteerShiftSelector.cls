public with sharing class VolunteerShiftSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Volunteer_Shift__c.Id, Volunteer_Shift__c.Name, Volunteer_Shift__c.Start_Time__c, Volunteer_Shift__c.End_Time__c,
			Volunteer_Shift__c.Day_of_the_Week__c, Volunteer_Shift__c.Duration_Hours__c, Volunteer_Shift__c.Frequency__c,
			Volunteer_Shift__c.Location_Address__c, Volunteer_Shift__c.Volunteer_Role__c, Volunteer_Shift__c.Volunteer__c  };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Volunteer_Shift__c.sObjectType;
	}

	public List<Volunteer_Shift__c> SelectByVolunteerRoleAndVolunteer(String volunteerRole, String volunteerId) {
		IsCustomAccessible(GetSObjectFieldList());

		String queryString = String.format('select {0} from {1} where CreatedDate != null and Volunteer_Role__c = :volunteerRole and (Volunteer__c = :volunteerId or Volunteer__c = \'\'\'\' or Volunteer__c = null)',
			new List<String> { GetFieldListString(), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Volunteer_Shift__c> SelectVolunteerRoleById(Set<Id> idSet) {
		List<Schema.SObjectField> customVolunteerShiftFieldList = new List<Schema.SObjectField> { Volunteer_Shift__c.Id, Volunteer_Shift__c.Volunteer_Role__c };
		IsCustomAccessible(customVolunteerShiftFieldList);

		String queryString = String.format('select {0} from {1} where Id in :idSet',
			new List<String> { GetFieldListString(customVolunteerShiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Volunteer_Shift__c> SelectVolunteerWhereRoleInIds(Set<String> Pids) {
		List<Schema.SObjectField> customVolunteerShiftFieldList = new List<Schema.SObjectField> { Volunteer_Shift__c.Id, Volunteer_Shift__c.Volunteer__c,
		Volunteer_Shift__c.Volunteer_Application__c, Volunteer_Shift__c.Volunteer_Role__c };
		IsCustomAccessible(customVolunteerShiftFieldList);

		String queryString = String.format('select {0} FROM {1} WHERE Volunteer_Role__c IN :Pids',
			new List<String> { GetFieldListString(customVolunteerShiftFieldList), GetSObjectName() });
        return Database.query(queryString);
	}

	public List<Volunteer_Shift__c> SelectVolunteerInfoByIdAndStatus(ID cId, String status) {
		List<Schema.SObjectField> customVolunteerShiftFieldList = new List<Schema.SObjectField> {
			Volunteer_Shift__c.Id, Volunteer_Shift__c.Name, Volunteer_Shift__c.Volunteer_Role__c, Volunteer_Shift__c.Shift_Date__c, Volunteer_Shift__c.Frequency__c, Volunteer_Shift__c.Duration_Hours__c };
		IsCustomAccessible(customVolunteerShiftFieldList);

		new VolunteerApplicationSelector().IsCustomAccessible(new List<Schema.SObjectField>{ Volunteer_Application__c.Volunteer__c, Volunteer_Application__c.Status__c});

		String queryString = String.format('select {0} FROM {1} WHERE Volunteer_Application__r.Volunteer__c = \':cId\' AND Volunteer_Application__r.Status__c = \':status\'',
			new List<String> { GetFieldListString(customVolunteerShiftFieldList), GetSObjectName() });
				return Database.query(queryString);
	}
}