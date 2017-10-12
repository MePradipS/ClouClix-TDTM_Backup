public with sharing class GivingpowerUtility {
   
   public static final string FIELD_TYPE_TEXT = 'Text';
   public static final string FIELD_TYPE_INT = 'Integer';
   public static final string FIELD_TYPE_DOUBLE = 'Double';
   public static final string FIELD_TYPE_DATE = 'Date';
   public static final string FIELD_TYPE_DATETIME = 'DateTime';
   public static final string FIELD_TYPE_BOOLEAN = 'Boolean';
    
    //array of dates, returns number of conseq years
    public static Integer ConseqFiscalYears(List<Date> dates, Integer fysm)
    {
        //To return 0 if no transaction exists
        Integer conseq = 0;
        Set<Integer> dateSet = new Set<Integer>();
        List<Integer> dateList = new List<Integer>();
        if(dates.size() > 0)
        {
          for (Integer i = (dates.size()-1); i >= 0; i--)
          { 
            if(dates[i] > Date.Today()){
                dates.remove(i);                
            }
          }
        }
      //getting distinct set of sorted records removing null values from it
      set<Date> setDate  = new set<Date>(dates);
      setDate.remove(null);
      dates.clear();
      dates.addAll(setDate);
        if(dates.size() > 0)
        {
            for (date d : dates)
            {
                dateSet.add(d.year());
            }
        }
      dateList.addAll(dateSet);
      dateList.sort();   
       //assign the size of date list to variable
      //Integer listSize = dates.size();
      Integer listSize = dateList.size();
      
      //if size is greater then zero then to proceed
        if(listSize > 0)
        { 
            conseq = 0;
            /*  calculating the conseq for the max date available in date list. atleast one date will be there
            *   Fetching the last date from the list of dates which will be the max year subtracted from previous year
            */
             //conseq = (dates[listSize - 1].year())-(Date.Today().Year()-1);
             conseq = (dateList[listSize - 1])-(Date.Today().Year()-1);
             
             //If year is the previous year it will be 0 then to return -1
             //if(conseq == 0 && (dates[listSize - 1].year()) == (Date.Today().Year()-1)) 
             if(conseq == 0 && (dateList[listSize - 1]) == (Date.Today().Year()-1))
                 conseq = 1;

           //If the dates size is greater then 1 then for checking the consecutive
           //checking for consecutive years 
           if(listSize > 1 && conseq > 0)
            { 
               //calulating the consecutive years
               for (Integer i = (listSize - 2); i >= 0; i--)
                { 
                if(((dateList[i+1] - dateList[i]) == 1))
                   {
                      conseq++;
                    }
                  else
                   break;        
                }      
             }    
             
        }
        else
          conseq = 0;
          return conseq ;      
    }
   
   public static Boolean isCurrentFiscal(Date aDate, Integer fysm)
   {
       Integer FYrStrtMonth = fysm;
       if (aDate == null)
           return false;
       
       //if the fiscal year starts on Jan 1st, then we only need to check the year
       if (FYrStrtMonth == 1 && aDate.Year() == Date.Today().Year())
       { return true; }       
       //if the current month is beyond the starting fiscal month, the fiscal year ends in the next calendar year
       if (Date.Today().Month() >= FYrStrtMonth && aDate > Date.newInstance(Date.Today().Year(), FYrStrtMonth, 1) && aDate < Date.newInstance(Date.Today().Year() + 1, FYrStrtMonth, 1))
       { return true; }
       //if the current month has not reached the starting fiscal month, the fiscal year began in the previous calendar year       
       else if (Date.Today().Month() < FYrStrtMonth && aDate > Date.newInstance(Date.Today().Year() - 1, FYrStrtMonth, 1) && aDate < Date.newInstance(Date.Today().Year(), FYrStrtMonth, 1))
       { return true; }
              
       return false;
   }
   
   public static Boolean isLastFiscalYear(Date aDate, Integer orgFiscalYearStartMonth)
   {
       if (aDate == null)
           return false;
       
       //if the fiscal year starts on Jan 1st, then we only need to check the year
       if (orgFiscalYearStartMonth == 1 && aDate.Year() == Date.Today().Year() - 1)
       { return true; }       
       //if the current month is beyond the starting fiscal month, the fiscal year ends in the next calendar year
       if (Date.Today().Month() >= orgFiscalYearStartMonth && aDate > Date.newInstance(Date.Today().Year() - 1, orgFiscalYearStartMonth, 1) && aDate < Date.newInstance(Date.Today().Year(), orgFiscalYearStartMonth, 1))
       { return true; }
       //if the current month has not reached the starting fiscal month, the fiscal year began in the previous calendar year       
       else if (Date.Today().Month() < orgFiscalYearStartMonth && aDate > Date.newInstance(Date.Today().Year() - 2, orgFiscalYearStartMonth, 1) && aDate < Date.newInstance(Date.Today().Year() - 1, orgFiscalYearStartMonth, 1))
       { return true; }
              
       return false;
   }
   
   public static Date fiscalYearStartDate(Integer orgFiscalYearStartMonth){
   		if(orgFiscalYearStartMonth == null)
   			return Date.newInstance(Date.Today().Year(),1,1);
   		 
       if (Date.Today().Month() <= orgFiscalYearStartMonth){
    	   return Date.newInstance(Date.Today().Year(),orgFiscalYearStartMonth,1); 
       } else if (Date.Today().Month() > orgFiscalYearStartMonth) {
    	   return Date.newInstance(Date.Today().Year() - 1,orgFiscalYearStartMonth,1);
       } else {
    	   return Date.newInstance(Date.Today().Year(),1,1); 
       }
   }
   
   public static Date fiscalYearEndDate(Integer orgFiscalYearStartMonth){
  		if(orgFiscalYearStartMonth == null)
  			return Date.newInstance(Date.Today().Year() + 1,1,1);
  		 
      if (Date.Today().Month() <= orgFiscalYearStartMonth){
   	   return Date.newInstance(Date.Today().Year() + 1,orgFiscalYearStartMonth,1); 
      } else if (Date.Today().Month() > orgFiscalYearStartMonth) {
   	   return Date.newInstance(Date.Today().Year(),orgFiscalYearStartMonth,1);
      } else {
   	   return Date.newInstance(Date.Today().Year() + 1,1,1); 
      }
  }

   public static Schema.SObjectType findSobjectType(string sObjectName) {
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
    for(string key : gd.keySet())
     if (key == sObjectName)
       return gd.get(key);
    return null;
  }
   
  public static SObject setFieldValue(SObject obj, string fieldName, string fieldType, string Value)
  {
       if (fieldType == GivingpowerUtility.FIELD_TYPE_BOOLEAN) {   
            Value = Value.toLowerCase();
            obj.put(fieldName,Value.equals('true'));
       }
       else if (fieldType == GivingpowerUtility.FIELD_TYPE_DATE)
            obj.put(fieldName,Date.parse(Value));
       else if (fieldType == GivingpowerUtility.FIELD_TYPE_DATETIME)
            obj.put(fieldName,DateTime.parse(Value));
       else if (fieldType == GivingpowerUtility.FIELD_TYPE_DOUBLE)
            obj.put(fieldName,Double.valueOf(Value));
       else if (fieldType == GivingpowerUtility.FIELD_TYPE_INT)
            obj.put(fieldName,Integer.valueOf(Value));
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