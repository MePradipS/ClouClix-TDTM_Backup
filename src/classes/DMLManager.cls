public with sharing class DMLManager {

	public static void UpsertSObject(sObject obj) {
		DescribeSObjectResult describe = DescribeObject(obj);
		if (describe.isCreateable() && describe.isUpdateable()) {
			upsert obj;
		} else {
			throw new PermissionException('Invalid permissions to upsert object');
		}
	}

	public static void UpsertSObjects(List<sObject> objs) {
		if (Utilities.IsListValid(objs)) {
			DescribeSObjectResult describe = DescribeObject(objs[0]);
			if (describe.isCreateable() && describe.isUpdateable()) {
				upsert objs;
			} else {
				throw new PermissionException('Invalid permissions to upsert objects');
			}
		}
	}

	public static Database.SaveResult InsertSObject(sObject obj) {
		DescribeSObjectResult describe = DescribeObject(obj);
		if (!describe.isCreateable()) {
			throw new PermissionException('Invalid permissions to insert object');
		}

		Database.SaveResult result = Database.insert(obj, true);
		return result;
	}

	public static Database.SaveResult[] InsertSObjects(List<sObject> objs) {
		if (!Utilities.IsListValid(objs)) {
			throw new InvalidListException('list passed was null or contained no values');
		}

		DescribeSObjectResult describe = DescribeObject(objs[0]);
		if (!describe.isCreateable()) {
			throw new PermissionException('Invalid permissions to insert objects');
		}

		Database.SaveResult[] results = Database.insert(objs, true);
		return results;
	}

	public static Database.SaveResult[] InsertSObjects(List<sObject> objs, Boolean arrayAllOrNoneParam) {
		if (!Utilities.IsListValid(objs)) {
			throw new InvalidListException('list passed was null or contained no values');
		}

		DescribeSObjectResult describe = DescribeObject(objs[0]);
		if (!describe.isCreateable()) {
			throw new PermissionException('Invalid permissions to insert objects');
		}

		Database.SaveResult[] results = Database.insert(objs, arrayAllOrNoneParam);
		return results;
	}

	public static Database.SaveResult UpdateSObject(sObject obj) {
		DescribeSObjectResult describe = DescribeObject(obj);
		if (!describe.isUpdateable()) {
			throw new PermissionException('Invalid permissions to update object');
		}

		Database.SaveResult result = Database.update(obj, true);
		return result;
	}

	public static Database.SaveResult[] UpdateSObjects(List<sObject> objs) {
		if (!Utilities.IsListValid(objs)) {
			throw new InvalidListException('list passed was null or contained no values');
		}

		DescribeSObjectResult describe = DescribeObject(objs[0]);
		if (!describe.isUpdateable()) {
			throw new PermissionException('Invalid permissions to update objects');
		}

		Database.SaveResult[] results = Database.update(objs, true);
		return results;
	}

	public static Database.SaveResult[] UpdateSObjects(List<sObject> objs, Boolean arrayAllOrNoneParam) {
		if (!Utilities.IsListValid(objs)) {
			throw new InvalidListException('list passed was null or contained no values');
		}

		DescribeSObjectResult describe = DescribeObject(objs[0]);
		if (!describe.isUpdateable()) {
			throw new PermissionException('Invalid permissions to update objects');
		}

		Database.SaveResult[] results = Database.update(objs, arrayAllOrNoneParam);
		return results;
	}

	public static Database.DeleteResult DeleteSObject(sObject obj) {
		DescribeSObjectResult describe = DescribeObject(obj);
		if (!describe.isDeletable()) {
			throw new PermissionException('Invalid permissions to delete object');
		}

		Database.DeleteResult result = Database.delete(obj, true);
		return result;
	}

	public static Database.DeleteResult[] DeleteSObjects(List<sObject> objs) {
		if (!Utilities.IsListValid(objs)) {
			throw new InvalidListException('list passed was null or contained no values');
		}

		DescribeSObjectResult describe = DescribeObject(objs[0]);
		if (!describe.isDeletable()) {
			throw new PermissionException('Invalid permissions to delete objects');
		} 

		Database.DeleteResult[] results = Database.delete(objs, true);
		return results;
	}

	public static Database.DeleteResult[] DeleteSObjects(List<sObject> objs, Boolean arrayAllOrNoneParam) {
		if (!Utilities.IsListValid(objs)) {
			throw new InvalidListException('list passed was null or contained no values');
		}

		DescribeSObjectResult describe = DescribeObject(objs[0]);
		if (!describe.isDeletable()) {
			throw new PermissionException('Invalid permissions to delete objects');
		} 

		Database.DeleteResult[] results = Database.delete(objs, arrayAllOrNoneParam);
		return results;
	}

	public static void DeleteIds(List<Id> ids) {
		if (ids != null && ids.size() > 0) {
			DescribeSObjectResult describe = DescribeObject(ids[0]);
			if (describe.isDeletable()) {
				Database.DeleteResult[] lsr = Database.delete(ids, true); 
			} else {
				throw new PermissionException('Invalid permissions to delete objects');
			}
		}
	}

	public static void DeleteIds(List<Id> ids, Boolean arrayAllOrNoneParam) {
		if (ids != null && ids.size() > 0) {
			DescribeSObjectResult describe = DescribeObject(ids[0]);
			if (describe.isDeletable()) {
				Database.DeleteResult[] lsr = Database.delete(ids, arrayAllOrNoneParam); 
			} else {
				throw new PermissionException('Invalid permissions to delete objects');
			}
		}
	}

	private static DescribeSObjectResult DescribeObject(sObject obj) {
		return obj.getSObjectType().getDescribe();
	}

	private static DescribeSObjectResult DescribeObject(Id id) {
		return id.getSObjectType().getDescribe();
	}

	public with sharing class PermissionException extends Exception {}
	public with sharing class InvalidListException extends Exception {}
}