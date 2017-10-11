public without sharing class VolunteerUtil {
public static void RecalculateOpportunityStatus(Set<String> oppIds) {
           String inFields = Converter.ConvertListSetToString(oppIds);
           String clause = ' WHERE Id IN ('+ inFields +') AND (Status__c = \'Open\' OR Status__c = \'Filled\')';

           List<Volunteer_Opportunity__c> theOpps = new GenericQueryBuilder().QueryBuilderWithSubQuery(Volunteer_Opportunity__c.sObjectType, 'Id,'+ Utilities.PackageNamespace + 'Status__c', clause, Volunteer_Role__c.sObjectType, 'Volunteer_Positions__r', 'Id,'+ Utilities.PackageNamespace + 'Role_Status__c', '');
           Boolean isOpen;

           for (Volunteer_Opportunity__c opp : theOpps)
           {
               isOpen = True;
               for (Volunteer_Role__c vp : opp.Volunteer_Positions__r)
               {
                   if (vp.Role_Status__c == 'Filled')
                   { isOpen = False; }
                   if (vp.Role_Status__c == 'Open')
                   { isOpen = True; break; }
               }
               if (isOpen) { opp.Status__c = 'Open'; }
               else { opp.Status__c = 'Filled'; }
           }

           if (theOpps != null && theOpps.size() > 0) {
            DMLManager.UpdateSObjects(theOpps);
           }
       }

       public static Contact upsertContactOnEmail(Contact c) {
           Contact retVal = new Contact();
           if (c.Id != null) { return c; }
           if (c.Email != '' && c.Email != null)
           {
               List<Contact> results = new ContactSelector().SelectIdByEmail(c.Email);
               if (results.size() == 1)
               {
                   return results[0];
               }
           }
           DMLManager.InsertSObject(c);
           return c;
       }

       public static void RollupHours(Set<String> hIds) {
           Set<String> volIds = new Set<String>();
           Set<String> orgIds = new Set<String>();


           for(Volunteer_Hours__c vh : new VolunteerHoursSelector().SelectVolunteerById(hIds))
           {
              volIds.add(vh.Volunteer__c);
              orgIds.add(vh.Volunteer__r.AccountId);
           }

           String inFields = Converter.ConvertListSetToString(volIds);
           String clause = ' WHERE Id IN ('+ inFields +')';
           String subClause = ' WHERE End_Day__c = THIS_FISCAL_YEAR AND Status__c = \'Confirmed\'';
           String fields = 'AccountId,Id,'+ Utilities.PackageNamespace + 'Total_Service_Hours_Completed_This_Year__c,'+ Utilities.PackageNamespace + 'Total_Miles_Traveled_This_Year__c';
           String subFields = 'Id,'+ Utilities.PackageNamespace + 'Service_Hours_Completed__c,'+ Utilities.PackageNamespace + 'Mileage__c';

           List<Contact> vols = new GenericQueryBuilder().QueryBuilderWithSubQuery(Contact.sObjectType, fields, clause, Volunteer_Hours__c.sObjectType, 'Volunteer_Hours__r', subFields, subClause);

           for (Contact vol : vols)
           {
               Decimal Total_Serv = 0;
               Decimal Total_Mile = 0;
               for (Volunteer_Hours__c vh : vol.Volunteer_Hours__r)
               {
                   if (vh.Service_Hours_Completed__c != null) { Total_Serv += vh.Service_Hours_Completed__c; }
                   if (vh.Mileage__c != null) { Total_Mile += vh.Mileage__c; }
               }
               vol.Total_Service_Hours_Completed_This_Year__c = Total_Serv;
               vol.Total_Miles_Traveled_This_Year__c = Total_Mile;
           }

           if (vols != null && vols.size() > 0) {
            DMLManager.UpdateSObjects(vols);
           }

           List<Account> orgs = new List<Account>();
           for (Account a: new AccountSelector().SelectVolunteerTotalsById(orgIds, BatchSettings__c.getInstance('Default').BucketAccountId__c)){
           		orgs.add(a);
           }
           List<Contact> contacts = new List<Contact>();
           for (Contact c: new ContactSelector().SelectVolunteerTotalsById(Utilities.ConvertStringSetToIdSet(orgIds))) {
           		contacts.add(c);
           }

           for (Account a : orgs)
           {
               Decimal Total_Serv = 0;
               Decimal Total_Mile = 0;
               Decimal Total_Serv_FY = 0;
               Decimal Total_Mile_FY = 0;
               for (Contact c : contacts)
               {
                   if (c.Total_Service_Hours_Completed__c != null) { Total_Serv += c.Total_Service_Hours_Completed__c; }
                   if (c.Total_Miles_Traveled__c != null) { Total_Mile += c.Total_Miles_Traveled__c; }
                   if (c.Total_Service_Hours_Completed_This_Year__c != null) { Total_Serv_FY += c.Total_Service_Hours_Completed_This_Year__c; }
                   if (c.Total_Miles_Traveled_This_Year__c != null) { Total_Mile_FY += c.Total_Miles_Traveled_This_Year__c; }
               }
               a.Total_Service_Hours_Completed_This_Year__c = Total_Serv_FY;
               a.Total_Miles_Traveled_This_Year__c = Total_Mile_FY;
               a.Total_Service_Hours_Completed__c = Total_Serv;
               a.Total_Miles_Traveled__c = Total_Mile;
           }

           if (orgs != null && orgs.size() > 0) {
            DMLManager.UpdateSObjects(orgs);
           }
       }

       public static boolean isEmptyOrNull(String value)
       {
           return (value==null)||(value=='');
       }

       public static void serializeShiftWrapper(ShiftWrapper theWrap) {
            if (theWrap.theShift.Frequency__c != 'Flexible')
            {
                theWrap.theShift.Start_Time__c = getDateTime(theWrap.theShift.Start_Day__c, theWrap.startHours, theWrap.startMins, theWrap.startMeridiemOffset);
                theWrap.theShift.End_Time__c = getDateTime(theWrap.theShift.End_Day__c, theWrap.endHours, theWrap.endMins, theWrap.endMeridiemOffset);
                theWrap.theShift.Day_of_the_week__c = getDayOfWeek(theWrap.theShift.Shift_Date__c);
            }
       }

       public static DateTime getDateTime(string hours, string mins, string meridium) {
           return DateTime.parse('1/1/1970 ' + hours + ':' + mins + ' ' + meridium);
       }

       public static DateTime getDateTime(Date d, string hours, string mins, string meridium) {
           if (UserInfo.getLocale() == 'en_US') {
               return DateTime.parse(d.Month() + '/' + d.Day() + '/' + d.Year() + ' ' + hours + ':' + mins + ' ' + meridium);
           }
           if (UserInfo.getLocale() == 'en_CA') {
               return DateTime.parse(d.Day() + '/' + d.Month() + '/' + d.Year() + ' ' + hours + ':' + mins + ' ' + meridium);
           }
           return DateTime.parse(d.Month() + '/' + d.Day() + '/' + d.Year() + ' ' + hours + ':' + mins + ' ' + meridium);
       }

       public static String getDayOfWeek(DateTime theDate) {
           Date weekStart = theDate.date().toStartofWeek();
           Integer dayOfWeek = weekStart.daysBetween(theDate.date());
           if (dayOfWeek == 6) { return 'Sunday'; }
           if (dayOfWeek == 0) { return 'Monday'; }
           if (dayOfWeek == 1) { return 'Tuesday'; }
           if (dayOfWeek == 2) { return 'Wednesday'; }
           if (dayOfWeek == 3) { return 'Thursday'; }
           if (dayOfWeek == 4) { return 'Friday'; }
           if (dayOfWeek == 5) { return 'Saturday'; }
           else { return 'Error'; }
       }

        public static List<Volunteer_Shift__c > getShiftsFromUser(String uId) {
            List<Volunteer_Shift__c > retVal = new List<Volunteer_Shift__c >();


            User u;
            List<User> users = new UserSelector().SelectContactIdById(uId);
            if (users.size() > 0 && users != null) { u = users[0]; }

            if (u.ContactId == null)
            { return new List<Volunteer_Shift__c >(); }

            Contact c;

            String clause = ' WHERE Id = \'' + u.ContactId + '\'';
            String subClause = ' WHERE Status__c = \'Approved\' OR Status__c = \'Placed\'';
            String fields = 'FirstName,LastName,'+ Utilities.PackageNamespace + 'Middle_Name__c,Salutation,'+ Utilities.PackageNamespace + 'Nickname__c,MailingStreet,'+ Utilities.PackageNamespace + 'Apt_Unit__c,MailingCity,MailingState,MailingPostalCode,Phone,OtherPhone,Email,BirthDate,'+ Utilities.PackageNamespace + 'Gender__c';
            String subFields = 'Id,'+ Utilities.PackageNamespace + 'Date_of_Background_Check__c,'+ Utilities.PackageNamespace + 'Status__c';

            List<Contact> contacts = new GenericQueryBuilder().QueryBuilderWithSubQuery(Contact.sObjectType, fields, clause, Volunteer_Application__c.sObjectType, 'Volunteer_Applications__r', subFields, subClause);
            if (contacts.size() > 0 && contacts != null) { c = contacts[0]; }

            if (c != null)
            {
                retVal = new VolunteerShiftSelector().SelectVolunteerInfoByIdAndStatus(c.Id, 'Placed');
            }

            return retVal;
        }

        public static Integer getDuration(DateTime startTime, DateTime endTime) {
            return Integer.valueOf(((startTime.getTime() - endTime.getTime())/60000)/60);
        }

        public static Contact getContactFromUser(String uId) {


            User u;
            List<User> users = new UserSelector().SelectContactIdById(uId);
            if (users.size() > 0 && users != null) { u = users[0]; }

            if (u.ContactId == null)
            { return new Contact(); }

            Contact c;
            List<Contact> contacts = new ContactSelector().SelectVolunteerByContactId(u.ContactId);

            if (contacts.size() > 0 && contacts != null) { c = contacts[0]; }

            return c;
        }

        public static Volunteer_Application__c getMostRecentAppFromUser(String uId) {

            User u;
            List<User> users = new UserSelector().SelectContactIdById(uId);
            if (users.size() > 0 && users != null) { u = users[0]; }

            if (u.ContactId == null )
            { return new Volunteer_Application__c(); }

            Volunteer_Application__c va = new Volunteer_Application__c();
            List<Volunteer_Application__c> apps = new VolunteerApplicationSelector().SelectVolunteerApplicationByContactId(u.ContactId);
            if (apps.size() > 0 && apps != null)
            {
                va = apps[0];
            }

            return va;
        }

        public static Set<String> getProgramSet(String uId) {

            Set<String> theProgs = new Set<String>();

            User u;
            List<User> users = new UserSelector().SelectContactIdById(uId);
            if (users.size() > 0 && users != null) { u = users[0]; }

            if (u.ContactId == null  )
            { return theProgs; }

            List<Volunteer_Application__c> apps = new VolunteerApplicationSelector().SelectVolunteerApplicationInfo(u.ContactId, 'Placed');

            for (Volunteer_Application__c a : apps)
            {
                theProgs.add(a.Volunteer_Role__r.Volunteer_Opportunity__r.Program__c);
            }
            return theProgs;
        }

        public static List<Volunteer_Application__c> getAppsFromUser(String uId) {

            User u;
            List<User> users = new UserSelector().SelectContactIdById(uId);
            if (users.size() > 0 && users != null) { u = users[0]; }

            if (u.ContactId == null )
            { return new List<Volunteer_Application__c>(); }

            List<Volunteer_Application__c> apps = new VolunteerApplicationSelector().SelectVolunteerDetailsByContactId(u.ContactId);

            return apps;
        }

        public static Integer getScreeningLevel(String uId) {
            return 0;
        }

        public static Integer getScreeningLevelFromContact(String cId) {
           return 0;
        }

        public static void updateVolunteerProfile(List<Volunteer_Application__c> theApps)
        {
            App_Settings__c app_settings = App_Settings__c.getInstance();
            Set<String> CIDs = new Set<String>();
            List<Contact> contacts = new List<Contact>();
            Map<String, Volunteer_Application__c> cid_to_app = new Map<String, Volunteer_Application__c>();

            for(Volunteer_Application__c va : theApps)
            {
                if(va.Volunteer__c == null || va.RecordTypeId != app_settings.Individual_App_RecordtypeId__c)
                { continue; }

                CIDs.add(va.Volunteer__c);
                cid_to_app.put(va.Volunteer__c, va);
            }

            contacts = new ContactSelector().SelectAllContactInfoById(CIDs);

            for(Contact c : contacts)
            {
                if (cid_to_app.get(c.Id).Currently_employed__c != '' && cid_to_app.get(c.Id).Currently_employed__c != null) { c.Currently_employed__c = cid_to_app.get(c.Id).Currently_employed__c; }
                if (cid_to_app.get(c.Id).Description_of_Work__c != '' && cid_to_app.get(c.Id).Description_of_Work__c != null) { c.Description_of_Work__c = cid_to_app.get(c.Id).Description_of_Work__c; }
                if (cid_to_app.get(c.Id).Programs_Offered_by_Employer__c != '' && cid_to_app.get(c.Id).Programs_Offered_by_Employer__c!= null) { c.Does_Your_Employer_Offer__c = cid_to_app.get(c.Id).Programs_Offered_by_Employer__c;}
                if (cid_to_app.get(c.Id).Name_of_Educational_Institution__c != '' && cid_to_app.get(c.Id).Name_of_Educational_Institution__c != null) { c.Name_of_Educational_Institution__c = cid_to_app.get(c.Id).Name_of_Educational_Institution__c;}
                if (cid_to_app.get(c.Id).Volunteer_Availability__c != '' && cid_to_app.get(c.Id).Volunteer_Availability__c != null) { c.Volunteer_Availability__c = cid_to_app.get(c.Id).Volunteer_Availability__c ;}
                if (cid_to_app.get(c.Id).Reasons_for_Volunteering__c != '' && cid_to_app.get(c.Id).Reasons_for_Volunteering__c != null) { c.Reasons_for_Volunteering__c = cid_to_app.get(c.Id).Reasons_for_Volunteering__c;}
                if (cid_to_app.get(c.Id).Professional_Skills__c != '' && cid_to_app.get(c.Id).Professional_Skills__c != null) { c.Professional_Skills__c = cid_to_app.get(c.Id).Professional_Skills__c;}
                if (cid_to_app.get(c.Id).Prefered_Locales__c!= '' && cid_to_app.get(c.Id).Prefered_Locales__c!= null) { c.Preferred_Locales__c = cid_to_app.get(c.Id).Prefered_Locales__c;}
                if (cid_to_app.get(c.Id).Miles_Willing_to_Travel_One_Way__c != '' && cid_to_app.get(c.Id).Miles_Willing_to_Travel_One_Way__c != null) { c.Miles_Willing_to_Travel_One_Way__c = cid_to_app.get(c.Id).Miles_Willing_to_Travel_One_Way__c;  }
                if (cid_to_app.get(c.Id).Education_Level__c != '' && cid_to_app.get(c.Id).Education_Level__c != null) { c.Education_Level__c = cid_to_app.get(c.Id).Education_Level__c;}
                if (cid_to_app.get(c.Id).How_Did_You_Hear_About_Us__c != '' && cid_to_app.get(c.Id).How_Did_You_Hear_About_Us__c != null) { c.How_Did_You_Hear_About_Us__c = cid_to_app.get(c.Id).How_Did_You_Hear_About_Us__c;}
                if (cid_to_app.get(c.Id).Languages__c != '' && cid_to_app.get(c.Id).Languages__c != null) { c.Languages__c = cid_to_app.get(c.Id).Languages__c;    }
                if (cid_to_app.get(c.Id).Emergency_Contact_Relationship__c != '' && cid_to_app.get(c.Id).Emergency_Contact_Relationship__c != null) { c.Emergency_Contact_Relationship__c = cid_to_app.get(c.Id).Emergency_Contact_Relationship__c ;}
                if (cid_to_app.get(c.Id).Emergency_Contact_Phone__c != '' && cid_to_app.get(c.Id).Emergency_Contact_Phone__c != null) { c.Emergency_Contact_Phone__c = cid_to_app.get(c.Id).Emergency_Contact_Phone__c ;     }
                if (cid_to_app.get(c.Id).Emergency_Contact__c != '' && cid_to_app.get(c.Id).Emergency_Contact__c != null) { c.Emergency_Contact__c = cid_to_app.get(c.Id).Emergency_Contact__c ;     }
                if (cid_to_app.get(c.Id).Education_Program__c!= '' && cid_to_app.get(c.Id).Education_Program__c!= null) { c.Educational_Program_Name__c = cid_to_app.get(c.Id).Education_Program__c;     }
                c.Last_Volunteer_Profile_Updated__c = DateTime.now();
            }

            if (contacts != null && contacts.size() > 0) {
                DMLManager.UpdateSObjects(contacts);
            }
        }
    }