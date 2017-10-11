public with sharing class recurringMaintController extends RedirectController {

    public string recurringDonationId { get; set; }
    public Recurring_Donation__c recurringDonation { get; set; }
    public integer wizardStep { get; set; }
    public string recurringAction { get; set; }

    //administration
    public boolean isValid { get; set; }

    //meta data
    public string ccName { get; set; }
    public string ccType { get; set; }
    public string ccNumber { get; set; }
    public integer expirationMonth { get; set; }
    public integer expirationYear { get; set; }
    public string securityCode { get; set; }
    public App_Settings__c settings { get; set; }

    //contructor
    public recurringMaintController()
    {
        super(true);
        wizardStep = 1;
        recurringDonationId = ApexPages.currentPage().getParameters().get('id');
        if (ApexPages.currentPage().getParameters().get('action')=='cancel') {
           wizardStep = 3;
           recurringAction = '1';
        } else if (ApexPages.currentPage().getParameters().get('action')=='shortupdate') {
           recurringAction = '5';
        } else {
            recurringAction = '0';
        }
        settings = App_Settings__c.getInstance();
    }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

    public PageReference init()
    {
      PageReference redirectTheme = RedirectByTheme();
      if(redirectTheme != null){
        return redirectTheme;
      }
       isValid = false;
       List<Recurring_Donation__c> rds = new RecurringDonationSelector().SelectEncryptedKey(recurringDonationId);
       if (rds!=null && rds.size()>0)
       {
         recurringDonation = rds[0];
       }

       isValid = (recurringDonation != null && recurringDonation.Status__c =='Active');

       //update CC info operation
       if (!isValid && recurringAction == '0')
       {
          apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: The record does not meet the criteria for this operation. It may not be Active or type may not be Credit Card'));
          wizardStep = 2;
       }

       if (!isValid && recurringAction == '1')
       {
            apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: The record does not meet the criteria for this operation. It may not be Active recurring.'));
            wizardStep = 2;
       }

       return null;

    }

    public List<SelectOption> getYearItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Year-'));

        Date d = Date.Today();
        integer year = d.year();
        for(integer i=year; i<year+10; i++)
        {
           string val = i.format().replaceAll(',','');
           options.add(new SelectOption(val, val));
        }
        return options;
    }

    public PageReference cancel()
    {
      string retUrl = '/'+recurringDonationId;
      PageReference pageRef = new PageReference(retUrl);
      pageRef.setRedirect(true);
      return pageRef;
    }
}