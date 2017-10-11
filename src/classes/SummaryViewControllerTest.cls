@isTest
public class SummaryViewControllerTest {
    public static testMethod void TestSummaryViewController(){ 
        
        contact con = createNewContact();        
        Account acc = createNewAccount();
        BatchSettings__c bSetting = BatchSettingsCSCreate();
        Gift__c gift = giftCreate(con);
		Payment__c pay = payCreate(gift);
		Solicitor__c softCre = SoftCreditCreate(gift);
        Fund__c fund = fundCreate();
        Campaign c = campaignCreate(fund, 'Appeal');
        Gift_Detail__c alloc1 = allocationCreate(gift,fund, c );
        alloc1.Payment__c = pay.id;
        update alloc1;		        
        Test.startTest();
        //to cover the code dependent on contact
        ApexPages.currentPage().getParameters().put('cid', con.id);		       
    	SummaryViewController sV = new SummaryViewController();
        system.assertEquals('Contact', sv.indivOrOrgan);
        system.assertEquals(con.id, sv.contAccid);
        
        //to cover the code dependent on account
        Map<String,Schema.RecordTypeInfo> recTypeMap = recordType('Account');       
        ApexPages.currentPage().getParameters().put('cid', '');
        ApexPages.currentPage().getParameters().put('AccountId', acc.id);
		ApexPages.currentPage().getParameters().put('RecordTypeId', [Select Id From RecordType Where Name = 'Organization'].Id);
        gift.Constituent__c = null;
        gift.Organization__c = acc.id;
		update gift;
        softCre.Solicitor__c = null;
        softCre.Organization_Solicitor__c = gift.Organization__c;
		update softCre;        
    	sV = new SummaryViewController();
		string imageurl = sv.getmyimageurl();        
        system.assertEquals('Account', sv.indivOrOrgan);
        system.assertEquals(acc.id, sv.contAccid);
        Test.stopTest();
    }
    public static contact createNewContact(){
        contact c = new contact();
        c.lastName = 'testContact'; 
        insert c;
        return c;
    }
    public static Account createNewAccount(){
        Account a = new Account();
        a.Name = 'testAccount';
        a.RecordTypeId = [Select Id From RecordType Where Name = 'Organization'].Id;
        insert a;        
        return a;
    }
    public static Map<String,Schema.RecordTypeInfo> recordType(string objName){
        list<string> listObjects = new list<string>{objName};
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(listObjects);
        if(descResult.size()>0){ 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = descResult[0].getRecordTypeInfosByName();            
			return AccountRecordTypeInfo;
        }
        return null;
    }
    public static BatchSettings__c BatchSettingsCSCreate(){
        BatchSettings__c bS =  new BatchSettings__c();
        bS.Name = 'Default';
 		bS.BatchFormID__c = 'a0JC000000nLFj6MAG';       
        bS.BatchReportId__c = '00O36000001vf0F';
        bS.BucketAccountId__c = '0013600000518B6';
        bS.CurrencyCode__c = 'CAD';
        bS.GatewayUrl__c = 'https://api.causeview.com/v2.1/Gateway.asmx';
        bS.RegularGiftRecordTypeId__c = '0123600000017YUAAY';
        bS.Data_Migration_Mode__c = False;
        insert bS;
        return bS;
    }
    public static Gift__c giftCreate(contact c){
        Gift__c gift =  new Gift__c();
        gift.Expected_Amount__c = 10;
        gift.Gift_Date__c = date.today();
        gift.Constituent__c = c.id;
        insert gift;
		return gift;        
    }
    public static Payment__c payCreate(Gift__c g){
        Payment__c pay =  new Payment__c();
        pay.Amount__c = 10;
        pay.Date__c = date.today();
        pay.Status__c = 'Approved';
        pay.Payment_Type__c = 'Cash';
        pay.Donation__c = g.id;
        insert pay;
		return pay;        
    }
    public static Solicitor__c SoftCreditCreate(Gift__c g){
        Solicitor__c SoftCredit =  new Solicitor__c();
        SoftCredit.Gift__c = g.id;        
        SoftCredit.Solicitor__c = g.Constituent__c; 
        insert SoftCredit;
		return SoftCredit;        
    }
    
    public static Letter__c letterCreate(){
        Letter__c letter =  new Letter__c();        
        letter.Name__c = 'testLetter';
        letter.Introduction__c = 'testText';
        insert letter;
		return letter;        
    }
    
    public static Gift_Detail__c allocationCreate(Gift__c g, Fund__c f, Campaign c ){
        Gift_Detail__c gD =  new Gift_Detail__c();        
        gD.Fund__c = f.id;
        gD.Gift__c = g.id;
        gD.New_Campaign__c = c.id;
        gD.Amount__c = 10;
        gD.Allocation_Date__c=Date.today();
        insert gD;
		return gD;        
    }
    public static Campaign campaignCreate(Fund__c f, string rType ){
        Map<String,Schema.RecordTypeInfo> recTypeMap = recordType('Campaign');  
        Campaign campaign = new Campaign();
        campaign.Name = 'Campaign Test123';
        campaign.Fund__c =f.id;
        campaign.RecordTypeId = recTypeMap.get(rType).RecordTypeId;
        insert campaign; 
        return campaign;
    }
    
    public static Fund__c fundCreate(){
        Fund__c fund = new Fund__c();
        fund.Fund_Name__c = 'Test fund123';
        insert fund;
        return fund;
    }
    
}