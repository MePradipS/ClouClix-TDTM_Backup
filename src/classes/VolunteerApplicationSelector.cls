public with sharing class VolunteerApplicationSelector extends SObjectSelector {
	public override List<Schema.SObjectField> GetSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Volunteer_Application__c.Id, Volunteer_Application__c.Volunteer_Role__c, Volunteer_Application__c.Volunteer__c,
			Volunteer_Application__c.Volunteer_Availability__c };
	}

	public override Schema.SObjectType GetSObjectType() {
		return Volunteer_Application__c.sObjectType;
	}

	public List<Volunteer_Application__c> SelectVolunteerApplicationByContactId(String cId) {
		List<Schema.SObjectField> customVolunteerFieldList  = new List<Schema.SObjectField> {
			Volunteer_Application__c.Reference_Type3__c, Volunteer_Application__c.Emergency_Contact__c, Volunteer_Application__c.Id, Volunteer_Application__c.Reference_Type1__c,
			Volunteer_Application__c.Reference_Type2__c, Volunteer_Application__c.Reasons_for_Volunteering__c, Volunteer_Application__c.Currently_employed__c, Volunteer_Application__c.Title__c,
			Volunteer_Application__c.Description_of_Work__c, Volunteer_Application__c.Programs_Offered_by_Employer__c,Volunteer_Application__c.Name_of_Educational_Institution__c,
			Volunteer_Application__c.Do_you_have_a_criminal_record__c, Volunteer_Application__c.Will_you_submit_criminal_records_check__c, Volunteer_Application__c.Education_Level__c,
			Volunteer_Application__c.How_Did_You_Hear_About_Us__c, Volunteer_Application__c.Languages__c, Volunteer_Application__c.Professional_Skills__c,
			Volunteer_Application__c.Prefered_Locales__c, Volunteer_Application__c.Miles_Willing_to_Travel_One_Way__c, Volunteer_Application__c.Agree__c, Volunteer_Application__c.Agree2__c};
		IsCustomAccessible(customVolunteerFieldList );

		String queryString = String.format('SELECT {0} FROM {1} WHERE Volunteer__c = :cId AND RecordTypeId = \'\'012d0000000siPV\'\' ORDER BY LastModifiedDate DESC',
			new List<String> { GetFieldListString(customVolunteerFieldList), GetSObjectName() });
				return Database.query(queryString);
		}

		public List<Volunteer_Application__c> SelectVolunteerDetailsByContactId(String cId) {
			List<Schema.SObjectField> customVolunteerFieldList = new List<Schema.SObjectField> {
				Volunteer_Application__c.Volunteer_Role__c, Volunteer_Application__c.Emergency_Contact__c, Volunteer_Application__c.Id, Volunteer_Application__c.Reference_Type1__c,
				Volunteer_Application__c.Reference_Type2__c, Volunteer_Application__c.Reasons_for_Volunteering__c, Volunteer_Application__c.Currently_employed__c,
				Volunteer_Application__c.Title__c, Volunteer_Application__c.Description_of_Work__c, Volunteer_Application__c.Programs_Offered_by_Employer__c,
				Volunteer_Application__c.Name_of_Educational_Institution__c, Volunteer_Application__c.Do_you_have_a_criminal_record__c,
				Volunteer_Application__c.Will_you_submit_criminal_records_check__c, Volunteer_Application__c.Education_Level__c,
				Volunteer_Application__c.How_Did_You_Hear_About_Us__c,  Volunteer_Application__c.Languages__c,  Volunteer_Application__c.Professional_Skills__c,
				Volunteer_Application__c.Prefered_Locales__c, Volunteer_Application__c.Miles_Willing_to_Travel_One_Way__c, Volunteer_Application__c.Agree__c, Volunteer_Application__c.Agree2__c};
			IsCustomAccessible(customVolunteerFieldList);
			IsCustomAccessible(new List<Schema.SObjectField>{Volunteer_Application__c.Volunteer__c, Volunteer_Application__c.LastModifiedDate});

			String queryString = String.format('SELECT {0} FROM {1} WHERE Volunteer__c = :cId ORDER BY LastModifiedDate DESC',
				new List<String> { GetFieldListString(customVolunteerFieldList), GetSObjectName() });
					return Database.query(queryString);
			}

			public List<Volunteer_Application__c> SelectVolunteerApplicationInfo(Id cId, String status) {
				List<Schema.SObjectField> customVolunteerFieldList = new List<Schema.SObjectField> {
					Volunteer_Application__c.Volunteer_Role__c, Volunteer_Application__c.Emergency_Contact__c, Volunteer_Application__c.Id, Volunteer_Application__c.Reference_Type1__c, Volunteer_Application__c.Reference_Type2__c,
					Volunteer_Application__c.Reasons_for_Volunteering__c, Volunteer_Application__c.Currently_employed__c, Volunteer_Application__c.Title__c, Volunteer_Application__c.Description_of_Work__c,
					Volunteer_Application__c.Programs_Offered_by_Employer__c, Volunteer_Application__c.Name_of_Educational_Institution__c, Volunteer_Application__c.Do_you_have_a_criminal_record__c,
					Volunteer_Application__c.Will_you_submit_criminal_records_check__c, Volunteer_Application__c.Education_Level__c, Volunteer_Application__c.How_Did_You_Hear_About_Us__c, Volunteer_Application__c.Languages__c,
					Volunteer_Application__c.Professional_Skills__c, Volunteer_Application__c.Prefered_Locales__c, Volunteer_Application__c.Miles_Willing_to_Travel_One_Way__c, Volunteer_Application__c.Agree__c, Volunteer_Application__c.Agree2__c};
				IsCustomAccessible(customVolunteerFieldList);

				IsCustomAccessible(new List<Schema.SObjectField>{Volunteer_Application__c.Volunteer__c, Volunteer_Application__c.LastModifiedDate});
				new VolunteerOpportunitySelector().IsCustomAccessible(new List<Schema.SObjectField>{Volunteer_Opportunity__c.Program__c});
				new VolunteerRoleSelector().IsCustomAccessible(new List<Schema.SObjectField>{Volunteer_Role__c.Volunteer_Opportunity__c});

				String queryString = String.format('SELECT {0}, Volunteer_Role__r.Volunteer_Opportunity__r.Program__c FROM {1} WHERE Volunteer__c = \':cId\' AND Status__c = \':status\' ORDER BY LastModifiedDate DESC',
					new List<String> { GetFieldListString(customVolunteerFieldList), GetSObjectName() });
						return Database.query(queryString);
				}
}