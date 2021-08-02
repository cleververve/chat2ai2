/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowUtils2
{
		@AuraEnabled @InvocableVariable global String sEntityName;
		@AuraEnabled @InvocableVariable global String sEntities;
	@InvocableMethod(label='Get Entity String' description='returns Entity Value from the json string of map of entities')
	global static list<string> getEntityString(list<FlowUtils2> lParam)
	{
		list<string>lret = new list<string>();
		for(FlowUtils2 param: lParam)
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

	public static object getEntity(FlowUtils2 param)
	{

		map<string, object> mObj = (map<string, object>) json.deserializeUntyped(param.sEntities);
		return mobj.get(param.sEntityName);
	}
}