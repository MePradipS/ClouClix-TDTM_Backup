public with sharing class CPlaceApplicant extends RedirectController {

    public PageReference place() {    
        List<Volunteer_Shift__c> shiftsToUpdate = new List<Volunteer_Shift__c>();
        Integer count = 0;
        for (PlacementWrapper pw : shift_wrappers) {
            if (pw.placed) {
                pw.shift.Volunteer__c = volunteerId;
                shiftsToUpdate.add(pw.shift);
                count++;
            }
            else {
                pw.shift.Volunteer__c = null;
                pw.shift.Volunteer_Application__c = null;                
                shiftsToUpdate.add(pw.shift);
            }
            if (count == 0) {
                app.Status__c = 'Exited';
                app.Service_Exit_Date__c = Date.Today();
            }
            else {
                app.Status__c = 'Placed';
            }
        }
        if (shiftsToUpdate != null && shiftsToUpdate.size() > 0) {
            DMLManager.UpdateSObjects(shiftsToUpdate);
        }
        if (app != null) {
            DMLManager.UpdateSObject(app);
        }
        return new PageReference('/' + ApexPages.CurrentPage().GetParameters().get('id'));        
    }

    
    public class PlacementWrapper {
        public PlacementWrapper() { }
        public boolean placed { get; set; }
        public Volunteer_Shift__c shift { get; set; }
    }
    
    public List<PlacementWrapper> shift_wrappers { get; set; }
    public string volunteerId { get; set; }
    public Contact volunteer { get; set; }
    public Volunteer_Application__c app { get; set; }
    
    public CPlaceApplicant() {
        super(true);
        shift_wrappers = new List<PlacementWrapper>();
        List<Volunteer_Application__c> volunteerAppList = new VolunteerApplicationSelector().SelectSObjectByIdLimit(new Set<Id> { ApexPages.CurrentPage().GetParameters().get('id') }, 1);
        if (volunteerAppList != null && volunteerAppList.size() > 0) {
            app = volunteerAppList[0];
            volunteerId = app.Volunteer__c;
            List<Contact> volunteerList = new ContactSelector().SelectVolunteerAvailabilityById(new Set<Id> { volunteerId });
            if (volunteerList != null && volunteerList.size() > 0) {
                volunteer = volunteerList[0];
                for (Volunteer_Shift__c vps : new VolunteerShiftSelector().SelectByVolunteerRoleAndVolunteer(app.Volunteer_Role__c, volunteerId)) {
                    PlacementWrapper pw = new PlacementWrapper();
                    pw.placed = (vps.Volunteer__c == volunteerId);
                    pw.shift = vps;
                    shift_wrappers.add(pw);
                }
            }
        }
    }
    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }
}