global with sharing class MappingService {
    //--------------------------------------------------------
  // Output Objects
  // --------------------------------------------------------
  global with sharing class MappingResponse {
    WebService String bagId = '';
    WebService MappingObjectResponse[] objectResponses;
    WebService String[] errors;
    WebService Log[] logs;
    WebService boolean success = false;

    public void addMessage(string msg) {
        addMessage(msg, LogEventType.Information);
    }

    public void addMessage(string msg, LogEventType t)
    {
        if (logs == null)
         logs = new List<Log>();

        Log l = new Log(t, msg);
        logs.add(l);
    }

    public void addError(string error) {
        if (logs == null)
         logs = new List<Log>();

        Log l = new Log(LogEventType.Error, error);
        logs.add(l);

        if (errors == null)
         errors = new List<String>();
        errors.add(error);

        success = false;
    }
  }
  //------------------------------------------------------
  global with sharing class MappingObjectResponse {
    //Alias used within the dataBag Context
    Webservice String alias = '';
    //SFDC Api Name of the object
    WebService String apiName = '';
    // Id found or newly created for the given object in Client org
    WebService String systemId = '';
    // whether Api ended up creating the record or updated an existing one (values: new, existing)
    WebService String recordType = 'new';
    // the object being worked on, used locally not in WS context
    public SObject mappingObject;
  }

  //--------------------------------------------------------
  // log Objects
  // --------------------------------------------------------
  global enum LogEventType { Information, Warning, Error }
  global with sharing class Log {
    Webservice DateTime logTime;
    Webservice LogEventType logType;
    Webservice String description = '';

    public Log(LogEventType t, String d)
    {
        logTime = DateTime.Now();
        logType = t;
        description = d;
    }
  }

  //--------------------------------------------------------
  // Input Objects
  // --------------------------------------------------------
  global enum MappingAction { INS, UPD, UPS, DEL, SEL }
  //------------------------------------------------------
  global with sharing class MappingDataBag {
     WebService string bagId;
     WebService MappingObject[] mappingObjects;
  }
  //------------------------------------------------------
  global with sharing class MappingObject {
     WebService string apiName;
     WebService string alias;
     WebService MappingAction action;
     WebService MappingLookupFilter[] lookupFilters;
     WebService MappingField[] mappingFields;
  }
  //------------------------------------------------------
  global with sharing class MappingField  {
     WebService string apiName;
     WebService string value;
     WebService string fieldType;
     public MappingField() { }
     public MappingField(string apiName,string Value,string fType) {
            this.ApiName = apiName;
            this.Value = Value;
            this.fieldType = fType;
     }
  }
  //------------------------------------------------------
  global with sharing class MappingLookupFilter {
     WebService string apiName;
     WebService string value;
     WebService string operator;
     WebService string fieldType;
     public MappingLookupFilter() { }
     public MappingLookupFilter(string apiName,string Value, string operator, string fieldType) {
        this.apiname = apiName; this.value = Value; this.operator = operator; this.fieldType = fieldType;
     }
  }
  //------------------------------------------------------
  global with sharing class MappingException extends Exception { }

  //--------------------------------------------------------
  // WS methods
  //--------------------------------------------------------
   WebService static MappingResponse PerformMapping(MappingDataBag dataBag) {

    // preparing the response objects
    MappingResponse retVal = new MappingResponse();
    if (dataBag == null)
    {
        retVal.addError('invalid parameter: null');
        return retVal;
    }

    List<MappingObjectResponse> objResponses = new List<MappingObjectResponse>();
    retVal.objectResponses = objResponses;
    retVal.bagId = dataBag.bagId;

    if (dataBag.mappingObjects == null || dataBag.mappingObjects.size()<=0)
    {
        retVal.addError('invalid parameter, Mapping Objects: null');
        return retVal;
    }

    //try/catch and handle transaction
     Savepoint sp = Database.setSavepoint();

    try
    {
       for(MappingObject mobj : dataBag.mappingObjects) {
            string objectFriendlyName = mobj.apiName+'-alias:'+mobj.alias;
            retVal.addMessage('Start: processing object:' + objectFriendlyName);

            MappingObjectResponse objResponse = new MappingObjectResponse();
            objResponse.apiName = mobj.apiName;
            objResponse.alias = (MappingUtil.IsEmptyOrNull(mobj.alias))? mobj.apiName : mobj.alias;
            mobj.alias = objResponse.alias;
            objResponses.add(objResponse);

            if (mobj.mappingFields == null || mobj.mappingFields.size() <= 0) {
                 retVal.addMessage('Skipped mapping ' + objectFriendlyName + ' -Reason: no fields provided.' );
                continue;
            }

            if (mobj.action == null)
            {
                retVal.addError('Error: Object action is missing: ' + objectFriendlyName);
                return retVal;
            }

            //find the object type
            Schema.SObjectType objType = MappingUtil.findSobjectType(mobj.apiName);
            if (objType == null) {
                retVal.addError('Error: Object not found.' + objectFriendlyName);
                return retVal;
            }

            //get a new instance of the object
            SObject newObject = objType.newSObject();
            objResponse.mappingObject = newObject;
            Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();

            //populate field values
            if (mobj.action != MappingAction.SEL)
                newObject = populateFields(newObject, sobjectDescribe, mobj, retVal);

            //upsert if there is no errors
            if (retVal.errors == null || retVal.errors.size() <= 0)
                upsertObject(newObject, sobjectDescribe, mobj, objResponse, retVal);

        }//end for
     }
     catch (Exception ex)
     {
        Database.rollback(sp);
        retVal.addError(ex.getMessage());
        retVal.success = false;
        return retVal;
     }

     retVal.success = true;
     return retVal;
   }//perfrom mapping

   //----------------------------------------------------------------------------------------
   public static void upsertObject(SObject newObject,
       Schema.DescribeSObjectResult objDescriber,
       MappingObject mobj,
       MappingObjectResponse objResponse,
       MappingResponse retVal) {

       string objectName = mobj.apiName + '-(alias:'+mobj.alias+')';

       if (mobj.action == MappingAction.SEL) {
           SObject[] foundObjs = selectSObject(mobj,retVal);
           if (foundObjs != null && foundObjs.size()>0) {
                if (foundObjs.size()>1)
                    retVal.addMessage('Object ' + objectName + ' action: select, warning the query found more than one record! The record at index 0 is used.');

                newObject = foundObjs[0];
                objResponse.systemId = newObject.Id;
                objResponse.recordType = 'existing';
                objResponse.mappingObject = newObject;
                retVal.addMessage('Object ' + objectName + ' action: select completed, system Id:' + newObject.Id);

           }
           else
             retVal.addError('Object ' + objectName + ' action: select, was not able to find the record. system Id:' + newObject.Id);

           return;
       }
       else if (mobj.action == MappingAction.UPS) {

         //lookup object record
         SObject foundObj = lookupSObject(mobj,retVal);
         if (foundObj != null)
         {
            //merge if exists
             newObject = mergeSObject(newObject, foundObj, mobj.mappingFields, true);
             DMLManager.UpdateSObject(newObject);

             //update results
             objResponse.systemId = newObject.Id;
             objResponse.recordType = 'existing';
             objResponse.mappingObject = newObject;
              //log message
             retVal.addMessage('Object ' + objectName + ' action: upsert completed, system Id:' + newObject.Id);
             return;
         }
         else
         {
            DMLManager.InsertSObject(newObject);

           //update results
           objResponse.systemId = newObject.Id;
           objResponse.recordType = 'new';
           objResponse.mappingObject = newObject;
           //log message
           retVal.addMessage('Object ' + objectName + ' action: upsert completed, system Id:' + newObject.Id);
           return;

         }


       }
       else if (mobj.action == MappingAction.INS) {
          DMLManager.InsertSObject(newObject);
          //log message
          retVal.addMessage('Object ' + objectName + ' action: insert completed, system Id:' + newObject.Id);
          //update results
           objResponse.systemId = newObject.Id;
           objResponse.recordType = 'new';
           objResponse.mappingObject = newObject;
       }
       else if (mobj.action == MappingAction.UPD) {

         SObject foundObj = lookupSObject(mobj,retVal);
         if (foundObj != null) {
            newObject = mergeSObject(newObject, foundObj, mobj.mappingFields, true);
         }

         if (newObject.Id != null) {
             DMLManager.UpdateSObject(newObject);

            //log message
            retVal.addMessage('Object ' + objectName + ' action: update completed, system Id:' + newObject.Id);
            //updating results
            objResponse.systemId = newObject.Id;
            objResponse.recordType = 'existing';
            objResponse.mappingObject = newObject;
         }
         else
         {
            retVal.addMessage('Object ' + objectName + ' action: update was skipped, system Id was not found.');
            return;
         }
       }
       else if (mobj.action == MappingAction.DEL) {

          boolean success = false;

          if (newObject.Id != null) {
            DMLManager.DeleteSObject(newObject);
            success = true;
          }
          else if (mobj.lookupFilters != null && mobj.lookupFilters.size()>0) {
            //lookup the record and then delete
            SObject foundObj = lookupSObject(mobj,retVal);
            if (foundObj != null) {
                DMLManager.DeleteSObject(foundObj);
                success = true;
            }

            //log message
            if (success) {
               retVal.addMessage('Object ' + objectName + ' action: delete completed, system Id:' + newObject.Id);
               //updating results
                objResponse.systemId = newObject.Id;
                objResponse.recordType = 'existing';
            }
            else
            {
                retVal.addMessage('Object ' + objectName + ' action: delete action was skipped, system record was not found.');
            }
          }
       }//end delete
       else {
          retVal.addError('Object ' + objectName + ' unsupported operation. Please check the form configuration' );
       }
   }


   //----------------------------------------------------------------------------------------
   public static SObject populateFields(SObject obj,
        Schema.DescribeSObjectResult objDescriber,
        MappingObject mobj,
        MappingResponse retVal)
   {
      string objectName = mobj.apiName + '-(alias:'+mobj.alias+')';

      for(MappingField mfield : mobj.mappingFields)
      {

          if (mfield.apiName == null || mfield.apiName == '')
           throw new MappingException('Object:'+ objectName + '- mapping field name is required and can not be null or empty.');

          if (mfield.fieldType != MappingUtil.FIELD_TYPE_BLOB)
            retVal.addMessage('Object:'+ objectName + '- mapping field:' + mfield.ApiName + ' to: '+ mfield.Value);

          //find if a relation mapping is required.
          if (isMergeField(mfield.Value)) {
            Object fieldValue = LookupMergeFieldValue(mfield.Value, objectName, retVal.objectResponses);

            retVal.addMessage('Object:'+ objectName + ', setting the lookup field: '+ mfield.apiName +' with value: '+ fieldValue);
            if (fieldValue != null)
                    obj.put(mfield.apiName,fieldValue);
          }
          else {

            if (MappingUtil.IsEmptyOrNull(mfield.Value)) {
                retVal.addMessage('Object:'+ objectName + ', setting field value was skipped, value is empty. field:' + mfield.apiName);
                continue;
            }

            //regular mapping
            obj = MappingUtil.setFieldValue(obj, mfield.ApiName, mfield.fieldType, mfield.Value);
            if (mfield.fieldType != MappingUtil.FIELD_TYPE_BLOB)
                retVal.addMessage('Object:'+ objectName + ', setting field: '+ mfield.apiName +' value to: '+ mfield.Value);

          }

      }
      return obj;
  }//end populate fields

  //----------------------------------------------------------------------------------------
  public static SObject mergeSObject(SObject newObject,
       SObject queryObject,
       List<MappingField> mfields,
       boolean updateMode)
  {
    //merge the two
    for(MappingField mfield : mfields)
    {
        object v = queryObject.get(mfield.apiName);
        if ((v == null || updateMode) && mfield.apiName!='Id')
        {
           //string Value = String.valueOf(newObject.get(mfield.apiName));
           //convert the value to the proper type and put into the record
           // queryObject = MappingUtil.setFieldValue(queryObject,mfield.apiName,mfield.fieldType,Value);
           object newValue = newObject.get(mfield.apiName);
           if (newValue != null)
             queryObject.put(mfield.apiName, newValue);
        }
    }
    return queryObject;
  }

  //------------------------------------------------------------------------------------------
  public static Object LookupMergeFieldValue(string value, string objectName, MappingObjectResponse[] objectResponses)
  {
     //find if a relation mapping is required.
      string[] lookupValues = tryLookupField(value);
      if (lookupValues != null)
      {
          if (lookupValues.size() <= 0) {
               throw new MappingException('Object:'+ objectName + ', input merge field string was not in correct format:' + value);
          }
          else
          {
                //lookup
                string lookupObjectAlias = lookupValues[0];
                Object fieldValue = '';
                boolean found = false;
                for(MappingObjectResponse r : objectResponses)
                 if (r.alias == lookupObjectAlias) {
                   fieldValue = r.mappingObject.get(lookupValues[1]);
                   found = true;
                   break;
                 }

                if (!found) {
                  throw new MappingException('Object:'+ objectName + ', lookup object was not found in the context:' + lookupObjectAlias);
                }//endif

                return fieldValue;
          }
      }


      return null;
  }
  //----------------------------------------------------------------------------------------
  public static Boolean isMergeField(string Value)
  {
     return (Value != null && Value.startsWith('{!') && Value.endsWith('}'));
  }

  //----------------------------------------------------------------------------------------
  public static string[] tryLookupField(string Value)
  {
     if (isMergeField(Value)) {
        Value = Value.replace('{!','');
        Value = Value.replace('}','');
        string[] strs = Value.split('\\.',0);
        return strs;
     }
     return null;
  }//end try lookup


  //----------------------------------------------------------------------------------------
  public static SObject lookupSObject(MappingObject mobj, MappingResponse response) {
    SObject[] foundObjects = selectSObject(mobj, response);
    if (foundObjects != null && foundObjects.size()>0)
    {
        return foundObjects[0];
    }
    else
       return null;
  }//end of lookup func
  //----------------------------------------------------------------------------------------
  public static SObject[] selectSObject(MappingObject mobj, MappingResponse response) {
    if (mobj.lookupFilters == null || mobj.lookupFilters.size()<=0)
      return null;

    string query = buildQuery(mobj.apiName,mobj.mappingFields,mobj.lookupFilters, response);
    String[] queryArray = query.split('#');
    SObject[] foundObjects = new GenericQueryBuilder().ListQueryBuilderClause(mobj.apiName, queryArray[0], queryArray[1]);
    return foundObjects;
  }
  //----------------------------------------------------------------------------------------
  public static string buildQuery(string sObjectName,
        List<MappingField> mfields,
        List<MappingLookupFilter> lookupFilters,
        MappingResponse retVal) {

    if (mfields == null || mfields.size() <= 0)
     return '';

    string commaDelimitedFields = 'Id';
    for(MappingField mfield : mfields)
      if (mfield.apiName.toLowerCase() != 'id') {
        commaDelimitedFields += ','+ string.escapeSingleQuotes(mfield.apiName);
    }//end for

    commaDelimitedFields += '#';
    string clause = '';
    string orderBy = '';

    if (lookupFilters != null && lookupFilters.size()>0)
    {
        orderBy = ' Order By ';

        for(MappingLookupFilter filter : lookupFilters) {
          if (filter.apiName == null)
              filter.apiName = '';

          clause += makeQueryCondition(filter, sObjectName, retVal.objectResponses) + ' AND ';
          orderBy += string.escapeSingleQuotes(filter.apiName) + ',';
        }

        //remove the last AND
        clause = clause.substring(0,clause.length()-4);
        orderBy = orderBy.substring(0,orderBy.length()-1);
        clause = commaDelimitedFields + clause + orderBy;
    }
    return clause;
  }
  //----------------------------------------------------------------------------------------
  private static string makeQueryCondition(MappingLookupFilter filter, string objectName, MappingObjectResponse[] objectResponses) {

    if (filter.apiName == null || filter.apiName == '')
    {
       throw new MappingException('Error: building lookup filter is skipped. Filter field name is empty.');
    }

    if (filter.value == null)
     filter.value = '';

    if (filter.operator == null || filter.operator == '')
       filter.operator = '=';


    string retVal = string.escapeSingleQuotes(filter.apiName)  + ' ' + string.escapeSingleQuotes(filter.operator) + ' ';
    string fieldValue = '';
    //try if merge field
    if (isMergeField(filter.value))
    {
        filter.value = String.valueOf(LookupMergeFieldValue(filter.value, objectName, objectResponses));
    }

    if (filter.fieldType == MappingUtil.FIELD_TYPE_TEXT)
      fieldValue = '\''+ string.escapeSingleQuotes(filter.value) + '\'';
    else if (filter.fieldType == MappingUtil.FIELD_TYPE_DATE){
       Date d = Date.parse(filter.value);
       fieldValue = MappingUtil.formatDateForQuery(d);
    }
    else if (filter.fieldType == MappingUtil.FIELD_TYPE_DATETIME) {
       DateTime d = DateTime.parse(filter.value);
       fieldValue = MappingUtil.formatDateTimeForQuery(d);
    }
    else
      fieldValue = string.escapeSingleQuotes(filter.value);

    retVal += fieldValue;
    return retVal;
  }


  //----------------------------------------------------------------------------------------
  static testMethod void testMe() {
    MappingService service = new MappingService();
    MappingService.PerformMapping(null);

    MappingService.MappingDataBag dataBag = new MappingService.MappingDataBag();
    MappingService.PerformMapping(dataBag);

    dataBag = testCreateBag(0);
    MappingService.PerformMapping(dataBag);

    dataBag = testCreateBag(1);
    MappingService.PerformMapping(dataBag);

    dataBag = testCreateBag(2);
    MappingService.PerformMapping(dataBag);

    dataBag = testCreateBag(3);
    MappingService.PerformMapping(dataBag);

    dataBag = testCreateBag(4);
    MappingService.PerformMapping(dataBag);
  }

  static testMethod void testMe2() {
    MappingService.MappingDataBag dataBag = testCreateBag(5);
    MappingService.PerformMapping(dataBag);

    dataBag = testCreateBag(6);
    MappingService.PerformMapping(dataBag);

    MappingService.MappingResponse response = new MappingService.MappingResponse();
    response.addMessage('hello');
    response.addError('hello error');
    response.bagId = 'sadasd';
    System.assertEquals(false,response.success);
  }

  static testMethod void testSelect() {
    MappingService.MappingDataBag bag = new MappingService.MappingDataBag();
    bag.bagId = 'testBag';
    bag.mappingObjects = new List<MappingObject>();

    MappingObject mobj = new MappingObject();
    mobj.apiName = 'Account';
    mobj.action = MappingService.MappingAction.SEL;
    bag.mappingObjects.add(mobj);
    mobj.mappingFields = new List<MappingField>();
    mobj.mappingFields.add(new MappingField('Name','test company', 'Text'));
    mobj.mappingFields.add(new MappingField('Type','Customer', 'Text'));
    mobj.mappingFields.add(new MappingField('NumberOfEmployees','23', 'Integer'));
    mobj.lookupFilters = new List<MappingLookupFilter>();
    mobj.lookupFilters.add(new MappingLookupFilter('Name','test company','=','Text'));

  }

  static testMethod void testSelectWithMergeFields() {
    MappingService.MappingDataBag bag = new MappingService.MappingDataBag();
    bag.bagId = 'testBag';
    bag.mappingObjects = new List<MappingService.MappingObject>();

    Account acc = new Account(Name='test Company 3456');
    DMLManager.InsertSObject(acc);

    Contact c = new Contact(LastName='test lastname', AccountId=acc.Id);
    DMLManager.InsertSObject(c);

    MappingService.MappingObject mobj = new MappingService.MappingObject();
    mobj.apiName = 'Account';
    mobj.action = MappingService.MappingAction.SEL;
    bag.mappingObjects.add(mobj);
    mobj.mappingFields = new List<MappingService.MappingField>();
    mobj.mappingFields.add(new MappingService.MappingField('Name','test company', 'Text'));
    mobj.mappingFields.add(new MappingService.MappingField('Type','Customer', 'Text'));
    mobj.lookupFilters = new List<MappingService.MappingLookupFilter>();
    mobj.lookupFilters.add(new MappingService.MappingLookupFilter('Name','test company 3456','=','Text'));

    MappingService.MappingObject con = new MappingService.MappingObject();
    con.apiName = 'Contact';
    con.action = MappingService.MappingAction.SEL;
    bag.mappingObjects.add(con);
    con.mappingFields = new List<MappingService.MappingField>();
    con.mappingFields.add(new MappingService.MappingField('FirstName','', 'Text'));
    con.mappingFields.add(new MappingService.MappingField('LastName','', 'Text'));
    con.lookupFilters = new List<MappingService.MappingLookupFilter>();
    con.lookupFilters.add(new MappingService.MappingLookupFilter('AccountId','{!Account.Id}','=','Text'));

    MappingService.PerformMapping(bag);

  }

  static MappingService.MappingDataBag testCreateBag(integer step) {
    MappingService.MappingDataBag bag = new MappingService.MappingDataBag();
    bag.bagId = 'testBag';
    bag.mappingObjects = new List<MappingObject>();

    MappingObject mobj = new MappingObject();
    mobj.apiName = 'Account';
    bag.mappingObjects.add(mobj);

    if (step>0)
        mobj.action = MappingService.MappingAction.UPD;

    if (step>1) {
        mobj.mappingFields = new List<MappingField>();
        mobj.mappingFields.add(new MappingField('Name','test company', 'Text'));
        mobj.mappingFields.add(new MappingField('Type','Customer', 'Text'));
        mobj.mappingFields.add(new MappingField('NumberOfEmployees','23', 'Integer'));
    }

    if (step>2) {
        mobj.lookupFilters = new List<MappingLookupFilter>();
        MappingLookupFilter filter = new MappingLookupFilter('Name','test company','=','Text');
        mobj.lookupFilters.add(filter);
    }

    if (step>3) {
        Account acc = new Account(Name='test Company');
        DMLManager.InsertSObject(acc);
    }

    if (step>4) {
        MappingObject cobj = new MappingObject();
        cobj.apiName = 'Contact';
        bag.mappingObjects.add(cobj);

        cobj.action = MappingService.MappingAction.UPS;
        cobj.mappingFields = new List<MappingField>();
        cobj.mappingFields.add(new MappingField('FirstName','Sam', 'Text'));
        cobj.mappingFields.add(new MappingField('LastName','Madison', 'Text'));
        cobj.mappingFields.add(new MappingField('Email','test@test.com', 'Text'));
        cobj.mappingFields.add(new MappingField('AccountId','{!Account.Id}', 'Text'));

        if (step>5) {
            cobj.lookupFilters = new List<MappingLookupFilter>();
            cobj.lookupFilters.add(new MappingLookupFilter('Email','test@test.com','=','Text'));

            Contact c = new Contact(FirstName='test', LastName='test2',Email='test@test.com');
            DMLManager.InsertSObject(c);

        }//endif step>5

    }

    return bag;
  }
}