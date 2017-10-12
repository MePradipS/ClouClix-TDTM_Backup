public with sharing class Converter {
	public static string ConvertListSetToString(List<SObject> listVariable) {
			if (listVariable == null || listVariable.size() < 1) {
				return '\'\'';
			}

			String seperatedString = '';
			for(SObject o : listVariable){
				seperatedString += '\'' + o + '\'' + ',';
			}
			seperatedString = seperatedString.removeEnd(',');

			return seperatedString;
	}

	public static string ConvertListSetToString(Set<SObject> setVariable) {
			if (setVariable == null || setVariable.size() < 1) {
				return '\'\'';
			}
			
			String seperatedString = '';
			for(SObject o : setVariable){
				seperatedString += '\'' + o + '\'' + ',';
			}
			seperatedString = seperatedString.removeEnd(',');

			return seperatedString;
	}

	public static string ConvertListSetToString(List<String> listVariable) {
			if (listVariable == null || listVariable.size() < 1) {
				return '\'\'';
			}

			String seperatedString = '';
			for(Object o : listVariable){
				seperatedString += '\'' + o + '\'' + ',';
			}
			seperatedString = seperatedString.removeEnd(',');

			return seperatedString;
	}

	public static string ConvertListSetToString(Set<String> setVariable) {
			if (setVariable == null || setVariable.size() < 1) {
				return '\'\'';
			}
			
			String seperatedString = '';
			for(Object o : setVariable){
				seperatedString += '\'' + o + '\'' + ',';
			}
			seperatedString = seperatedString.removeEnd(',');

			return seperatedString;
	}

	public static string ConvertListSetToString(List<Id> listVariable) {
			if (listVariable == null || listVariable.size() < 1) {
				return '\'\'';
			}
			
			String seperatedString = '';
			for(Object o : listVariable){
				seperatedString += '\'' + o + '\'' + ',';
			}
			seperatedString = seperatedString.removeEnd(',');

			return seperatedString;
	}

	public static string ConvertListSetToString(Set<Id> setVariable) {
			if (setVariable == null || setVariable.size() < 1) {
				return '\'\'';
			}
			
			String seperatedString = '';
			for(Object o : setVariable){
				seperatedString += '\'' + o + '\'' + ',';
			}
			seperatedString = seperatedString.removeEnd(',');

			return seperatedString;
	}

	public static string ConvertListSetToString(List<Integer> listVariable) {
			if (listVariable == null || listVariable.size() < 1) {
				return '\'\'';
			}
			
			String seperatedString = '';
			for(Object o : listVariable){
				seperatedString += '\'' + o + '\'' + ',';
			}
			seperatedString = seperatedString.removeEnd(',');

			return seperatedString;
	}

	public static string ConvertListSetToString(Set<Integer> setVariable) {
			if (setVariable == null || setVariable.size() < 1) {
				return '\'\'';
			}
			
			String seperatedString = '';
			for(Object o : setVariable){
				seperatedString += '\'' + o + '\'' + ',';
			}
			seperatedString = seperatedString.removeEnd(',');

			return seperatedString;
	}
}