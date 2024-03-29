/**
* @group Utilities
* @description This class allows easy access to object and field description information from within other classes.
*
* It is called statically, and therefore will supply the same information to all calls made from
* within one transaction, or set of trigger calls. This is beneficial because this info should
* be the same for all calls in a transaction, and by calling it statically we reduce the calls
* that are made, making the total transaction more efficient.
*/

public class UTIL_Describe {

    // throw custom exceptions when a bogus object or field is provided.
    public class SchemaDescribeException extends Exception {}

    //maps to hold the describe info
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String, Schema.DescribeSObjectResult> objectDescribes = new Map<String, Schema.DescribeSObjectResult>();
    private static Map<String, Map<String, Schema.SObjectField>> fieldTokens = new Map<String,Map<String, Schema.SObjectField>>();
    private static Map<String, Map<String, Schema.DescribeFieldResult>> fieldDescribes = new Map<String,Map<String, Schema.DescribeFieldResult>>();

    /*******************************************
    * Gets describe maps for a new object
    ********************************************/
    static void fillMapsForObject(string objectName) {
        // get the object map the first time
        if (gd==null) gd = Schema.getGlobalDescribe();

        // get the object description
        if (gd.containsKey(objectName)) {

            if (!objectDescribes.containsKey(objectName))
                objectDescribes.put(objectName, gd.get(objectName).getDescribe());
        } else {
            throw new SchemaDescribeException('Invalid object name \'' + objectName + '\'');
        }
    }

    /*******************************************
    * Gets a field map for a new object/field pair
    ********************************************/
    private static void fillFieldMapsForObject(string objectName, string fieldName) {
        // get the object map the first time
        fillMapsForObject(objectName);

        // get the field description
        if (!fieldTokens.containsKey(objectName)) {
            fieldTokens.put(objectName, objectDescribes.get(objectName).fields.getMap());
            fieldDescribes.put(objectName, new Map<String, Schema.DescribeFieldResult>());
        }
        if (!fieldDescribes.get(objectName).containsKey(fieldName)) {
            if (fieldTokens.get(objectName).containsKey(fieldName)) {
                Schema.DescribeFieldResult dfr = fieldTokens.get(objectName).get(fieldName).getDescribe();
                fieldDescribes.get(objectName).put(fieldName, dfr);
            } else {
                throw new SchemaDescribeException('Invalid field name \'' + fieldName + '\'');
            }
        }
    }

    /*******************************************
    * Gets all field maps for a new object
    ********************************************/
    static void fillFieldMapsForObject(string objectName) {
        // get the object map the first time
        fillMapsForObject(objectName);

        // get the field description
        if (!fieldTokens.containsKey(objectName)) {
            fieldTokens.put(objectName, objectDescribes.get(objectName).fields.getMap());
            fieldDescribes.put(objectName, new Map<String, Schema.DescribeFieldResult>());
        }

        //Map<String, Schema.SObjectField> fieldsMap = objectDescribes.get(objectName).fields.getMap();
        if (fieldTokens.get(objectName).size() != fieldDescribes.get(objectName).size()) {
            for ( string fieldName : fieldTokens.get(objectName).keyset()) {
                if (!fieldDescribes.get(objectName).containsKey(fieldName)) {
                    Schema.DescribeFieldResult dfr = fieldTokens.get(objectName).get(fieldName).getDescribe();
                    fieldDescribes.get(objectName).put(fieldName, dfr);
                }
            }
        }
    }

    /*******************************************************************************************************
    * @description Returns new object of given type.
    * @param objectName the name of the object to create
    * @return the new SObject
    */
    public static SObject getPrototypeObject(String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName))
            fillMapsForObject(objectName);

        return gd.get(objectName).newSObject();
    }

    /*******************************************************************************************************
    * @description Returns object friendly name.
    * @param objectName the name of the object to lookup
    * @return the Label of the object
    */
    public static string getObjectLabel(String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName))
            fillMapsForObject(objectName);

        return objectDescribes.get(objectName).getLabel();
    }

    /*******************************************************************************************************
    * @description Returns object describe data.
    * @param objectName the name of the object to lookup
    * @return Schema.DescribeSObjectResult of the object
    */
    public static Schema.DescribeSObjectResult getObjectDescribe(String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName))
            fillMapsForObject(objectName);

        return objectDescribes.get(objectName);
    }

    /*******************************************************************************************************
    * @description Compares Id to verify object type
    * @param salesforceId of the object
    * @param objectName
    * @return true if the Id is for the given object type, false otherwise.
    */
    public static boolean isObjectIdThisType(Id salesforceId, String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName))
            fillMapsForObject(objectName);

        // now grab the requested id prefix
        boolean ret = false;
        if (salesforceId != null) {
            string prefix = objectDescribes.get(objectName).getKeyPrefix();
            if (prefix != null)
                ret = ((string)(salesforceId)).startsWith(prefix);
        }
        return ret;
    }

    /*******************************************************************************************************
    * @description Returns all field describe data
    * @param objectName the name of the object to look up
    * @return Map<String, Schema.DescribeFieldResult> a map of object names to describe file results.
    */
    public static Map<String, Schema.DescribeFieldResult> getAllFieldsDescribe(String objectName) {

        // make sure we have this object's schema mapped
        fillFieldMapsForObject(objectName);

        Map<String, Schema.DescribeFieldResult> fieldMap = fieldDescribes.get(objectName);
        return fieldMap;
    }

    /*******************************************************************************************************
    * @description Returns the Name field of any given object.
    * @param objectName the name of the object to look up
    * @return String the API name of the Name field
    */
    public static String getNameField(String objectName) {
        String nameField = 'Name';

        Map<String, Schema.DescribeFieldResult> mapObjectFields = getAllFieldsDescribe(objectName);

        if (!mapObjectFields.containsKey(nameField)) {
            nameField = null;
            for (String relatedFieldName : mapObjectFields.keySet()) {
                if (mapObjectFields.get(relatedFieldName).isNameField()) {
                    return relatedFieldName;
                }
            }
        }
        
        return nameField;
    }

    /*******************************************************************************************************
    * @description Gives field type name - ID, STRING, TEXTAREA, DATE, DATETIME, BOOLEAN, REFERENCE,
    * PICKLIST, MULTIPICKLIST, CURRENCY, DOUBLE, INTEGER, PERCENT, PHONE, EMAIL
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the name of the of the field's type
    */
    public static string getFieldType(String objectName, String fieldName) {
        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
            fillFieldMapsForObject(objectName, fieldName);

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr.getType().name();
    }

    /*******************************************************************************************************
    * @description Gives field type name - ID, STRING, TEXTAREA, DATE, DATETIME, BOOLEAN, REFERENCE,
    * PICKLIST, MULTIPICKLIST, CURRENCY, DOUBLE, INTEGER, PERCENT, PHONE, EMAIL
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return Displaytype the Displaytype of the field
    */
    public static Schema.Displaytype getFieldDisplaytype(String objectName, String fieldName) {
        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
            fillFieldMapsForObject(objectName, fieldName);

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr.getType();
    }

    /*******************************************************************************************************
    * @description Returns field describe data
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return Schema.DescribeFieldResult the describe field result for the given field
    */
    public static Schema.DescribeFieldResult getFieldDescribe(String objectName, String fieldName) {
        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
            fillFieldMapsForObject(objectName, fieldName);

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr;
    }

    /*******************************************************************************************************
    * @description Gives field friendly name
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the label of the field
    */
    public static string getFieldLabel(String objectName, String fieldName) {
        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
            fillFieldMapsForObject(objectName, fieldName);

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr.getLabel();
    }

    /*******************************************************************************************************
    * @description Gives field friendly name without throwing exception if not valid.
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the label of the field
    */
    public static string getFieldLabelSafe(string strObj, string strField) {
        try {
            return getFieldLabel(strObj, strField);
        } catch (Exception e) {
            return strField;
        }
    }

    /*******************************************************************************************************
    * @description checks whether the field exists
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return boolean whether the field exists
    */
    public static boolean isValidField(String objectName, String fieldName) {
        // make sure we have this field's schema mapped
        try {
            if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
                fillFieldMapsForObject(objectName, fieldName);

            Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
            return dfr != null;
        } catch (exception ex) {
            return false;
        }
    }

    /*******************************************************************************************************
    * @description utility to check for compatible datatypes for data copying
    * @param dtSrc the DisplayType of the source object
    * @param dtTgt the DisplayType of the target object
    * @return true if the types can be copied between
    */
    public static boolean canDisplaytypesCopy(Schema.Displaytype dtSrc, Schema.Displaytype dtTgt) {

        if (dtSrc == dtTgt)
           return true;

        // date can go to datetime
        if (dtSrc == Schema.Displaytype.Date && dtTgt == Schema.Displaytype.DateTime)
           return true;

        // numbers can implictly cast to other numbers
        if ((dtSrc == Schema.Displaytype.Currency ||
            dtSrc == Schema.Displaytype.Double ||
            dtSrc == Schema.Displaytype.Integer ||
            dtSrc == Schema.Displaytype.Percent) &&
           (dtTgt == Schema.Displaytype.Currency ||
            dtTgt == Schema.Displaytype.Double ||
            dtTgt == Schema.Displaytype.Integer ||
            dtTgt == Schema.Displaytype.Percent)) {
            return true;
        }

        // text can go to longer text
        if (dtSrc == Schema.Displaytype.String && dtTgt == Schema.Displaytype.TextArea)
            return true;

        return false;
    }

    /*******************************************************************************************************
    * @description utility to return a list of strings from a field set.
    * @param strObject the name of the object
    * @param strFS the name of the object's field set
    * @return a list of strings of field names in the field set
    */
    // utility to return a list of strings from a field set.
    public static list<string> listStrFromFieldSet(string strObject, string strFS) {
        list<string> listStrFields = new list<string>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(strObject);
        Schema.DescribeSObjectResult d = targetType.getDescribe(); 
        Schema.FieldSet fs = d.fieldSets.getMap().get(strFS); 
        if (fs == null) {
            return null;
        } else {
            for(Schema.FieldSetMember f : fs.getFields()) {
                if (f.getFieldPath().contains('.')) {
                    throw (new SchemaDescribeException('Related field \'' + f.getFieldPath() + '\' not supported ' +
                        'in field set \'' + strFS + '\'.  You can only include fields directly on object \'' + strObject + '\'.'));
                }
                listStrFields.add(f.getFieldPath());
            }
            return listStrFields;
        }
    }

    /*******************************************************************************************************
    * @description utility to return a comma separated string of field names from a field set
    * @param strObject the name of the object
    * @param strFS the name of the object's field set
    * @return a comma separated string of field names in the field set
    */
    public static string strFieldNamesFromFieldSet(string strObject, string strFS) {
        string strFields = '';
        for (string str : listStrFromFieldSet(strObject, strFS)) {
            strFields += str + ',';
        }
        return strFields.substring(0, strFields.length()-1);
    }

    /*******************************************************************************************************
    * @description copies the specified fields, make sure the user has apppropriate permissions
    * @param strObject the name of the object
    * @param src the Source object
    * @param dst the Destination object
    * @param listStrF the list of field names to check FLS and copy data from
    * @return void
    */
    public static void copyObjectFLS(string strObject, SObject src, SObject dst, list<String> listStrF) {
        for (String strF : listStrF) {
            DescribeFieldResult dfr = UTIL_Describe.getFieldDescribe(strObject, strF);
            if (dfr == null || !dfr.isCreateable() || !dfr.isUpdateable())
                throw (new permsException(string.format(label.flsError, new string[]{strObject + '.' + strF})));
            
            // don't copy null for checkbox fields, or they will give an error on update
            if (dfr.isNillable() || src.get(strF)!= null) {    
                dst.put(strF, src.get(strF));
            }
        }
    }

    /** @description Returns a list of SelectOptions for a given object and picklist field name.
    * @param objectName The name of the object.
    * @param fieldName The name of the field.
    * @return List<SelectOption> The select options for this picklist field.
    */

    public static List<SelectOption> getSelectOptions(String objectName, String fieldName) {
        Schema.DescribeFieldResult describeField = UTIL_Describe.getFieldDescribe(objectName, fieldName);
        List<SelectOption> result = new List<SelectOption>();
        if (describeField.getType() == Schema.DisplayType.PICKLIST) {
            for (Schema.PicklistEntry entry : describeField.getPicklistValues()) {
                if (entry.isActive()) {
                    result.add(new SelectOption(entry.getLabel(), entry.getValue()));
                }
            }
        }
        return result;
    }

    /** @description Returns the default SelectOption for a given object and picklist field name.
    * @param objectName The name of the object.
    * @param fieldName The name of the field.
    * @return String The default select option for this picklist field.
    */
    public static String getDefaultSelectOption(String objectName, String fieldName) {
        Schema.DescribeFieldResult describeField = getFieldDescribe(objectName, fieldName);
        if (describeField.getType() == Schema.DisplayType.PICKLIST) {
            for (Schema.PicklistEntry entry : describeField.getPicklistValues()) {
                if (entry.isDefaultValue()) {
                    return entry.getValue();
                }
            }
        }
        return null;
    }

    /** @description For a given object and field, verifies that the field is accessible and updateable,
    * throwing an exception if it isn't.*/
    public static void checkFieldFLS(String objectName, String fieldName) {
        DescribeFieldResult dfr = getFieldDescribe(
            UTIL_Namespace.StrTokenNSPrefix(objectName), 
            fieldName.endsWith('__c')?UTIL_Namespace.StrTokenNSPrefix(fieldName):fieldName
        );
        if (dfr == null || !dfr.isAccessible() || !dfr.isUpdateable()) {
            throw (new permsException(
                string.format(
                    label.flsError, 
                    new string[]{UTIL_Namespace.StrTokenNSPrefix(objectName) + '.' + 
                                 UTIL_Namespace.StrTokenNSPrefix(fieldName)}
                )
            ));
        }
    }

    /** @description returns true if the MiddleName field is enabled in this org */
    public static Boolean isMiddleNameEnabled() {
        if (!fieldTokens.containsKey('Contact')) {
            fieldTokens.put('Contact', Contact.sObjectType.getDescribe().fields.getMap());
            fieldDescribes.put('Contact', new Map<String, Schema.DescribeFieldResult>());
        }
        return fieldTokens.get('Contact').containsKey('middlename');
    }

    /** @description our exception object for Field Level & Object Security errors. */
    private class permsException extends Exception {}
    
}