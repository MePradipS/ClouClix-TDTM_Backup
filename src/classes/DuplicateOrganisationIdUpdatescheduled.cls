global with sharing class DuplicateOrganisationIdUpdatescheduled implements Schedulable {
   global void execute(SchedulableContext sc) {
      DuplicateOrganisationIdUpdateBatch b = new DuplicateOrganisationIdUpdateBatch(); 
      database.executebatch(b);
   }
}