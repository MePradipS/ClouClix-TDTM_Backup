public class Actionpage
{
    public void setStringField(string field_id, string field_value) {
        for (Field f : field) {
            if (f.id == field_id) {
                f.value = field_value;
            }
        }
    }
    
    public Decimal conversion_time { get; set; }
    public string action_page_id { get; set; }
    public string gateway_type { get; set; }
    public List<Field> field { get; set; }
}