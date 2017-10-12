trigger GiftAidUpdates_new on Gift_Aid_Declaration__c (after insert, after update, before insert, before update) {
    App_Settings__c appSetting = App_Settings__c.getInstance();
    if (appSetting.Gift_Aid_Enable__c) {
      set<Id> contactIds = new set<Id>();
      if (!Trigger.isDelete) {
        for (Gift_Aid_Declaration__c gift : trigger.new) {
          contactIds.add(gift.Donor__c);
        }
      }

      List<Gift_Aid_Declaration__c> giftaidlist = new List<Gift_Aid_Declaration__c> ();
      set<id> contactset = new set<id> ();
      map<Gift_Aid_Declaration__c, id> contactgiftmap = new map<Gift_Aid_Declaration__c, id> ();
      String customdate;

      map<Id, List<payment__c>> transpaymnetmap = new map<Id, List<payment__c>>();
      map<id, Gift__c> transactionind = new map<id, Gift__c> ();
      list<Gift__c> transactionlist = new list<Gift__c>();
      map<id, List<Gift__c>> contransmap = new map<id, List<Gift__c>>();
      List<contact> mycon = new List<contact>();
      App_Settings__c appSettings = App_Settings__c.getInstance(UserInfo.getOrganizationId());



      if (Trigger.isBefore) {
        if (Trigger.isInsert  || Trigger.isupdate) {
          contact currentContact;
          Map<Id, contact> contactsWithGADs = new Map<Id, contact>(new ContactSelector().SelectContactDataCompleteDetails(contactIds));
          Gift_Aid_Declaration__c oldGiftAidRecord;
          Map<Id, Gift_Aid_Declaration__c> oldGiftAidList;
          if (Trigger.isupdate)
            oldGiftAidList = new Map<Id, Gift_Aid_Declaration__c> (trigger.old);

          for (Gift_Aid_Declaration__c gift : trigger.new) {
            currentContact = contactsWithGADs.get(gift.Donor__c);

            if (currentContact.Data_complete_for_Gift_Aid__c == false) {
              gift.isActive__c = false;
            } else {
              gift.isActive__c = true;
            }

            if (gift.End_Date__c < gift.Effective_Date__c)
              gift.addError('End date cannot be less than effective date.');

            if (oldGiftAidList != null)
              oldGiftAidRecord = oldGiftAidList.get(gift.Id);


            customdate = gift.Next_Fiscal_Date__c.year() - 5 + '-' + gift.Next_Fiscal_Date__c.month() + '-01' ;
            if (gift.Type__c == 'This donation, and all future & historic')
              gift.Effective_Date__c = date.valueOf(customdate);
            if ((gift.Type__c == 'This donation, and all future' || gift.Type__c == 'This Donation Only') && gift.Effective_Date__c == null)
              gift.Effective_Date__c = gift.Start_Date__c;
            if (gift.Type__c == 'This Donation Only' && gift.End_Date__c == null)
              gift.End_Date__c = gift.Start_Date__c;

            if (Trigger.isupdate) {
              if (gift.Type__c == 'This donation, and all future & historic' && oldGiftAidRecord.Type__c != gift.Type__c) {
                gift.End_Date__c = null;
                gift.Effective_Date__c = date.valueOf(customdate);
              } else if (gift.Type__c == 'This donation, and all future' && oldGiftAidRecord.Type__c != gift.Type__c) {
                gift.End_Date__c = null;
                gift.Effective_Date__c = gift.Start_Date__c;
              } else if(gift.Type__c == 'This Donation Only' && oldGiftAidRecord.Type__c != gift.Type__c){
                gift.End_Date__c = gift.Start_Date__c;
                gift.Effective_Date__c = gift.Start_Date__c;
              }
            } else {
              if(gift.Type__c == 'This Donation Only' && gift.End_Date__c == null && gift.Start_Date__c == null){
                gift.End_Date__c = gift.Start_Date__c;
                gift.Effective_Date__c = gift.Start_Date__c;
              }
            }

            if (gift.Type__c != null && gift.Effective_Date__c != null && gift.End_Date__c != null && gift.Type__c == 'This Donation Only' && gift.Effective_Date__c != gift.End_Date__c)
              gift.addError('End Date must be the same as Effective Date.');
          }
        }

      }
      if (Trigger.isAfter) {


        //List<Gift_Detail__c> AllocationUpdateList =  new List<Gift_Detail__c>();
        list<Gift_Aid_Declaration__c> updateoldgiftaiddeclaration = new list<Gift_Aid_Declaration__c>();
        set<Id> cids = new set<Id>();
        Datetime dateTimeVal = Datetime.now();

        String fields = '';
        String subFields = '';
        String clause = '';
        String subClause = '';
        String inFields = '';

        //IF GIFT AID DECLARATION IS INSERTED//
        if (Trigger.isInsert) {

          //POPULATE ALL MAPS, LISTS, AND SETS NEEDED//
          for (Gift_Aid_Declaration__c gift : trigger.new) {
            cids.add(gift.Donor__c);
            giftaidlist.add(gift);
            contactset.add(gift.Donor__c);
            contactgiftmap.put(gift, gift.Donor__c);
          }
          /////////////////////////////////////////////

          //GET ALL CONTACTS AND THEIR GADS THAT BELONG TO THE GAD//
          fields = 'FirstName,LastName,MailingPostalCode,MailingCountry,MailingCity,MailingState,MailingStreet';
          subFields = 'id,name,'+ Utilities.PackageNamespace + 'isActive__c,'+ Utilities.PackageNamespace + 'Type__c,'+ Utilities.PackageNamespace + 'Effective_Date__c,'+ Utilities.PackageNamespace + 'End_Date__c';
          inFields = Converter.ConvertListSetToString(cids);
          clause = ' WHERE Id IN ('+ inFields +')';
          subClause = ' where End_Date__c = null AND CreatedDate < :dateTimeVal';

          List<contact> contactslist = new GenericQueryBuilder().QueryBuilderWithSubQueryWithDate('Contact', fields, clause, 'Gift_Aid_Declaration__c', 'Gift_Aid_Declarations__r', subFields, subClause, dateTimeVal);
          //////////////////////////////////////////////////////////

          //FOR EVERY CONTACT CHANGE THEIR GAD END DATES TO YESTERDAY//
          for (contact cc : contactslist) {
            if (cc.Gift_Aid_Declarations__r.size() > 0) {
              list<Gift_Aid_Declaration__c> glist = cc.Gift_Aid_Declarations__r;
              for (Gift_Aid_Declaration__c g : glist) {
                g.End_Date__c = system.today() - 1;
                updateoldgiftaiddeclaration.add(g);
              }
            }
          }
          //////////////////////////////////////////////////////////////
          ///////////////////////////////////////
        } else if (Trigger.isUpdate) {
          for (Gift_Aid_Declaration__c gift : trigger.new) {
            string oldvalue = Trigger.oldMap.get(gift.Id).Type__c;
            string newvalue = gift.Type__c;
            giftaidlist.add(gift);
            contactset.add(gift.Donor__c);
            contactgiftmap.put(gift, gift.Donor__c);
          }
        }

        fields = 'id,name,'+ Utilities.PackageNamespace + 'Constituent__c';
        subFields = 'id,name,'+ Utilities.PackageNamespace + 'Gift_Aid_Claim_Status__c,'+ Utilities.PackageNamespace + 'Gift_Aid_Declaration__c,'+ Utilities.PackageNamespace + 'Date__c,'+ Utilities.PackageNamespace + 'Payment_Type__c';
        inFields = Converter.ConvertListSetToString(contactset);
        clause = ' WHERE Constituent__c IN ('+ inFields +')';
        subClause = ' where Gift_Aid_Eligible__c = TRUE';

        transactionlist = new GenericQueryBuilder().QueryBuilderWithSubQuery(Gift__c.sObjectType, fields, clause, Payment__c.sObjectType, 'Recurring_Payments__r', subFields, subClause);

        clause = ' WHERE Id IN ('+ inFields +')';
        mycon = new GenericQueryBuilder().QueryBuilderWithSubQuery(Contact.sObjectType, 'id,name', clause, Gift__c.sObjectType, 'Gifts__r', 'id,name', '');

        for (contact mycon2 : mycon) {
          contransmap.put(mycon2.id, mycon2.Gifts__r);
        }

        for (Gift__c t : transactionlist) {
          transactionind.put(t.Constituent__c, t);
          transpaymnetmap.put(t.Id, t.Recurring_Payments__r);
        }

        Set<payment__c> mypay2 = new Set<payment__c> ();
        if (trigger.isInsert) {
          for (Gift_Aid_Declaration__c gg : giftaidlist) {
            Id cc = contactgiftmap.get(gg);
            List<Gift__c> mytransaction = contransmap.get(cc);
            if (gg.End_Date__c == null) {
              if (mytransaction.size() > 0) {
                for (Gift__c trans : mytransaction) {
                  List<payment__c> mypay = transpaymnetmap.get(trans.Id);
                  if (mypay != null) {
                    if (mypay.size() > 0) {
                      for (payment__c p : mypay) {
                        if (p.Date__c >= gg.Effective_Date__c && p.Gift_Aid_Claim_Status__c == 'Not claimed' && gg.isActive__c == true) {
                          p.Gift_Aid_Declaration__c = gg.Id;
                          mypay2.add(p);
                        }
                      }
                    }
                  }
                }
              }

            }
            else {
              if (mytransaction.size() > 0) {
                for (Gift__c trans : mytransaction) {
                  List<payment__c> mypay = transpaymnetmap.get(trans.Id);
                  if (mypay != null) {
                    if (mypay.size() > 0) {
                      for (payment__c p : mypay) {
                        if (p.Gift_Aid_Claim_Status__c == 'Rejected' || p.Gift_Aid_Claim_Status__c == 'Claimed not received') {
                          mypay2.add(p);
                        } else if (p.Gift_Aid_Claim_Status__c == 'Received') {
                          if (p.Date__c <  gg.Effective_Date__c || p.Date__c >  gg.End_Date__c) {
                            p.Gift_Aid_Claim_Status__c = 'To be Refunded';
                            mypay2.add(p);
                          }
                        } else if (p.Gift_Aid_Claim_Status__c == 'Not claimed') {
                          if (p.Date__c <  gg.Effective_Date__c || p.Date__c >  gg.End_Date__c || gg.isActive__c == false || appSettings.Gift_Aid_Eligible_Payment_Types__c.contains(p.Payment_Type__c) != true) {
                            p.Gift_Aid_Declaration__c = null;
                            mypay2.add(p);
                          } else {
                            p.Gift_Aid_Declaration__c = gg.Id;
                            mypay2.add(p);
                          }
                        }
                      }
                    }
                  }
                }
              }

            }
          }
        } else if (trigger.isUpdate) {
          for (Gift_Aid_Declaration__c gg : giftaidlist) {

            if ((Trigger.oldMap.get(gg.Id).End_Date__c == null && gg.End_Date__c != null) || (Trigger.oldMap.get(gg.Id).End_Date__c != gg.End_Date__c) || (Trigger.oldMap.get(gg.Id).Effective_Date__c !=  gg.Effective_Date__c) || (Trigger.oldMap.get(gg.Id).Start_Date__c !=  gg.Start_Date__c) || (Trigger.oldMap.get(gg.Id).isActive__c != gg.isActive__c)) {
              Id cc = contactgiftmap.get(gg);
              List<Gift__c> mytransaction = contransmap.get(cc);

              if (mytransaction.size() > 0) {
                for (Gift__c trans : mytransaction) {
                  List<payment__c> mypay = transpaymnetmap.get(trans.Id);
                  if (mypay != null) {
                    if (mypay.size() > 0) {
                      for (payment__c p : mypay) {
                        if (p.Gift_Aid_Claim_Status__c == 'Rejected' || p.Gift_Aid_Claim_Status__c == 'Claimed not received') {
                          mypay2.add(p);
                        } else if (p.Gift_Aid_Claim_Status__c == 'Received') {
                          if (p.Date__c <  gg.Effective_Date__c || p.Date__c >  gg.End_Date__c) {
                            p.Gift_Aid_Claim_Status__c = 'To be Refunded';
                            mypay2.add(p);
                          } else {
                            mypay2.add(p);
                          }
                        }

                        else if (p.Gift_Aid_Claim_Status__c == 'Not claimed') {
                          if (p.Date__c <  gg.Effective_Date__c || p.Date__c >  gg.End_Date__c || gg.isActive__c == false || appSettings.Gift_Aid_Eligible_Payment_Types__c.contains(p.Payment_Type__c) != true) {
                            p.Gift_Aid_Declaration__c = null;
                            mypay2.add(p);
                          } else {
                            p.Gift_Aid_Declaration__c = gg.Id;
                            mypay2.add(p);
                          }
                        }
                      }
                    }
                  }
                }
              }

            }


            //end date to null
            else if (Trigger.oldMap.get(gg.Id).End_Date__c != null && gg.End_Date__c == null) {
              Id cc = contactgiftmap.get(gg);
              List<Gift__c> mytransaction = contransmap.get(cc);
              if (mytransaction.size() > 0) {
                for (Gift__c trans : mytransaction) {
                  List<payment__c> mypay = transpaymnetmap.get(trans.Id);
                  if (mypay != null) {
                    if (mypay.size() > 0) {
                      for (payment__c p : mypay) {
                        if (p.Date__c >= gg.Effective_Date__c && p.Gift_Aid_Claim_Status__c == 'Not claimed' && gg.isActive__c == true) {
                          p.Gift_Aid_Declaration__c = gg.Id;
                          mypay2.add(p);
                        }
                      }
                    }
                  }
                }
              }

            }

          }//end date updated

        }//is update

        if (updateoldgiftaiddeclaration.size() > 0) {
          DMLManager.UpdateSObjects(updateoldgiftaiddeclaration);
        }

        if (mypay2.size() > 0) {
          List<Payment__c> paymentsToUpdate = new List<Payment__c>();
          Map<Id, Payment__c> paymentMap = new Map<Id, Payment__c>();
          for (payment__c payment : mypay2) {
            if (paymentMap.containsKey(payment.Id) == false) {
              paymentMap.put(payment.Id, payment);
              paymentsToUpdate.add(payment);
            }
          }
          DMLManager.UpdateSObjects(paymentsToUpdate);
        }
      } //is after trigger
    }
  }