public class CTDTM_sysLastTransUpdateTriggerHandler extends CTDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Gifts from trigger new. 
    * @param listOld the list of Gifts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Gifts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        CTDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == CTDTM_Runnable.Action.AfterInsert || triggerAction == CTDTM_Runnable.Action.AfterUpdate) 
        {
            BatchSettings__c settings = BatchSettings__c.getInstance('Default');
            
            set<Id> TriggerNewMapKeySet = new set<Id>();
            
            for(Gift__c objGift : (list<Gift__c>)listNew)
            {
                TriggerNewMapKeySet.add(objGift.Id);
            }

            if(settings != null && !settings.Data_Migration_Mode__c) 
            {
                if(!Validator_cls.isAlreadyModified())
                {
                    Validator_cls.setAlreadyModified();

                   //For RollUpName Trigger To avoid cycle
                   String guestId = '';
                   String inFields = Converter.ConvertListSetToString(TriggerNewMapKeySet);
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
                    List<Event_Registration__c> eventRegList = new EventRegistrationSelector().LastTransactionByGiftIdForUpdate(TriggerNewMapKeySet);
                    if(eventRegList.size() > 0)
                     {
                        for(Event_Registration__c eventReg: eventRegList)
                        {
                           eventReg.sysLastTransactionUpdate__c = system.today();
                           toUpdateEventReg.add(eventReg);
                        }
                        if(toUpdateEventReg.size() > 0) 
                        {
                            DMLManager.UpdateSObjects(toUpdateEventReg);
                        }
                    }
                }
            }
        }
        return null;
    }
}