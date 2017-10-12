trigger UpdateVolunteerProfile on Volunteer_Application__c (after insert, after update) {
    VolunteerUtil.updateVolunteerProfile(Trigger.new);
}