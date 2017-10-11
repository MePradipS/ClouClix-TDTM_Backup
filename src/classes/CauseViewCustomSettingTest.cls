@isTest
public with sharing class CauseViewCustomSettingTest {
	public static testMethod void CauseViewCustomSettingTest1() {
		CauseViewCustomSetting.updateSeachKey();
		Map<String, String> maps = CauseViewCustomSetting.cronJobMethod();
		Id newId = CauseViewCustomSetting.createObject('Contact', null, 'testName');
	}
}