global class Validator_cls {
    private static set<Id> ids;
    private static boolean blnAlreadyDone = false;
    private static boolean blnAlreadyDone1 = false;
    private static boolean alreadyModified = false;
    private static boolean alreadyModifiedforPayment = false;
    private static boolean alreadyModifiedforTriggerRecurringPayment = false;
    private static boolean alreadyModifiedforReceiptUpdateOnTransaction = false;
    private static boolean alreadyFiredRollupTotalGiving = false;

    Private static boolean fromaccounttrigger = false;

    public static boolean alreadyModifiedforTriggerRecurringPayment1 = false;

    public static set<Id> paymentidsset = new set<id> ();

    public static boolean hasAlreadyDone() {
        return blnAlreadyDone;
    }

    public static boolean hasAlreadyDone1() {
        return blnAlreadyDone1;
    }
    public static void setAlreadyDone() {
        blnAlreadyDone = true;
    }
    public static void setAlreadyDone1() {
        blnAlreadyDone1 = true;
    }

    public static boolean isAlreadyModified() {
        return alreadyModified;
    }

    public static void setAlreadyModified() {
        alreadyModified = true;
    }

    public static boolean isAlreadyModifiedforPayment() {
        return alreadyModifiedforPayment;
    }

    public static void setAlreadyModifiedforPayment() {
        alreadyModifiedforPayment = true;
    }

    public static boolean isAlreadyModifiedforTriggerRecurringPayment() {
        return alreadyModifiedforTriggerRecurringPayment;
    }

    public static void setAlreadyModifiedforTriggerRecurringPayment() {
        alreadyModifiedforTriggerRecurringPayment = true;
    }

    public static boolean isAlreadyModifiedforReceiptUpdateOnTransaction() {
        return alreadyModifiedforReceiptUpdateOnTransaction;
    }

    public static void setAlreadyModifiedforReceiptUpdateOnTransaction() {
        alreadyModifiedforReceiptUpdateOnTransaction = true;
    }

    public static boolean isalreadyFiredRollupTotalGiving() {
        return alreadyFiredRollupTotalGiving;
    }

    public static void setalreadyFiredRollupTotalGiving() {
        alreadyFiredRollupTotalGiving = true;
    }

    //GIFT AID DECLARATION RECURSIVE CHECKING//
    Private Static Boolean giftAidDeclarationBeforeRunUpdate = false;
    Private Static Boolean giftAidDeclarationBeforeRunInsert = false;
    Private Static Boolean giftAidDeclarationAfterRunUpdate = false;
    Private Static Boolean giftAidDeclarationAfterRunInsert = false;

    Public Static Void GiftAidDeclarationBeforeRunUpdate() {
        giftAidDeclarationBeforeRunUpdate = true;
    }

    Public Static Boolean HasGiftAidDeclarationBeforeRunUpdate() {
        return Trigger.isUpdate;// && giftAidDeclarationBeforeRunUpdate;
    }

    Public Static Void GiftAidDeclarationBeforeRunInsert() {
        giftAidDeclarationBeforeRunInsert = true;
    }

    Public Static Boolean HasGiftAidDeclarationBeforeRunInsert() {
        return Trigger.isInsert;// && giftAidDeclarationBeforeRunInsert;
    }

    Public Static Void GiftAidDeclarationAfterRunUpdate() {
        giftAidDeclarationAfterRunUpdate = true;
    }

    Public Static Boolean HasGiftAidDeclarationAfterRunUpdate() {
        return Trigger.isUpdate;// && giftAidDeclarationAfterRunUpdate;
    }

    Public Static Void GiftAidDeclarationAfterRunInsert() {
        giftAidDeclarationAfterRunInsert = true;
    }

    Public Static Boolean HasGiftAidDeclarationAfterRunInsert() {
        return Trigger.isInsert;// && giftAidDeclarationAfterRunInsert;
    }
    ////////////////////////////////////////////
    
    //GIFT AID PAYMENT RECURSIVE CHECKING//
    Private Static Boolean giftAidPaymentBeforeRunUpdate = false;
    Private Static Boolean giftAidPaymentBeforeRunInsert = false;
    Private Static Boolean giftAidPaymentAfterRunUpdate = false;
    Private Static Boolean giftAidPaymentAfterRunInsert = false;

    Public Static Void GiftAidPaymentBeforeRunUpdate() {
        giftAidPaymentBeforeRunUpdate = true;
    }

    Public Static Boolean HasGiftAidPaymentBeforeRunUpdate() {
        return Trigger.isUpdate;// && !giftAidPaymentBeforeRunUpdate;
    }

    Public Static Void GiftAidPaymentBeforeRunInsert() {
        giftAidPaymentBeforeRunInsert = true;
    }

    Public Static Boolean HasGiftAidPaymentBeforeRunInsert() {
        return Trigger.isInsert;// && !giftAidPaymentBeforeRunInsert;
    }

    Public Static Void GiftAidPaymentAfterRunUpdate() {
        giftAidPaymentAfterRunUpdate = true;
    }

    Public Static Boolean HasGiftAidPaymentAfterRunUpdate() {
        return Trigger.isUpdate;// && !giftAidPaymentAfterRunUpdate;
    }

    Public Static Void GiftAidPaymentAfterRunInsert() {
        giftAidPaymentAfterRunInsert = true;
    }

    Public Static Boolean HasGiftAidPaymentAfterRunInsert() {
        return Trigger.isInsert;// && !giftAidPaymentAfterRunInsert;
    }
    ///////////////////////////////////////
    
    //GIFT AID ALLOCATION RECURSIVE CHECKING//
    Private Static Boolean giftAidAllocationBeforeRunUpdate = false;
    Private Static Boolean giftAidAllocationBeforeRunInsert = false;
    Private Static Boolean giftAidAllocationAfterRunUpdate = false;
    Private Static Boolean giftAidAllocationAfterRunInsert = false;

    Public Static Void GiftAidAllocationBeforeRunUpdate() {
        giftAidAllocationBeforeRunUpdate = true;
    }

    Public Static Boolean HasGiftAidAllocationBeforeRunUpdate() {
        return Trigger.isUpdate;// && !giftAidAllocationBeforeRunUpdate;
    }

    Public Static Void GiftAidAllocationBeforeRunInsert() {
        giftAidAllocationBeforeRunInsert = true;
    }

    Public Static Boolean HasGiftAidAllocationBeforeRunInsert() {
        return Trigger.isInsert;// && !giftAidAllocationBeforeRunInsert;
    }

    Public Static Void GiftAidAllocationAfterRunUpdate() {
        giftAidAllocationAfterRunUpdate = true;
    }

    Public Static Boolean HasGiftAidAllocationAfterRunUpdate() {
        return Trigger.isUpdate;// && !giftAidAllocationAfterRunUpdate;
    }

    Public Static Void GiftAidAllocationAfterRunInsert() {
        giftAidAllocationAfterRunInsert = true;
    }

    Public Static Boolean HasGiftAidAllocationAfterRunInsert() {
        return Trigger.isInsert;// && !giftAidAllocationAfterRunInsert;
    }
    ////////////////////////////////////////////
}