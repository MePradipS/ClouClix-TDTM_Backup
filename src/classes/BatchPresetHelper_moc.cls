public class BatchPresetHelper_moc {
    private String namespacePrefix = Utilities.getCurrentNamespace();
    private String namespaceFieldPrefix = namespacePrefix + (String.isEmpty(namespacePrefix) ? '' : '__');
    private String namespaceCreditCardNumberField = namespaceFieldPrefix + 'Credit_Card_Number__c';
    private String namespaceCreditCartTypeField = namespaceFieldPrefix + 'Credit_Card_Type__c';
    private String namespaceDateDepoistedField = namespaceFieldPrefix + 'Date_Deposited__c';
    private String namespaceChequeNumField = namespaceFieldPrefix + 'Cheque_Num__c';
    private String namespaceChequeDateField = namespaceFieldPrefix + 'Cheque_Date__c';
    private String namespaceAccountNumberField = namespaceFieldPrefix + 'Account_Number__c';
    private String namespaceRoutingBranchNumberField = namespaceFieldPrefix + 'Routing_Branch_Number__c';
    private String namespaceAccountTypeField = namespaceFieldPrefix + 'Account_Type__c';
    Public String paymentTypesSelected = '';
    Public String giftTypePicklistValues = '';

    //get SelectOption/picklist values for new/edit batch preset template.
    public List<SelectOption> pickListOptions(Map<String,PresetWrapper> fieldsMap, Set<String> pickValues, Boolean isPayment) {

        List<string> tempList = new List<String>();
        List<SelectOption> options = new List<SelectOption>();

        if(pickValues.size() == 0) {
            pickValues.addAll(fieldsMap.keySet());
            tempList.addAll(pickValues);
            for(String fieldName : tempList) {
                // Do not add options if the fields are from Payment Type Map.
                if( !(isPayment && getPaymentTypeFields().contains(fieldName)) && fieldsMap.get(fieldName) != null ) {
                    if(fieldsMap.get(fieldName).fieldLable == 'Business Phone') fieldsMap.get(fieldName).fieldLable = 'Phone';
                    options.add(new SelectOption(fieldName, fieldsMap.get(fieldName).fieldLable));
                }
            }
        }
        else {
            tempList.addAll(pickValues);
            for(String fieldName : tempList) {
                // Do not add options if the fields are from Payment Type Map.
                if( !(isPayment && getPaymentTypeFields().contains(fieldName)) ) {
                    options.add(new SelectOption(fieldName, fieldsMap.get(fieldName).fieldLable));
                }
            }
        }

        return selectOptionSortByLabel(options);
    }

    public String getPaymentTypes() {
        list<Schema.PicklistEntry> values = Payment__c.Payment_Type__c.getDescribe().getPickListValues();
        String paymentTypes = '';
        for (Schema.PicklistEntry a : values) {
            paymentTypes += a.getValue() + ',';
        }
        return paymentTypes;
    }

    public String getPaymentTypeFields() {
        return namespaceCreditCardNumberField + ', ' + namespaceCreditCartTypeField + ', ' + namespaceChequeNumField +
                ', ' + namespaceChequeDateField + ', ' + namespaceDateDepoistedField + ', ' + namespaceAccountNumberField +
                ', ' + namespaceRoutingBranchNumberField + ', ' + namespaceAccountTypeField;
    }

    public Map<String, List<String>> getPaymentTypeFieldMap() {
        Map<String, List<String>> paymentTypeFieldMap = new Map<String, List<String>>();
        paymentTypeFieldMap.put('Credit Card', new List<String> {namespaceCreditCardNumberField, namespaceCreditCartTypeField});
        paymentTypeFieldMap.put('Credit Card - Offline', new List<String> {namespaceDateDepoistedField});
        paymentTypeFieldMap.put('Check', new List<String> {namespaceChequeNumField, namespaceChequeDateField, namespaceDateDepoistedField});
        paymentTypeFieldMap.put('Cheque', new List<String> {namespaceChequeNumField, namespaceChequeDateField, namespaceDateDepoistedField});
        paymentTypeFieldMap.put('Cash', new List<String> {namespaceDateDepoistedField});
        paymentTypeFieldMap.put('Other', new List<String> {namespaceDateDepoistedField});
        paymentTypeFieldMap.put('Stock', new List<String> {namespaceDateDepoistedField});
        paymentTypeFieldMap.put('ACH/PAD', new List<String> {namespaceAccountNumberField, namespaceAccountTypeField, namespaceRoutingBranchNumberField});
        paymentTypeFieldMap.put('In Kind', new List<String> {namespaceDateDepoistedField});
        paymentTypeFieldMap.put('Property', new List<String> {namespaceDateDepoistedField});
        return paymentTypeFieldMap;
    }

    public void bildFieldsMap(Map<String, PresetWrapper> fieldsMap, List<PresetWrapper> dataList, String objectName, Boolean isNewPreset) {
        if(isNewPreset == true) {
            for(PresetWrapper pw : discribeObjects(objectName)) {
                if(pw.isRequired)
                    dataList.add(pw);
                else
                    fieldsMap.put(pw.fieldName, pw);
            }
        }
        else {
            for(PresetWrapper pw : discribeObjects(objectName))
                fieldsMap.put(pw.fieldName, pw);

            for(PresetWrapper edit_pw :dataList)
                fieldsMap.remove(edit_pw.fieldName);
        }
    }

    //discribe sObject to get field lable, API Name and create PresetWrapper object
    public List<PresetWrapper> discribeObjects(String sObjectType) {

        List<PresetWrapper> PW_List = new List<PresetWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(sObjectType);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

        Set<String> fieldsToExclude = new Set<String>();
        Set<String> requiredFields = new Set<String>();
        if(objSchema.getDescribe().FieldSets.getMap().get('Fields_To_Exclude_From_Batch_Template') != null) {
            List<Schema.FieldSetMember> fieldSetMemberList = objSchema.getDescribe().FieldSets.getMap().get('Fields_To_Exclude_From_Batch_Template').getFields();
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                fieldsToExclude.add(fieldSetMemberObj.getFieldPath());
            }
        }
        if(objSchema.getDescribe().FieldSets.getMap().get('Required_Fields_for_Batch_Templates') != null) {
            List<Schema.FieldSetMember> fieldSetMemberList = objSchema.getDescribe().FieldSets.getMap().get('Required_Fields_for_Batch_Templates').getFields();
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                requiredFields.add(fieldSetMemberObj.getFieldPath());
            }
        }
        
        for (String fieldName: fieldMap.keySet()) {
            Schema.DescribeFieldResult desribeResult = fieldMap.get(fieldName).getDescribe();
            fieldName = desribeResult.getName();

            if(desribeResult.isAccessible() && !desribeResult.isAutoNumber() && !desribeResult.isCalculated() && desribeResult.isCreateable()
                && !desribeResult.isDeprecatedAndHidden() && fieldName != 'OwnerId' && desribeResult.getLabel() != '(DEPRECATED)') {

                if(!(fieldsToExclude.contains(fieldName) || (sObjectType == (namespaceFieldPrefix + 'Solicitor__c')))
                    || (sObjectType == (namespaceFieldPrefix + 'Solicitor__c') && (fieldName == (namespaceFieldPrefix + 'Solicitor__c') || fieldName == (namespaceFieldPrefix + 'Organization_Solicitor__c')
                        || fieldName == (namespaceFieldPrefix + 'Role__c') || fieldName == (namespaceFieldPrefix + 'Custom_Amount__c')))
                    )
                {
                    PresetWrapper pw = new PresetWrapper(objSchema);
                    pw.fieldLable = desribeResult.getLabel();
                    pw.fieldName = fieldName;
                    pw.fieldType = String.valueOf(desribeResult.getType());
                    pw.fieldValue = null;
                    pw.isHidden = false;
                    pw.isReadOnly = false;
                    pw.isForSummary = false;
                    if(desribeResult.isCreateable() && !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate())
                        pw.isRequired = true;
                    else
                        pw.isRequired = false;

                    //Payment Type Field Mappings.
                    //Make Payment Type field as required and summary.
                    if(pw.fieldName == (namespaceFieldPrefix + 'Payment_Type__c')) {
                        pw.isForSummary = true;
                    }

                    if(requiredFields.contains(pw.fieldName)) {
                        pw.isRequired = true;
                    }

                    //Populate picklist values if field type is picklist
                    if(pw.fieldType == 'PICKLIST' || pw.fieldType == 'MULTIPICKLIST') {
                        if (fieldMap.get(pw.fieldName) != null)
                        {
                            list<Schema.PicklistEntry> values = fieldMap.get(pw.fieldName).getDescribe().getPickListValues();
                            for (Schema.PicklistEntry a : values) {
                                pw.picklistValues.add(a.getValue());
                            }
                        }
                    }


                    PW_List.add(pw);
                }
            }
        }

        return PW_List;
    }

    //Convert PresetWrapper object information into XML to store template information.
    public String writeXML(String ObjectType, List<PresetWrapper> dataToWrite, String paymentTypesSelected) {
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement(null, ObjectType, null);

        // Write Payment Types selected.
        if(paymentTypesSelected != null) {
            w.writeAttribute(null, null, 'PTypes', paymentTypesSelected);
        }
        // Write Gift Type Picklist Values
        if(ObjectType == (namespaceFieldPrefix + 'Gift__c') && giftTypePicklistValues != null) {
            w.writeAttribute(null, null, 'GiftTypes', giftTypePicklistValues);
        }
        for(PresetWrapper obj_PW : dataToWrite) {

            if(obj_PW.sObjectType.get(obj_PW.fieldName) == null && obj_PW.isReadOnly == true)
                throw new PresetWrapper.MyCustomException('You can not make field as Read Only without default value. Please assign default value to '+obj_PW.fieldLable);

            w.writeStartElement(null, 'fields', null);
            w.writeAttribute(null, null, 'Lable', obj_PW.fieldLable);
            w.writeAttribute(null, null, 'Name', obj_PW.fieldName);
            w.writeAttribute(null, null, 'Type', obj_PW.fieldType);

            if(obj_PW.sObjectType.get(obj_PW.fieldName) != null)
                w.writeAttribute(null, null, 'Value', String.valueOf(obj_PW.sObjectType.get(obj_PW.fieldName)));
            else
                w.writeAttribute(null, null, 'Value', 'null');

            w.writeAttribute(null, null, 'isHidden', String.valueOf(obj_PW.isHidden));
            w.writeAttribute(null, null, 'ReadOnly', String.valueOf(obj_PW.isReadOnly));
            w.writeAttribute(null, null, 'Req', String.valueOf(obj_PW.isRequired));
            w.writeAttribute(null, null, 'Summ', String.valueOf(obj_PW.isForSummary));
            w.writeEndElement(); //end fields
        }
        w.writeEndElement(); //end objectType
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();

        return xmlOutput;
    }

    //Read and convert stored template information from XML to PresetWrapper objects.
    public List<PresetWrapper> readXML(String xmlString, String sObjectType) {

        List<PresetWrapper> presetDataList = new List<PresetWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(sObjectType);

        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

        XmlStreamReader reader = new XmlStreamReader(xmlString);
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                // Read Payment Types selected.
                if(sObjectType == (namespaceFieldPrefix + 'Payment__c') && reader.getLocalName() == (namespaceFieldPrefix + 'Payment__c')) {
                    paymentTypesSelected = reader.getAttributeValue(null, 'PTypes');
                }
                // Read Gift Type Picklist Values
                if(sObjectType == (namespaceFieldPrefix + 'Gift__c') && reader.getLocalName() == (namespaceFieldPrefix + 'Gift__c')) {
                    giftTypePicklistValues = reader.getAttributeValue(null, 'GiftTypes');
                }
                if (reader.getLocalName() == 'fields') {

                    PresetWrapper pw = new PresetWrapper(objSchema);

                    pw.fieldLable = reader.getAttributeValue(null, 'Lable');
                    pw.fieldName = reader.getAttributeValue(null, 'Name');
                    pw.fieldType = reader.getAttributeValue(null, 'Type');
                    if(reader.getAttributeValue(null, 'Value') != 'null')
                        pw.fieldValue = reader.getAttributeValue(null, 'Value');
                    else
                        pw.fieldValue = null;

                    if(pw.fieldValue != null && pw.fieldValue != 'null') {
                        if(pw.fieldType == 'BOOLEAN')
                            pw.sObjectType.put(pw.fieldName, Boolean.valueOf(pw.fieldValue));
                        else if(pw.fieldType == 'DOUBLE' || pw.fieldType == 'CURRENCY' || pw.fieldType == 'PERCENT')
                            pw.sObjectType.put(pw.fieldName, Double.valueOf(pw.fieldValue));
                        else if(pw.fieldType == 'DATE')
                            pw.sObjectType.put(pw.fieldName, convertDate(pw.fieldValue));
                        else if(pw.fieldType == 'DATETIME')
                            pw.sObjectType.put(pw.fieldName, DateTime.valueofGmt(pw.fieldValue));
                        else if(pw.fieldType == 'INTEGER')
                            pw.sObjectType.put(pw.fieldName, Integer.valueOf(pw.fieldValue));
                        else {
                            pw.sObjectType.put(pw.fieldName, pw.fieldValue);
                        }
                    }
                    else
                        pw.sObjectType.put(pw.fieldName, pw.fieldValue);

                    pw.isHidden = Boolean.valueOf(reader.getAttributeValue(null, 'isHidden'));
                    pw.isReadOnly = Boolean.valueOf(reader.getAttributeValue(null, 'ReadOnly'));
                    pw.isRequired = Boolean.valueOf(reader.getAttributeValue(null, 'Req'));
                    pw.isForSummary = Boolean.valueOf(reader.getAttributeValue(null, 'Summ'));

                    //Populate picklist values if field type is picklist
                    if(pw.fieldType == 'PICKLIST' || pw.fieldType == 'MULTIPICKLIST') {
                        if(fieldMap.get(pw.fieldName) != null)
                        {
                            list<Schema.PicklistEntry> values = fieldMap.get(pw.fieldName).getDescribe().getPickListValues();
                            for (Schema.PicklistEntry a : values) {
                                pw.picklistValues.add(a.getValue());
                            }
                        }
                    }

                    if(pw.fieldName == (namespaceFieldPrefix + 'Gift_Type__c') && giftTypePicklistValues != null) {
                        pw.picklistValues.clear();
                        for(String val : giftTypePicklistValues.split('~`~', 0)) {
                            if(val != '') {
                                pw.picklistValues.add(val);
                            }
                        }
                    }

                    presetDataList.add(pw);
                }
            }
            reader.next();
        }
        return presetDataList;
    }

    //Convert date string in date instance.
    public Date convertDate(string stringDate) {

        String[] strDateDivided = stringDate.split(' ');
        strDateDivided = strDateDivided[0].split('-');

        Integer year = Integer.ValueOf(strDateDivided[0]);
        Integer month = Integer.ValueOf(strDateDivided[1]);
        Integer day = Integer.ValueOf(strDateDivided[2]);

        return date.newinstance(year, month, day);
    }

    //Sort picklist option by field's label.
    public list<selectOption> selectOptionSortByLabel(list<selectOption> selectOptionsToSort) {

        if(selectOptionsToSort == null || selectOptionsToSort.size() <= 1)
            return selectOptionsToSort;

        List<SelectOption> lessSelectOption = new List<SelectOption>();
        List<SelectOption> greaterSelectOption = new List<SelectOption>();
        integer pivot = selectOptionsToSort.size() / 2;

        //save the pivot and remove it from the selectOption list
        SelectOption pivotValue = selectOptionsToSort[pivot];
        selectOptionsToSort.remove(pivot);
        for(selectOption SO : selectOptionsToSort) {
            if(SO.getLabel() <= pivotValue.getLabel()) {
                lessSelectOption.add(SO);
            }
            else if(SO.getLabel() > pivotValue.getLabel()) {
                greaterSelectOption.add(SO);
            }
        }

        list<selectOption> sortedSelectOptions = new list<selectOption>();
        sortedSelectOptions.addAll(selectOptionSortByLabel(lessSelectOption));
        sortedSelectOptions.add(pivotValue);
        sortedSelectOptions.addAll(selectOptionSortByLabel(greaterSelectOption));

        return SortedSelectOptions;
    }

}