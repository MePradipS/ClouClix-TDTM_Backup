public with sharing class hedAffiliationSelector extends SObjectSelector {
    public override List<Schema.SObjectField> GetSObjectFieldList() {
        return new List<Schema.SObjectField> { hed__Affiliation__c.Id, hed__Affiliation__c.Name, 
        	hed__Affiliation__c.Hed__Description__c, hed__Affiliation__c.Hed__Role__c };
    }
    public override Schema.SObjectType GetSObjectType() {
        return hed__Affiliation__c.sObjectType;
    }
    public List<hed__Affiliation__c> SelectAffiliationInfoByOrgId(String[] orgIds, String extraClause) {
        List<Schema.SObjectField> affiliationFieldList = new List<Schema.SObjectField> {
            hed__Affiliation__c.Id, hed__Affiliation__c.Name, hed__Affiliation__c.Hed__Description__c, hed__Affiliation__c.Hed__Role__c, hed__Affiliation__c.Hed__Account__c };
        IsCustomAccessible(affiliationFieldList);
        new ContactSelector().isAccessible();
        String queryString = String.format('SELECT id, name, hed__Contact__r.id, hed__Contact__r.name, hed__Contact__r.firstname, hed__Contact__r.lastname, hed__Description__c, hed__Role__c FROM {1} WHERE hed__Account__c in :orgIds',
            new List<String> { GetFieldListString(affiliationFieldList), GetSObjectName() });
                return Database.query(queryString);
    }


    public List<hed__Affiliation__c> SelectAffiliationWhereContactInId(Set<id> contactIds) {
        List<Schema.SObjectField> affiliationFieldList = new List<Schema.SObjectField> { hed__Affiliation__c.Id, hed__Affiliation__c.HED__Contact__c, 
        		hed__Affiliation__c.HED__Account__c, hed__Affiliation__c.HED__Role__c, hed__Affiliation__c.Apply_Soft_Credit__c  };
        IsCustomAccessible(affiliationFieldList);
        new ContactSelector().isAccessible();
        String queryString = String.format('SELECT {0} FROM {1} WHERE hed__Contact__c IN :contactIds AND Apply_Soft_Credit__c=true',
            new List<String> { GetFieldListString(affiliationFieldList), GetSObjectName() });
                return Database.query(queryString);
    }

    public List<hed__Affiliation__c> SelectAffiliationWhereAccountInId(Set<id> contactIds) {
        List<Schema.SObjectField> affiliationFieldList = new List<Schema.SObjectField> { hed__Affiliation__c.Id, hed__Affiliation__c.HED__Contact__c, 
        		hed__Affiliation__c.HED__Account__c, hed__Affiliation__c.HED__Role__c, hed__Affiliation__c.Apply_Soft_Credit__c  };
        IsCustomAccessible(affiliationFieldList);
        new ContactSelector().isAccessible();
        String queryString = String.format('SELECT {0} FROM {1} WHERE hed__Account__c IN :contactIds AND Apply_Soft_Credit__c=true AND hed__Contact__c !=null',
            new List<String> { GetFieldListString(affiliationFieldList), GetSObjectName() });
                return Database.query(queryString);
    }
}