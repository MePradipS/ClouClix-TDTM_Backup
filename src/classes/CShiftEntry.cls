public with sharing class CShiftEntry extends RedirectController {
   public string pType { get; set; }

    public CShiftEntry(ApexPages.StandardController controller) {
        super(controller, true);
        List<Volunteer_Shift__c> theVPS = new VolunteerShiftSelector().SelectVolunteerRoleById(new Set<Id> { controller.getId() });
        if (theVPS.size() > 0){
            posId = theVPS[0].Volunteer_Role__c;
        }else{
            posId = ApexPages.currentPage().getParameters().get('pid');
            posId = ESAPI.encoder().SFDC_HTMLENCODE(posId);
        }
        wizardState = 1;
        refresh();
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

    private void refresh() {
        List<Volunteer_Role__c> volunteerRoleList = new VolunteerRoleSelector().SelectRoleAndShiftById(new Set<Id> { posId });
        if (volunteerRoleList != null && volunteerRoleList.size() > 0) {
            thePos = volunteerRoleList[0];
        }
        theShifts = new List<ShiftWrapper>();
        for (Volunteer_Shift__c vps : thePos.Volunteer_Position_Shifts__r)
        {
            theShifts.add(new ShiftWrapper(vps));
        }
        selected = new ShiftWrapper(thePos);
    }

    public List<SelectOption> getPTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- None --'));
        options.add(new SelectOption('Flexible', 'Flexible'));
        //options.add(new SelectOption('Credit Card - Offline', 'Credit Card - Offline'));
        options.add(new SelectOption('One-Time', 'One-Time'));
        options.add(new SelectOption('Weekly', 'Weekly'));
        options.add(new SelectOption('Bi-Weekly', 'Bi-Weekly'));
        options.add(new SelectOption('Monthly', 'Monthly'));
        return options;
    }

    public String posId { get;set; }
    public Integer wizardState { get; set; }
    public List<ShiftWrapper> theShifts { get; set; }
    public ShiftWrapper selected { get; set; }
    public Volunteer_Role__c thePos { get; set; }
    public Integer NumOfWeeks { get; set; }


    public List<SelectOption> getPickLstValue()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        Schema.DescribeFieldResult fieldResult = Volunteer_Shift__c.Frequency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

    public List<SelectOption> getHours() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', '1'));
        options.add(new SelectOption('2', '2'));
        options.add(new SelectOption('3', '3'));
        options.add(new SelectOption('4', '4'));
        options.add(new SelectOption('5', '5'));
        options.add(new SelectOption('6', '6'));
        options.add(new SelectOption('7', '7'));
        options.add(new SelectOption('8', '8'));
        options.add(new SelectOption('9', '9'));
        options.add(new SelectOption('10', '10'));
        options.add(new SelectOption('11', '11'));
        options.add(new SelectOption('12', '12'));
        return options;
    }

    public List<SelectOption> getMins() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('00', '00'));
        options.add(new SelectOption('15', '15'));
        options.add(new SelectOption('30', '30'));
        options.add(new SelectOption('45', '45'));
        return options;
    }

    public List<SelectOption> getMeridiemOffset () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('AM', 'AM'));
        options.add(new SelectOption('PM', 'PM'));
        return options;
    }

    public void addShift() {
        if (selected.theShift.Frequency__c != '' && selected.theShift.Frequency__c != null)
        {
            List<Volunteer_Shift__c> toBeInserted = new List<Volunteer_Shift__c>();
            selected.theShift.Shift_Date__c = selected.theShift.Start_Day__c;
            VolunteerUtil.serializeShiftWrapper(selected);
            selected.theShift.Volunteer_Role__c = thePos.Id;
            toBeInserted.add(selected.theShift);
            if (selected.theShift.Frequency__c == 'Weekly' || selected.theShift.Frequency__c == 'Bi-Weekly' || selected.theShift.Frequency__c == 'Monthly')
            {
                Volunteer_Shift__c buffShift = selected.theShift.clone(false, true);
                for (Integer i = 1; i < NumOfWeeks; i++)
                {
                    selected = new ShiftWrapper(thePos);
                    selected.theShift = buffShift.clone(false, true);
                    if (selected.theShift.Frequency__c == 'Weekly')
                    {
                        selected.theShift.Shift_Date__c = buffShift.Shift_Date__c.addDays(i*7);
                        selected.theShift.Start_Day__c = buffShift.Start_Day__c.addDays(i*7);
                        selected.theShift.Start_Time__c = buffShift.Start_Time__c.addDays(i*7);
                        selected.theShift.End_Day__c = buffShift.End_Day__c.addDays(i*7);
                        selected.theShift.End_Time__c = buffShift.End_Time__c.addDays(i*7);
                    }
                    if (selected.theShift.Frequency__c == 'Bi-Weekly')
                    {
                        selected.theShift.Shift_Date__c = buffShift.Shift_Date__c.addDays(i*14);
                        selected.theShift.Start_Day__c = buffShift.Start_Day__c.addDays(i*14);
                        selected.theShift.Start_Time__c = buffShift.Start_Time__c.addDays(i*14);
                        selected.theShift.End_Day__c = buffShift.End_Day__c.addDays(i*14);
                        selected.theShift.End_Time__c = buffShift.End_Time__c.addDays(i*14);
                    }
                    if (selected.theShift.Frequency__c == 'Bi-Weekly')
                    {
                        selected.theShift.Shift_Date__c = buffShift.Shift_Date__c.addMonths(i);
                        selected.theShift.Start_Day__c = buffShift.Start_Day__c.addMonths(i);
                        selected.theShift.Start_Time__c = buffShift.Start_Time__c.addMonths(i);
                        selected.theShift.End_Day__c = buffShift.End_Day__c.addMonths(i);
                        selected.theShift.End_Time__c = buffShift.End_Time__c.addMonths(i);
                    }
                    selected.theShift.Volunteer_Role__c = thePos.Id;
                    toBeInserted.add(selected.theShift);
                }
            }
            DMLManager.InsertSObjects(toBeInserted);
            selected = new ShiftWrapper(thePos);

            refresh();
        }
    }

    public void removeShift() {
        Integer i = Decimal.valueOf(ApexPages.currentPage().getParameters().get('Index')).intValue();
        DMLManager.DeleteSObject(theShifts.remove(i-1).theShift);
    }

    public void clear() {
        List<Volunteer_Shift__c> toDelete = new List<Volunteer_Shift__c>();
        for (ShiftWrapper i : theShifts){
            toDelete.add(i.theShift);
        }
        DMLManager.DeleteSObjects(toDelete);
        refresh();
    }

    public void editShift() {
        Integer i = Decimal.valueOf(ApexPages.currentPage().getParameters().get('Index')).intValue();
        wizardState = 2;
        selected = new ShiftWrapper(theShifts.remove(i-1).theShift);
    }

    public void cancelUpdate() {
        wizardState = 1;
        refresh();
    }

    public void updateShift() {
        VolunteerUtil.serializeShiftWrapper(selected);
        DMLManager.UpdateSObject(selected.theShift);
        wizardState = 1;
        refresh();
    }

    public PageReference back() {
        PageReference pr = new ApexPages.StandardController(thePos).view();
        pr.setRedirect(true);
        return pr;
    }

    public void processPaymentType(){
      //pType = paymentType;
    }
}