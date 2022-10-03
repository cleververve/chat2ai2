/**
Author:         serhiivolynets
Date:           28.09.2022
Description:   
**/

public with sharing class SM080_Learn
{

//	public class LearnResponse
//	{
//		public String sIntent = '';
//		public String sQuery = '';
//		public Decimal dScore = 0;
//		public Map<String, Object> mParameters = new Map<String, Object>();
//		public String getEntities()
//		{
//			return JSON.serialize(mParameters);
//		}
//	}

	public static map<string,string>getHeaders(String sChatNumber)
	{
		map<string,string> mRet = new map<string,string>();
		mRet.put('Ocp-Apim-Subscription-Key',SM010_Utils.getChat2aiValue('Ocp-Apim-Subscription-Key',sChatNumber));
		mRet.put('Apim-Request-Id',SM010_Utils.getChat2aiValue('Apim-Request-Id',sChatNumber));
		mRet.put('Content-Type','application/json');
		system.debug(mRet);
		return mRet;
	}
	public static String getBody(String sQueryText, String sChatNumber)
	{
		return getBody(sQueryText,
				SM010_Utils.getChat2aiValue('Learn_ProjectName',sChatNumber),
				SM010_Utils.getChat2aiValue('Learn_DeploymentName',sChatNumber),
				SM010_Utils.getChat2aiValue('Learn_StringIndexType',sChatNumber)
		);
	}

	public static String getBody(String sQueryText, String projectName, String deploymentName, String stringIndexType)
	{
		Map<String, Object> mRet = new Map<String, Object>
		{
				'kind' => 'Conversation',
				'analysisInput' => new Map<String, Object>
				{
						'conversationItem' => new Map<String, Object>
						{
								'id' => '1',
								'participantId' => '1',
								'text' => sQueryText
						}
				},
				'parameters' => new Map<String, Object>
				{
						'projectName' => projectName,
						'deploymentName' => deploymentName,
						'stringIndexType' => stringIndexType
				}
		};
		return JSON.serialize(mRet);
	}

	public static SM080_LUIS.LuisResponse queryPhrase(String sPhrase, String sChatNumber)
	{
		SM080_LUIS.LuisResponse ret;

		String sURL = SM010_Utils.getChat2aiValue('Learn URL', sChatNumber);
		if (sURL != '' || Test.isRunningTest())
		{
			ret = new SM080_LUIS.LuisResponse();
			ret.dScore = 0;
			if (Test.isRunningTest())
			{
				ret.dScore = 90;
			}
			System.debug('learn url:' + sURL);

			HttpResponse resp = SM003_Http.request(sURL ,
					'POST', getHeaders(sChatNumber), getBody(sPhrase,sChatNumber),  'Learn QUERY', null, 'SM080_LearnMock');
			Map<String, Object>mObj = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
			ret.sQuery = (String) JPath.get0(mObj,'/result/query');
			Map<String, Object> mPred = (Map<String, Object>) JPath.get0(mObj,'/result/prediction');
			system.debug(mPred);
			ret.sIntent = (String) mPred.get('topIntent');
			list<Object> mIntents = (list<Object>) mPred.get('intents');
			if (!mIntents.isEmpty())
			{
				ret.dScore = ((Decimal) ((Map<String, Object>) (mIntents[0])).get('confidenceScore')) * 100;
			}

			list<Object>mEntities = (list<Object>) mPred.get('entities');
			for (Object obj :mEntities)
			{
				String category = (String) ((map<string,object>) obj).get('category');
				String text = (String) ((map<string,object>)obj).get('text');

				if (category != null)
				{
					ret.mParameters.put(category, text);
				}
			}
		}
		return ret;
	}
}

