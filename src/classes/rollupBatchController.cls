public with sharing class rollupBatchController
{
    private ApexPages.StandardSetController standardSetController;
    private ID id;
    public boolean jobProcess {Get; Set;}

    public rollupBatchController(ApexPages.StandardController controller){
        id = controller.getRecord().Id;
    }

    public PageReference executeRollupBatch()
    {
        Database.executeBatch(new RollupBatch(id),200);
        jobProcess = true;

        return null;
    }

    public PageReference executeFullRollup()
    {
        Database.executeBatch(new RollupBatch('Full'),200);

        return null;
    }

     public PageReference redirect()
    {
        PageReference newPage = new PageReference('/' + id);
        newPage.setRedirect(true);

        return newPage ;
    }

     public PageReference pausingExecution(){
            PageReference pgref;
            list<AsyncApexJob> job = new AsyncApexJobSelector().SelectJobByIdAndMethodName('RollupBatch', UserInfo.getUserId());
            if(job.size()>0){
                if(job[0].Status == 'Queued' || job[0].Status=='Preparing' || job[0].Status=='Processing'){
                    return null ;
                }
                if(job[0].Status == 'Completed' ){
                    jobProcess= false;
                }
                if(job[0].Status == 'Aborted' || job[0].Status == 'Failed' || job[0].Status == 'Holding' ){
                    jobProcess= false;
                    job[0].addError('Error occurred during updating Allocations');
                    return null;
                }
            }
            return null;
    }
}