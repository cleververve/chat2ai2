/**
Author:         serhiivolynets
Date:           25.06.2020
Description:   
**/

public with sharing class SM080_LUIS
{
	public class LuisResponse
	{
		public String sIntent = '';
		public String sQuery = '';
		public Decimal dScore = 0;
		public Map<String,Object> mParameters = new Map<String,Object>();
		public String getEntities()
		{
			return JSON.serialize(mParameters);
		}
	}
	public static LuisResponse queryPhrase(String sPhrase,String language,String sChatNumber)
	{
		LuisResponse ret = new LuisResponse();
		ret.dScore=0;
		if (Test.isRunningTest())
		{
			ret.dScore = 90;
		}
		String sURLSetting = 'Luis URL';
		if (SM010_Utils.getChat2aiValue2('Multi ChatBots') == 'TRUE')
		{
			sURLSetting = sURLSetting + '_' + sChatNumber;
		}
		//if(language != null && language != 'en' && language != '')
		//	sURLSetting = sURLSetting+'_'+language;
		String sURL = SM010_Utils.getChat2aiValue2(sURLSetting);
		if(sURL !='' || Test.isRunningTest())
		{
			System.debug('luis url:('+sURLSetting+')'+sURL);

			HttpResponse resp = SM003_Http.request(
					sURL+'&query='+EncodingUtil.urlEncode(sPhrase, 'UTF-8'),
					'GET', NULL, '', 'LUIS QUERY', NULL, 'SM080_LUISMock');
			Map<String, Object>mObj = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
			ret.sQuery = (String) mObj.get('query');
			Map<String, Object> mPred = (Map<String, Object>) mObj.get('prediction');
			ret.sIntent = (String) mPred.get('topIntent');
			Map<String,Object> mIntents = (Map<String,Object> )mPred.get('intents');
			if(!mIntents.isEmpty())
			{
				ret.dScore = ((Decimal)((Map<String,Object>)(mIntents.values()[0])).get('score'))*100;
			}

			Map<String, Object>mEntities = (Map<String, Object>) mPred.get('entities');
			for (String sKey : mEntities.keySet())
			{
				if (sKey != '$instance')
				{
					System.debug(sKey);
					System.debug(mEntities.get(sKey));
					ret.mParameters.put(sKey, ((List<Object>)mEntities.get(sKey))[0]);
				}
			}
		}
		return ret;
	}
}
