public with sharing class CampaignMemberSelector extends SObjectSelector { 
  public override List<Schema.SObjectField> GetSObjectFieldList() { 
    return new List<Schema.SObjectField> { 
      CampaignMember.CampaignId, CampaignMember.ContactId }; 
  } 
 
  public override Schema.SObjectType GetSObjectType() { 
    return CampaignMember.sObjectType; 
  } 
 
  public List<CampaignMember> SelectCampaignAndContactIdWhereIdInIds(Set<Id> contactIds, Set<Id> eventIds) { 
    List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {  
      CampaignMember.CampaignId, CampaignMember.ContactId }; 
    IsCustomAccessible(customCampaignFieldList); 
 
    String queryString = String.format('select {0} from {1} where ContactId in :contactIds and CampaignId in :eventIds',  
      new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() }); 
        return Database.query(queryString); 
  } 
 
  public List<CampaignMember> SelectCampaignAndContactIdWhereIdInIdsForUpdate(Set<Id> contactIds, Set<Id> eventIds) { 
    List<Schema.SObjectField> customCampaignFieldList = new List<Schema.SObjectField> {  
      CampaignMember.CampaignId, CampaignMember.ContactId }; 
    IsCustomAccessible(customCampaignFieldList); 
 
    String queryString = String.format('select {0} from {1} where ContactId in :contactIds and CampaignId in :eventIds for update',  
      new List<String> { GetFieldListString(customCampaignFieldList), GetSObjectName() }); 
        return Database.query(queryString); 
  } 
}