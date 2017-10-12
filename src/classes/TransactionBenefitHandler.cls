public class TransactionBenefitHandler {
    public static void RollupTotals (List<Transaction_Benefit__c> records) {
        Set<string> giftIds = new Set<string>();
        for (Transaction_Benefit__c tb : records) {
            giftIds.add(tb.Transaction__c);
        }
        String inFields = Converter.ConvertListSetToString(giftIds);
        String clause = ' WHERE Id IN ('+ inFields +')';
        List<Gift__c> gifts = new GenericQueryBuilder().QueryBuilderWithSubQuery(Gift__c.sObjectType, 'Id,'+ Utilities.PackageNamespace + 'Sponsorship_Amount__c', clause, Transaction_Benefit__c.sObjectType, 'Transaction_Benefits__r', 'Id,'+ Utilities.PackageNamespace + 'Sponsorship_Amount__c', '');
        for (Gift__c g : gifts) {
            Decimal total = 0;
            for (Transaction_Benefit__c tb : g.Transaction_Benefits__r) {
                total = total + tb.Sponsorship_Amount__c;
            }
            g.Sponsorship_Amount__c = total;
        }
        DMLManager.UpdateSObjects(gifts);
    }
}