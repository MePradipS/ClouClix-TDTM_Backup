public with sharing class HouseHold extends RedirectController {
    public class MyMember {
        public Integer Id {get; set;}
        public Boolean Checked {get; set;}
        //public Boolean Deleted {get;set;}
        public Contact Member {get; set;}
        public MyMember(Integer id, Boolean c, Contact m) {
            this.Id = id;
            this.Checked = c;
            this.Member = m;
        }
        public MyMember() {
        }
    }
    public String HouseHoldId {get; set;}
    public String Url {get; set;}
    public Contact c {get; set;}
    //public String MemberRequired {get;set;}
    public String Msg {get; set;}
    public Account HouseHold {get; set;}
    public Contact Member {get; set;}
    public List<Schema.FieldSetMember> HouseHoldFieldList {get; set;}
    public List<Schema.FieldSetMember> MemberFieldList {get; set;}
    public List<List<Schema.FieldSetMember>> HouseHoldFieldListOfList {get; set;}
    public List<List<Schema.FieldSetMember>> MemberFieldListOfList {get; set;}
    public Boolean MemberRequired {get; set;}
    public String ActionMemberId {get; set;}
    public String UpdatedMemberIds {get; set;}
    public String TestActionMemberId {get; set;}
    public List<MyMember> MyMemberList {get; set;}
    public List<MyMember> SelectedMyMemberList {get; set;}
    public List<Contact> DelMemberList {get; set;}
    public String Keywords {get; set;}
    public List<MyMember> ExistingMemberList {get; set;}
    public Contact ExistingMember {get; set;}
    public String ExistingMemberId {get; set;}
    public String NewMemberType {get; set;}
    public String MemberOperation {get; set;}

    public String DisplayNewMemberButton {get; set;}
    public String DisplaySuggestedMemberButton {get; set;}
    public String DisplayEditMemberButton {get; set;}
    public String DisplayExistingMemberButton {get; set;}
    public String DisplayMemberDetails {get; set;}
    public String DisplaySearchKeywords {get; set;}
    public String DisplayExistingMemberList {get; set;}
    public String DisplayBackBlock {get; set;}
    public String DisplayPopUp {get; set;}
    public String DisplayHiddenPopUp {
        get{
            if (DisplayPopUp.equals('none')) {
                return '';
            } else{
                return 'none';
            }
        }
    }
    public String DisplayAddSelectedMemberButton {get; set;}
    public String DisplayPageIndex {
        get{
            if (ExistingMemberList.size() > 0) {
                return '';
            } else{
                return 'none';
            }
        }
    }


    public Integer TotalCount {get; set;}
    public Integer TotalPageNumber {
        get{
            Integer n = TotalCount / PageSize;
            Integer mod = TotalCount - (n * PageSize);
            if (mod > 0) {
                n++;
            }
            return n;
        }
    }
    public Integer PageSize = 10;
    public Integer PageIndex {get; set;}
    public Boolean PreviousButtonDisabled {
        get{
            return !(PageIndex > 1);
        }
    }
    public Boolean NextButtonDisabled {
        get{
            return !(PageIndex < TotalPageNumber);
        }
    }

    public HouseHold() {
        super(true);
        UpdatedMemberIds = '';
        TotalCount = 0;
        PageIndex = 1;
        setHouseHoldFieldList();
        setMemberFieldList();
        setHouseHold();
        setMemberList();
        resetMember();
        hideAll();
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

    public void setHouseHoldFieldList() {
        HouseHoldFieldList = SObjectType.Account.FieldSets.Household.getFields();

        // For Lightning version
        HouseHoldFieldListOfList = new List<List<Schema.FieldSetMember>>();
        List<Schema.FieldSetMember> listTemp = new List<Schema.FieldSetMember>();
        for(Schema.FieldSetMember f : HouseHoldFieldList){
           listTemp.add(f);
           if(listTemp.size() == 2){
               HouseHoldFieldListOfList.add(listTemp);
               listTemp = new List<Schema.FieldSetMember>();
           }
        }
        if(listTemp.size() == 1){
            HouseHoldFieldListOfList.add(listTemp);
        }
    }
    public void setMemberFieldList() {
        MemberFieldList = SObjectType.Contact.FieldSets.Member.getFields();

        // For Lightning version
        MemberFieldListOfList = new List<List<Schema.FieldSetMember>>();
        List<Schema.FieldSetMember> listTemp = new List<Schema.FieldSetMember>();
        for(Schema.FieldSetMember f : MemberFieldList){
           listTemp.add(f);
           if(listTemp.size() == 2){
               MemberFieldListOfList.add(listTemp);
               listTemp = new List<Schema.FieldSetMember>();
           }
        }
        if(listTemp.size() == 1){
            MemberFieldListOfList.add(listTemp);
        }
    }

    private void setHouseHold() {
        Url = ApexPages.currentPage().getParameters().get('Url');

        HouseHoldId = ApexPages.currentPage().getParameters().get('Id');
        if (HouseHoldId != null && !HouseHoldId.equals('')) {
            HouseHold = new AccountSelector().SelectByHouseHoldId(string.escapeSingleQuotes(HouseHoldId));
        } else {
            HouseHold = new Account();
            HouseHold.RecordTypeId = utilities.getObjectRecordTypeId(Account.SObjectType, 'Household');
        }
    }
    public void resetMember() {
        ActionMemberId = null;
        Member = new Contact();
        Member.LastName = Keywords ;
        ExistingMemberList = new List<MyMember>();
    }
    public void saveMember() {
        for (Schema.FieldSetMember f : MemberFieldList) {
            Member.Household__c = HouseHold.Id;
            Member.put(f.getFieldPath(), Member.get(f.getFieldPath()));
        }
        if (MyMemberList == null) {
            MyMemberList = new List<MyMember>();
        }
        //ActionMemberId = ApexPages.currentPage().getParameters().get('ActionMemberId');
        if (ActionMemberId == null) {
            MyMember mm = new MyMember();
            mm.Id = MyMemberList.size();
            mm.Member = Member;
            MyMemberList.add(mm);
        } else {
            Integer i = Integer.ValueOf(ActionMemberId);
            for (MyMember mm : MyMemberList) {
                if (mm.Id == i) {
                    mm.Member = Member;
                    UpdatedMemberIds += Member.Id;
                }
            }
        }
    }
    public void queryExistingMember() {
        ExistingMemberList = new List<MyMember>();
        String clause = '';

        if (DisplayMemberDetails.equals('')) {
            clause = 'WHERE ';
            string memLastName = Member.LastName;

            if (memLastName.contains('\\')) {
                memLastName = memLastName.replaceAll('\\\\', '\\\\\\\\');
            }
            if (memLastName.contains('\'')) {
                memLastName = memLastName.replaceAll('\'', '\\\\\'');
            }
            memLastName = memLastName.remove('\'');
            clause += ' LastName like \'\'%' + string.escapeSingleQuotes(memLastName) + '%\'\'';
        } else {
            if (Keywords != null && !Keywords.equals('')) {
                clause = 'WHERE ';

                if (Keywords.contains('\\')) {
                    Keywords = Keywords.replaceAll('\\\\', '\\\\\\\\');
                }
                if (Keywords.contains('\'')) {
                    Keywords = Keywords.replaceAll('\'', '\\\\\'');
                }
                Keywords = Keywords.remove('\'');
                clause += ' LastName like \'\'%' + string.escapeSingleQuotes(Keywords) + '%\'\'';
            }
        }
        setExistingMember(clause);
    }
    public void setExistingMember(String clause) {
        ExistingMemberList = new List<MyMember>();

        Integer min = (PageIndex - 1) * PageSize;
        Integer max = PageIndex * PageSize - 1;

        Integer i = 0;
        for (Contact m : new ContactSelector().SelectContactWithDynamicClause(clause)) {
            if (i >= min && i <= max) {
                boolean AddedAlready = false;
                for (MyMember mm : MyMemberList) {
                    if (mm.Member.Id == m.Id) { AddedAlready = true; }
                }
                if (!AddedAlready) {
                    ExistingMemberList.add(new MyMember(i + 1, false, m));
                }
            }
            i++;
        }
        TotalCount = i;
        if (TotalCount == 0) {
            PageIndex = 0;
        }
    }

    public void hideAll() {
        DisplayBackBlock = 'none';
        DisplayPopUp = 'none';
        hideAllController();
        PageIndex = 1;
    }
    public void hideAllController() {
        DisplayNewMemberButton = 'none';
        DisplaySuggestedMemberButton = 'none';
        DisplayEditMemberButton = 'none';
        DisplayExistingMemberButton = 'none';
        DisplayMemberDetails = 'none';
        DisplaySearchKeywords = 'none';
        DisplayExistingMemberList = 'none';
        DisplayAddSelectedMemberButton = 'none';
        if (ExistingMemberList.size() > 0) {
            DisplayAddSelectedMemberButton = '';
        }
        MemberRequired = false;
    }
    public void displayPopUp() {
        DisplayBackBlock = 'block';
        DisplayPopUp = 'block';
    }

    public void displayNewMember() {
        hideAllController();
        DisplayNewMemberButton = '';
        DisplayMemberDetails = '';
        MemberRequired = true;
        MemberOperation = 'Add New Member';
    }
    public void displaySuggestedMember() {
        hideAllController();
        DisplaySuggestedMemberButton = '';
        DisplayMemberDetails = '';
        DisplayExistingMemberList = '';
        MemberRequired = true;
    }
    public void displayEditMember() {
        hideAllController();
        DisplayEditMemberButton = '';
        DisplayMemberDetails = '';
        MemberRequired = true;
        MemberOperation = 'Edit Existing Individual ';
    }
    public void displayExistingMember() {
        hideAllController();
        DisplayExistingMemberButton = '';
        DisplaySearchKeywords = '';
        DisplayExistingMemberList = '';
        MemberOperation = 'Add Existing Individual ';
    }

    public void setMemberList() {
        MyMemberList = new List<MyMember>();
        if (HouseHold.Id != null) {
            String fields = '';
            for (Schema.FieldSetMember f : MemberFieldList) {
                fields += f.getFieldPath() + ', ';
            }
            fields += 'Id';
            String clause = 'Household__c = \'' + string.escapeSingleQuotes(HouseHold.Id) + '\'';
            List<Contact> MemberList = new GenericQueryBuilder().ListQueryBuilderWhere('Contact', fields, clause);
            Integer i = 0;
            for (Contact m : MemberList) {
                MyMember mm = new MyMember();
                mm.Id = i;
                mm.Member = m;
                MyMemberList.add(mm);
                i++;
            }
        }
        DelMemberList = new List<Contact>();
    }
    public void setSelectedMember() {
        String ids = '';
        for (MyMember mm : ExistingMemberList) {
            if (mm.Checked) {
                if (!ids.equals('')) {
                    ids += ',';
                }
                ids += '\'' + mm.Member.Id + '\'';
            }
        }
        if (ids.equals('')) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You have not selected any individuals to add');
            ApexPages.addMessage(myMsg);
        } else {
            String fields = '';
            for (Schema.FieldSetMember f : MemberFieldList) {
                fields += f.getFieldPath() + ', ';
            }
            fields += ' Id';
            String clause = 'id in (' + ids + ')';
            List<Contact> cList = new GenericQueryBuilder().ListQueryBuilderWhere('Contact', fields, clause);
            for (Contact c : cList) {
                MyMemberList.add(new MyMember(MyMemberList.size(), false, c));
                c.Household__c = HouseHold.Id;
                UpdatedMemberIds += c.Id;
            }
        }
    }
    public void setActionMemberId() {
        ActionMemberId = ApexPages.currentPage().getParameters().get('ActionMemberId');
        if (ActionMemberId == null) {
            ActionMemberId = TestActionMemberId;
        }
    }

    public PageReference saveAll() {
        try {
            Boolean bHasPrimaryContact = false;
            for (Schema.FieldSetMember f : HouseHoldFieldList) {
                HouseHold.put(f.getFieldPath(), HouseHold.get(f.getFieldPath()));
            }
            DMLManager.UpsertSObject(houseHold);

            HouseHoldId = houseHold.Id;

            List<Contact> UpsertContactList = new List<Contact>();
            for (MyMember mm : MyMemberList) {
                mm.Member.Household__c = HouseHold.Id;
                UpsertContactList.add(mm.Member);
                if (mm.Member.Household_Primary_Contact__c) {
                    bHasPrimaryContact = true;
                }
            }
            if (bHasPrimaryContact || MyMemberList.size() <= 1) {

                if (UpsertContactList != null && UpsertContactList.size() > 0) {
                    List<Contact> InsertContactList = new List<Contact>();
                    List<Contact> UpdateContactList = new List<Contact>();
                    for (Contact c : UpsertContactList) {
                        if (c.Id != null) {
                            if (UpdatedMemberIds.Contains(c.Id)) {
                                UpdateContactList.add(c);
                            }
                        } else {
                            InsertContactList.add(c);
                        }
                    }
                    if (UpdateContactList.size() > 0) {
                        DMLManager.UpdateSObjects(UpdateContactList);
                    }
                    if (InsertContactList.size() > 0) {
                        DMLManager.InsertSObjects(InsertContactList);
                    }
                }
                return cancelAll();
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a Head of Household.  Edit an individual, set them as the Head of Household and try saving again.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    public PageReference cancelAll() {
        PageReference p;
        if (HouseHoldId == null || HouseHoldId.equals('')) {
            p = new PageReference(Url);
        } else {
            p = new PageReference('/' + HouseHoldId);
        }
        return p;
    }
    public PageReference save() {
        saveMember();
        hideAll();
        return null;
    }
    public PageReference saveAndNewMember() {
        saveMember();
        Keywords = '';
        resetMember();
        hideAll();
        displayPopUp();
        displayNewMember();
        return null;
    }
    public PageReference showSuggestedMember() {
        PageIndex = 1;
        queryExistingMember();
        displaySuggestedMember();
        return null;
    }
    public PageReference addSelectedMember() {
        setSelectedMember();
        ApexPages.Message[] mssgs = ApexPages.getMessages();
        if (mssgs.size() == 0) {
            hideAll();
        }
        return null;
    }
    public PageReference selectExistingMember() {
        ExistingMemberId = ApexPages.currentPage().getParameters().get('ExistingMemberId');
        if (ExistingMemberId == null) {
        } else {
            for (MyMember m : ExistingMemberList) {
                Contact em = m.Member;
                String strId = em.Id;
                if (strId.equals(ExistingMemberId)) {
                    em.Household__c = HouseHold.Id;
                    MyMember mm = new MyMember();
                    mm.Id = MyMemberList.size();
                    mm.Member = em;
                    MyMemberList.add(mm);
                }
            }
        }
        hideAll();
        return null;
    }
    public PageReference cancel() {
        Keywords = '';
        hideAll();
        return null;
    }
    public PageReference newMember() {
        resetMember();
        displayPopUp();
        displayNewMember();
        return null;
    }
    public PageReference addExistingMember() {
        resetMember();
        displayPopUp();
        displayExistingMember();
        return null;
    }
    public PageReference editMember() {
        setActionMemberId();
        MyMember mm = MyMemberList[Integer.valueOf(ActionMemberId)];
        Member = mm.Member;
        displayPopUp();
        displayEditMember();
        return null;
    }
    public PageReference cloneMember() {
        setActionMemberId();
        Member = new Contact();
        Integer i = Integer.ValueOf(ActionMemberId);
        for (MyMember mm : MyMemberList) {
            if (mm.Id == i) {
                for (Schema.FieldSetMember f : MemberFieldList) {
                    Member.Household__c = HouseHold.Id;
                    Member.put(f.getFieldPath(), mm.Member.get(f.getFieldPath()));
                }
            }
        }
        ActionMemberId = null;
        displayPopUp();
        displayNewMember();
        return null;
    }
    public PageReference delMember() {
        if (DelMemberList == null) {
            DelMemberList = new List<Contact>();
        }
        setActionMemberId();
        Integer i = Integer.ValueOf(ActionMemberId);
        Integer n = 0;
        for (MyMember mm : MyMemberList) {
            if (mm.Id == i) {
                if (mm.Member.Id != null) {
                    DelMemberList.add(mm.Member);
                }
                break;
            }
            n++;
        }
        MyMemberList.remove(i);

        n = 0;
        for (MyMember mm : MyMemberList) {
            mm.Id = n;
            n++;
        }

        return null;
    }
    public PageReference searchExistingMember() {
        PageIndex = 1;
        queryExistingMember();
        displayExistingMember();
        return null;
    }

    public PageReference nextBtnClick() {
        PageIndex = PageIndex + 1;
        queryExistingMember();
        return null;
    }
    public PageReference previousBtnClick() {
        PageIndex = PageIndex - 1;
        queryExistingMember();
        return null;
    }

    public list<string> getHouseholdRole()
    {
        List<String> houseoptions=new List<String>();
        Schema.DescribeFieldResult  household= Contact.fields.Household_Role__c.getDescribe();
        List<Schema.PicklistEntry>  householdpval = household.getPicklistValues();

        for(Schema.PicklistEntry pval : householdpval)
             houseoptions.add(String.valueOf(pval.getLabel()));


        return houseoptions;
    }
    //added on 26-04-2017
    public list<string> getSolicitCodes()
    {
        List<String> options=new List<String>();
        Schema.DescribeFieldResult  solicitcodes= Account.fields.Solicit_Codes__c.getDescribe();
        List<Schema.PicklistEntry>  solipval = solicitcodes.getPicklistValues();

        for(Schema.PicklistEntry pval : solipval)
             options.add(String.valueOf(pval.getLabel()));


        return options;
    }
}