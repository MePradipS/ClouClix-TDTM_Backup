public with sharing class CSearch {
// Security issue resolve.
    public CSearch() {
        thePositions = new List<Volunteer_Role__c >();
        List<Contact> contactList = new ContactSelector().SelectVolunteerInfoById(new Set<Id> { ApexPages.currentPage().getParameters().get('id') });
        if (contactList != null && contactList.size() > 0) {
            theVolunteer = contactList[0];
        }
        theOpp = new Volunteer_Opportunity__c();
        thePos = new Volunteer_Role__c();
        thePos.Role_Locale__c = theVolunteer.Preferred_Locales__c;
        filterOptions = new List<CKvp>();
        filterOptionsLang = new List<CKvp>();
        Set<String> selectedSkills = new Set<String>();
        if (theVolunteer.Professional_Skills__c != '' && theVolunteer.Professional_Skills__c != null)
        { selectedSkills.addAll(theVolunteer.Professional_Skills__c.split(';')); }
        Set<String> selectedLangs = new Set<String>();
        if (theVolunteer.Languages__c != '' && theVolunteer.Languages__c != null)
        { selectedLangs.addAll(theVolunteer.Languages__c.split(';')); }
        for (Schema.PicklistEntry p : Contact.Professional_Skills__c.getDescribe().getPicklistValues()) {
            if (selectedSkills.contains(p.getLabel())) { filterOptions.add(new CKvp(p.getLabel(), true)); }
            else { filterOptions.add(new CKvp(p.getLabel(), false)); }
        }
        for (Schema.PicklistEntry p : Contact.Languages__c.getDescribe().getPicklistValues()) {
            if (selectedLangs.contains(p.getLabel())) { filterOptionsLang.add(new CKvp(p.getLabel(), true)); }
            else { filterOptionsLang.add(new CKvp(p.getLabel(), false)); }
        }
    }

    public List<CKvp> filterOptionsLang { get; set; }
    public List<Volunteer_Role__c > thePositions { get; set; }
    public Contact theVolunteer { get; set; }
    public Volunteer_Opportunity__c theOpp { get; set; }
    public Volunteer_Role__c thePos { get; set; }
    public List<CKvp> filterOptions { get; set; }
    public String posType { get; set; }

    public List<SelectOption> getTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        options.add(new SelectOption('012d0000000siPU', 'Group'));
        options.add(new SelectOption('012d0000000siPV', 'Individual'));
        return options;
    }

    public void refreshList() {
        String finalFilters = '';
        String fields = '';
        String clause = '';
        try {
            fields = 'Number_Of_Service_Hours_Involved__c, Name, Position_Description_Templates__c, Position_Status__c, Position_Location__c';
            List<String> filters = new List<String>();
            List<Volunteer_Role__c > posBuffer = new List<Volunteer_Role__c >();
            Integer volScreeningLevel;
            String buffFilters = '';
            finalFilters = '';

            //LOCATION
            if (thePos.Role_Locale__c != '' && thePos.Role_Locale__c != null) {
                buffFilters = '';
                buffFilters += '(Position_Location__c INCLUDES(';
                for (String strLoc : thePos.Role_Locale__c.split(';')) {
                    buffFilters += ('\'' + strLoc + '\', ');
                }
                buffFilters = buffFilters.substring(0, buffFilters.length() - 2);
                buffFilters += '))';
                filters.add(buffFilters);
            }

            //PROGRAM
            if (theOpp.Program__c != null) {
                buffFilters = '';
                buffFilters += '(Volunteer_Opportunity__r.Program__c = \'' + theOpp.Program__c + '\')';
                filters.add(buffFilters);
            }

            //MY PROFESSIONAL SKILLS
            List<String> selectedSkills = new List<String>();
            Boolean isSkillFiltered = false;
            for (CKvp kvp : filterOptions) {
                if (kvp.value) {
                    selectedSkills.add(kvp.key);
                    isSkillFiltered = true;
                }
            }
            if (isSkillFiltered) {
                buffFilters = '';
                buffFilters += '(Skills_Needed__c INCLUDES(\'';
                for (String strSkill : selectedSkills) {
                    buffFilters += (strSkill + ';');
                }
                buffFilters = buffFilters.substring(0, buffFilters.length() - 1);
                buffFilters += '\'))';
                filters.add(buffFilters);
            }

            clause += ' WHERE (Position_Status__c = \'Open - Public\' OR Position_Status__c = \'Open - Private\' OR Position_Status__c = \'Proposed\')';

            if (filters.size() > 0) {
                for (String f : filters) {
                    clause += (' AND ' + f);
                }
            }

            clause += ' ORDER BY Name';

            thePositions = new List<Volunteer_Role__c >();
            posBuffer = new GenericQueryBuilder().ListQueryBuilderWhere('Volunteer_Positions__c', fields, clause);

            volScreeningLevel = VolunteerUtil.getScreeningLevelFromContact(theVolunteer.Id);  //UserInfo.getUserId() 005J0000000YOsQ
            for (Volunteer_Role__c vp : posBuffer) {
                thePositions.add(vp);
            }
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, String.valueOf('Select ' + fields + ' FROM Volunteer_Positions__c ' + clause)));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, ex.getMessage()));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, ex.getStackTraceString()));
        }
    }

    public PageReference signUp() {
        try {
            Integer i = Decimal.valueOf(ApexPages.currentPage().getParameters().get('Index')).intValue();
            Volunteer_Role__c selectedPos = thePositions[i - 1];
            Volunteer_Application__c theApp = new Volunteer_Application__c();

            theApp = new Volunteer_Application__c(RecordTypeId = '012d0000000siPX', Volunteer__c = theVolunteer.Id, Volunteer_Role__c = selectedPos.Id, Status__c = 'Approved');
            DMLManager.InsertSObject(theApp);
            selectedPos.Role_Status__c = 'Filled';
            DMLManager.UpdateSObject(selectedPos);

            PageReference pr = new ApexPages.StandardController(theApp).view();
            pr.setRedirect(true);
            return pr;
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, String.valueOf(ex.getLineNumber())));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, ex.getMessage()));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, ex.getStackTraceString()));
            return null;
        }
    }

    public class CKvp {
        public CKvp(string sKey, boolean bValue) {
            key = sKey;
            value = bValue;
        }
        public string key { get; set; }
        public boolean value { get; set; }
    }
}