@isTest(seeAllData=true) 
public class DataTableHelperTest {
    public static testMethod void testOne() {
        Test.startTest();

        DataTableHelper dt = new DataTableHelper();

		Test.setCurrentPageReference(new PageReference('Page.DataTableHelper')); 
		
		System.currentPageReference().getParameters().put('q', 'select id, name from contact');
		System.currentPageReference().getParameters().put('order[0][column]', '0');
		System.currentPageReference().getParameters().put('columns[0][data]', 'id');
        System.currentPageReference().getParameters().put('order[0][dir]', 'desc');
		System.currentPageReference().getParameters().put('start', '0');
        System.currentPageReference().getParameters().put('length', '10');

		dt.processData();

        Test.stopTest();
    }
}