/**
* @group Utilities
* @description This class allows easy access to object and field description information from within other classes.
*
* It is called statically, and therefore will supply the same information to all calls made from
* within one transaction, or set of trigger calls. This is beneficial because this info should
* be the same for all calls in a transaction, and by calling it statically we reduce the calls
* that are made, making the total transaction more efficient.
*/
@isTest
public with sharing class UTIL_Describe_TEST {

    // TEST
    static testmethod void testDescribe() {
        
        string s;
        
        Schema.DescribeSObjectResult res = UTIL_Describe.getObjectDescribe('Contact');        
        system.assertEquals(res.getName(), 'Contact');
        s = UTIL_Describe.getObjectLabel('Contact');
        system.assertEquals (s, res.getLabel());

        account a = new account(name='Test');
        insert a;
        system.assert(UTIL_Describe.isObjectIdThisType(a.id, 'Account'));
        
        s = UTIL_Describe.getFieldLabel('Account', 'LastModifiedDate');
        
        Schema.DescribeFieldResult fr = UTIL_Describe.getFieldDescribe('Account', 'CreatedDate');     
        s = UTIL_Describe.getFieldLabel('Account', 'CreatedDate');
        system.assertEquals (s, fr.getLabel());

        Map<String, Schema.DescribeFieldResult> afd = UTIL_Describe.getAllFieldsDescribe('Account');
        system.assertEquals ('BillingCity', afd.get('billingcity').getName());
        afd = UTIL_Describe.getAllFieldsDescribe('Account');

        SObject acctObj = UTIL_Describe.getPrototypeObject('Account');
        // should be able to cast to account
        account acct = (account)(acctObj);

        s = UTIL_Describe.getFieldType('Account', 'CreatedDate');
        system.assertEquals('DATETIME', s);
        
        s = UTIL_Describe.getNameField('Account');
        system.assertEquals('name', s);

        try {
            s = UTIL_Describe.getObjectLabel('sdlkfjsdlkfjsldkfjlsdkfj');
        } catch (exception e) {
            system.assertEquals('Invalid object name \'sdlkfjsdlkfjsldkfjlsdkfj\'', e.getMessage());
        } 
        try {
            s = UTIL_Describe.getFieldLabel('Opportunity', 'sdlkfjsdlkfjsldkfjlsdkfj');
        } catch (exception e) {
            system.assertEquals('Invalid field name \'sdlkfjsdlkfjsldkfjlsdkfj\'', e.getMessage());
        } 
    }  
}