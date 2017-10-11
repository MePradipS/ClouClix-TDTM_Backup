public class BatchPresetXMLParser {
    
    public String writeXML(String ObjectType, List<PresetWrapper> dataToWrite) {
        
        XmlStreamWriter w = new XmlStreamWriter();
        
        w.writeStartElement(null, ObjectType, null);
        for(PresetWrapper obj_PW : dataToWrite) {
            w.writeStartElement(null, 'fields', null);
            w.writeAttribute(null, null, 'Lable', obj_PW.fieldLable);
            w.writeAttribute(null, null, 'Name', obj_PW.fieldName);
            w.writeAttribute(null, null, 'Type', obj_PW.fieldType);
            
            if(obj_PW.sObjectType.get(obj_PW.fieldName) != null) {
                w.writeAttribute(null, null, 'Value', String.valueOf(obj_PW.sObjectType.get(obj_PW.fieldName)));   
            }
            else {
                w.writeAttribute(null, null, 'Value', 'null');
            }
                
            w.writeAttribute(null, null, 'ReadOnly', String.valueOf(obj_PW.isReadOnly));
            w.writeAttribute(null, null, 'Hidden', String.valueOf(obj_PW.isHidden));
            w.writeAttribute(null, null, 'Summ', String.valueOf(obj_PW.isForSummary));

            w.writeEndElement(); 
        }
        w.writeEndElement();
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();
        
        return xmlOutput;
    }
    
    public List<PresetWrapper> readXML(String xmlString, String sObjectType) {
        List<PresetWrapper> presetDataList = new List<PresetWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(sObjectType);
        
        XmlStreamReader reader = new XmlStreamReader(xmlString);
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
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
                            pw.sObjectType.put(pw.fieldName, convertDateTime(pw.fieldValue));
                        else
                            pw.sObjectType.put(pw.fieldName, pw.fieldValue);
                    }
                    else
                        pw.sObjectType.put(pw.fieldName, pw.fieldValue);
                        
                    pw.isReadOnly = Boolean.valueOf(reader.getAttributeValue(null, 'ReadOnly'));
                    pw.isHidden = Boolean.valueOf(reader.getAttributeValue(null, 'isHidden'));
                    pw.isForSummary = Boolean.valueOf(reader.getAttributeValue(null, 'Summ'));
                    
                    presetDataList.add(pw);
                } 
            }
            reader.next();
        }
        
        return presetDataList;
    }
    
    public Date convertDate(string stringDate) {
        
        String[] strDateDivided = stringDate.split(' ');
        strDateDivided = strDateDivided[0].split('-');
        
        Integer year = Integer.ValueOf(strDateDivided[0]);
        Integer month = Integer.ValueOf(strDateDivided[1]);
        Integer day = Integer.ValueOf(strDateDivided[2]);
        
        return date.newinstance(year, month, day);
    }
    
    public DateTime convertDateTime(string strDT) {
        String[] strDateDivided = strDT.split(' ')[0].split('-');
        String[] strTimeDivided = strDT.split(' ')[1].split(':');
        
        Integer year = Integer.ValueOf(strDateDivided[0]);
        Integer month = Integer.ValueOf(strDateDivided[1]);
        Integer day = Integer.ValueOf(strDateDivided[2]);
        
        Integer hour = Integer.ValueOf(strTimeDivided[0]);
		Integer minute = Integer.ValueOf(strTimeDivided[1]);
		Integer second = Integer.ValueOf(strTimeDivided[2]);
		
        return dateTime.newInstance(year, month, day, hour, minute, second);
    }
}