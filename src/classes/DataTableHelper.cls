public with sharing class DataTableHelper{
    // todo: error handling for invalid query
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    Public Integer start{get;set;}
    string queryString;
    public ApexPages.StandardSetController setCon {get;set;}
    public DataTableHelper(){}
    public string dataTableJson {get;set;}

    public void processData(){
        try{
            queryString = ApexPages.currentPage().getParameters().get('q');
            string searchKey = ApexPages.currentPage().getParameters().get('search[value]');
            if(searchKey != null && searchKey != '' && searchKey.trim().length() > 0){
                //queryString += ' AND FirstName like \'%'+searchKey+'%\' or LastName like \'%'+searchKey+'%\'';
            }
            integer i = 0;
            String str = 'order[0][column]';

            queryString += ' order by ' + ApexPages.currentPage().getParameters().get('columns['+ApexPages.currentPage().getParameters().get(str) + '][data]') + ' ' +
                                    ApexPages.currentPage().getParameters().get('order[0][dir]');
            queryString += ' NULLS LAST';
            start= Integer.valueOf(ApexPages.currentPage().getParameters().get('start'));
            size = Integer.valueOf(ApexPages.currentPage().getParameters().get('length'));
            setCon = new ApexPages.StandardSetController(new PaymentSelector().SelectDataTablesQueryFields(queryString));
            setCon.setPageSize(size);
            noOfRecords= setCon.getResultSize();
            setCon.setPageNumber((start/size)+1);
            List<sobject> contactList = setCon.getRecords();

            DataTableWrapper datawrap = new DataTableWrapper(0,noOfRecords,noOfRecords,contactList );
            dataTableJson = JSON.serialize(datawrap);
        } catch( DmlException e){
            dataTableJson = '{"recordsTotal":0,"recordsFiltered":0,"draw":0,"data":[]}';
        } catch( QueryException e){
            dataTableJson = '{"recordsTotal":0,"recordsFiltered":0,"draw":0,"data":[]}';
        } catch( ListException  e){
            dataTableJson = '{"recordsTotal":0,"recordsFiltered":0,"draw":0,"data":[]}';
        } catch( Exception e){
            dataTableJson = '{"recordsTotal":0,"recordsFiltered":0,"draw":0,"data":[]}';
        }
    }
    public class DataTableWrapper{
        public Integer draw;
        public Integer recordsTotal;
        public Integer recordsFiltered;
        public List<sobject> data;
        public DataTableWrapper(Integer draw,Integer recordsTotal,Integer recordsFiltered,list<contact> data){
            this.draw = draw;
            this.recordsTotal = recordsTotal;
            this.recordsFiltered = recordsFiltered ;
            this.data = data;
        }

    }

}