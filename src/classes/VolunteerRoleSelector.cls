public with sharing class VolunteerRoleSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Volunteer_Role__c.Id, Volunteer_Role__c.Number_Of_Service_Hours_Involved__c, Volunteer_Role__c.Role_Locale__c,
			Volunteer_Role__c.Language__c, Volunteer_Role__c.Name, Volunteer_Role__c.Skills_Needed__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Volunteer_Role__c.sObjectType;
	}

	public List<Volunteer_Role__c> SelectRoleAndShiftById(Set<Id> idSet) {
		List<Schema.SObjectField> customVolunteerRoleFieldList = new List<Schema.SObjectField> {
			Volunteer_Role__c.Id, Volunteer_Role__c.Name, Volunteer_Role__c.Start_Date__c, Volunteer_Role__c.End_Date__c };
		List<Schema.SObjectField> volunteerShiftFieldList = new List<Schema.SObjectField> {
			Volunteer_Shift__c.Logged_Hours__c, Volunteer_Shift__c.Volunteer_Role__c, Volunteer_Shift__c.Start_Day__c, Volunteer_Shift__c.End_Day__c,
			Volunteer_Shift__c.Start_Time__c, Volunteer_Shift__c.End_Time__c, Volunteer_Shift__c.Location_Address__c, Volunteer_Shift__c.Location__c,
			Volunteer_Shift__c.Frequency__c, Volunteer_Shift__c.Shift_Date__c, Volunteer_Shift__c.Duration_Hours__c, Volunteer_Shift__c.Day_of_the_week__c };
		IsCustomAccessible(customVolunteerRoleFieldList);
		IsRelatedSObjectAccessible(new VolunteerShiftSelector().GetSObjectType(), volunteerShiftFieldList);

		String relatedQueryString = '(select Logged_Hours__c, Volunteer_Role__c, Start_Day__c, End_Day__c, Start_Time__c, End_Time__c, Location_Address__c, Location__c, Frequency__c, Shift_Date__c, Duration_Hours__c, Day_of_the_week__c from Volunteer_Position_Shifts__r order by Shift_Date__c desc)';
		String queryString = String.format('select {0}, {1} from {2} where Id in :idSet',
			new List<String> { GetFieldListString(customVolunteerRoleFieldList), relatedQueryString, GetSObjectName() });
        return Database.query(queryString);
	}
}