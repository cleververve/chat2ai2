/**
Author:         serhiivolynets
Date:           08.07.2020
Description:   
**/

global class SM080_QnA
{
	global class QnAPrompt
	{
		public Integer displayOrder = 0;
		public Integer qnaId = 0;
		public String displayText = '';

	}
	global class QnAResponse
	{
		public String sAnswer = '';
		public String sQuery = '';
		public Decimal dScore = 0;
		public List<QnAPrompt> prompts = new List<QnAPrompt>();
	}
	public static Map<String, String> getHeaders(String sChatNumber)
	{
		String sSettingName = 'QnA Authorization';
		if(SM010_Utils.getChat2aiValue2('Multi ChatBots')=='TRUE')
			sSettingName = sSettingName+'_'+sChatNumber;

		CVCH__Chat2ai__c oAuth = CVCH__Chat2ai__c.getInstance(sSettingName);
		String sAuth = 'EndpointKey 62b515e5-9377-4b3b-8d94-c236a49eeda9';
		if(oAuth != null)
			sAuth = oAuth.Value__c;
		else if(!Test.isRunningTest())
				throw new MyException('Can not find '+sSettingName+' chat2ai custom setting');
		Map<String, String> ret = new Map<String, String>();
		ret.put('Content-Type', 'application/json');
		ret.put('Authorization', sAuth);
		return ret;
	}
	public static String getBody(String sPhrase, Integer qnaid)
	{
		Map<String, Object> mResp = new Map<String, Object>();
		if (qnaid != null)
			mResp.put('qnaId', qnaid);
		else
				mResp.put('question', sPhrase);
		return JSON.serialize(mResp);
	}
	global static QnAResponse queryPhrase(String sPhrase,String language)
	{
		return queryPhrase(sPhrase, null,language,null);
	}
	global static QnAResponse queryPhrase(String sPhrase,String language, String sChatNumber)
	{
		return queryPhrase(sPhrase, null,language,sChatNumber);
	}

	public static QnAResponse getQNA(Integer  qnaid, String language, String sChatNumber)
	{
		return queryPhrase(null, qnaid, language,sChatNumber);
	}

	public static QnAResponse getQNA(Integer  qnaid, String language)
	{
		return queryPhrase(null, qnaid, language,null);
	}


	global static QnAResponse queryPhrase(String sPhrase, Integer qnaid, String language)
	{
		return queryPhrase(sPhrase,  qnaid,  language, null);
	}
	global static QnAResponse queryPhrase(String sPhrase, Integer qnaid, String language, String sChatNumber)
	{
		QnAResponse ret = new QnAResponse();
		ret.dScore =0;
		String sURL = 'callout:QnA';
		if(SM010_Utils.getChat2aiValue2('Multi ChatBots')=='TRUE')
			sURL = sURL +'_'+sChatNumber;
		System.debug('qna url='+sURL);
		HttpResponse resp = SM003_Http.request(
				sURL
				,
				'POST', getHeaders(sChatNumber), getBody(sPhrase,qnaid), 'QnA QUERY', NULL, 'SM080_QnAMock');
		Map<String, Object>mObj = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
		ret.sQuery = sPhrase;
		List<Object>lAns = (List<Object>) mObj.get('answers');
		if (!lAns.isEmpty())
		{
			Map<String, Object> mAns = (Map<String, Object>) lAns[0];
			ret.sAnswer = (String) mAns.get('answer');
			ret.dScore = (Decimal) mAns.get('score');
			Map<String, Object> mCont = (Map<String, Object>) mAns.get('context');
			if(mCont != null && mCont.get('prompts') != null)
			{
				List<Object> lPrompts = (List<Object>) mCont.get('prompts');
				for (Object oPrompt : lPrompts)
				{
					Map<String, Object>mPrompt = (Map<String, Object>) oPrompt;
					QnAPrompt pr = new QnAPrompt();
					pr.displayText = (String) mPrompt.get('displayText');
					pr.qnaId = (Integer) mPrompt.get('qnaId');
					pr.displayOrder = (Integer) mPrompt.get('displayOrder');
					ret.prompts.add(pr);
				}
			}
		}
		return ret;
	}
}
