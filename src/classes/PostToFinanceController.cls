public with sharing class PostToFinanceController extends RedirectController {
    public string fromDate {get;set;}
    public string toDate {get;set;}
    public Boolean isTrue {get;set;}
    public List<csvExportWrapper> allocations {get;set;}
    transient public List<Gift_Detail__c> allocationRecords {get;set;}
    transient public List<Gift_Detail__c> allocationRecords1 {get;set;}
    public List<csvExportWrapper> csvRecords {get;set;}
    public string fileFormat {get;set;}
    private integer totalRecs = 0;
    private integer OffsetSize = 0;
    private integer LimitSize = 1500;
    public integer pageNumber {get; set;}
    public integer totalPages {get; set;}
    public List<List<csvExportWrapper>> listCSVRecords {get; set;}
    public List<List<csvExportWrapper>> listExportRecords {get; set;}
    public string reportDateTime {get;set;}
    public boolean jobProcess {get;set;}
    set<id> allocIds;
    public List<String> fieldSetApi{get;set;}
    public List<String> fieldSetLabel{get;set;}
    public map<String, string> fieldSetLabelMap{get;set;}
    public String buildquery;

    public String sortDirection = 'ASC';
    public String sortExp = 'Name';
    public String sortExpLabel{get;set;}


    public integer pollarInterval {
            get{
                if(allocIds.size()>600){
                    return 8;
                }else{
                    return 5;
                }
            }
        }

    public PostToFinanceController(){
        super(true);
        jobProcess = false;
        allocationRecords = new List<Gift_Detail__c>();
        allocations = new List<csvExportWrapper>();
        listCSVRecords = new List<List<csvExportWrapper>>();
        isTrue = true;
        fileFormat = 'CSV';
        fieldSetApi = Addfieldset();
        callSearchAllocationMethod();
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

    public void callSearchAllocationMethod(){
        pageNumber = 1;
        OffsetSize = 0;
        searchAllocation();
    }

    public void searchAllocation(){
        allocationRecords = new List<Gift_Detail__c>();
        allocationRecords1 = new List<Gift_Detail__c>();
        allocations = new List<csvExportWrapper>();
        listCSVRecords = new List<List<csvExportWrapper>>();
        Date fromDt;Date toDt;
        string sortFullExp = sortExpression  + ' ' + sortDirection;


        if((fromDate == null && toDate == null) || fromDate == '' && toDate == '')
       {
            Date daysBack= date.today();
            fromDate = String.valueOf(daysBack.addDays(-7));
            toDate = String.valueOf(daysBack);

            allocationRecords = new AllocationSelector().SelectAllocationRecordsByDate(daysBack.addDays(-7), daysBack, sortFullExp, buildquery);
       }
       else
        {
           try
            {
                fromDt = Date.valueOf(fromDate);
                toDt = Date.valueOf(toDate);

            }
            catch(Exception e)
            {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter Valid Date'));
                 return;
            }

            allocationRecords = new AllocationSelector().SelectAllocationRecordsByDate(fromDt, toDt, sortFullExp, String.escapeSingleQuotes(buildquery));
         }

            if(allocationRecords.size()>0){
                isTrue = true;
                totalRecs = allocationRecords.size();
            }else
            {
                isTrue = false;
                totalRecs = 0;
            }
            if(totalRecs != 0){
                totalPages = (Math.mod(totalRecs, LimitSize) == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize) + 1);
            }else
            {
                totalPages = 1;
            }


            if(totalRecs >= OffsetSize+LimitSize){
                for(Integer i = OffsetSize; i<OffsetSize+LimitSize; i++){
                    allocations.add(new csvExportWrapper(allocationRecords[i],fieldSetApi));
                    if(allocations.size() == 1000){
                        listCSVRecords.add(allocations);
                        allocations = new List<csvExportWrapper>();
                    }
                }
                if(!allocations.isEmpty()){
                    listCSVRecords.add(allocations);
                    allocations = new List<csvExportWrapper>();
                }
            }else
            {
                for(Integer i = OffsetSize; i<totalRecs; i++){
                    allocations.add(new csvExportWrapper(allocationRecords[i],fieldSetApi));
                    if(allocations.size() == 1000){
                        listCSVRecords.add(allocations);
                        allocations = new List<csvExportWrapper>();
                    }
                }
                if(!allocations.isEmpty()){
                    listCSVRecords.add(allocations);
                    allocations = new List<csvExportWrapper>();
                }
            }
            allocationRecords.clear();
        }

    public pagereference exportAllocationRecords(){
        fileFormat = ApexPages.currentPage().getParameters().get('fileFormat');
        fileFormat = ESAPI.encoder().SFDC_HTMLENCODE(fileFormat);

        allocIds = new set<id>();
        reportDateTime = 'GLReport'+ currentDateTime();
        allocationRecords = new List<Gift_Detail__c>();
        csvRecords = new List<csvExportWrapper>();
        listExportRecords = new List<List<csvExportWrapper>>();
        for(List<csvExportWrapper> alloc : listCSVRecords){
            for(csvExportWrapper a : alloc){
                if(a.selected){
                    allocIds.add(a.allocation.id);
                    csvRecords.add(new csvExportWrapper(a.allocation,fieldSetApi));
                    if(csvRecords.size() == 1000){
                        listExportRecords.add(csvRecords);
                        csvRecords = new List<csvExportWrapper>();
                    }
                }
            }
        }
        if(!csvRecords.isEmpty()){
            listExportRecords.add(csvRecords);
            csvRecords = new List<csvExportWrapper>();
        }
        if(allocIds.size() > 0){
            jobProcess= true;
            Util.allocationUpdate(allocIds);
        }
        allocationRecords.clear();
        return null;
    }

    public pagereference exportPage(){
        if(fileFormat == 'CSV'){
            return Page.AllocationCSVPage;
        }else
        if(fileFormat == 'Excel'){
            return Page.AllocationExcelPage;
        }
        return null;
    }

    public list<SelectOption> getFileFormatList()
    {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('CSV', 'CSV'));
        options.add(new SelectOption('Excel', 'Excel'));

        return options;
    }

    public void FirstPage()
    {
        OffsetSize = 0;
        pageNumber = 1;
        searchAllocation();
    }

    public void previous()
    {
        OffsetSize = OffsetSize - LimitSize;
        pageNumber--;
        searchAllocation();
    }

    public void next()
    {
        OffsetSize = OffsetSize + LimitSize;
        pageNumber++;
        searchAllocation();
    }

    public void LastPage()
    {
        OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
        pageNumber = (Math.mod(totalRecs, LimitSize) == 0 ? totalRecs/LimitSize : (totalRecs/LimitSize) + 1);
        searchAllocation();
    }

    public boolean getprev()
    {
        if(OffsetSize == 0)
        return true;
        else
        return false;
    }

    public boolean getnxt()
    {
        if((OffsetSize + LimitSize) > totalRecs)
        return true;
        else
        return false;
    }
    public string currentDateTime(){
        Integer YearInt = Date.Today().year();
        Integer monthInt = Date.Today().month();
        Integer dayInt = Date.Today().Day();
        Integer hourInt = Datetime.Now().Hour();
        Integer minInt = Datetime.Now().minute();
        Integer secInt = Datetime.Now().second();
        String concatenatedDateTime = String.valueof(YearInt)+String.valueof(monthInt)+String.valueof(dayInt)+String.valueof(hourInt)+String.valueof(minInt)+String.valueof(secInt);
        return concatenatedDateTime;
    }

    public PageReference pausingExecution()
    {
            PageReference pgref;
            list<AsyncApexJob> job = new AsyncApexJobSelector().SelectStatusByTodayAndMethodName('allocationUpdate');
            if(job.size()>0){
                if(job[0].Status == 'Queued' || job[0].Status=='Preparing' || job[0].Status=='Processing'){
                    return null ;
                }
                if(job[0].Status == 'Completed' ){
                    jobProcess= false;
                    callSearchAllocationMethod();
                }
                if(job[0].Status == 'Aborted' || job[0].Status == 'Failed' || job[0].Status == 'Holding' ){
                    jobProcess= false;
                    job[0].addError('Error occurred during updating Allocations');
                    return null;
                }
            }
            return null;
    }

    public class csvExportWrapper{
        public Gift_Detail__c allocation{get;set;}
        public string debit{get;set;}
        public string credit{get;set;}
        Public string allocationDate {get;set;}
        Public string allocationDate1 {get;set;}
        Public string reference{get;set;}
        public boolean selected{get;set;}
        Public string transactionDate {get;set;}

        public decimal amount1{get; set;}
        public list<String> fieldSetValues {get;set;}


        public csvExportWrapper(Gift_Detail__c a, List<String> fieldSetApi){
            fieldSetValues = new List<String>();

            allocation = a;
            allocationDate1=string.valueOf(a.Allocation_Date__c);
            selected = false;
            transactionDate = string.valueOf(a.Gift__r.Gift_Date__c);
            if(a.Payment__r.Status__c == 'Committed'){
                allocationDate = string.valueOf(a.Gift__r.Gift_Date__c);
            }else
            {
                allocationDate = string.valueOf(a.Allocation_Date__c);
            }
            reference = parseReference(a);
            debit = 'D';
            Credit = 'C';
            if(a.Approved_Amount__c != null) {
                amount1= a.Approved_Amount__c;
                amount1= amount1.setScale(2, RoundingMode.HALF_UP);
                }


             for(integer i=0;i<fieldSetApi.size();i++)
             {
                String ReferenceId = fieldSetApi[i];

                if(fieldSetApi[i] != null)
                {
                    if(ReferenceId.contains('r.Name'))
                     {
                        ReferenceId = ReferenceId.replace('r.Name','c');
                        if(a.get(ReferenceId) != null)
                        {
                             String RefrenceApiName = fieldSetApi[i];
                             RefrenceApiName = RefrenceApiName.replace('.Name','');
                             fieldSetValues.add(String.valueOf(a.getSobject(RefrenceApiName).get('Name')));
                        }
                        else
                             fieldSetValues.add('');
                    }
                    else
                      fieldSetValues.add(String.valueOf(a.get(fieldSetApi[i])));
                }

             }
        }

        public String parseReference(Gift_Detail__c allocation){
            Pattern myPattern = Pattern.compile('>(.*?)</a>');
            Matcher MyMatcher = MyPattern.matcher(allocation.Constituent__c);
            MyMatcher.find();
            string constituent = MyMatcher.group(1);
            return constituent;
        }
    }
    public List<string> Addfieldset()
    {
       buildquery ='';
       List<Schema.FieldSetMember> Allocationfieldset = getFields();
       List<string> ApinameFieldsetNameList = new List<String>();
       fieldSetLabel = new List<String>();
       fieldSetLabelMap = new map<String, string>();
       for(Schema.FieldSetMember f : Allocationfieldset)
       {
           if(String.valueOf(f.getType()).equalsIgnoreCase('REFERENCE'))
           {
               String referenceApiName;
               if(String.valueOf(f.getFieldPath()).contains('__c'))
                   referenceApiName = String.valueOf(f.getFieldPath()).replace('__c','__r.Name');
               else
                   referenceApiName = String.valueOf(f.getFieldPath()+'.Name');

               ApinameFieldsetNameList.add(referenceApiName);
                buildquery += ','+ referenceApiName;
                fieldSetLabel.add(f.getLabel());
                fieldSetLabelMap.put(f.getLabel(), referenceApiName);
           }
           else
           {
                ApinameFieldsetNameList.add(f.getFieldPath());
                buildquery += ','+ f.getFieldPath();
                fieldSetLabel.add(f.getLabel());
                fieldSetLabelMap.put(f.getLabel(), f.getFieldPath() );
           }
       }

       integer i= ApinameFieldsetNameList.size();
       return ApinameFieldsetNameList;
    }
    public List<Schema.FieldSetMember> getFields()
    {
       return SObjectType.Gift_Detail__c.FieldSets.Post_To_Finance.getFields();
    }

   public String sortExpression
   {
     get
     {
         return sortExp;
     }
     set
     {
       sortExpressionLabel= value;
       if(fieldSetLabelMap.keyset().contains(value)){
           value=fieldSetLabelMap.get(value);
       }
       if (value == sortExp){
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       }else{
             sortDirection = 'ASC';
             if(fieldSetLabelMap.keyset().contains(value)){
               sortExp=fieldSetLabelMap.get(value);
             }else{
                 sortExp = value;
             }
         }
     }
   }

   public String sortExpressionLabel
   {
     get
     {
         return sortExpLabel;
     }
     set
     {
         sortExpLabel=value;
     }
   }

    public String getSortDirection()
    {
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
          return sortDirection;
    }

     public void setSortDirection(String value)
     {
       sortDirection = value;
     }
}