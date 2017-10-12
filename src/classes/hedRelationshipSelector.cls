public with sharing class hedRelationshipSelector extends SObjectSelector {
    public override List<Schema.SObjectField> GetSObjectFieldList() {
        return new List<Schema.SObjectField> {
            hed__Relationship__c.hed__RelatedContact__c, hed__Relationship__c.Apply_Soft_Credit__c };
    }
    public override Schema.SObjectType GetSObjectType() {
        return hed__Relationship__c.sObjectType;
    }

    public List<hed__Relationship__c> SelectRelationshipWhereContactInIds(Set<id> contactIds) {
        List<Schema.SObjectField> relationshipFieldList = new List<Schema.SObjectField> { hed__Relationship__c.Id, hed__Relationship__c.HED__Contact__c, 
        		hed__Relationship__c.HED__RelatedContact__c, hed__Relationship__c.Apply_Soft_Credit__c };
        IsCustomAccessible(relationshipFieldList);
        new ContactSelector().isAccessible();
        String queryString = String.format('SELECT {0} FROM {1} WHERE hed__Contact__c IN :contactIds AND Apply_Soft_Credit__c=true AND hed__RelatedContact__c !=null',
            new List<String> { GetFieldListString(relationshipFieldList), GetSObjectName() });
        return Database.query(queryString);
    }
}