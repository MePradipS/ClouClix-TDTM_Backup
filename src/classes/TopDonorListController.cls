public class TopDonorListController {
    List<Contact> transactions;

    public List<Contact> getTransactions() {
        if(transactions == null)
            transactions = new ContactSelector().SelectTopTenDonors();

        return transactions;
    }
}