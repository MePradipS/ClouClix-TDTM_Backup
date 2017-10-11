@isTest
public class GiftAidInformationTestclass{
    public static testMethod void GiftAidInformationTestclass(){        
        Map<String, String> rtype_Map = new Map<String, String>();
        List<RecordType> recordtypelist=[ SELECT Id,Name FROM RecordType];
        for(RecordType r:recordtypelist) {
            rtype_Map.put(r.Name,r.id); }
        
        BatchSettings__c bs = new BatchSettings__c();
        bs.Name='Default'; 
        bs.CurrencyCode__c='CAD';
        bs.BatchFormID__c ='a0JC000000YZxr8'; 
        bs.BatchReportId__c ='00OF000000524ozMAA'; 
        bs.RegularGiftRecordTypeId__c='012F0000000r5T8IAI'; 
        bs.BucketAccountId__c ='001F00000135zxEIAQ'; 
        bs.LockBucketAccount__c =true; 
        bs.GatewayUrl__c ='https://api.cv_pkg_dev_2.com/v2.1/Gateway.asmx'; 
        bs.Data_Migration_Mode__c=false;
        insert bs;
        
        Account a = new Account(Name = 'Platy IT');
        insert a;
        
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtype_Map.get('Appeal'), Campaign_RecordType_Id__c = rtype_Map.get('Campaign'), 
            Event_RecordType_Id__c = rtype_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false, Gift_Aid_Enable__c = true );
        insert app; 
        
        
        contact c= new contact();
        c.FirstName='firstname';
        c.lastname='lastname';
        c.MailingStreet='TestStreet';
        c.MailingPostalCode='AP9078';
        c.AccountId = a.Id;
        insert c;
        
           
        
        
        Gift__c g= new Gift__c();
        g.Constituent__c = c.Id;
        g.RecordTypeId = rtype_Map.get('Gift');
        insert g;        
        
        //Event_Registration__c e= new Event_Registration__c();
        
        Payment__c p1 = new Payment__c();
        p1.Donation__c = g.Id; 
        p1.Gift_Aid_Claim_Status__c='Rejected';
        insert p1;
        
        p1.Description__c='description';
        p1.Gift_Aid_Claim_Status__c='Not claimed';
        Update p1;        
        
        p1.Status__c='Approved';
        p1.Gift_Aid_Eligible__c =true;
        Update p1;
        
        Gift_Aid_Declaration__c d= new Gift_Aid_Declaration__c();
        d.Donor__c=c.id;
        d.Next_Fiscal_Date__c= date.today();
        insert d;    
        d.Type__c='This donation, and all future';
        update d;
       
        Fund__c  fund = new Fund__c ();
        fund.gift_Aid_Eligible__c= true;
        insert fund;        
        
        
        Campaign a1 = new Campaign();
        a1.RecordTypeId = rtype_Map.get('Appeal');
        a1.Name='appeal';
        insert a1;
        
        Gift_Detail__c allocation = new Gift_Detail__c();
        //allocation.Appeal__c =a1.id;
        allocation.Fund__c = fund.Id;
        allocation.Amount__c = 100;
        allocation.Payment__c = p1.id;
        allocation.Gift__c = g.id;
              
        insert allocation;        
        
        delete allocation;        
        
        delete p1;
        
    }
    //This test method is to cover the AllocMetrics, AllocationFix(37%) and Controller_GiftAid
    //Added on 25/08/15 to resolve avg test coverage issue during pacakge updloading
    ////shridhar
    public static testMethod void AllocMetricsTestClass(){ 
       /* AllocMetrics allocMetrics = new AllocMetrics();
        allocMetrics.pca2013=21;
        integer temp =allocMetrics.pca2013;
        temp =allocMetrics.pca2014;
        temp =allocMetrics.pca2015;
        temp =allocMetrics.aia2013;
        temp =allocMetrics.aia2014;
        temp =allocMetrics.aia2015;
        temp =allocMetrics.pia2013;
        temp =allocMetrics.pia2014;
        temp =allocMetrics.pia2015;
        temp =allocMetrics.pna2013;
        temp =allocMetrics.pna2014;
        temp =allocMetrics.pna2015;
        temp=allocMetrics.arg;
        allocMetrics.arg=22; */
        
        //Controller_GiftAid controllerGiftAid = new Controller_GiftAid();
        //controllerGiftAid.assignPerPage();
        //controllerGiftAid.cnrassignPerPage();
        //controllerGiftAid.cnrFirstPage();
        //controllerGiftAid.toBeOffsetSize=12;
        //controllerGiftAid.toBeLimitSize=2;
        //controllerGiftAid.toBeTotalRecs=14;
        //controllerGiftAid.cnrOffsetSize=33;
       // controllerGiftAid.cnrTotalRecs=44;
        //controllerGiftAid.cnrLimitSize=33;
        //controllerGiftAid.receivedTotalRecs=11;
        //controllerGiftAid.receivedOffsetSize=23;
        //controllerGiftAid.receivedLimitSize=15;
            
        //controllerGiftAid.FirstPage();        
        //controllerGiftAid.previous();
       // controllerGiftAid.LastPage();        
        //controllerGiftAid.cnrOffsetSize=33;
        //controllerGiftAid.next();
        //controllerGiftAid.cnrLastPage();
        //controllerGiftAid.cnrnext();
        //controllerGiftAid.cnrprevious();  
        //controllerGiftAid.cnrFirstPage(); 
        //controllerGiftAid.exportToCSV();        
        //controllerGiftAid.getcnrnxt();
       // controllerGiftAid.receivedFirstPage();
        //controllerGiftAid.receivedLastPage();
        //controllerGiftAid.receivednext();
        //controllerGiftAid.receivedprevious();
        //controllerGiftAid.getreceivednxt();
        //controllerGiftAid.getreceivedprev();
        //controllerGiftAid.getreceivedList();
        //controllerGiftAid.getprev();
        //controllerGiftAid.getnxt();
        //controllerGiftAid.getcnrList();
        //list<Payment__c> tempList =controllerGiftAid.getcnrList;
        //controllerGiftAid.getToBeList();
        //controllerGiftAid.getcnrprev();
        
        //controllerGiftAid.rejectedLimitSize=12;
        //controllerGiftAid.rejectedOffsetSize=11;
        
        //controllerGiftAid.rejectedperPageNumbers;
        //controllerGiftAid.rejectedperPageSelection=33;        
        //controllerGiftAid.receivedassignPerPage();
        
        //controllerGiftAid.rejectedassignPerPage();
       // controllerGiftAid.rejectedFirstPage();
      //  controllerGiftAid.rejectedLastPage();
     //   controllerGiftAid.rejectednext();
      //  controllerGiftAid.rejectedprevious();
     //   //controllerGiftAid.getrejectedList();
      //  controllerGiftAid.getrejectednxt();
      //  controllerGiftAid.getrejectedprev();
        
        
        
       /* Test.StartTest();
        AllocationFix allocationFix = new AllocationFix();        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, allocationFix); 
        Test.stopTest(); */
       
        
        
        
        
    }    
    
}