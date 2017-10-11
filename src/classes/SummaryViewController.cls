public with sharing class SummaryViewController {
    public List<Gift__c > giftlist{get;set;}
    public List<transactionsWrap > giftlistWrap{get;set;}
    public list<Campaign> eventlist {get;set;}
    public list<Event> eventactivitylist{get;set;}
    public list<task> taskactivitylist{get;set;}
    public string contAccid{get;set;}
    public Contact c{get;set;}
    public account a{get;set;}
    public string query;
    public List<Schema.FieldSetMember> MemberFieldSet{get; set;}
    public String googleChartBarURL{get;set;}
    public boolean hasdata1 { get; set; }
    public list<constProfWrap> givingProfWrapList{get;set;}
    public string indivOrOrgan{get;set;}
    public string recordType{get;set;}

    private string NamespacePrefix = Utilities.getCurrentNamespace();
    private string NamespaceField = NamespacePrefix + (String.isEmpty(NamespacePrefix) ? '' : '__');
    private string NamespaceEmail = NamespaceField + 'Email__c';

    public string getmyimageurl () {
        list<document> doc = new DocumentSelector().SelectUsingSpecificName('CV New Logo');
        if(doc.size() > 0 ){
            if(!Test.isRunningTest()){
                string imageid = doc[0].id;
                imageid = imageid.substring(0,15);
                return '/servlet/servlet.FileDownload?file=' + imageid;
            }
        }
        return null;
    }
    public void setmemberfieldset(string cOrAid)
    {
        MemberFieldSet = new List<Schema.FieldSetMember>();
        String fields = '';
        string whereClause = 'id = \'' + cOrAid + '\' limit 1';
        List<Schema.FieldSetMember> fieldSetMemberList = new List<Schema.FieldSetMember>();

        if(indivOrOrgan.equals('Contact')){
            fieldSetMemberList = SObjectType.Contact.FieldSets.Summary_Profile.getFields();
            fields = 'Name,phone,Email,MailingPostalcode,MailingState,MailingCity,MailingStreet,MailingCountry,';
        }else if(indivOrOrgan.equals('Account')){
            Account record = new AccountSelector().SelectByRecordTypeIdLimit(ApexPages.currentPage().getParameters().get('RecordTypeId'));
            recordType = record.RecordType.Name;
            fields = 'Name,phone,Email__c,BillingPostalcode, BillingState , BillingCity, BillingStreet, BillingCountry,';
            if(recordType.equals('Household')){
                fieldSetMemberList = SObjectType.Account.FieldSets.Summary_Profile_Household.getFields();
            }else{
                fieldSetMemberList = SObjectType.Account.FieldSets.Summary_Profile.getFields();
            }
        }

        for(Schema.FieldSetMember f : fieldSetMemberList) {
            MemberFieldSet.add(f);
            if(!fields.containsIgnoreCase(f.getFieldPath())){
                fields +=f.getFieldPath() + ',';
            }
        }
        fields.removeEnd(',');

        if(indivOrOrgan.equals('Contact')){
            c = (Contact)new GenericQueryBuilder().ObjectQueryBuilderWhere('Contact', fields, whereClause);
            givingProfilePrepare(c);
        }else{
            a = (Account)new GenericQueryBuilder().ObjectQueryBuilderWhere('Account', fields, whereClause);
            givingProfilePrepare(a);
        }
    }

        public void givingProfilePrepare(sObject conAcc){
        givingProfWrapList = new list<constProfWrap>();
        contact conValues;
        account accValues;
        integer i;
        string col1;
        string col2;
        string col3;
        string col4;
        if(indivOrOrgan.equals('Contact')){
            conValues = (Contact)conAcc;
            for(i=0; i < MemberFieldSet.size();i++) {
                col1 = MemberFieldSet[i].getLabel()+ ':';
                if((string.valueof(MemberFieldSet[i].getType()).equals('DATETIME')) || (string.valueof(MemberFieldSet[i].getType()).equals('DATE'))){
                    Date dateTimetemp  = Date.valueOf(conValues.get(MemberFieldSet[i].getfieldPath()));
                    if(dateTimetemp != null){
                            col2 =dateTimetemp.format();
                        }else{
                            col2 = '';
                        }
                }else{
                    col2 = string.valueOf(conValues.get(MemberFieldSet[i].getfieldPath()));
                }
                i+=1;
                if(i < MemberFieldSet.size()){
                    col3 = MemberFieldSet[i].getLabel() + ':';
                    if((string.valueof(MemberFieldSet[i].getType()).equals('DATETIME')) || (string.valueof(MemberFieldSet[i].getType()).equals('DATE'))){
                        Date dateTimetemp  = Date.valueOf(conValues.get(MemberFieldSet[i].getfieldPath()));
                        if(dateTimetemp != null){
                            col4 =dateTimetemp.format();
                        }else{
                            col4 = '';
                        }
                    }else{
                    col4 = string.valueOf(conValues.get(MemberFieldSet[i].getfieldPath()));
                }
                }else{
                    col3 = '';
                    col4 = '';
                }
                givingProfWrapList.add(new constProfWrap(col1,col2,col3,col4));
            }
        }else{
            accValues = (Account)conAcc;
            for(i=0; i < MemberFieldSet.size();i++) {
                col1 = MemberFieldSet[i].getLabel()+ ':';
                if((string.valueof(MemberFieldSet[i].getType()).equals('DATETIME')) || (string.valueof(MemberFieldSet[i].getType()).equals('DATE'))){
                    Date dateTimetemp  = Date.valueOf(accValues.get(MemberFieldSet[i].getfieldPath()));
                    if(dateTimetemp != null){
                            col2 =dateTimetemp.format();
                        }else{
                            col2 = '';
                        }
                }else{
                    col2 = string.valueOf(accValues.get(MemberFieldSet[i].getfieldPath()));
                }
                i+=1;
                if(i < MemberFieldSet.size()){
                    col3 = MemberFieldSet[i].getLabel() + ':';
                    if((string.valueof(MemberFieldSet[i].getType()).equals('DATETIME')) || (string.valueof(MemberFieldSet[i].getType()).equals('DATE'))){
                        Date dateTimetemp  = Date.valueOf(accValues.get(MemberFieldSet[i].getfieldPath()));
                        if(dateTimetemp != null){
                            col4 =dateTimetemp.format();
                        }else{
                            col4 = '';
                        }
                    }else{
                    col4 = string.valueOf(accValues.get(MemberFieldSet[i].getfieldPath()));
                }
                }else{
                    col3 = '';
                    col4 = '';
                }
                givingProfWrapList.add(new constProfWrap(col1,col2,col3,col4));
            }
        }
    }
    public SummaryViewController (){
        giftlist = new List<Gift__c>();
        giftlistWrap = new list<transactionsWrap>();
        eventlist = new List<Campaign>();
        eventactivitylist = new List<Event>();
        taskactivitylist = new List<Task>();
        contAccid = ApexPages.currentPage().getParameters().get('cid');
        if(contAccid == null || String.isEmpty(contAccid)){
            contAccid = ApexPages.currentPage().getParameters().get('AccountId');
        }
        if(contAccid.startsWith('003'))
        {
            indivOrOrgan = 'Contact';
        }else{
            indivOrOrgan = 'Account';
        }
        setmemberfieldset(contAccid);
        barURLPrepare(contAccid);
        //getRemoteData(contAccid);
        String fields = '';
        String clause = '';
        String subFields = '';
        String subClause = '';

        if(indivOrOrgan.equals('Contact'))
        {
            giftlist = new GiftSelector().SelectGiftSummaryByContactId(contAccid);
            for(Gift__c g : giftlist){
                if(g.Gift_Allocations__r.size() > 0 ){
                    giftlistWrap.add(new transactionsWrap(g, g.Gift_Allocations__r[0].New_Campaign__r.Name));
                }else{
                    giftlistWrap.add(new transactionsWrap(g, ''));
                }
            }
            eventlist = new CampaignSelector().SelectCampaignContactInfoByPrimaryId(contAccid);
            eventactivitylist= new EventSelector().SelectEventByWhoId(contAccid);
            taskactivitylist = new TaskSelector().SelectTaskByIdOrderByCreatedDate(contAccid);
        }
        else
        {
            giftlist = new GiftSelector().SelectGiftAndCampaignInfoByContactId(contAccid);
            for(Gift__c g : giftlist){
                if(g.Gift_Allocations__r.size() > 0 ){
                    giftlistWrap.add(new transactionsWrap(g, g.Gift_Allocations__r[0].New_Campaign__r.Name));
                }else{
                    giftlistWrap.add(new transactionsWrap(g, ''));
                }
            }
            eventlist = new CampaignSelector().SelectCampaignByAccountId(contAccid);
            taskactivitylist = new TaskSelector().SelectTaskByAccountIdOrderByCreatedDate(contAccid);
        }
    }

    public AggregateResult findItem(List<AggregateResult> objects, object value, string property)
    {
        for(AggregateResult obj : objects)
            if (obj.get(property) == value)
            return obj;

        return null;
    }
    public void barURLPrepare(string contAccid)
    {
        Date today = Date.today();
        integer currentYear = today.year();
        string xAxis = '';
        string data ='';
        string dataSoftCredit ='';
        decimal axisYMax = 0;
        AggregateResult[] aggrYears;
        AggregateResult[] aggrYearsOfSoftCredit;
        if(indivOrOrgan.equals('Contact'))
        {
            aggrYears = new GiftSelector().SelectAmountAndYearByConstituentAndPastFourYears(contAccid);
            aggrYearsOfSoftCredit = new SolicitorSelector().SelectAmountAndYearBySolicitorAndPastFourYears(contAccid);
        }else{
            aggrYears = new GiftSelector().SelectAmountAndYearByOrganizationAndPastFourYears(contAccid);
            aggrYearsOfSoftCredit = new SolicitorSelector().SelectAmountAndYearByOrganizationSolicitorAndPastFourYears(contAccid);
        }

        if (aggrYears!=null && aggrYears.size()>0)
        {
            hasdata1 = true;
            integer inx = currentYear - 4;
            for(integer i=inx;i<=currentYear;i++)
            {
                AggregateResult result = findItem(aggrYears, inx, 'year');
                if (result!=null){
                    //amountByYear.add(new PieWedgeData(string.valueOf(result.get('year')),(decimal)result.get('total')));
                    //xAxis != null? xAxis += '|'+ string.valueOf(result.get('year')) : xAxis = '|'+ string.valueOf(result.get('year'));
                    xAxis += '|'+ string.valueOf(result.get('year'));
                    if(result.get('total') != null){
                        if(decimal.valueOf(string.valueOf(result.get('total'))) > axisYMax){
                            axisYMax =decimal.valueOf(string.valueOf(result.get('total'))) ;
                        }
                    }
                    if(data != ''){
                        data += ','+string.valueOf(result.get('total'));
                    }else{
                        data = string.valueOf(result.get('total'));
                    }
                }else{
                    if(data != ''){
                        data += ',0';
                    }else{
                        data = '0';
                    }
                }

                AggregateResult resultSoft = findItem(aggrYearsOfSoftCredit, inx, 'year');
                if (resultSoft!=null){
                    //amountByYear.add(new PieWedgeData(string.valueOf(result.get('year')),(decimal)result.get('total')));
                    //xAxis != null? xAxis += '|'+ string.valueOf(result.get('year')) : xAxis = '|'+ string.valueOf(result.get('year'));
                    xAxis += '|'+ string.valueOf(resultSoft.get('year'));
                    if(resultSoft.get('total') != null){
                        if(decimal.valueOf(string.valueOf(resultSoft.get('total'))) > axisYMax){
                            axisYMax =decimal.valueOf(string.valueOf(resultSoft.get('total'))) ;
                        }
                    }
                    if(dataSoftCredit != ''){
                        dataSoftCredit += ','+string.valueOf(resultSoft.get('total'));
                    }else{
                        dataSoftCredit = string.valueOf(resultSoft.get('total'));
                    }
                }else{
                    if(dataSoftCredit != ''){
                        dataSoftCredit += ',0';
                    }else{
                        dataSoftCredit = '0';
                    }
                }
                inx++;
            }
            data +='%7C'+dataSoftCredit;
        }
        googleChartBarURL = 'http://chart.apis.google.com/chart?cht=bvs&chbh=40,20,40&chd=t:'+data+'&chs=450x180&chxt=x,y&chxl=0:|'+(currentYear-4)+'|'+(currentYear-3)+'|'+(currentYear-2)+'|'+(currentYear-1)+'|'+currentYear+'&chxs=2,000000,20,0,t|3,000000,20,0,t&chco=6fb6ff,d8d8d8&chds=a&chm=N,000000,0,,12,,c|N,000000,1,,12,,c';
    }

    /*public class PieWedgeData
    {
        public String name { get; set; }
        public Decimal data { get; set; }

        public PieWedgeData(String name, Decimal data)
        {
            this.name = name;
            this.data = data;
        }
    }*/

    public class constProfWrap{
        public string column1Label{get;set;}
        public string column1Value{get;set;}
        public string column2Label{get;set;}
        public string column2Value{get;set;}
        public constProfWrap(string co1L, string co1V, string co2L, string co2V){
            column1Label =  co1L;
            column1Value =  co1V;
            column2Label =  co2L;
            column2Value =  co2V;
        }
    }

    public class transactionsWrap{
        public Gift__c trans{get;set;}
        public string appeal{get;set;}
        public transactionsWrap(Gift__c g, string app){
            trans = g;
            appeal = app;
        }
    }


}