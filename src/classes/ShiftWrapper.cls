public class ShiftWrapper {
        public ShiftWrapper(Volunteer_Role__c p) { theShift = new Volunteer_Shift__c (); theShift.Volunteer_Role__c= p.Id; }
        //public ShiftWrapper(Volunteer_Positions__c p, Date sd) { theShift = new Volunteer_Position_Shift__c(); theShift.Volunteer_Position__c = p.Id; startDate = sd; }
        public ShiftWrapper(Volunteer_Shift__c s) 
        { 
            theShift = s; 
            //startDate = theShift.Shift_Date__c; 
            if (theShift.Start_Day__c != null)
            {
                startHours = String.valueOf(Math.mod(theShift.Start_Time__c.hour(), 12));
                startMins = String.valueOf(theShift.Start_Time__c.minute());            
                startMeridiemOffset = (theShift.Start_Time__c.hour() > 11 ? 'PM' : 'AM');
            }
            if (theShift.End_Day__c != null)
            {
                endHours = String.valueOf(Math.mod(theShift.End_Time__c.hour(), 12));
                endMins = String.valueOf(theShift.End_Time__c.minute());            
                endMeridiemOffset = (theShift.End_Time__c.hour() > 11 ? 'PM' : 'AM');        
            }
        }        
        public Volunteer_Shift__c theShift { get; set; }
        //public Date startDate { get; set; }
        //public Date startDay { get; set; }
        public String startHours { get; set; } 
        public String startMins { get; set; }
        public String startMeridiemOffset { get; set; }        
        //public Date endDay { get; set; }
        public String endHours { get; set; }
        public String endMins { get; set; }        
        public String endMeridiemOffset { get; set; }     
    }