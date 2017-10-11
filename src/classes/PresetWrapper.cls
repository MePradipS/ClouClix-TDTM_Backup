public class PresetWrapper {
        
        public sObject sObjectType{get;set;}
        public String fieldLable{get;set;}
        public String fieldName{get;set;}
        public String fieldType{get;set;}
        public String fieldValue{get;set;}
        public List<String> picklistValues{get;set;}
        public Boolean isHidden{get;set;}
        public Boolean isReadOnly{get;set;}
        public Boolean isForSummary{get;set;}
        public Boolean isRequired{get;set;}
        
        public PresetWrapper(Schema.SObjectType objSchema) {
            picklistValues = new List<String>();
            sObjectType = objSchema.newSObject();
        }

        public class MyCustomException extends exception{}
}