trigger CascadeHouseholdAddress on Account (after update) {
    CascaseHouseholdAddressHandler.Execute(Trigger.old, Trigger.new, Trigger.old.size()); 
}