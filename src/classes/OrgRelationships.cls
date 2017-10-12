public class OrgRelationships {

    public OrgRelationships() {
    }

    public OrgRelationships( Organization_Relationship__c[] Relationships,  Organization_Relationship__c[] oldRelationships, Integer ta) {

        List< Organization_Relationship__c> origrelationships = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToCreate = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToUpdate = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToDelete = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> reciprocalsToUpdate = new List< Organization_Relationship__c>();

        Integer i = 0; // processing counter

        for ( Organization_Relationship__c r : Relationships) {
            // AFTER INSERT
            if (ta == 3) {
                if (r.Reciprocal_Organization_Relationship__c == null) {
                    relationshipsToCreate.add(r);
                }
                if (r.Reciprocal_Organization_Relationship__c != null) {
                    reciprocalsToUpdate.add(r);
                }
            }

            // AFTER UPDATE
            if (ta == 4) {
                if (r.Reciprocal_Organization_Relationship__c == oldRelationships[i].Reciprocal_Organization_Relationship__c && r.Related_Account__c != null) {
                    relationshipsToUpdate.add(r);
                    origRelationships.add(oldRelationships[i]);
                }
                if (r.Related_Account__c == null) {
                    relationshipsToDelete.add(r);
                }
            }

            // AFTER DELETE
            if (ta == 5) {
                if (r.Reciprocal_Organization_Relationship__c != null) {
                    relationshipsToDelete.add(r);
                }
            }

            i += 1;
        }

        if (relationshipsToCreate.size() > 0 ) {
            createRelationship(relationshipsToCreate);
        }

        if (relationshipsToUpdate.size() > 0 ) {
            updateRelationship(relationshipsToUpdate, origRelationships);
        }

        if (reciprocalsToUpdate.size() > 0 ) {
            reciprocate(reciprocalsToUpdate);
        }

        if (relationshipsToUpdate.size() > 0 ) {
            updateRelationship(relationshipsToUpdate, origRelationships);
        }

        if (relationshipsToDelete.size() > 0 ) {
            deleteRelationship(relationshipsToDelete);
        }
    }

    public static void deleteRelationship( Organization_Relationship__c[] relationships) {
        List<Id> relationshipsToDelete = new List<Id>();
        for ( Organization_Relationship__c r : Relationships) {
            if (r.Reciprocal_Organization_Relationship__c != null) {
                relationshipsToDelete.add(r.Reciprocal_Organization_Relationship__c);
            } else if (r.Related_Account__c == null) {
                relationshipsToDelete.add(r.Id);
            }
        }

        if ( relationshipsToDelete.size() > 0 ) {
            DMLManager.DeleteIds(relationshipsToDelete, false);
        }
    }

    public static void deleteEmptyRelationships() {
        List<Organization_Relationship__c> relationshipsToDelete = new List< Organization_Relationship__c>();
        for (Organization_Relationship__c r : new OrganizationRelationshipSelector().SelectByRelatedAccount(null)) {
            relationshipsToDelete.add(r);
        }

        if (relationshipsToDelete.size() > 0) {
            DMLManager.DeleteSObjects(relationshipsToDelete, false);
        }
    }

    public static void reciprocate( Organization_Relationship__c[] Relationships) {
        List< Organization_Relationship__c> relationshipsToUpdate = new List< Organization_Relationship__c>();
        for ( Organization_Relationship__c r : Relationships) {
            Organization_Relationship__c copy = new  Organization_Relationship__c(Id = r.Reciprocal_Organization_Relationship__c, Reciprocal_Organization_Relationship__c = r.Id);
            relationshipsToUpdate.add(copy);
        }

        DMLManager.UpdateSObjects(relationshipsToUpdate);
    }

    public static void createRelationship( Organization_Relationship__c[] Relationships) {
        List< Organization_Relationship__c> relationshipsToCreate = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToUpdate = new List< Organization_Relationship__c>();
        for ( Organization_Relationship__c r : Relationships) {
            Organization_Relationship__c copy = new  Organization_Relationship__c();
            copy.Account__c = r.Related_Account__c;
            copy.Related_Account__c = r.Account__c;
            copy.Status__c = r.Status__c;
            copy.Type__c = r.Type__c;
            copy.Reciprocal_Organization_Relationship__c = r.Id;
            copy.Description__c = r.Description__c;
            relationshipsToCreate.add(copy);
        }

        DMLManager.InsertSObjects(relationshipsToCreate);
    }

    public static void updateRelationship( Organization_Relationship__c[] Relationships,  Organization_Relationship__c[] oldRelationships) {
        List< Organization_Relationship__c> relationshipsToCreate = new List< Organization_Relationship__c>();
        List< Organization_Relationship__c> relationshipsToUpdate = new List< Organization_Relationship__c>();
        Integer counter = 0;

        for ( Organization_Relationship__c r : Relationships) {
            if ((r.Status__c != oldRelationships[counter].Status__c || r.Type__c != oldRelationships[counter].Type__c || r.Description__c != oldRelationships[counter].Description__c) && r.Reciprocal_Organization_Relationship__c != null) {
                Organization_Relationship__c copy = new  Organization_Relationship__c(Id = r.Reciprocal_Organization_Relationship__c);

                if (oldRelationships[counter].Related_Account__c != r.Related_Account__c) {
                    copy.Account__c = r.Related_Account__c;
                }

                copy.Status__c = r.Status__c;
                copy.Type__c = r.Type__c;
                copy.Description__c = r.Description__c;
                relationshipsToUpdate.add(copy);
            }
            counter += 1;
        }

        if (relationshipsToUpdate != null && relationshipsToUpdate.size() > 0) {
            DMLManager.UpdateSObjects(relationshipsToUpdate);
        }
    }

    static testMethod void Relationships_Test() {
        OrgRelationships testRelationships = new OrgRelationships();
    }

    static testMethod void createRelationship_Test() {
        Account con = new Account(Name = 'test');
        DMLManager.InsertSObject(con);

        Account con2 = new Account(Name = 'Contact2');
        DMLManager.InsertSObject(con2);

        Organization_Relationship__c r = new  Organization_Relationship__c();
        r.Account__c = con.Id;
        r.Related_Account__c = con2.Id;
        r.Status__c = 'Test';
        r.Type__c = 'Test';
        r.Description__c = 'Test Description';
        DMLManager.InsertSObject(r);

        Organization_Relationship__c[] rList = new OrganizationRelationshipSelector().SelectSObjectsById(new Set<Id> { r.Id });
        System.assert(rList.size() > 0);
        Organization_Relationship__c r2 = rList[0];
        r2.Status__c = 'Test2';

        DMLManager.UpdateSObject(r2);
    }

    static testMethod void deleteRelationship_Test() {
        Account con = new Account(Name = 'contact');
        DMLManager.InsertSObject(con);

        Account con2 = new Account(Name = 'Contact2');
        DMLManager.InsertSObject(con2);

        Organization_Relationship__c r = new  Organization_Relationship__c();
        r.Account__c = con.Id;
        r.Related_Account__c = con2.Id;
        r.Status__c = 'Test';
        r.Type__c = 'Test';
        r.Description__c = 'Test Description';
        DMLManager.InsertSObject(r);

        DMLManager.DeleteSObject(r);
    }

    static testMethod void deleteEmptyRelationships_Test() {
        Account con = new Account(Name = 'contact');
        DMLManager.InsertSObject(con);

        Account con2 = new Account(Name = 'Contact2');
        DMLManager.InsertSObject(con2);

        Organization_Relationship__c r = new  Organization_Relationship__c();
        r.Account__c = con.Id;
        r.Related_Account__c = con2.Id;
        r.Status__c = 'Test';
        r.Type__c = 'Test';
        r.Description__c = 'Test Description';
        DMLManager.InsertSObject(r);

        DMLManager.DeleteSObject(con2);
    }
}