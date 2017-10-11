@isTest
private class TestMultiChannelCampaign {

    static testMethod void myUnitTest() {
        Campaign c = new Campaign(Name='Test Campaign');
        insert c;
        List<Campaign> cs = new Campaign[] { c };
        ApexPages.StandardSetController std = new ApexPages.StandardSetController(cs);
        MultichannelCampaignController cnt = new MultichannelCampaignController(std);
        cnt.isTesting = false;
        cnt.campaignId = c.Id;
        cnt.init();
        
        MultichannelCampaignController.CampaignWrapper wrapper = new MultichannelCampaignController.CampaignWrapper(c,new List<Goal__c>());        
        
        cnt.newAppeal.Name = 'test appeal';
        cnt.newGoal.Name = 'test goal';
        cnt.newGoal.Q1_Goal__c=300;
        cnt.newGoal.Q2_Goal__c=345;
        cnt.newGoal.Q3_Goal__c=456;
        cnt.newGoal.Q4_Goal__c=3400;
        cnt.saveAll();
        
        cnt.addAppeal();
       
        cnt.newAppeal.Name = 'test appeal';
        cnt.newGoal.Name = 'test goal';
        //cnt.newGoal.Q1_Goal__c=300;
        //cnt.newGoal.Q2_Goal__c=345;
        //cnt.newGoal.Q3_Goal__c=456;
        //cnt.newGoal.Q4_Goal__c=3400;
        cnt.newGoal.Overall_Goal__c = 534;
        cnt.newGoal.Active__c = true;
        cnt.newGoal.Fiscal_Year__c = '2012';
        cnt.campaignGoal.Name='test campaign goal';
        cnt.campaignGoal.Q1_Goal__c=300;
        cnt.campaignGoal.Q2_Goal__c=345;
        cnt.campaignGoal.Q3_Goal__c=456;
        cnt.campaignGoal.Q4_Goal__c=3400;
        cnt.campaignGoal.Overall_Goal__c = 534;
        //cnt.isTesting = true;
        cnt.saveAll();
        
        cnt.cancelLastAction();
        if (cnt.newAppeal.Id == null)
            insert cnt.newAppeal;
        cnt.selectedAppealId = cnt.newAppeal.Id;
        cnt.newGoal();
        cnt.addGoal();
        
        
        
    }
}