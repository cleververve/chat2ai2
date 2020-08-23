/**
Author:         serhiivolynets
Date:           25.06.2020
Description:   
**/

public with sharing class SM080_LUIS
{
	public class LuisResponse
	{
		public string sIntent = '';
		public string sQuery = '';
		public decimal dScore = 0;
		public map<string,object> mParameters = new map<string,object>();
		public string getEntities()
		{
			return json.serialize(mParameters);
		}
	}
	public static LuisResponse queryPhrase(string sPhrase,string language)
	{
		LuisResponse ret = new LuisResponse();
		string sURLSetting = 'Luis';

		string sURL = SM010_Utils.getValue(sURLSetting);
		system.debug('luis url:('+sURLSetting+')'+sURL);

		HttpResponse resp = SM003_Http.request(
				sURL+'&query='+EncodingUtil.urlEncode(sPhrase, 'UTF-8')
				,
				'GET', NULL, '', 'LUIS QUERY', NULL, 'SM080_LUISMock');
		map<string, object>mObj = (map<string, object>) JSON.deserializeUntyped(resp.getBody());
		ret.sQuery = (string) mObj.get('query');
		map<string, object> mPred = (map<string, object>) mObj.get('prediction');
		ret.sIntent = (string) mPred.get('topIntent');
		map<string,object> mIntents = (map<string,object> )mPred.get('intents');
		if(!mIntents.isEmpty())
			ret.dScore = ((decimal)((map<string,object>)(mIntents.values()[0])).get('score'))*100;

		map<string, object>mEntities = (map<string, object>) mPred.get('entities');
		for (string sKey : mEntities.keySet())
		{
			if (sKey != '$instance')
			{
				system.debug(sKey);
				system.debug(mEntities.get(sKey));
				ret.mParameters.put(sKey, ((list<object>)mEntities.get(sKey))[0]);
			}
		}
		return ret;
	}
}
