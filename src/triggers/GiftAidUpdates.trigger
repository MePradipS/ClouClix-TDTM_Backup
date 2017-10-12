trigger GiftAidUpdates on Gift_Aid_Declaration__c (after insert,after update) {
        // -------------------------------------------------------------------------------------------
        // This trigger code has been commented to reduce the probability of getting the Percent of Apex
        // Used limit. 
        // -------------------------------------------------------------------------------------------
        //    Date                Author                 Description
        // -------------------------------------------------------------------------------------------
        // 11-Oct-2017        Pradip Shukla          Initial Version
        // --------------------------------------------------------------------------------------------

       /*App_Settings__c appSetting = App_Settings__c.getInstance();
       if(appSetting.Gift_Aid_Enable__c)
        {
    
    
       List<Gift_Aid_Declaration__c> giftaidlist= new List<Gift_Aid_Declaration__c> ();
       set<id> contactset = new set<id> ();
       map<Gift_Aid_Declaration__c,id> contactgiftmap = new map<Gift_Aid_Declaration__c,id> ();
    
    
       for(Gift_Aid_Declaration__c gift:trigger.new)
       {
         if(gift.Type__c == 'This donation, and all future & historic' )
         {
         giftaidlist.add(gift);
         contactset.add(gift.Donor__c);
         contactgiftmap.put(gift,gift.Donor__c);
         }
       }
    
    
      map<Id, List<payment__c>> transpaymnetmap = new map<Id, List<payment__c>>();
      map<id,Gift__c> transactionind= new map<id,Gift__c> ();
    
      String inFields = Converter.ConvertListSetToString(contactset);
      String clause = ' WHERE Constituent__c IN ('+ inFields +')';
      String fields = 'id,name,'+ Utilities.PackageNamespace + 'Constituent__c';
      String subClause = ' where Gift_Aid_Claim_Status__c = \'Not claimed\' AND Gift_Aid_Declaration__c = null';
      String subFields = 'id,name ,'+ Utilities.PackageNamespace + 'Gift_Aid_Claim_Status__c,'+ Utilities.PackageNamespace + 'Gift_Aid_Declaration__c,'+ Utilities.PackageNamespace + 'Date__c';
    
      list<Gift__c> transactionlist=new GenericQueryBuilder().QueryBuilderWithSubQuery(Gift__c.sObjectType, fields, clause, Payment__c.sObjectType, 'Recurring_Payments__r', subFields, subClause);
    
      map<id,List<Gift__c>> contransmap=new map<id,List<Gift__c>>();
      clause = ' WHERE id IN ('+ inFields +')';
    
      List<contact> mycon=new GenericQueryBuilder().QueryBuilderWithSubQuery(Contact.sObjectType, 'id,name', clause, Gift__c.sObjectType, 'Gifts__r', 'id,name', '');
    
      for(contact mycon2:mycon)
      {
       contransmap.put(mycon2.id, mycon2.Gifts__r);
      }
    
    
    
      for(Gift__c t:transactionlist)
      {
      transactionind.put(t.Constituent__c, t);
      transpaymnetmap.put(t.Id, t.Recurring_Payments__r);
      }
    
    
     List<payment__c> mypay2=new List<payment__c> ();
    
    
      for(Gift_Aid_Declaration__c gg:giftaidlist)
      {
           Id cc=contactgiftmap.get(gg);
           List<Gift__c> mytransaction = contransmap.get(cc);
    
          if(mytransaction.size() >0)
          {
               for(Gift__c trans:mytransaction)
               {
    
                   List<payment__c> mypay= transpaymnetmap.get(trans.Id);
                   if(mypay != null)
                       {
                            if(mypay.size() > 0)
                                {
                                    for(payment__c p: mypay)
                                          {
                                              if(p.Date__c >= gg.Effective_Date__c)
                                                    {
                                                         p.Gift_Aid_Declaration__c= gg.Id;
                                                         mypay2.add(p);
                                                    }
                                          }
    
                              }
                      }
              }
           }
       }
    
      DMLManager.UpdateSObjects(mypay2);
  }*/
}