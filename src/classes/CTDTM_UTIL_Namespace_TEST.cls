/**
* @group Utilities
* @description test Class which holds test methods for common utilities, 
* such as detecting whether we are in a managed package, and some string helpers.
*/
@isTest
public with sharing class CTDTM_UTIL_Namespace_TEST {

    static testmethod void TestNamespacePrefixFixups() {
        if (CTDTM_UTIL_Namespace.getNamespace()!='') {
            system.assertNotEquals('',CTDTM_UTIL_Namespace.getNamespace());
            system.assertEquals(CTDTM_UTIL_Namespace.getNamespace()+'__foo', CTDTM_UTIL_Namespace.StrTokenNSPrefix('foo'));
            system.assertEquals(CTDTM_UTIL_Namespace.getNamespace()+'__foo__c', CTDTM_UTIL_Namespace.StrTokenNSPrefix('foo__c'));     
            system.assertEquals('foo', CTDTM_UTIL_Namespace.StrAllNSPrefix('foo'));
            system.assertEquals(CTDTM_UTIL_Namespace.getNamespace()+'__foo__c', CTDTM_UTIL_Namespace.StrAllNSPrefix('foo__c'));
            system.assertEquals(CTDTM_UTIL_Namespace.getNamespace()+'__foo_bar_baz__c', CTDTM_UTIL_Namespace.StrAllNSPrefix('foo_bar_baz__c'));
            system.assertEquals('select '+CTDTM_UTIL_Namespace.getNamespace()+'__foo__c, bar, '+CTDTM_UTIL_Namespace.getNamespace()+'__baz1__c, '+CTDTM_UTIL_Namespace.getNamespace()+'__biz_buz__c from Contact', CTDTM_UTIL_Namespace.StrAllNSPrefix('select foo__c, bar, baz1__c, biz_buz__c from Contact'));
        } else {
            system.assertEquals('foo', CTDTM_UTIL_Namespace.StrTokenNSPrefix('foo'));
            system.assertEquals('foo__c', CTDTM_UTIL_Namespace.StrTokenNSPrefix('foo__c'));     
            system.assertEquals('foo', CTDTM_UTIL_Namespace.StrAllNSPrefix('foo'));
            system.assertEquals('foo__c', CTDTM_UTIL_Namespace.StrAllNSPrefix('foo__c'));
            system.assertEquals('foo_bar_baz__c', CTDTM_UTIL_Namespace.StrAllNSPrefix('foo_bar_baz__c'));
            system.assertEquals('select foo__c, bar, baz1__c, biz_buz__c from Contact', CTDTM_UTIL_Namespace.StrAllNSPrefix('select foo__c, bar, baz1__c, biz_buz__c from Contact'));           
        }
        system.assertEquals('foo__c', CTDTM_UTIL_Namespace.StrTokenRemoveNSPrefix('npsp__foo__c'));
        system.assertEquals('foo_npsp__c', CTDTM_UTIL_Namespace.StrTokenRemoveNSPrefix('foo_npsp__c'));
    }               

    static testmethod void testSandboxEmailToRealEmail() {
        String fixedEmail = CTDTM_UTIL_Namespace.sandboxEmailToRealEmail('awheeler=universalcontainers.com@example.com'); 
        System.assertEquals('awheeler@universalcontainers.com', fixedEmail);
    }
    
    //we have some packaged labels that we no longer reference.
    //unfortunately, this causes our local DE Orgs to not include them in our local package.
    //but these labels were already released in the managed package and cannot be deleted.
    //so we now refer to them here, just so our DE Orgs will keep the in our local package.
    /*static testmethod void keepUnusedPackagedLabelsInPackage() {
        string str;
        str = Label.Addr_Settings_API_Body;
        str = Label.Addr_Settings_Intro_Body;
        str = Label.Addr_Settings_Intro_Title;
        str = Label.Addr_Settings_Notice;
        str = Label.Addr_Settings_Test_Body;
        str = Label.Addr_Settings_Test_Response_Title;
        str = Label.Addr_Settings_Test_Title;
        str = Label.Addr_Verification_Batch_Status;
        str = Label.stgHHNameRefreshTitle;
        str = Label.stgLabelAfflSettings;
        str = Label.stgLabelBDESettings;
        str = Label.stgLabelBatchStatus;
        str = Label.stgLabelCurrentUDR;
        str = Label.stgLabelErrorNotify;
        str = Label.stgLabelMembershipSettings;
        str = Label.stgLabelPaymentSettings;
        str = Label.stgLabelRDFieldMap;
        str = Label.stgLabelRDPeriod;
        str = Label.stgLabelRDSettings;
        str = Label.stgLabelRelSettings;
        str = Label.stgLabelTriggerHandlers;
        str = Label.stgNavContacts;
        str = Label.stgLabelHHNamingProgress;
        str = Label.statusNotStarted;
        str = Label.statusInProgress;
        str = Label.statusCompleted;
        str = Label.Address_StateCountry_Invalid_Error;
        str = Label.Addr_Verify_Google_Help;
        str = Label.SmartyStreets_Help_Text;
        str = Label.stgHelpCiceroAddrVerification;
        str = Label.stgHelpRDDisableScheduling;
        str = Label.stgHelpRDFieldMapOppField;
        str = Label.stgHelpRDFieldMapRDField;
        str = Label.CONV_Reload;
        str = Label.stgLabelOppUpdatePrimaryContact;
        str = Label.stgHelpNoUDR;
        str = Label.alloRemainder;
        str = Label.alloTotals;
        str = Label.alloCampaignExceedsOppAmount;
        str = Label.alloUnallocated;
        str = Label.alloBtnCancel;
        str = Label.alloBtnSaveAndClose;
        str = Label.stgHelpBatchCreateDefault;
        str = Label.addrHHAddressAlwaysDefault;
        str = Label.Addr_Verification_Cant_Load_Class;
        str = Label.pmtWizardWarning;
        str = Label.hhCmpDedupLabelReturnToCmp;
        str = Label.sendAcknowledgmentReturnLinkLabel;

        // The following labels are referenced because the spider was having
        // issues resolving references to them and they need to be directly
        // referenced here to avoid build issues in the packaging org
        str = Label.PageMessagesConfirm;
        str = Label.PageMessagesError;
        str = Label.PageMessagesFatal;
        str = Label.PageMessagesWarning;
        str = Label.mtchBtnSearch;
        str = Label.mtchCloseDateEnd;
        str = Label.mtchCloseDateStart;
        str = Label.mtchFindMatchedGiftsSectionHeader;
        str = Label.mtchFindMoreGifts;
        str = Label.mtchFindMoreGiftsInfo;
        str = Label.mtchItems;
        str = Label.mtchSearchCriteriaEmpty;
        str = Label.mtchSelectCbxTitle;
        str = Label.mtchTotalMatchingGift;
        str = Label.mtchTotalSelected;
        str = Label.mtchTotalUnaccounted;
        str = Label.pscManageSoftCreditsAdd;
        str = Label.pscManageSoftCreditsAmount;
        str = Label.pscManageSoftCreditsAmountMissing;
        str = Label.pscManageSoftCreditsAmountOrPercent;
        str = Label.pscManageSoftCreditsCantChangeCurrency;
        str = Label.pscManageSoftCreditsFull;
        str = Label.pscManageSoftCreditsInvalidContact;
        str = Label.pscManageSoftCreditsNoRoles;
        str = Label.pscManageSoftCreditsOppAmount;
        str = Label.pscManageSoftCreditsPSCAmount;
        str = Label.pscManageSoftCreditsPartial;
        str = Label.pscManageSoftCreditsPercent;
        str = Label.pscManageSoftCreditsPrimaryDonor;
        str = Label.pscManageSoftCreditsReconcileFail;
        str = Label.pscManageSoftCreditsRestrictions;
        str = Label.pscManageSoftCreditsRoleMissing;
        str = Label.pscManageSoftCreditsTitle;
        str = Label.pscManageSoftCreditsType;
        str = Label.pscManageSoftCreditsUnaccounted;
        str = Label.pscManageSoftCreditsValidateTotals;
        str = Label.stgHelpMatchedDonorRole;
        str = Label.stgNavBulkProcesses;
        str = Label.EPAddTask;
        str = Label.healthDetailsInvalidScheduledJob;
        str = Label.healthSolutionInvalidScheduledJob;
        str = Label.healthDetailsScheduleJobs;
        str = Label.healthSolutionScheduleJobs;
    }*/
}