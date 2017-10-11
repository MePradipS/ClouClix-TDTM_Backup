public with sharing class SingleTransactionController {

   public string formId { get; set; }
   public string serviceUrl { get; set; }
   public string widgetWidth { get; set; }
   public string widgetHeight { get; set; }
   public List<SelectOption> options { get; set; }
   public List<WidgetForms__c> forms { get; set; }
   public string selectedOption { get; set; }
   
   public SingleTransactionController()
   {
       /*
       serviceUrl = 'https://www.opinov.com/breakeven/Gateway.asmx';
       formId = 'a02A0000001lq1d';
       widgetWidth = '100%';
       widgetHeight = '700';*/
       forms = new WidgetFormsSelector().SelectWidgetFormsWithLimit();
       loadFormOptions();
   } 
   
   private void loadFormOptions()
   {
      options = new List<SelectOption>();
      for(WidgetForms__c form : forms)
      {
         SelectOption option = new SelectOption(form.Id,form.Name);
         options.add(option);
      }
      selectedOption = forms[0].Id;
      loadForm();
   }
   
   public void loadForm()
   {
     if (forms != null)
      for(WidgetForms__c form : forms)
       if (form.Id == selectedOption)
       {
           formId = form.FormId__c;
           break;
       }
   }
   
   static testMethod void testMe()
   {
        WidgetForms__c widgetForm = new WidgetForms__c(name = 'test Widget', Form_Name__c='test widget1', FormId__c = 'gdf123');//, ServiceUrl__c='https://www.opinov.com/breakeven/Gateway.asmx',WidgetWidth__c = '100%', WidgetHeight__c = '700');
        DMLManager.InsertSObject(widgetForm);
        SingleTransactionController cnt = new SingleTransactionController();
        cnt.loadFormOptions();
        cnt.loadForm();
   }
}