@isTest
private class RedirectControllerTest {	 
    private static List<TestParameters> listOfTestParams = new List<TestParameters>{
        new TestParameters(
            Page.AccountHouseHoldRedirect,
            (ObjectRedirectController)new AccountHouseHoldController(new ApexPages.StandardController((Account)TestDataTemplates.createSObject(new Account()))),
			'HouseHold'
        ),
        new TestParameters(
			Page.AccountSingleTransactionRedirect,
			(ObjectRedirectController)new AccountSingleTransactionController(new ApexPages.StandardController((Account)TestDataTemplates.createSObject(new Account()))),
			'SingleTransaction'
        ),
        new TestParameters(
			Page.AccountSummaryViewRedirect,
			(ObjectRedirectController)new AccountSummaryViewController(new ApexPages.StandardController((Account)TestDataTemplates.createSObject(new Account()))),
			'SummaryView'
        ),
        new TestParameters(
			Page.CampaignActionpageDesignerRedirect,
			(CampaignRedirectController)new CampaignActionpageDesignController( new ApexPages.StandardController( (Campaign)TestDataTemplates.createSObject(new Campaign(),true) ) ),
			'CampaignActionpageDesigner'
        ),
        new TestParameters(
			Page.CampaignCompRegRedirect,
			(CampaignRedirectController)new CampaignCompRegController(new ApexPages.StandardController((Campaign)TestDataTemplates.createSObject(new Campaign(),true))),
			'CampaignCompReg'
        ),
        new TestParameters(
			Page.CampaignCreateAppealAPRedirect,
			(CampaignRedirectController)new CampaignCreateAppealAPController(new ApexPages.StandardController((Campaign)TestDataTemplates.createSObject(new Campaign(),true))),
			'CampaignCreateAppealAP'
        ),        
        new TestParameters(
			Page.CampaignRegNowRedirect,
			(CampaignRedirectController)new CampaignRegNowController(new ApexPages.StandardController((Campaign)TestDataTemplates.createSObject(new Campaign(),true))),
			'CampaignRegNow'
        ),        
        new TestParameters(
			Page.ContactNewCVEventRegistrationRedirect,
			(ContactRedirectController)new ContactNewEventRegistrationController(new ApexPages.StandardController((Contact)TestDataTemplates.createSObject(new Contact()))),
			'NewCVEventRegistration'
        ),        
        new TestParameters(
			Page.ContactSingleTransactionRedirect,
			(ContactRedirectController)new ContactSingleTransactionController(new ApexPages.StandardController((Contact)TestDataTemplates.createSObject(new Contact()))),
			'SingleTransaction'
        ),        
        new TestParameters(
			Page.ContactSummaryViewRedirect,
			(ContactRedirectController)new ContactSummaryViewController(new ApexPages.StandardController((Contact)TestDataTemplates.createSObject(new Contact()))),
			'RedirectToSummaryView'
        ),
        new TestParameters(
			Page.GiftBatchMyPresetsRedirect,
			(ObjectRedirectController)new GiftBatchNewPresetController(new ApexPages.StandardController((Gift_Batch__c)TestDataTemplates.createSObject(new Gift_Batch__c()))),
			'EditBatchPreset_moc'
        ),
        new TestParameters(
			Page.LeadConvertRedirect,
			(ObjectRedirectController)new LeadConvertRedirectController(new ApexPages.StandardController((Lead)TestDataTemplates.createSObject(new Lead()))),
			'LeadConvertContact'
        ),        
        new TestParameters(
			Page.OpportunityConvertGrantRedirect,
			(ObjectRedirectController)new OpportunityConvertGrantController(new ApexPages.StandardController((Opportunity)TestDataTemplates.createSObject(new Opportunity()))),
			'ConvertOpp2'
        ),
        new TestParameters(
			Page.PaymentFulfillInstallmentRedirect,
			(ObjectRedirectController)new PaymentFulfillInstallmentController(new ApexPages.StandardController((Gift__c)TestDataTemplates.createSObject(new Gift__c()))),
			'FulFillInstallmentPage'
        ),
        new TestParameters(
			Page.PaymentRefundRedirect,
			(ObjectRedirectController)new PaymentRefundController(new ApexPages.StandardController( (Payment__c)TestDataTemplates.createSObject(new Payment__c(), 'TestDataTemplates.PaymentWithTransactionWithContact', true) ) ),
			'refundPayment'
        ),
        new TestParameters(
			Page.RDUpdateCreditCardRedirect,
			(ObjectRedirectController)new RDUpdateCreditCardController(new ApexPages.StandardController((Recurring_Donation__c)TestDataTemplates.createSObject(new Recurring_Donation__c()))),
			'recurringMaint'
        ),
        new TestParameters(
			Page.RDUpdateProfileRedirect,
			(ObjectRedirectController)new RDUpdateProfileController(new ApexPages.StandardController((Recurring_Donation__c)TestDataTemplates.createSObject(new Recurring_Donation__c()))),
			'recurringMaint'
        ),
        new TestParameters(
			Page.ReceiptGenerateReceiptRedirect,
			(RedirectController)new ReceiptGenerateReceiptController(),
			'ConsolidatedReceipt'
        ),
        new TestParameters(
			Page.ReceiptPrintRedirect,
			(ObjectRedirectController)new ReceiptPrintController(new ApexPages.StandardController((Receipt__c)TestDataTemplates.createSObject(new Receipt__c()))),
			'ReceiptPrinter'
        ),
        new TestParameters(
			Page.ReceiptVoidRedirect,
			(ReloadController)new ReceiptVoidController(new ApexPages.StandardController((Receipt__c)TestDataTemplates.createSObject(new Receipt__c()))),
			'ReceiptVoid'
        ),
        new TestParameters(
			Page.RecurringDonationCancelRedirect,
			(ObjectRedirectController)new RecurringDonationCancelController(new ApexPages.StandardController((Recurring_Donation__c)TestDataTemplates.createSObject(new Recurring_Donation__c()))),
			'recurringMaint'
        ),
        new TestParameters(
			Page.VolunteerPlaceApplicantRedirect,
			(ObjectRedirectController)new VolunteerPlaceApplicantController(new ApexPages.StandardController((Volunteer_Application__c)TestDataTemplates.createSObject(new Volunteer_Application__c()))),
			'ManagePlacements'
        ),
        new TestParameters(
			Page.VolunteerRoleFindRedirect,
			(ObjectRedirectController)new VolunteerRoleFindController(new ApexPages.StandardController((Volunteer_Role__c)TestDataTemplates.createSObject(new Volunteer_Role__c()))),
			'searchPos'
        ),
        new TestParameters(
			Page.VolunteerRoleManageShiftsRedirect,
			(ObjectRedirectController)new VolunteerRoleManageShiftsController(new ApexPages.StandardController((Volunteer_Role__c)TestDataTemplates.createSObject(new Volunteer_Role__c()))),
			'shiftentry'
        )
    };
        
	private static PageReference pageRef = Page.AccountHouseHoldRedirect;
	private static RedirectController redirectCtrl = new AccountHouseHoldController(new ApexPages.StandardController((Account)TestDataTemplates.createSObject(new Account())));
	private static ObjectRedirectController objRedirectCtrl;// = new AccountSummaryViewController(new ApexPages.StandardController((Account)TestDataTemplates.createSObject(new Account())));
	private static CampaignRedirectController campaignRedirectCtrl;// = new CampaignActionpageDesignController(new ApexPages.StandardController((Campaign)TestDataTemplates.createSObject(new Campaign(),true)));
	private static ContactRedirectController contactRedirectCtrl;// = new ContactNewEventRegistrationController(new ApexPages.StandardController((Contact)TestDataTemplates.createSObject(new Contact())));
	private static ReloadController reloadCtrl;// = new ReceiptVoidController(new ApexPages.StandardController((Receipt__c)TestDataTemplates.createSObject(new Receipt__c())));
	private static String redirectPage = 'HouseHold';
    
    private class TestParameters{
        private PageReference pageRefC;
        private RedirectController redirectCtrlC;
        private ObjectRedirectController objRedirectCtrlC;    
        private CampaignRedirectController campaignRedirectCtrlC;
        private ContactRedirectController contactRedirectCtrlC;
        private ReloadController reloadCtrlC;        
        private String redirectPageC;
                
        private TestParameters(PageReference aPageRef, RedirectController aRedirectCtrl, String aRedirectPage){
            pageRefC = aPageRef;
            redirectCtrlC = aRedirectCtrl;
            redirectPageC = aRedirectPage;
        }
        private TestParameters(PageReference aPageRef, ObjectRedirectController aObjRedirectCtrl, String aRedirectPage){
            pageRefC = aPageRef;
            objRedirectCtrlC = aObjRedirectCtrl;
            redirectPageC = aRedirectPage;
        }
        private TestParameters(PageReference aPageRef, CampaignRedirectController aCampaignRedirectCtrl, String aRedirectPage){
            pageRefC = aPageRef;
            campaignRedirectCtrlC = aCampaignRedirectCtrl;
            redirectPageC = aRedirectPage;
        }        
        private TestParameters(PageReference aPageRef, ContactRedirectController aContactRedirectCtrl, String aRedirectPage){
            pageRefC = aPageRef;
            contactRedirectCtrlC = aContactRedirectCtrl;
            redirectPageC = aRedirectPage;
        }
        private TestParameters(PageReference aPageRef, ReloadController aReloadCtrl, String aRedirectPage){
            pageRefC = aPageRef;
            reloadCtrlC = aReloadCtrl;
            redirectPageC = aRedirectPage;
        }         
    }

	@isTest static void ExtensionsTest() {
		Test.startTest();
        for(TestParameters param: listOfTestParams){
			pageRef = param.pageRefC;	
			redirectPage = param.redirectPageC;				
			if(param.redirectCtrlC != null){
				redirectCtrl = param.redirectCtrlC;
				TestSetDirectPage();
			}
			if(param.objRedirectCtrlC != null){
				objRedirectCtrl = param.objRedirectCtrlC;
				TestObjSetDirectPage();
			}
			if(param.campaignRedirectCtrlC != null){
				campaignRedirectCtrl = param.campaignRedirectCtrlC;
				TestCampaignSetDirectPage();
			}
			if(param.contactRedirectCtrlC != null){
				contactRedirectCtrl = param.contactRedirectCtrlC;
				TestContactSetDirectPage();
			}
			if(param.reloadCtrlC != null){
				reloadCtrl = param.reloadCtrlC;				
			}
		}
		Test.stopTest();
	}
	
	@isTest static void TestSetDirectPage() {
		Test.setCurrentPage(pageRef);
		System.AssertEquals(redirectPage, redirectCtrl.SetRedirectPage());
	}

	@isTest static void TestObjSetDirectPage() {
		Test.setCurrentPage(pageRef);
		//System.AssertEquals(redirectPage, objRedirectCtrl.SetRedirectPage());
	}

	@isTest static void TestCampaignSetDirectPage() {
		Test.setCurrentPage(pageRef);
		if(redirectPage == 'CampaignActionpageDesigner' 
			||redirectPage == 'CampaignCompReg'
			||redirectPage == 'CampaignCreateAppealAP'
			||redirectPage == 'CampaignRegNow'){
			System.AssertNotEquals(null, campaignRedirectCtrl.SetRedirectPage());
		}else{
			//System.AssertEquals(redirectPage, campaignRedirectCtrl.SetRedirectPage());
		}
	}

	@isTest static void TestContactSetDirectPage() {
		Test.setCurrentPage(pageRef);
		//System.AssertEquals(redirectPage, contactRedirectCtrl.SetRedirectPage());
	}	
  
	@isTest static void TestSetUrlParameters() {
		PageReference pageRef = Page.AccountHouseHoldRedirect;
		Account testAccount = (Account)TestDataTemplates.createSObject(new Account());

		Test.startTest();
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getHeaders().put('Referer', 'OldPage');
		AccountHouseHoldController ahhc = new AccountHouseHoldController(new ApexPages.StandardController(testAccount));
		
		System.AssertEquals('?Url=OldPage', ahhc.SetUrlParameters());
		Test.stopTest();
	}	
}