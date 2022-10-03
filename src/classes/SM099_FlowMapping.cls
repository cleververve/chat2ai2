/**
Author:         serhiivolynets
Date:           22.09.2022
Description:   
**/

public with sharing class SM099_FlowMapping
{

	public static String getFlow(String sIntent, String sText)
	{
		String sIntent2 = getIntentFromText(sText);
		if(sIntent2 != null)
		{
			return getFlowFromIntent(sIntent2);
		}
		else
		{
			return getFlowFromIntent(sIntent);
		}
	}

	static String startString = '{{!!';
	static String endString = '!!}}';

	public static String getIntentFromText(String sText)
	{
		String sRet;
		if(sText != null && sText.contains(startString) && sText.indexOf(startString)< sText.indexOf(endString)+startString.length())
		{
			sRet = sText.substring(sText.indexOf(startString)+startString.length(),sText.indexOf(endString));
		}
		return sRet;
	}


	static Map<String,String>mCache;
	public static Map<String,String> getIntentFlowMap()
	{
		if(mCache== null)
			mCache = initCache();
		return mCache;
	}
	static list<Flow_Mapping__mdt> getRecords()
	{
		list<Flow_Mapping__mdt> lRet = [SELECT DeveloperName,Label,Intent__c,Flow__c FROM Flow_Mapping__mdt];
		if(test.isRunningTest())
			lRet = (list<Flow_Mapping__mdt>)Json.deserialize('[{"attributes":{"type":"CVCH__Flow_Mapping__mdt"},"CVCH__Intent__c":"abc","CVCH__Flow__c":"flow1","Label":"Setting1","DeveloperName":"Setting1"},{"attributes":{"type":"CVCH__Flow_Mapping__mdt"},"CVCH__Intent__c":"def","CVCH__Flow__c":"flow2","Label":"Setting2","DeveloperName":"Setting2"}]', List<Flow_Mapping__mdt>.class);
		return lRet;
	}

	static Map<String,String> initCache()
	{
		Map<String,String>mRet = new Map<String,String>();
		List<Flow_Mapping__mdt> lFlowMappings = getRecords();
		for(Flow_Mapping__mdt rec:lFlowMappings)
		{
			mRet.put(rec.Intent__c,rec.Flow__c);
		}
		return mRet;
	}

	public static String getFlowFromIntent(String sIntent)
	{
		return getIntentFlowMap().get(sIntent);
	}
}
