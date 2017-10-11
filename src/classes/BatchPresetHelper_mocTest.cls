@isTest
public class BatchPresetHelper_mocTest{
    public static testMethod void BatchPresetHelper_moc(){
        String namespacePrefix = Utilities.getCurrentNamespace();
        String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');

        string stringDate = '2014-12-12';
        Boolean isNewPreset = true;
        Boolean isNewPreset1 = false;
        Schema.sObjectType t = Account.sObjectType;
        PresetWrapper pw = new PresetWrapper(t);
        List<PresetWrapper> dataList = new List<PresetWrapper>();
        dataList.add(pw);
        Map<String,PresetWrapper> fieldsMap = new Map<String,PresetWrapper>();
        fieldsMap.put('1', pw);
        Set<String> pickValues = new Set<String>();
        pickValues.add('2');
        Boolean isPayment = false;
        String xmlInput = '<Account><fields Lable="Organization Name" Name="Name" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="true" Summ="true"></fields><fields Lable="Email" Name="' + namespaceFieldPrefix + 'Email__c" Type="EMAIL" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="true"></fields><fields Lable="Industry" Name="Industry" Type="PICKLIST" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Mailing City" Name="BillingCity" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Number of Locations" Name="' + namespaceFieldPrefix + 'CVA_NumberofLocations__c" Type="DOUBLE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Number" Name="AccountNumber" Type="STRING" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Phone" Name="Phone" Type="PHONE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Organization Record Type" Name="RecordTypeId" Type="REFERENCE" Value="012A00000012MG8IAM" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields><fields Lable="Parent Organization" Name="ParentId" Type="REFERENCE" Value="null" isHidden="false" ReadOnly="false" Req="false" Summ="false"></fields></Account>';
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('US','US'));
        options.add(new SelectOption('CANADA','Canada'));
        options.add(new SelectOption('MEXICO','Mexico'));
        BatchPresetHelper_moc batchpreset = new BatchPresetHelper_moc();
        batchpreset.getPaymentTypes();
        batchpreset.getPaymentTypeFields();
        batchpreset.getPaymentTypeFieldMap();
        batchpreset.convertDate(stringDate);
        batchpreset.discribeObjects('Account');
        batchpreset.readXML(xmlInput, 'Account');
        batchpreset.bildFieldsMap(fieldsMap, dataList, 'Account', isNewPreset);
        batchpreset.bildFieldsMap(fieldsMap, dataList, 'Account', isNewPreset1);
        batchpreset.selectOptionSortByLabel(options);
    }
}