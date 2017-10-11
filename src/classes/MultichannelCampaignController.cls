public with sharing class MultichannelCampaignController {
  public boolean isTesting { get; set; }
  public string campaignId { get; set; }
  public Campaign selectedRecord { get; set; }
  public Goal__c campaignGoal { get; set; }

  public string appealRecordTypeId { get; set; }
  public integer wizardStep { get; set; }
  public string selectedAppealId { get; set; }

  public Campaign newAppeal { get; set; }
  public Goal__c newGoal { get; set; }

  public List<CampaignWrapper> existingAppeals { get; set; }
  public List<String> appealFields { get; set; }
  public List<String> goalFields { get; set; }

  public class CampaignWrapper {
    public Campaign Appeal { get; set; }
    public List<Goal__c> Goals { get; set; }
    public CampaignWrapper(Campaign a, List<Goal__c> b) {
      Appeal = a; Goals = b;
    }
  }

  public MultichannelCampaignController(ApexPages.StandardSetController controller) {
    isTesting = true;
    selectedRecord = (Campaign) controller.getRecord();
    campaignId = ApexPages.currentPage().getParameters().get('id');

    appealFields = new String[] { 'ParentAppeal__c:ro', 'type', 'Description', 'IsActive', 'BudgetedCost', 'startdate', 'NumberSent',
                                  'enddate', 'ExpectedResponse'
                                };

    goalFields = new string[] { 'Name', 'overall_Goal__c', 'Fiscal_Year__c', 'Q1_Goal__c',
                                'Active__c', 'Q2_Goal__c', 'Notes__c', 'Q3_Goal__c:insBlnk',
                                'Q4_Goal__c'
                              };

    init();
  }

  public void init() {
    wizardStep = 1;
    if (campaignId == null || campaignId == '') {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Cannot locate the Campaign record.'));
      wizardStep = 10;
      return;
    }
    List<Campaign> campaignList = new CampaignSelector().SelectCampaingMembersById(new Set<Id> { campaignId });
    if (campaignList != null && campaignList.size() > 0) {
      selectedRecord = campaignList[0];
    }

    string gfieldsStr = getsObjectFields(goalFields);
    List<Goal__c> gs = new GoalSelector().SelectGoalByCampignId(campaignId);
    if (gs != null && gs.size() > 0) {
      campaignGoal = gs[0];
    } else {
      campaignGoal = new Goal__c();
      campaignGoal.Campaign_Appeal__c = selectedRecord.Id;
    }

    appealRecordTypeId = getAppealRecordTypeId();
    prepareNewAppeal();
    loadExistingAppeals();
  }

  private string getsObjectFields(List<string> fields) {
    string output = '';
    for (string f : fields) {
      output += f.replace(':ro', '').replace(':insBlnk', '') + ',';
    }

    if (output.endsWith(',')) {
      output = output.substring(0, output.length() - 1);
    }

    return output;
  }

  public void prepareNewAppeal() {

    newAppeal = new Campaign();
    newAppeal.ParentId = selectedRecord.Id;
    newAppeal.RecordTypeId = appealRecordTypeId;
    newGoal = new Goal__c();
  }
  public void cancelLastAction() {
    wizardStep = 1;
  }
  public void newGoal() {
    wizardStep = 2;

    if (existingAppeals != null)
      for (CampaignWrapper c : existingAppeals)
        if (c.appeal.Id == selectedAppealId)
          newAppeal = c.appeal;
    newGoal = new Goal__c();
  }
  public void AddGoal() {
    try {
      newGoal.Campaign_Appeal__c = selectedAppealId;
      DMLManager.InsertSObject(newGoal);
      init();
    } catch (Exception ex) {
      ApexPages.addMessages(ex);
    }
  }

  private string getAppealRecordTypeId() {
    List<RecordType> recTypes = new RecordTypeSelector().SelectRecordByNamePrefixNameAndSobjectType('Campaign', 'Appeal', Utilities.getCurrentNamespace());
    if (recTypes != null && recTypes.size() > 0)
      return recTypes[0].Id;
    else
      return null;
  }
  private void loadExistingAppeals() {
    string aFields = getsObjectFields(appealFields);
    aFields += (String.isEmpty(aFields))?'id, Name':',id, Name';
    string gFields = getsObjectFields(goalFields);
    gFields += (String.isEmpty(gFields))?'id':',id';
    String whereClause = ' WHERE ParentId = \'' + campaignId + '\' ORDER BY CreatedDate DESC';

    List<Campaign> existingOnes = new GenericQueryBuilder().QueryBuilderWithSubQuery(Campaign.sObjectType, aFields, whereClause, Goal__c.sObjectType, 'Goals__r', gFields, '');

    if (existingOnes != null && existingOnes.size() > 0) {
      existingAppeals = new List<CampaignWrapper> ();
      for (Campaign c : existingOnes)
        existingAppeals.add(new CampaignWrapper(c, c.Goals__r));
    }
  }

  public void addAppeal() {
    DMLManager.InsertSObject(newAppeal);

    newGoal.Campaign_Appeal__c = newAppeal.Id;
    DMLManager.InsertSObject(newGoal);
  }

  public void saveAll() {

    Savepoint sp = Database.setSavepoint();
    try {
      DMLManager.UpdateSObject(selectedRecord);
      DMLManager.UpsertSObject(campaignGoal);

      addAppeal();

      List<Campaign> appeals = new List<Campaign> ();
      List<Goal__c> goals = new List<Goal__c> ();

      if (existingAppeals != null) {
        for (CampaignWrapper c : existingAppeals) {
          appeals.add(c.Appeal);
          if (c.Goals != null && c.Goals.size() > 0)
            goals.addAll(c.Goals);
        }
      }

      DMLManager.UpdateSObjects(appeals);
      DMLManager.UpdateSObjects(goals);

      init();
    } catch (Exception ex) {
      Database.rollback(sp);
      newAppeal = newAppeal.clone(false);
      newGoal = newGoal.clone(false);
      ApexPages.addMessages(ex);
      if (isTesting) throw ex;
    }
  }
}