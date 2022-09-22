/**
Author:         serhiivolynets
Date:           28.07.2022
Description:   
**/

public class SM097_GoogleSheetsProdExportBatch 	implements Database.Batchable<SObject>,Database.AllowsCallouts
{
	static String sFieldSetName = 'CVCH__Google_Sheets_Columns';
	public Iterable<SObject> start(Database.BatchableContext param1)
	{
		String sQuery = 'SELECT Id from Product2 where CVCH__Google_Sheets_Synch_Required__c = true';

		return Database.getQueryLocator(sQuery);
	}

	public void execute(Database.BatchableContext param1, List<SObject> lObjects)
	{

		Set<Id> sProdIds = new set<id>();
		for(sobject obj : lObjects)
		{
			sProdIds.add((Id)obj.get('Id'));
		}
		syncProducts(sProdIds);
	}

	public void finish(Database.BatchableContext param1)
	{
	}

	public static Set<String> getFieldSetFields(FieldSet fs)
	{
		if (fs == null)
			return null;

		Set<String>sFSFieldNames = null;
		if (fs != null)
		{
			sFSFieldNames = new Set<String>();
			for (Schema.FieldSetMember mem : fs.getFields())
			{
				sFSFieldNames.add(mem.getFieldPath());
			}
		}
		return sFSFieldNames;
	}

	public static List<Product2> getProductRecords(Set<Id> sProductIds,List<String> lFields)
	{
		List<Product2> lProd = new List<Product2>();
		if(!lFields.contains('Id'))
			lFields.add('Id');
		String sQuery = 'SELECT '+String.join(lFields, ',')+' from Product2 where Id in :sProductIds';
		List<SObject> lObject = Database.query(sQuery);
		for(SObject obj : lObject)
		{
			lProd.add((Product2)obj);
		}
		return lProd;
	}

	public static void syncProducts(Set<Id> sProductIds)
	{
		FieldSet fsFields = Schema.getGlobalDescribe().get('Product2').getDescribe().fieldSets.getMap().get(sFieldSetName);
		List<String>lFields = new List<String>(getFieldSetFields(fsFields));
		List<Product2> lProd = getProductRecords(sProductIds,lFields);
		SM097_GoogleSheet.callAppendProducts(lProd,lFields);
	}
}
