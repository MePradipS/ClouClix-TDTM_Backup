/**
* @group Utilities
* @description Class which holds static methods for common utilities, 
* such as detecting whether we are in a managed package, and some string helpers.
*/

public class UTIL_Namespace { 

    /******************************************************************************************************
    * @description String helper property for getNamespace() method.
    *******************************************************************************************************/
    private static string plainNamespace;
    /*******************************************************************************************************
    * @description Finds the namespace for the current context.
    * @return string The current namespace as a string, or a blank string if we're not in a namespaced context.
    ********************************************************************************************************/
    public static string getNamespace() {       
        if (plainNamespace == null) {
            string withDotNotation = UTIL_Namespace.class.getName();  
        
            if (withDotNotation.contains('.')) {
                plainNamespace = withDotNotation.substringBefore('.');
            } else {
                plainNamespace = '';
            }
        }
        return plainNamespace;   
    }

    /*******************************************************************************************************
    * @description Static method adds the current namespace to a string if we're in a managed context, 
    * with double underscore notation. If we're not in a managed context, returns the string itself.
    * @param str Token name.
    * @return Token name, with namespace prefix and double underscore if in a managed package.
    ********************************************************************************************************/
    public static string StrTokenNSPrefix(string str) {
        if (getNamespace() == '') return str;
        return getNamespace() + '__' + str;
    }
    
    /*******************************************************************************************************
    * @description Static method adds the current namespace to a string if we're in a managed context, 
    * with dot notation. If we're not in a managed context, returns the string itself.
    * @param str Token name.
    * @return Token name, with namespace prefix and dot notation if in a managed package.
    ********************************************************************************************************/
    public static string StrTokenNSPrefixDotNotation(string str) {
        if (getNamespace() == '') return str;
        return getNamespace() + '.' + str;
    }

    /*******************************************************************************************************
    * @description If we are in a managed package, tokens in dynamic SOQL must include the package namespace
    * prefix, bit field describes don't include namespace prefix fields within the package. This method can
    * be used in our describe code to remove an incorrect namespace prefix.
    * Removes NPSP__ prefix, then removes dynamic prefix if one is detected.
    * @param str token name 
    * @return token name, with namespace prefix removed, if present.
    ********************************************************************************************************/
    public static string StrTokenRemoveNSPrefix(string str) {
        if(str.startsWith('npsp__'))
            str = str.replaceFirst('npsp__', '');
        if (getNamespace() != '' && str.startsWith(getNamespace() + '__'))
            str = str.replaceFirst(getNamespace() + '__', '');
        return str;
    }
    
    /*******************************************************************************************************
    * @description Static method that takes a string of a multiple potential field names or object names.  
    * If it is a custom object or field (name ends with __c), it prepends the namespace prefix if required.
    * If we are in a managed package, tokens in dynamic SOQL must include the package namespace prefix.
    * If you ever deploy this package as unmanaged, this routine will do nothing!
    * @param str string that contains 0 or more token names 
    * @return same string with token names, namespace prefixed, if required.
    ********************************************************************************************************/
    public static string StrAllNSPrefix(string str) {
        if (getNamespace() == '') return str;
        Pattern pat = Pattern.Compile('[a-zA-z0-9]*__c');
        Matcher match = pat.matcher(str);
        return match.replaceAll(getNamespace()+'__$0');
    }
    
    /*******************************************************************************************************
    * @description Static method that detects if we are running in a sandbox.
    * @return true if running in sandbox. false otherwise.
    ********************************************************************************************************/
    public static Boolean isSandbox() {
        return URL.getSalesforceBaseUrl().getHost().left(2).equalsignorecase('cs');
    }
    
    /*******************************************************************************************************
    * @description Static method that returns the real email if it's a sandbox email.
    * @return string with user's email.
    ********************************************************************************************************/
    public static String sandboxEmailToRealEmail(String email) {
        if((isSandbox() || Test.isRunningTest()) && email.contains('=')) {
          email = email.substring(0, email.indexOf('@'));
          email = email.replace('=', '@');
        }
        return email;
    }
}