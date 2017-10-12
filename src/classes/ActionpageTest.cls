@isTest
public with sharing class ActionpageTest {
	public static testMethod void ActionpageConstructorTest() {
		Actionpage ap = new Actionpage();
		ap.conversion_time = 1.2;
		ap.action_page_id = 'id';
		ap.gateway_type = 'iATS';
		
		List<Field> actionPageFields = new List<Field>();
		Field f = new Field();
		f.id = 'id';
		actionPageFields.add(f);
		ap.field = actionPageFields;
		ap.setStringField('id', 'value'); 
	}
}