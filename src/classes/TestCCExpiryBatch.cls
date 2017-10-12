@isTest
private class TestCCExpiryBatch {
 static testMethod void testMe()
    { 
       Date thirty = Date.today()+30;
       Date fifteen = Date.today()+15;
       Date  seven = Date.today()+7;
        
        Test.startTest(); 
        CCExpiryBatch cc = new CCExpiryBatch();
        cc.query = 'SELECT r.Id, r.Constituent__c, r.Credit_Card_Expiry_Date__c, r.Amount__c, r.Reference__c, r.URL_Safe_Key__c FROM Recurring_Donation__c r WHERE r.Credit_Card_Expiry_Date__c = :thirty OR r.Credit_Card_Expiry_Date__c = :fifteen OR r.Credit_Card_Expiry_Date__c = :seven';        
          Database.executeBatch(cc); 
         Test.stopTest(); 
    }
 }