public with sharing class CurrencyOutputFieldController {
 public Decimal value {get; set;}
    public String currencyIsoCode {get; set;}
    public Opportunity opp {
        get {
            Opportunity hack = new Opportunity();
            hack.Amount = value;
            return hack;
        }
    }
	
	static testMethod void testMe() {
		currencyOutputFieldController cnt = new currencyOutputFieldController();
		cnt.currencyIsoCode = 'USD';
		cnt.value = 100;
		Opportunity opp = cnt.opp;
		
	}
}