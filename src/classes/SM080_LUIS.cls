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
		string sURLSetting = 'Luis URL';
		//if(language != null && language != 'en' && language != '')
		//	sURLSetting = sURLSetting+'_'+language;
		string sURL = SM010_Utils.getChat2aiValue(sURLSetting);
		system.debug('luis url:('+sURLSetting+')'+sURL);

		HttpResponse resp = SM003_Http.request(
				sURL+'&query='+EncodingUtil.urlEncode(sPhrase, 'UTF-8')

//				'https://westus.api.cognitive.microsoft.com/luis/prediction/v3.0/apps/4ce5b4f3-2dad-4f40-a0b1-3437086ef112/slots/staging/predict?subscription-key=158d3123e3f340a29cc38e4bb72bff91&verbose=true&show-all-intents=true&log=true&query=would'
				,
				'GET', NULL, '', 'LUIS QUERY', NULL, 'SM080_LUISMock');
		map<string, object>mObj = (map<string, object>) JSON.deserializeUntyped(resp.getBody());
		ret.sQuery = (string) mObj.get('query');
		map<string, object> mPred = (map<string, object>) mObj.get('prediction');
		ret.sIntent = (string) mPred.get('topIntent');
		map<string,object> mIntents = (map<string,object> )mPred.get('intents');
		if(!mIntents.isEmpty())
		{
			ret.dScore = ((decimal)((map<string,object>)(mIntents.values()[0])).get('score'))*100;
		}

//		map<string, string> sEntities = new map<string, string>();
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