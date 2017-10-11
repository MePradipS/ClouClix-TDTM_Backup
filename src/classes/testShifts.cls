@isTest
private class testShifts {
    @isTest static void test3() {
        //Program__c p = new Program__c(Name = 'TestProg');
        //insert p;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(Name = 'afas');
        insert vopp;
        Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved');
        insert vpd;
        Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos');
        insert vp;
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Role__c = vp.Id, Start_Day__c = Date.Today(), End_Day__c = Date.Today(), Shift_Date__c = Date.Today(), Start_Time__c = DateTime.Now(), End_Time__c = DateTime.Now().addHours(2));
        insert shift;
        
        ShiftWrapper sw = new ShiftWrapper(shift);
        //HourWrapper hw = new HourWrapper(DateTime.Now(), DateTime.Now().addHours(2));
       //VolunteerUtil.serializeShiftWrapper(sw);
       // VolunteerUtil.serializeHourWrapper(hw);    
        PageReference pageRef = Page.ShiftEntry;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', shift.Id);        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(shift);
        CShiftEntry controller = new CShiftEntry (stdcontroller);    
        controller.getPickLstValue();
        controller.getHours();
        controller.getMins();
        controller.getMeridiemOffset();
        controller.clear();     
        controller.selected.theShift.Frequency__c = 'Weekly';
        controller.selected.theShift.Shift_Date__c = Date.Today();
        controller.selected.theShift.Start_Day__c = Date.Today();
        controller.selected.theShift.End_Day__c = Date.Today();                
        controller.selected.startHours = '2';
        controller.selected.startMins = '15';
        controller.selected.startMeridiemOffset = 'PM';        
        controller.selected.endHours = '3';
        controller.selected.endMins = '15';
        controller.selected.endMeridiemOffset = 'PM';     
        controller.NumOfWeeks = 3;                
        controller.addShift();
        ApexPages.currentPage().getParameters().put('Index', '1');   
        controller.removeShift();
        controller.editShift();
        controller.updateShift();
        controller.cancelUpdate();
        controller.back();     
    }  
    
    
    @isTest static void test4() {
        //Program__c p = new Program__c(Name = 'TestProg');
        //insert p;
        Contact c = new Contact(lastName ='test');
        insert c;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(Name = 'afas');
        insert vopp;
        Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved');
        insert vpd;
        Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos');
        insert vp;
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Role__c = vp.Id, Start_Day__c = Date.Today(), End_Day__c = Date.Today(), Shift_Date__c = Date.Today(), Start_Time__c = DateTime.Now(), End_Time__c = DateTime.Now().addHours(2));
        insert shift;
    
         ApexPages.currentPage().getParameters().put('id',c.id);
    
    
        CSearch controller = new CSearch (); 
        controller.getTypes();
        controller.refreshList();
    
    }
    @isTest static void test5() {
        PageReference pageRef = Page.searchPos;
        Test.setCurrentPage(pageRef);
        Contact c = new Contact(lastName ='test');
        insert c;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(Name = 'afas');
        insert vopp;
        Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved');
        insert vpd;
        Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos');
        insert vp;
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Role__c = vp.Id, Start_Day__c = Date.Today(), End_Day__c = Date.Today(), Shift_Date__c = Date.Today(), Start_Time__c = DateTime.Now(), End_Time__c = DateTime.Now().addHours(2));
        insert shift;
    
        ApexPages.currentPage().getParameters().put('id',vp.id);
    
    
        CSearchPos controller = new CSearchPos(); 
        controller.addConfirm();
        controller.addToCampaign();
        controller.getTypes();
        controller.refreshList();
    
    }
    
    
    @isTest static void test7() {
        //Program__c p = new Program__c(Name = 'TestProg');
        //insert p;
        Contact c = new Contact(lastName ='test');
        insert c;
        Volunteer_Opportunity__c vopp = new Volunteer_Opportunity__c(Name = 'afas');
        insert vopp;
        Role_Template__c vpd = new Role_Template__c(Status__c = 'Approved');
        insert vpd;
        Volunteer_Role__c vp = new Volunteer_Role__c(Volunteer_Opportunity__c = vopp.Id, Role_Description_Templates__c = vpd.Id, Name = 'pos');
        insert vp;
        Volunteer_Shift__c shift = new Volunteer_Shift__c(Volunteer_Role__c = vp.Id, Start_Day__c = Date.Today(), End_Day__c = Date.Today(), Shift_Date__c = Date.Today(), Start_Time__c = DateTime.Now(), End_Time__c = DateTime.Now().addHours(2));
        insert shift;
        Volunteer_Application__c va= new Volunteer_Application__c(Volunteer_Role__c = vp.Id, Volunteer__c = c.id);
        insert va;
    
        ApexPages.currentPage().getParameters().put('id',va.id);
    
        PageReference pageRef = Page.ManagePlacements;
        Test.setCurrentPage(pageRef);
        CPlaceApplicant controller = new CPlaceApplicant(); 
        //controller.volunteerId = c.Id;
        controller.place();
        
    
    }
    
    
          
}