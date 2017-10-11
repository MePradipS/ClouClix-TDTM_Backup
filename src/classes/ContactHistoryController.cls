public with sharing class ContactHistoryController {
    public List<PieWedgeData> amountByFund { get; set; }
    public List<PieWedgeData> amountByYear { get; set; }
    public boolean hasdata1 { get; set; }
    public boolean hasdata2 { get; set; }
    
    public ContactHistoryController(ApexPages.StandardController controller) {
       string contactId = ApexPages.currentPage().getParameters().get('id');
       loadGivingByFund(contactId);
       loadGivingByYear(contactId);
    }
    
    public void loadGivingByYear(string contactId)
    {
       Date today = Date.today();
       integer currentYear = today.year();
       amountByYear = new List<PieWedgeData>();
       
       AggregateResult[] aggrYears = new GiftSelector().SelectAmountAndYearByConstituentAndPastFourYears(contactId);
              
       if (aggrYears!=null && aggrYears.size()>0)
       {
          hasdata1 = true;
          integer inx = currentYear - 4;
          for(integer i=inx;i<=currentYear;i++)
          {
              AggregateResult result = findItem(aggrYears, inx, 'year');
              if (result!=null)
                 amountByYear.add(new PieWedgeData(string.valueOf(result.get('year')),(decimal)result.get('total'))); 
              else
                 amountByYear.add(new PieWedgeData(string.valueOf(inx),0)); 
               inx++;
          }
       } 
       
    }
    
    public void loadGivingByFund(string contactId)
    {
       AggregateResult[] groupedResults = new AllocationSelector().SelectSumAmountAndFundByConstituent(contactId);
       
       List<Gift_Detail__c> allocations = new AllocationSelector().SelectIdAndFundByConstituent(contactId);
       
       amountByFund = new List<PieWedgeData>();
       if (groupedResults!=null && groupedResults.size()>0) {
           
           for(AggregateResult result :groupedResults) {
             string fundId = (string)result.get('Fund__c');
             if (fundId==null) 
               fundId = 'Unknown'; 
             else 
             {  
                Gift_Detail__c gd = (Gift_Detail__c)FindObject(allocations, fundId, 'Fund__c'); 
                if (gd!=null)
                  fundId = gd.Fund__r.Fund_Name__c;
              }
             amountByFund.add(new PieWedgeData(fundId, (decimal)result.get('total')));
           }
          hasdata2 = true;
      }
    }
    
    
    
    // Wrapper class 
    public class PieWedgeData {

        public String name { get; set; }
        public decimal data { get; set; }
       
        public PieWedgeData(String name, decimal data) {
         Integer size = name!=null?name.length() : 0;
         Integer i=0;         
        if (size > 32) {//User story : #101128482  shridhar
            Integer j=0;
            this.name='';
            for(i=27;i<size;i+=27){            
                this.name+= name.subString(j, i); 
                this.name+='\n';
                j=i-1;
            }
            this.name+= name.subString(j, size);     
        
        }else{            
            this.name = name;
        }
            this.data = data;
        }
    }
    
    public AggregateResult FindItem(List<AggregateResult> objects, object value, string property)
    {
     for(AggregateResult obj : objects)
      if (obj.get(property) == value)
       return obj;
       
     return null;
    }
    
    public Sobject FindObject(List<Sobject> objects, object value, string property)
    {
     for(Sobject obj : objects)
      if (obj.get(property) == value)
       return obj;
       
     return null;
    }
}