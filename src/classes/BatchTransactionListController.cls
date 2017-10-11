public with sharing class BatchTransactionListController {

    public string batchId {get; set;}
    public string selectedView {get; set; }
    public boolean isBatchOpen {get; set; }
    public boolean hasGifts {
        get {
            return  batchGifts == null || batchGifts.size() == 0 ? false : true;
        }
    }
    public List<GiftBatchWrapper> giftItems {
      get;
      set {
        giftItems = value;
        batchGifts = new List<GiftBatchWrapper>();
        for (GiftBatchWrapper gift : giftItems)
        {
            if (selectedView == 'All')
            {
                batchGifts.add(gift);
            }
            else if (selectedView == 'Pending')
            {
                if (gift.payment.Payment_Type__c == 'Credit Card' &&(gift.gift.Batch_Status__c == 'Pending' || gift.gift.Batch_Status__c == null)) batchGifts.add(gift);
            }
            else if (gift.gift.Batch_Status__c == 'Failed')
            {
                batchGifts.add(gift);
            }
        }
      }
    }

    public List<GiftBatchWrapper> batchGifts { get; set; }
    public batchTransactionListController(){
       selectedView = 'All';
    }
    public void refreshGifts () {}

    static testMethod void testMe() {

        BatchSettings__c bs = GiftBatchWrapper.testCustomSettings();
        RecordType rtype = new RecordTypeSelector().SelectByNameNamespacePrefixAndName(Utilities.getCurrentNamespace(), 'Gift');

        Batch_Template__c bt123 = new Batch_Template__c();
        bt123.name = 'abc';
        DMLManager.InsertSObject(bt123);

        Gift_Batch__c gb2 = new Gift_Batch__c();
        gb2.Name__c = 'test980';
        gb2.Template_Name__c = bt123.id;
        DMLManager.InsertSObject(gb2);

        Account a = new Account(Name = 'ssss');
        DMLManager.InsertSObject(a);

        if (rtype != null)
        {
            Gift__c g = new Gift__c();
            g.Organization__c = a.Id;
            g.GiftBatch__c = gb2.Id;
            g.Batch_Status__c = 'Pending';
            g.RecordTypeId = rtype.id;
            DMLManager.InsertSObject(g);

            GiftBatchWrapper wrapper = GiftBatchWrapper.CreateInstance(g.Id);
            wrapper.payment.Payment_Type__c = 'Credit Card';
            wrapper.payment.Donation__c = g.Id;
            DMLManager.InsertSObject(wrapper.payment);

            wrapper = GiftBatchWrapper.CreateInstance(g.Id);
            List<GiftBatchWrapper> wrappers = new List<GiftBatchWrapper>();
            wrappers.add(wrapper);

            BatchTransactionListController cnt = new BatchTransactionListController();
            cnt.batchId  = gb2.Id;
            cnt.selectedView = 'Pending';
            cnt.giftItems = wrappers;
            List<GiftBatchWrapper> wrappers2 = cnt.giftItems;

            cnt.selectedView = 'All';
            wrappers2 = cnt.giftItems;

            cnt.selectedView = 'Failed';
            wrappers2 = cnt.giftItems;

            boolean has = cnt.hasGifts;
            has = cnt.isBatchOpen;
            cnt.refreshGifts();
        }
    }

}