public class ContactTriggerHandler1 extends TDTM_Runnable 
{
    /*******************************************************************************************************
    * @param listNew the list of Contacts from trigger new. 
    * @param listOld the list of Contacts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Contacts 
    * @return dmlWrapper.  always null.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        if (triggerAction == TDTM_Runnable.Action.BeforeInsert) 
        {
            OrgContactHandler.CreateHouseholdupdate(listNew);
            OrgContactHandler.AutoNumber(listNew, 'Contact');
        }
        if (triggerAction == TDTM_Runnable.Action.BeforeUpdate)
        {
            // OrgContactHandler.PreventGuestModify(Trigger.old, Trigger.new);
            OrgContactHandler.CreateHouseholdupdate(listNew);
            OrgContactHandler.AutoNumber(listNew, 'Contact');
        }
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate)
        {
            App_Settings__c appSetting = App_Settings__c.getInstance();
            if (appSetting.Other_Address_Trigger_Setting__c) {
                OrgContactHandler.LegacyAddress(listOld, listNew, 'Contact');
            }
            
            if (appSetting.Other_Address_Trigger_Setting__c  ) { //story:#106969638
                OrgContactHandler.LegacyAddressOfHousehold(Trigger.new);
            }
            
            /*//Create a set for GAD Ids
            Set<id> GADDonorIds = new Set<id>();
            //Create List of GADs To be updated
            List<Gift_Aid_Declaration__c> GADsToUpdate = new List<Gift_Aid_Declaration__c>();

            //Query all GAD with contact ids included and put them into a Set
            Set<Gift_Aid_Declaration__c> donorsGADs = new Set<Gift_Aid_Declaration__c>(new GiftAidDeclarationSelector().SelectGADsById(Trigger.new));

            //Apply the Donor__c Ids to the set of contact Ids
            for (Gift_Aid_Declaration__c GAD : donorsGADs) {
                GADDonorIds.add(GAD.Donor__c);
            }

            //for every Trigger.new
            for (contact c : Trigger.new) {
                if (c.Data_complete_for_Gift_Aid__c != trigger.oldMap.get(c.Id).Data_complete_for_Gift_Aid__c) {
                    //if GAD query set contains Trigger.new contact then do following otherwise debug the fact that they had no GAD
                    if (GADDonorIds.contains(c.Id)) {
                        //for every GAD in donorsGAD list
                        for (Gift_Aid_Declaration__c GAD : donorsGADs) {
                            //if the current GAD belongs to the current contact
                            if (GAD.Donor__c == c.Id) {
                                //if the data is complete for Gift Aid
                                if (c.Data_complete_for_Gift_Aid__c == true) {
                                    //Update the contacts GADs to active
                                    GAD.isActive__c = true;
                                    //else
                                } else {
                                    //Update the contacts GADs to inactive
                                    GAD.isActive__c = false;
                                }
                                GADsToUpdate.add(GAD);
                            }
                        }
                    }
                }
            }
            if (GADsToUpdate.size() > 0) {
                DMLManager.UpdateSObjects(GADsToUpdate);
            }*/
        }

        return null;
    }
}