@isTest
public class CustomAccountContactLookupControllerTest{
    public static testMethod void CustomAccountContactLookupControllerTest(){
        Account a = GLAllocationfieldUpdateTriggerTest.acc();
        Contact c = GLAllocationfieldUpdateTriggerTest.con();
        
        CustomAccountContactLookupController accconSearch = new CustomAccountContactLookupController();
        CustomAccountContactLookupController accconSearch1 = new CustomAccountContactLookupController('s');
        accconSearch.searchString = 's';
        accconSearch.searchAccountContact();
        //System.assertEquals(c, accconSearch.contactLookupResults[0]);
        accconSearch.getFormTag();
        accconSearch.getTextBox();
    }
}