trigger sysLastTransUpdateGift on Gift__c (after insert, after update) {

     BatchSettings__c settings = BatchSettings__c.getInstance('Default');

     if(settings != null && !settings.Data_Migration_Mode__c) {
        if(!Validator_cls.isAlreadyModified()){
            Validator_cls.setAlreadyModified();

               //For RollUpName Trigger To avoid cycle
               String guestId = '';
               String inFields = Converter.ConvertListSetToString(trigger.newMap.keySet());
               String clause = ' WHERE Id IN ('+ inFields +')';
               String subClause = ' WHERE Individual__c != \'' + guestId + '\'';

               List<Gift__c> trans = new GenericQueryBuilder().QueryBuilderWithSubQuery(Gift__c.sObjectType, 'Id,'+ Utilities.PackageNamespace + 'Attendee_Names_Received__c', clause, Event_Registration__c.sObjectType, 'Event_Registrations__r', 'Id', subClause);

               if(trans.size() > 0)
               {
                   List<Gift__c> updateGift = new List<Gift__c>();
                     for (Gift__c g : trans)
                     {
                       if(g.Attendee_Names_Received__c != g.Event_Registrations__r.size())
                        {
                            g.Attendee_Names_Received__c = g.Event_Registrations__r.size();
                            updateGift.add(g);
                        }
                     }
                     if(updateGift.size() > 0) {
                         DMLManager.UpdateSObjects(updateGift);
                     }
                }

          //Systransc Update Logic
        List<Event_Registration__c> toUpdateEventReg = new List<Event_Registration__c>();
        List<Event_Registration__c> eventRegList = new EventRegistrationSelector().LastTransactionByGiftIdForUpdate(Trigger.newMap.keySet());
        if(eventRegList.size() > 0)
         {
            for(Event_Registration__c eventReg: eventRegList)
            {
               eventReg.sysLastTransactionUpdate__c = system.today();
               toUpdateEventReg.add(eventReg);
            }
            if(toUpdateEventReg.size() > 0) {
                DMLManager.UpdateSObjects(toUpdateEventReg);
            }
         }
        }
    }
}