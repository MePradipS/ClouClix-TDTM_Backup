public with sharing class GatewaySettingsManager {
	public static GatewaySettings__c GetGatewaySettings(String gatewaySettingName) {
		GatewaySettings__c gatewaySetting = GatewaySettings__c.getValues(gatewaySettingName);
		return gatewaySetting;
	}
}