/**
Author:         serhiivolynets
Date:           18.07.2020
Description:   
**/

global class FlowUtils
{
    global class getEntityParam
	{
		@AuraEnabled @InvocableVariable global String sEntityName;
		@AuraEnabled @InvocableVariable global String sEntities;
	}
	@InvocableMethod(label='Get Entity String' description='returns Entity Value from the json string of map of entities')
	global static list<string> getEntityString(list<getEntityParam> lParam)
	{
		list<string>lret = new list<string>();
		for(getEntityParam param: lParam)
		{
			string sRet = '';
			object obj = getEntity(param);
			try
			{
				map<string,object> mObj = (map<string,object>) obj;
				sRet = ''+mObj.get('value');
			}catch(Exception e)
			{
				sRet = ''+obj;
			}
			lret.add(sRet);

		}
		return lret;
	}

	
	public static object getEntity(getEntityParam param)
	{

		map<string, object> mObj = (map<string, object>) json.deserializeUntyped(param.sEntities);
		return mobj.get(param.sEntityName);
	}
	
}
