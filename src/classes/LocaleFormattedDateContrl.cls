public class LocaleFormattedDateContrl
{
    
    public DateTime date_time { get; set; } //property that reads the datetime value from the component attribute tag
    
    //returns the properly formatted datetime value
    public String getTimeZoneValue() 
    {
        Map<String, String> mappedValues = new Map<String, String>(); //map for holding locale to datetime format
        mappedValues = MapValues(); //populate the map with all the locale specific datetime formats
        String user_locale = UserInfo.getLocale(); //grab the locale of the user
        String datetime_format = 'M/d/yyyy h:mm a'; //variable for the datetime format defaulted to the US format
        if (mappedValues.containsKey(user_locale)) { //if the map contains the correct datetime format
            datetime_format = mappedValues.get(user_locale); //grab the datetime format for the locale
        }
        
        date dt=Date.ValueOf(date_time);
        string sdt=string.valueof(dt);
       //addDays(1).
        String locale_formatted_date_time_value='';
        if(date_time !=null)
        {
         locale_formatted_date_time_value= DateTime.newInstance(dt.year(),dt.month(),dt.day()).format(datetime_format); 
        }
        return locale_formatted_date_time_value; //return the string
    }
    
    //populate a map with locale values and corresponding datetime formats
    public string getDateLocale(string userLocale){
        Map<String, String> locale_map = MapValues();
        string localeStr = '';
        if(locale_map.containskey(userLocale)){
            localeStr = locale_map.get(userLocale);
        }
        return localeStr;
    }
    
    public Map<String, String> MapValues() {
        Map<String, String> locale_map = new Map<String, String>();
        locale_map.put('ar', 'dd/MM/yyyy');
        locale_map.put('ar_AE', 'dd/MM/yyyy');
        locale_map.put('ar_BH', 'dd/MM/yyyy');
        locale_map.put('ar_JO', 'dd/MM/yyyy');
        locale_map.put('ar_KW', 'dd/MM/yyyy');
        locale_map.put('ar_LB', 'dd/MM/yyyy');
        locale_map.put('ar_SA', 'dd/MM/yyyy');
        locale_map.put('bg_BG', 'yyyy-M-d');
        locale_map.put('ca', 'dd/MM/yyyy');
        locale_map.put('ca_ES', 'dd/MM/yyyy');
        locale_map.put('ca_ES_EURO', 'dd/MM/yyyy');
        locale_map.put('cs', 'd.M.yyyy');
        locale_map.put('cs_CZ', 'd.M.yyyy');
        locale_map.put('da', 'dd-MM-yyyy');
        locale_map.put('da_DK', 'dd-MM-yyyy');
        locale_map.put('de', 'dd.MM.yyyy');
        locale_map.put('de_AT', 'dd.MM.yyyy');
        locale_map.put('de_AT_EURO', 'dd.MM.yyyy');
        locale_map.put('de_CH', 'dd.MM.yyyy');
        locale_map.put('de_DE', 'dd.MM.yyyy');
        locale_map.put('de_DE_EURO', 'dd.MM.yyyy');
        locale_map.put('de_LU', 'dd.MM.yyyy');
        locale_map.put('de_LU_EURO', 'dd.MM.yyyy');
        locale_map.put('el_GR', 'd/M/yyyy');
        locale_map.put('en_AU', 'd/MM/yyyy');
        locale_map.put('en_B', 'M/d/yyyy');
        locale_map.put('en_BM', 'M/d/yyyy');
        locale_map.put('en_CA', 'dd/MM/yyyy');
        locale_map.put('en_GB', 'dd/MM/yyyy');
        locale_map.put('en_GH', 'M/d/yyyy');
        locale_map.put('en_IE', 'dd/MM/yyyy');
        locale_map.put('en_IE_EURO', 'dd/MM/yyyy');
        locale_map.put('en_NZ', 'd/MM/yyyy');
        locale_map.put('en_SG', 'M/d/yyyy');
        locale_map.put('en_US', 'M/d/yyyy');
        locale_map.put('en_ZA', 'yyyy/MM/dd');
        locale_map.put('es', 'd/MM/yyyy');
        locale_map.put('es_AR', 'dd/MM/yyyy');
        locale_map.put('es_BO', 'dd-MM-yyyy');
        locale_map.put('es_CL', 'dd-MM-yyyy');
        locale_map.put('es_CO', 'd/MM/yyyy');
        locale_map.put('es_CR', 'dd/MM/yyyy');
        locale_map.put('es_EC', 'dd/MM/yyyy');
        locale_map.put('es_ES', 'd/MM/yyyy');
        locale_map.put('es_ES_EURO', 'd/MM/yyyy');
        locale_map.put('es_GT', 'd/MM/yyyy');
        locale_map.put('es_HN', 'MM-dd-yyyy');
        locale_map.put('es_MX', 'd/MM/yyyy');
        locale_map.put('es_PE', 'dd/MM/yyyy');
        locale_map.put('es_PR', 'MM-dd-yyyy');
        locale_map.put('es_PY', 'dd/MM/yyyy');
        locale_map.put('es_SV', 'MM-dd-yyyy');
        locale_map.put('es_UY', 'dd/MM/yyyy');
        locale_map.put('es_VE', 'dd/MM/yyyy');
        locale_map.put('et_EE', 'd.MM.yyyy');
        locale_map.put('fi', 'd.M.yyyy');
        locale_map.put('fi_FI', 'd.M.yyyy');
        locale_map.put('fi_FI_EURO', 'd.M.yyyy');
        locale_map.put('fr', 'dd/MM/yyyy');
        locale_map.put('fr_BE', 'd/MM/yyyy');
        locale_map.put('fr_CA', 'yyyy-MM-dd');
        locale_map.put('fr_CH', 'dd.MM.yyyy');
        locale_map.put('fr_FR', 'dd/MM/yyyy');
        locale_map.put('fr_FR_EURO', 'dd/MM/yyyy');
        locale_map.put('fr_LU', 'dd/MM/yyyy');
        locale_map.put('fr_MC', 'dd/MM/yyyy');
        locale_map.put('hr_HR', 'yyyy.MM.dd');
        locale_map.put('hu', 'yyyy.MM.dd.');
        locale_map.put('hy_AM', 'M/d/yyyy');
        locale_map.put('is_IS', 'd.M.yyyy');
        locale_map.put('it', 'dd/MM/yyyy');
        locale_map.put('it_CH', 'dd.MM.yyyy');
        locale_map.put('it_IT', 'dd/MM/yyyy');
        locale_map.put('iw', 'dd/MM/yyyy');
        locale_map.put('iw_IL', 'dd/MM/yyyy');
        locale_map.put('ja', 'yyyy/MM/dd');
        locale_map.put('ja_JP', 'yyyy/MM/dd');
        locale_map.put('kk_KZ', 'M/d/yyyy');
        locale_map.put('km_KH', 'M/d/yyyy');
        locale_map.put('ko', 'yyyy. M. d');
        locale_map.put('ko_KR', 'yyyy. M. d');
        locale_map.put('lt_LT', 'yyyy.M.d');
        locale_map.put('lv_LV', 'yyyy.d.M');
        locale_map.put('ms_MY', 'dd/MM/yyyy');
        locale_map.put('nl', 'd-M-yyyy');
        locale_map.put('nl_BE', 'd/MM/yyyy');
        locale_map.put('nl_NL', 'd-M-yyyy');
        locale_map.put('nl_SR', 'd-M-yyyy');
        locale_map.put('no', 'dd.MM.yyyy');
        locale_map.put('no_NO', 'dd.MM.yyyy');
        locale_map.put('pl', 'yyyy-MM-dd');
        locale_map.put('pt', 'dd-MM-yyyy');
        locale_map.put('pt_AO', 'dd-MM-yyyy');
        locale_map.put('pt_BR', 'dd/MM/yyyy');
        locale_map.put('pt_PT', 'dd-MM-yyyy');
        locale_map.put('ro_RO', 'dd.MM.yyyy');
        locale_map.put('ru', 'dd.MM.yyyy');
        locale_map.put('sk_SK', 'd.M.yyyy');
        locale_map.put('sl_SI', 'd.M.y');
        locale_map.put('sv', 'yyyy-MM-dd');
        locale_map.put('sv_SE', 'yyyy-MM-dd');
        locale_map.put('th', 'M/d/yyyy');
        locale_map.put('th_TH', 'd/M/yyyy');
        locale_map.put('tr', 'dd.MM.yyyy');
        locale_map.put('ur_PK', 'M/d/yyyy');
        locale_map.put('vi_VN', 'dd/MM/yyyy');
        locale_map.put('zh', 'yyyy-M-d');
        locale_map.put('zh_CN', 'yyyy-M-d');
        locale_map.put('zh_HK', 'yyyy-M-d');
        locale_map.put('zh_TW', 'yyyy/M/d');
        return locale_map; 
    }

}