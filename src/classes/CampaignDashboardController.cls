public with sharing class CampaignDashboardController {
    public List<Util.PieWedgeData> allocByMonth { get; set; }
    public List<Util.PieWedgeData> allocByDonorLevel { get; set; }
    public Campaign camp { get; set; }
    public boolean hasDonorLevel { get; set; }
    public boolean hasAllocation { get; set; }
   
    public CampaignDashboardController(ApexPages.StandardController controller) {
       string campId = ApexPages.currentPage().getParameters().get('id');
       if (campId==null || campId=='') {
         return;
       }
       List<Campaign> campaignList = new CampaignSelector().SelectIdNameFundLetterRecordTypeIdById(new Set<Id> { campId });
       if (campaignList != null && campaignList.size() > 0) {
         camp = campaignList[0];
       }
       
       loadAllocByMonth(campId);
       loadAllocByDonorLevel(campId);
    }
    
    public void loadAllocByMonth(string campId) {
       allocByMonth = new List<Util.PieWedgeData>();
       AggregateResult[] aggrRecs = null;
       
       if (camp!=null && camp.RecordTypeId == Util.GetRecordTypeId('Campaign','Campaign')) {
          aggrRecs = new AllocationSelector().SelectSumAmountAndMonthByIdAndCurrentYearByCampaignId(campId);
       }
       else {
          aggrRecs = new AllocationSelector().SelectSumAmountAndMonthByIdAndCurrentYearByNewCampaignId(campId);
       }
       
       if (aggrRecs!=null && aggrRecs.size()>0) {
          integer inx = 1;
          hasAllocation = true;
          for(integer i=inx;i<=12;i++) {
              AggregateResult result = Util.findItem(aggrRecs, i, 'month');
              if (result!=null)
                 allocByMonth.add(new Util.PieWedgeData(string.valueOf(result.get('month')),(decimal)result.get('total'))); 
              else
                 allocByMonth.add(new Util.PieWedgeData(string.valueOf(i),0)); 
               inx++;
          }
       } 
    }
    
    
    public void loadAllocByDonorLevel(string campId)
    {
       allocByDonorLevel = new List<Util.PieWedgeData>();
       AggregateResult[] aggrRecs = null;
       
       if (camp!=null && camp.RecordTypeId == Util.GetRecordTypeId('Campaign','Campaign'))
       {
          // Keeping a note here that a SOQL query was deleted because it tried to GROUP BY Contact.First_Time_Donor__c, which is not groupable
       }
       else
       {
          aggrRecs = new AllocationSelector().SelectSumAmountAndDonorSegmentationByCampaignId(campId);
       }
       
       if (aggrRecs!=null && aggrRecs.size()>0)
       {
          hasDonorLevel = true;
          for(AggregateResult r : aggrRecs)
          {
             string level = (r.get('level')==null)? 'Unknown' : string.valueOf(r.get('level'));
             allocByDonorLevel.add(new Util.PieWedgeData(level,(decimal)r.get('total'))); 
          }
       } 
        
    }
}