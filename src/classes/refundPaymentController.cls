public with sharing class refundPaymentController extends RedirectController {

   public string paymentId { get; set; }
   public Payment__c payment { get; set; }
   public boolean isValid { get; set; }
   public boolean showComments { get; set; }
   public Decimal totalRefunded { get; set; }
   public Decimal paymentAmount { get; set; }

   public integer wizardStep { get; set; }
   // test edit  commit test
   public refundPaymentController()
   {
      super(true);

      paymentId = ApexPages.currentPage().getParameters().get('id');
      paymentId = ESAPI.encoder().SFDC_HTMLENCODE(paymentId);
      init();
   }

    protected override String SetRedirectPage(){ return getPageUrl(); }
    protected override String SetUrlParameters(){ return getUrlParams(); }

   public void init()
   {
      //initial values
      isValid = false;
      showComments = false;
      wizardStep = 1;
      paymentAmount = 0;
      totalRefunded = 0;
      
      List<Payment__c> payments = new PaymentSelector().SelectRefundedPaymentInfo(paymentId);
      if (payments!=null && payments.size()>0)
      {
         payment = payments[0];
         isValid = (payment.Status__c == 'Approved');
         paymentAmount = payment.Amount__c;
      }

      totalRefunded = RefundedAmount(paymentId);
      if (payment != null && (payment.Amount__c - totalRefunded) <= 0)
      {
         isValid = false;
      }
   }

   public void refresh()
   {
      if (payment.Refund_Reason__c == 'Other')
       showComments = true;
      else
       showComments  = false;
   }

   public PageReference submit()
   {
       Map<String, String> rtypes_Map = new Map<String, String>();
      //valiation
      if (payment==null)
        return null;

      //get refunded payments
      totalRefunded  = RefundedAmount(paymentId);
      Decimal maxRefund = paymentAmount - totalRefunded;

      if (payment.Amount__c > maxRefund)
      {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Invalid amount. Maximum possible refund amount is: ' + maxRefund.format() ));
         return null;
      }

        try
        {
            if (payment.Payment_Type__c == 'Credit Card' || payment.Payment_Type__c == 'ACH/PAD' || payment.Payment_Type__c == 'ACH/EFT' || payment.Payment_Type__c == 'Direct Debit') {
                BatchGateway4.GatewaySoap gateway = RollupHelper.newGPServiceInstance();
                ID pid = paymentId;
                String refundReason = payment.Refund_Reason__c;

                if (refundReason!=null && refundReason.toLowerCase() == 'other' && !RollupHelper.IsEmptyOrNull(payment.Refund_Comments__c))
                    refundReason += ':' + payment.Refund_Comments__c;

                BatchGateway4.TransactionResult result = gateway.SubmitRefund(pid,payment.Amount__c,refundReason);
                if (result.Errors != null && result.Errors.ErrorMessages != null && result.Errors.ErrorMessages.size()>0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'The refund request failed, this may be due to the fact that the payment is already refunded. please contact the administrator for more information.'));
                    List<BatchGateway4.ErrorMessages> msgs = result.Errors.ErrorMessages;

                    for (BatchGateway4.ErrorMessages msg : msgs) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg.ErrorCode + ' : '+ msg.Error ));
                    }
                    return null;
                }
                else
                {
                    wizardStep = 2;
                }

            } else {
                wizardStep = 2;
                Payment__c refund = new Payment__c();
                refund.Amount__c = 0 - payment.Amount__c;
                refund.Donation__c = payment.Donation__c;
                refund.Date__c = Date.Today();
                refund.Status__c = 'Refunded';
                refund.Payment_Refunded__c = payment.Id;
                refund.Payment_Type__c = payment.Payment_Type__c;
                refund.RecordTypeId = Utilities.getObjectRecordTypeId(Payment__c.sObjectType, 'Refund');
                refund.Refund_Reason__c=payment.Refund_Reason__c;
                refund.Refund_Comments__c=payment.Refund_Comments__c;

                DMLManager.InsertSObject(refund);
            }
      }
      catch(Exception ex)
      {
           ApexPages.addMessages(ex);
           return null;
      }
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'The payment is sucessfully refunded.' ));
      return null;

   }
   public PageReference cancel()
   {
      string retUrl = ApexPages.currentPage().getParameters().get('returl');
      if (rollupHelper.IsEmptyOrNull(retUrl))
        retUrl = '/'+paymentId;
      PageReference pageRef = new PageReference(retUrl);
      pageRef.setRedirect(true);
      return pageRef;
   }

   private decimal RefundedAmount(string paymentId)
   {
       List<Payment__c> payments = new PaymentSelector().SelectPaymentByRefundId(paymentId);
       decimal total = 0;
       if (payments!=null && payments.size()>0)
        for(Payment__c p : payments)
            total += p.Amount__c.abs();

       return total;
   }

   //added on 20-04-2017
    public  List<String>  getResionForRefund()
    {

        List<String> refundoptions=new List<String>();

         Schema.DescribeFieldResult refund=Payment__c.fields.Refund_Reason__c.getDescribe();
        List<Schema.PicklistEntry>  refundpval = refund.getPicklistValues();

        for(Schema.PicklistEntry pval : refundpval)
             refundoptions.add(String.valueOf(pval.getLabel()));


        return refundoptions;
    }


}