@isTest
public class TestTotalGAEligibleAllocationsRollUp{
    public static testMethod void TotalGAEligibleAllocationsRollUp(){        
        
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
        
        App_Settings__c app = new App_Settings__c(Appeal_RecordType_Id__c = rtype_Map.get('Appeal'), Campaign_RecordType_Id__c = rtype_Map.get('Campaign'), 
            Event_RecordType_Id__c = rtype_Map.get('Event'), Actionpages_URL__c = 'www.example.com', Appeal_Donate_Now_Form_Id__c = 'sdfd', Event_Registration_Form_Id__c = 'dsf',
            Form_URL__c = 'www.example.com', Free_Event_Registration_Form_Id__c = 'gfdf', CV_Account_Id__c = '123', Default_Actionpages_Campaign__c = 'jdksf',
            Individual_App_RecordtypeId__c = '123', Enable_Recurring_Receipts__c = false, Gift_Aid_Enable__c = true );
        insert app; 
        
        
        
        Account a = new Account(Name = 'Platy IT');
        insert a;
        
        
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
        
        Payment__c p1 = new Payment__c();
        p1.Donation__c = g.Id; 
        p1.Gift_Aid_Claim_Status__c='Rejected';
        insert p1;      
        
        p1.Gift_Aid_Claim_Status__c=null;
        update p1;
        
        Gift_Aid_Declaration__c d= new Gift_Aid_Declaration__c();
        d.Donor__c=c.id;
        d.Next_Fiscal_Date__c= date.today();
        insert d;    
        d.Type__c='This donation, and all future';
        update d;
        
        // for the user story-Gift-Aid Test Coverage(updateAllocationGAEligibleField trigger is not covered)
        //shridhar
        
        Fund__c fund = new Fund__c();
        fund.Fund_Name__c = 'Test Fund';
        insert fund;
        
        
        
        
        Campaign  appeal  = new Campaign();
        appeal.Name='appeal test';
        appeal.RecordTypeId = rtype_Map.get('Appeal');
        insert appeal;
        
        Gift_Detail__c allocation = new Gift_Detail__c();
        allocation.New_Campaign__c  = appeal.id;
        allocation.Fund__c = fund.id;
        allocation.Gift__c=g.id;
        allocation.Payment__c=p1.id;
        allocation.Amount__c=20;
        insert allocation;
        
        update fund;
        //test coverage for TotalGiftAidRollUp trigger
        Payment__c pay = new Payment__c();
        pay.Date__c=Date.today();
        pay.Amount__c=20;
        pay.Status__c='Approved';
        pay.Payment_Type__c ='cash';
        pay.Donation__c=g.Id;
        insert pay;
        //---------
    }
}