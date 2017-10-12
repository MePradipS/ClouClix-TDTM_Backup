trigger SetTraining on Volunteer_Application__c (before insert) {
    Set<String> posIds = new Set<String>();  }