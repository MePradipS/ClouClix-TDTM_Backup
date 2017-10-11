public with sharing class MappingUtil {
   
   public static final string FIELD_TYPE_TEXT = 'Text';
   public static final string FIELD_TYPE_INT = 'Integer';
   public static final string FIELD_TYPE_DOUBLE = 'Double';
   public static final string FIELD_TYPE_DATE = 'Date';
   public static final string FIELD_TYPE_DATETIME = 'DateTime';
   public static final string FIELD_TYPE_BOOLEAN = 'Boolean';
   public static final string FIELD_TYPE_BLOB = 'Blob';

   public static Schema.SObjectType findSobjectType(string sObjectName) {
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
    
    for(string key : gd.keySet())
     if (key == sObjectName)
       return gd.get(key);
    return null;
  }
   
  public static SObject setFieldValue(SObject obj, string fieldName, string fieldType, string Value)
  {
       if (fieldType == MappingUtil.FIELD_TYPE_BOOLEAN) {   
            Value = Value.toLowerCase();
            obj.put(fieldName,Value.equals('true'));
       }
       else if (fieldType == MappingUtil.FIELD_TYPE_DATE)
            obj.put(fieldName,Date.parse(Value));
       else if (fieldType == MappingUtil.FIELD_TYPE_DATETIME)
            obj.put(fieldName,DateTime.parse(Value));
       else if (fieldType == MappingUtil.FIELD_TYPE_DOUBLE)
            obj.put(fieldName,Double.valueOf(Value));
       else if (fieldType == MappingUtil.FIELD_TYPE_INT)
            obj.put(fieldName,Integer.valueOf(Value));
       else if (fieldType == MappingUtil.FIELD_TYPE_BLOB)
       		obj.put(fieldName, encodingUtil.base64Decode(Value));
       else
            obj.put(fieldName,String.valueOf(Value));         
       return obj;
  }
  
  public static Boolean IsEmptyOrNull(string value) {
    return (value==null || value=='');
  }
  
  public static string formatDateForQuery(Date d)
  {
  	string year = decimal.valueOf(d.year()).toPlainString();
  	string month = decimal.valueOf(d.month()).toPlainString();
    string day = decimal.valueOf(d.day()).toPlainString();
    month = addLeadingZero(month);
    day = addLeadingZero(day);
    return year+'-'+month+'-'+day;	
  }
  
  public static string formatDateTimeForQuery(DateTime d)
  {
  	string year = decimal.valueOf(d.year()).toPlainString();
  	string month = decimal.valueOf(d.month()).toPlainString();
    string day = decimal.valueOf(d.day()).toPlainString();
    month = addLeadingZero(month);
    day = addLeadingZero(day);
  	string formattedDate = year+'-'+month+'-'+day;
  	string hour = decimal.valueOf(d.hour()).toPlainString();
  	string min =  decimal.valueOf(d.minute()).toPlainString();
  	string second =  decimal.valueOf(d.second()).toPlainString();
  	hour = addLeadingZero(hour);
  	min = addLeadingZero(min);
  	second = addLeadingZero(second);
  	
  	return formattedDate+'T'+hour+':'+min+':'+second+'Z';
  }
  
  private static string addLeadingZero(string val)
  {
  	if (val.length()==1)
  	  val = '0'+val;
  	return val;
  }
  
}