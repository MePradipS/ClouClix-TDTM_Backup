/*
    Updates all the Email Templates in the Org, that are using the components "DocEmailTemplate" and "DocPDFTemplate".
    The component's attribute names in the Email Templates are searched for strings "recipientType", "relatedToType", "recipientId" and "relatedToId",
    if present, these are prepended with '_'.
*/
public class ModifyRecipientTemplates {

    public void modify(){
        try {
            List<EmailTemplate> etUpdate=new List<EmailTemplate>();
            List<EmailTemplate> et1 = new EmailTemplateSelector().SelectByTemplateType('visualforce');     
    
            for(EmailTemplate et : et1)
            {
                //Get the body(code) of the Email Templates.
                String template = et.Markup;
                //patter to match "DocEmailTemplate" component code(erroneous) in the Email Templates.
                Pattern p = Pattern.compile('(?is).*(<c:\\s*(\\w*)DocEmailTemplate\\s+recipientType\\s*=\\s*([^\\s]*)\\s+relatedToType\\s*=\\s*([^\\s]*)\\s+recipientId\\s*=\\s*([^\\s]*)\\s+relatedToId\\s*=\\s*([^\\s]*)(\\s+dupe\\s*=\\s*[^\\s]*)?\\s*/>).*'); 
                //patter to match "DocPDFTemplate" component code(erroneous) in the Email Templates.
                Pattern p1 = Pattern.compile('(?is).*(<c:\\s*(\\w*)DocPDFTemplate\\s+recipientType\\s*=\\s*([^\\s]*)\\s+relatedToType\\s*=\\s*([^\\s]*)\\s+recipientId\\s*=\\s*([^\\s]*)\\s+relatedToId\\s*=\\s*([^\\s]*)(\\s+dupe\\s*=\\s*[^\\s]*)?\\s*/>).*'); 
                //Compare the "DocEmailTemplate" component pattern with the Email Templates body(code).
                Matcher pm = p.matcher(template);
                String replaced_text;

                if(pm.matches())
                {
                    //Construct a "DocEmailTemplate" component code(non erroneous) string to replace.
                    String replace_with = '<c:'+pm.group(2)+'DocEmailTemplate _recipientType='+pm.group(3)+' _relatedToType='+pm.group(4)+' _recipientId='+pm.group(5)+' _relatedToId='+pm.group(6);
                    if(pm.group(7) == null || pm.group(7) == 'null') {
                        replace_with = replace_with + '/>';
                    }
                    else { 
                        replace_with = replace_with + pm.group(7) + '/>';
                    }
                    
                    //Construct a Email Templates body(code) string with modified "DocEmailTemplate" component code(non erroneous) to replace.
                    replaced_text = template.replace(pm.group(1),replace_With);
                }
                else {
                    replaced_text = template;
                }

                //Compare the "DocPDFTemplate" component pattern with the Email Templates body(code).
                Matcher pm1 = p1.matcher(replaced_text);

                if(pm1.matches())
                {
                    //Construct a "DocPDFTemplate" component code(non erroneous) string to replace.
                    String replace_with1 = '<c:'+pm1.group(2)+'DocPDFTemplate _recipientType='+pm1.group(3)+' _relatedToType='+pm1.group(4)+' _recipientId='+pm1.group(5)+' _relatedToId='+pm1.group(6);
                    if(pm1.group(7) == null || pm1.group(7) == 'null') {
                        replace_with1 = replace_with1 + '/>';
                    }
                    else { 
                        replace_with1 = replace_with1 + pm1.group(7) + '/>';
                    }
                    //Construct a Email Templates body(code) string with modified "DocPDFTemplate" component code(non erroneous) to replace.
                    replaced_text = replaced_text.replace(pm1.group(1),replace_With1);        
                }
                
                //Replace the body(code) of the Email Templates with modified(non erroneous) body(code).
                et.Markup = replaced_text;
                etUpdate.add(et);
            }
    
            if(etUpdate.size()>0) {
                DMLManager.UpdateSObjects(etUpdate);
            }
        } catch(Exception ex) {
        }
    }
}