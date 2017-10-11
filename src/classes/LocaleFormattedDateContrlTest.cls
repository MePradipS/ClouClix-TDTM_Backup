@isTest
public with sharing class LocaleFormattedDateContrlTest {
	// public static User CreateSObject() {
	// 		BatchSettings__c testBatch = (BatchSettings__c)TestDataTemplates.createSObject(new BatchSettings__c(), true);
	// 		App_Settings__c testApp = (App_Settings__c)TestDataTemplates.createSObject(new App_Settings__c(), true);
	// 		User testUser = (User)TestDataTemplates.createSObject(new User(
	// 			Username = 'testerson@causeview.com',
	// 			LastName = 'testerson',
	// 		  	Email = 'Test@email.com',
	// 			Alias = 'Tester',
	// 			CommunityNickname = 'Tester',
	// 			TimeZoneSidKey = 'America/New_York',
	// 			LocaleSidKey = 'en_CA',
	// 		  	EmailEncodingKey = 'ISO-8859-1',
	// 			ProfileId = '00e46000001QmOgAAK',
	// 			LanguageLocaleKey = 'en_US'), true);

	// 		return testUser;
	// }

	// @isTest static void TestGetDateLocale() {
	// 	User expectedUser = CreateSObject();

	// 	Test.startTest();
	// 		LocaleFormattedDateContrl localeFDC = new LocaleFormattedDateContrl();
	// 		String localeDateFormatVal = localeFDC.getDateLocale(expectedUser.LocaleSidKey);
	// 		System.AssertEquals(localeDateFormatVal, 'dd/MM/yyyy');
	// 	Test.stopTest();
	// }

	// @isTest static void TestGetTimeZoneValue() {
	// 	User expectedUser = CreateSObject();

	// 	Test.startTest();
	// 		LocaleFormattedDateContrl localeFDC = new LocaleFormattedDateContrl();
	// 		String timeZoneValue = localeFDC.getTimeZoneValue();
	// 		System.AssertEquals(timeZoneValue, '');
	// 	Test.stopTest();
	// }
}