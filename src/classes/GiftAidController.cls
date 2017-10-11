public with sharing class GiftAidController {
/*--------------------------- GiftAidController---------------------------------
|  Class GiftAidController
|
|  Purpose: Controller for Gift_Aid.page visualforce page.
|
|  Last Modified Date: 07/03/2017
 *----------------------------------------------------------------------------*/

//  TODO: To keep a record of claims sent, export data to file and save to Documents
//  TODO: Popout toolbox (select all, select page/ deselect all, deselect page)
//  ==
//  REF: https://www.datatables.net/forums/discussion/31113/call-print-from-a-custom-button
//  REF: http://salesforce.stackexchange.com/questions/46943/return-custom-event-message-using-javascript-remoting

    public static String PackageNamespace { get; set; }
    public static String Instance { get{ return Utilities.GetInstance();} }

    private static final App_Settings__c AppSettings = Utilities.GetAppSettings();

    public Boolean IsGiftAidEnabled { get{ return Utilities.IsGiftAidEnabled();} }

    public List<String> validPayments = new List<String>(Utilities.CommaDelimitedStringToList(AppSettings.Gift_Aid_Eligible_Payment_Types__c, false));

    private String fields = 'ID, Name, Claim_Reference_Number__c, Constituent__c, Gift_Aid_Claim_Status__c, Gift_Aid_Declaration__c, Date__c, Gift_Aid_Amount__c, Gift_Aid_Claim_Date__c, Gift_Aid_Received_Date__c, Gift_Aid_Rejected_Date__c, Status__c, Gift_Aid_Declaration__r.Name, Gift_Aid_Declaration__r.isActive__c, Gift_Aid_Declaration__r.Donor__r.Title, Gift_Aid_Declaration__r.Donor__r.Salutation, Donation__r.Constituent__r.FirstName, Donation__r.Constituent__r.LastName, Donation__r.Constituent__r.MailingStreet, Donation__r.Constituent__r.MailingPostalCode';
    private String  criteria = 'WHERE '
                    + 'Gift_Aid_Eligible__c = true AND '
                    + 'Gift_Aid_Amount__c > 0 AND '
                    + 'Gift_Aid_Declaration__c != \'\' AND '
                    + buildInPaymentType();

    private string buildInPaymentType() {
        String inPaymentType = '(';
        for(String paymentType: validPayments){
            inPaymentType += 'Payment_Type__c = \'' + paymentType + '\' OR ';
        }
        inPaymentType = inPaymentType.removeEnd(' OR ');
        inPaymentType += ')';
        return inPaymentType;
    }

    // GIFT AID STATUS
    private String notclaimed = ' AND Gift_Aid_Claim_Status__c = \'Not claimed\' AND Gift_Aid_Declaration__r.isActive__c = True';
    private String claimed = ' AND Gift_Aid_Claim_Status__c = \'Claimed not received\'';
    private String received = ' AND Gift_Aid_Claim_Status__c = \'Received\'';
    private String rejected = ' AND Gift_Aid_Claim_Status__c = \'Rejected\'';
    private String toBeRefunded = ' AND Gift_Aid_Claim_Status__c = \'To Be Refunded\'';
    private String refunded = ' AND Gift_Aid_Claim_Status__c = \'Refunded\'';
    // QUERY
    private String buildNotClaimedQuery = 'SELECT '+ fields +' FROM Payment__c '+ criteria + notclaimed;
    private String buildClaimedQuery = 'SELECT '+ fields +' FROM Payment__c '+ criteria + claimed;
    private String buildReceivedQuery = 'SELECT '+ fields +' FROM Payment__c '+ criteria + received;
    private String buildRejectedQuery = 'SELECT '+ fields +' FROM Payment__c '+ criteria + rejected;
    private String buildToBeRefundedQuery = 'SELECT '+ fields +' FROM Payment__c '+ criteria + toBeRefunded;
    private String buildRefundedQuery = 'SELECT '+ fields +' FROM Payment__c '+ criteria + refunded;

    public String tbcQuery { get; set; }
    public String cnrQuery { get; set; }
    public String recQuery { get; set; }
    public String rejQuery { get; set; }
    public String tbrQuery { get; set; }
    public String refQuery { get; set; }

    public GiftAidController(){
        init();
    }

    public void init(){
        tbcQuery = buildNotClaimedQuery;
        cnrQuery = buildClaimedQuery;
        recQuery = buildReceivedQuery;
        rejQuery = buildRejectedQuery;
        tbrQuery = buildToBeRefundedQuery;
        refQuery = buildRefundedQuery;
        SetNamespace();
    }

    public static List<Application_Setting__c> getGiftAidAutoNumber(){
      List<Application_Setting__c> giftAidCVAppSettings = new ApplicationSettingSelector().SelectSObjectsByNameLimit('Gift Aid Claim Auto Number Setting', 1);
      if(giftAidCVAppSettings.size() <= 0 || giftAidCVAppSettings == null ){
        Application_Setting__c newgiftAidCVAppSettings = new Application_Setting__c(Name = 'Gift Aid Claim Auto Number Setting', Org_Count__c = 1);
        DMLManager.InsertSObject(newgiftAidCVAppSettings);
        giftAidCVAppSettings.add(newgiftAidCVAppSettings);
      }
      return giftAidCVAppSettings;
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

    @RemoteAction
    public static RemoteResponse UpdateNotClaimed(String ids) {
      RemoteResponse response = new RemoteResponse();
      // response.data = new List<String>();
      // response.message = new List<String>();
      try{
        List<String> paymentIdList = Utilities.CommaDelimitedStringToList(Utilities.RemoveSquareBracketsFromString(ids),true);

        Integer numberOfIds = paymentIdList.size();
        Document doc = new Document();

        List<Payment__c> paymentList = new PaymentSelector().SelectAllPaymentAndContactInfoById(Utilities.ConvertStringListToIdSet(paymentIdList));
        List<Application_Setting__c> giftAidAutoNumber = getGiftAidAutoNumber();
        giftAidAutoNumber[0].Org_Count__c++;

        if(paymentList.size() > 0){
          String b = generateCSV(paymentList);

          for(Payment__c p: paymentList){
            p.Claim_Reference_Number__c = giftAidAutoNumber[0].Org_Count__c;
            p.Gift_Aid_Claim_Status__c = 'Claimed not received';
            p.Gift_Aid_Claim_Date__c = Date.Today();
          }
          
          DMLManager.UpdateSObjects(giftAidAutoNumber);
          DMLManager.UpdateSObjects(paymentList);

          // send to current user email
          // String emailAddress = 'salesforce@breakeveninc.com';
          String emailAddress = UserInfo.getUserEmail();
          String emailSubject = 'Gift Aid Claim';
          String emailBody = '<html xmlns="http://www.w3.org/1999/xhtml"> <head> <meta name="viewport" content="width=device-width"/> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> <title>Causeview Notification</title> </head> <body style="-webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%; line-height: 1.6; background-color: #f6f6f6; font-family: \'Helvetica Neue\', \'Helvetica\', Helvetica, Arial, sans-serif;"> <table style="background-color: #f6f6f6; width: 100%;" class="body-wrap"> <tbody><tr> <td style="vertical-align: top;"></td> <td style="vertical-align: top; display: block !important; max-width: 960px !important; margin: 0 auto !important; /* makes it centered */ clear: both !important;" class="container" width="600"> <div style="max-width: 600px; margin: 0 auto; display: block; padding: 20px;" class="content"> <table style="background: #f6f6f6; border-radius: 3px; padding-bottom:20px;" class="main" width="100%" cellpadding="0" cellspacing="0"> <tbody> <tr> <td> <p style="text-align:center;"> <img src="http://causeview.com/wp-content/uploads/2016/04/Causeview-Inc-Transparent-Logo-Final-385x100.png" alt="Causeview"/> </p> </td> </tr> </tbody> </table> <table style="background: #fff; border: 1px solid #e9e9e9; border-radius: 3px;" class="main" width="100%" cellpadding="0" cellspacing="0"> <tbody><tr> <td style="vertical-align: top; font-size: 16px; color: #fff; font-weight: 500; padding: 20px; text-align: center; border-radius: 3px 3px 0 0; background: #1981ff;" class="alert alert-good"> New Gift Aid Claim </td> </tr> <tr> <td style="vertical-align: top; padding: 20px;" class="content-wrap"> <table width="100%" cellpadding="0" cellspacing="0"> <tbody> <tr> <td style="vertical-align: top;padding: 0 0 20px;text-align: left;" class="content-block">'
            +'<p>Dear '+UserInfo.getFirstName()+',</p> <p>Please find, attached to this email, a copy of your Gift Aid Claim file (Claim Reference Number: '+giftAidAutoNumber[0].Org_Count__c+') produced on '+DateTime.Now()+'.</p>'
            +'<p>Sent from</p> <p>Causeview</p>'
            +'</td> </tr> </tbody></table> </td> </tr> </tbody></table> <div style="width: 100%; clear: both; color: #999; padding: 20px;" class="footer"> <table width="100%"> <tbody><tr> <td style="vertical-align: top; padding: 0 0 20px; text-align: center; font-size: 12px;" class="aligncenter content-block">'
            +'Powered By <a href="http://www.causeview.com/" style="color: #1981ff; text-decoration: none;"><span><img src="http://causeview.com/wp-content/uploads/2016/04/favicon-16x16-1.png" width="10px"/></span> Causeview</a><br/>© Copyright 2008-'+DateTime.Now().year()+'<br/> </td> </tr> </tbody></table> </div></div> </td> <td style="vertical-align: top;"></td> </tr> </tbody></table> </body></html> ';
          String emailAttachmentName = 'Gift-Aid-Claim.csv';

          Utilities.SendingEmail(new String[]{emailAddress}, emailSubject, null, emailBody, emailAttachmentName, Blob.valueOf(b));

          response.data.add(b);
          response.data.add(String.valueOf(giftAidAutoNumber[0].Org_Count__c));

          response.status = ResponseStatus.SUCCESS;
          response.message.add( 'GiftAidController | UpdateNotClaimed(): email successfully sent.' );
        }else{
          response.message.add( 'GiftAidController | UpdateNotClaimed(): payment list size == 0' );
          response.status = ResponseStatus.ERROR;
        }
        return response;
      } catch( System.Exception e ){
        response.status = ResponseStatus.ERROR;
        response.message.add( 'GiftAidController | UpdateNotClaimed() |  Exception: ' + String.valueOf(e));
        return response;
      }
    }

    @RemoteAction
    public static RemoteResponse UpdateClaimed(String ids, String status) {
      RemoteResponse response = new RemoteResponse();
      try{
        if(String.isNotBlank(ids) && String.isNotBlank(status)) {
            //The string is not empty or blank or null
            List<String> paymentIdList = Utilities.CommaDelimitedStringToList(Utilities.RemoveSquareBracketsFromString(ids),true);
            Integer numberOfIds = paymentIdList.size();

            List<Payment__c> paymentList = new PaymentSelector().SelectGiftAidAndContactInfoById(Utilities.ConvertStringListToIdSet(paymentIdList));

            if(paymentList.size() > 0){
                  for(Payment__c p: paymentList){ p.Gift_Aid_Claim_Status__c = status.capitalize(); }

                  DMLManager.UpdateSObjects(paymentList);

                  String s = line(new String[] {
                          format('Claim Reference Number'),
                          format('Payment'),
                          format('Payment Id'),
                          format('Donor'),
                          format('Gift Aid Received Date'),
                          format('Gift Aid Amount'),
                          format('Gift Aid Claim Status'),
                          format('Gift Aid Declaration')
                          });
                  for (Payment__c p : paymentList) {
                      s += line(new String[] {
                          format(p.Claim_Reference_Number__c),
                          format(p.Name),
                          format(p.Id),
                          format(p.Donation__r.Constituent__r.FirstName + ' ' + p.Donation__r.Constituent__r.LastName),
                          format(p.Gift_Aid_Received_Date__c),
                          format(p.Gift_Aid_Amount__c),
                          format(p.Gift_Aid_Claim_Status__c),
                          format(p.Gift_Aid_Declaration__c)
                        });
                  }

                  response.data.add(s);
                  response.message.add( 'GiftAidController | UpdateClaimed(): csv generated');

                  // send to current user email
                  // String emailAddress = 'salesforce@breakeveninc.com';
                  String emailAddress = UserInfo.getUserEmail();
                  String emailSubject = 'Gift Aid Claim';

                  if(status == 'received'){
                    emailSubject = 'Gift Aid Claims Marked Received';
                  }

                  if(status == 'rejected'){
                    emailSubject = 'Gift Aid Claims Marked Rejected';
                  }

                  if(status == 'to be refunded'){
                    emailSubject = 'Gift Aid Claims Marked To Be Refunded';
                  }
                  if(status == 'refunded'){
                    emailSubject = 'Gift Aid Claims Marked Refunded';
                  }
                  String emailBody = '<html xmlns="http://www.w3.org/1999/xhtml"> <head> <meta name="viewport" content="width=device-width"/> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> <title>Causeview Notification</title> </head> <body style="-webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%; line-height: 1.6; background-color: #f6f6f6; font-family: \'Helvetica Neue\', \'Helvetica\', Helvetica, Arial, sans-serif;"> <table style="background-color: #f6f6f6; width: 100%;" class="body-wrap"> <tbody><tr> <td style="vertical-align: top;"></td> <td style="vertical-align: top; display: block !important; max-width: 960px !important; margin: 0 auto !important; /* makes it centered */ clear: both !important;" class="container" width="600"> <div style="max-width: 600px; margin: 0 auto; display: block; padding: 20px;" class="content"> <table style="background: #f6f6f6; border-radius: 3px; padding-bottom:20px;" class="main" width="100%" cellpadding="0" cellspacing="0"> <tbody> <tr> <td> <p style="text-align:center;"> <img src="http://causeview.com/wp-content/uploads/2016/04/Causeview-Inc-Transparent-Logo-Final-385x100.png" alt="Causeview"/> </p> </td> </tr> </tbody> </table> <table style="background: #fff; border: 1px solid #e9e9e9; border-radius: 3px;" class="main" width="100%" cellpadding="0" cellspacing="0"> <tbody><tr> <td style="vertical-align: top; font-size: 16px; color: #fff; font-weight: 500; padding: 20px; text-align: center; border-radius: 3px 3px 0 0; background: #1981ff;" class="alert alert-good"> New Gift Aid Claim </td> </tr> <tr> <td style="vertical-align: top; padding: 20px;" class="content-wrap"> <table width="100%" cellpadding="0" cellspacing="0"> <tbody> <tr> <td style="vertical-align: top;padding: 0 0 20px;text-align: left;" class="content-block">'
                    +'<p>Dear '+UserInfo.getFirstName()+',</p> <p>Please find, attached to this email, a copy of your Gift Aid Claim file produced on '+DateTime.Now()+'.</p>'
                    +'<p>Sent from</p> <p>Causeview</p>'
                    +'</td> </tr> </tbody></table> </td> </tr> </tbody></table> <div style="width: 100%; clear: both; color: #999; padding: 20px;" class="footer"> <table width="100%"> <tbody><tr> <td style="vertical-align: top; padding: 0 0 20px; text-align: center; font-size: 12px;" class="aligncenter content-block">'
                    +'Powered By <a href="http://www.causeview.com/" style="color: #1981ff; text-decoration: none;"><span><img src="http://causeview.com/wp-content/uploads/2016/04/favicon-16x16-1.png" width="10px"/></span> Causeview</a><br/>© Copyright 2008-'+DateTime.Now().year()+'<br/> </td> </tr> </tbody></table> </div></div> </td> <td style="vertical-align: top;"></td> </tr> </tbody></table> </body></html> ';
                  String emailAttachmentName = 'Gift-Aid-File.csv';

                  Utilities.SendingEmail(new String[]{emailAddress}, emailSubject, null, emailBody, emailAttachmentName, Blob.valueOf(s));

                  response.message.add( 'GiftAidController | UpdateClaimed(): email successfully sent');
                  response.status = ResponseStatus.SUCCESS;
            }else{
              response.message.add( 'GiftAidController | UpdateNotClaimed(): payment list size == 0' );
              response.status = ResponseStatus.ERROR;
            }
            return response;
        }
        else {
            response.status = ResponseStatus.ERROR;
            response.message.add( 'GiftAidController | UpdateClaimed(): params empty or blank or null' );
            return response;
        }
      } catch( System.Exception e ){
        response.status = ResponseStatus.ERROR;
        response.message.add( 'GiftAidController | UpdateNotClaimed() |  DmlException: ' + String.valueOf(e));
        return response;
      }
    }

    public static String generateCSV(List<Payment__c> paymentList) {
        String s = line(new String[] {
          format('Title'),
          format('First Name'),
          format('Last Name'),
          format('House Name or number'),
          format('Postalcode'),
          format(''),
          format(''),
          format('Donation Date'),
          format('Amount')
        });
        for (Payment__c p : paymentList) {
          s += line(new String[] {
            format(p.Gift_Aid_Declaration__r.Donor__r.Salutation),
            format(p.Donation__r.Constituent__r.FirstName),
            format(p.Donation__r.Constituent__r.LastName),
            format(p.Donation__r.Constituent__r.MailingStreet),
            format(p.Donation__r.Constituent__r.MailingPostalCode),
            format(' '),
            format(' '),
            format(p.Date__c),
            format(p.Gift_Aid_Amount__c)
          });
        }
        return s;
    }

    private static String line(String[] cells) {
        return String.join(cells, ',') + '\n';
    }
    private static String format(Date d)    {
        return d != null ? '"' + d.format().escapeCsv() + '"' : '""';
    }
    private static String format(String s) {
        return s != null ? s.escapeCsv() : '""';
    }
    private static String format(Decimal d, Integer scale) {
        return d != null ? String.valueOf(d.setScale(scale)) : '';
    }
    private static String format(Decimal d) {
        return format(d, 2);
    }

    public enum ResponseStatus { SUCCESS, ERROR }
    public with sharing class RemoteResponse {
        public ResponseStatus status { get; set; }
        public List<Object> data { get; set; }
        public List<String> message { get; set; }
        public RemoteResponse() {
            this.status = null;
            this.data = new List<Object>();
            this.message = new List<String>();
        }
        public RemoteResponse(ResponseStatus status, List<Object> data, List<String> message) {
            this.status = status;
            this.data = data;
            this.message = message;
        }
    }

    public static String isPackaged{ get{
      Boolean isManaged, isUserLicensed;
      String namespacePrefix = '';
      try {
        isUserLicensed = UserInfo.isCurrentUserLicensed(namespacePrefix);
        isManaged = true;
      } catch(exception e) {
        isManaged = false;
      }
      return isManaged ? namespacePrefix : '' ;
    }}

    private static void SetNamespace()
    {
      String namespace = Utilities.getCurrentNamespace();
      PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
    }
}