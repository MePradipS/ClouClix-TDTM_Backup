@RestResource(urlMapping = '/UpsertRegistrationBulk')
global with sharing class RESTUpsertRegistrationBulk {

	@HttpPost
	global static List<RegistrationWrapper> UpsertRegistration(List<RegistrationWrapper> wrapper_list) {
		Set<string> contactEmails = new Set<string> ();
		Map<string, Contact> contactsToUpdate = new Map<string, Contact> ();
		List<Contact> contactsToInsert = new List<Contact> ();
		List<Event_Registration__c> registrationsToUpdate = new List<Event_Registration__c> ();

		for (RegistrationWrapper w : wrapper_list) {
			if (w.con != null) {
				if (w.con.Email != '' && w.con.Email != null) {
					contactEmails.add(w.con.Email);
				}
			}
		}

		List<Contact> contacts = new ContactSelector().SelectIdByEmailList(contactEmails);

		for (RegistrationWrapper w : wrapper_list) {
			if (w.con != null) {
				if (w.con.Id != null) {
					contactsToUpdate.put(w.con.Id, w.con);
					continue;
				}
				if (w.con.Email != '' && w.con.Email != null) {
					if (contacts.size() == 0) {
						contactsToInsert.add(w.con);
					}
					for (Contact con : contacts) {
						if (w.con.Email == con.Email) {
							boolean isUpdate = false;
							if (w.con.Id != null) {
								isUpdate = true;
								w.con.Id = con.Id;
							}
							if (isUpdate) {
								contactsToUpdate.put(w.con.Id, w.con);
							}
							else {
								contactsToInsert.add(w.con);
							}
							break;
						}
					}
				}
			}
		}

		if(Schema.SObjectType.Contact.isUpdateable()) {
			List<Contact> contactsToUpdateList = new List<Contact>();
			contactsToUpdateList = contactsToUpdate.values();
			DMLManager.UpdateSObjects(contactsToUpdateList);
		}

		if(Schema.SObjectType.Contact.isCreateable()) {
			DMLManager.InsertSObjects(contactsToInsert);
		}

		for (RegistrationWrapper w : wrapper_list) {
			w.reg.Individual__c = w.con.Id;
			registrationsToUpdate.add(w.reg);
		}

		if (Schema.SObjectType.Event_Registration__c.isCreateable() && Schema.SObjectType.Event_Registration__c.isUpdateable()) {
			if (registrationsToUpdate != null && registrationsToUpdate.size() > 0) {
				DMLManager.UpsertSObjects(registrationsToUpdate);
			}
		}

		return wrapper_list;

	}
}