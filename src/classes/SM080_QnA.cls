/**
Author:         serhiivolynets
Date:           08.07.2020
Description:   
**/

global class SM080_QnA
{
	global class QnAPrompt
	{
		public integer displayOrder = 0;
		public integer qnaId = 0;
		public string displayText = '';

	}
	global class QnAResponse
	{
		public string sAnswer = '';
		public string sQuery = '';
		public decimal dScore = 0;
		public list<QnAPrompt> prompts = new list<QnAPrompt>();
	}
	public static map<string, string> getHeaders()
	{
		CVCH__Chat2ai__c oAuth = CVCH__Chat2ai__c.getInstance('QnA Authorization');
		string sAuth = 'EndpointKey 62b515e5-9377-4b3b-8d94-c236a49eeda9';
		if(oAuth != null)
			sAuth = oAuth.Value__c;
		map<string, string> ret = new map<string, string>();
		ret.put('Content-Type', 'application/json');
		ret.put('Authorization', sAuth);
		return ret;
	}
	public static string getBody(string sPhrase, integer qnaid)
	{
		map<string, object> mResp = new map<string, object>();
		if (qnaid != null)
			mResp.put('qnaId', qnaid);
		else
				mResp.put('question', sPhrase);
		return JSON.serialize(mResp);
	}
	global static QnAResponse queryPhrase(string sPhrase,string language)
	{
		return queryPhrase(sPhrase, null,language,null);
	}
	global static QnAResponse queryPhrase(string sPhrase,string language, string sChatNumber)
	{
		return queryPhrase(sPhrase, null,language,sChatNumber);
	}

	public static QnAResponse getQNA(integer  qnaid, string language, string sChatNumber)
	{
		return queryPhrase(null, qnaid, language,sChatNumber);
	}

	public static QnAResponse getQNA(integer  qnaid, string language)
	{
		return queryPhrase(null, qnaid, language,null);
	}


	global static QnAResponse queryPhrase(string sPhrase, integer qnaid, string language)
	{
		return queryPhrase(sPhrase,  qnaid,  language, null);
	}
	global static QnAResponse queryPhrase(string sPhrase, integer qnaid, string language, string sChatNumber)
	{
		QnAResponse ret = new QnAResponse();
		ret.dScore =0;
		string sURL = 'callout:QnA';
		if(SM010_Utils.getChat2aiValue2('Multi ChatBots')=='TRUE')
			sURL = sURL +'_'+sChatNumber;
		system.debug('qna url='+sURL);
		HttpResponse resp = SM003_Http.request(
				sURL
				,
				'POST', getHeaders(), getBody(sPhrase,qnaid), 'QnA QUERY', NULL, 'SM080_QnAMock');
		map<string, object>mObj = (map<string, object>) JSON.deserializeUntyped(resp.getBody());
		ret.sQuery = sPhrase;
		list<object>lAns = (list<object>) mObj.get('answers');
		if (!lAns.isEmpty())
		{
			map<string, object> mAns = (map<string, object>) lAns[0];
			ret.sAnswer = (string) mAns.get('answer');
			ret.dScore = (decimal) mAns.get('score');
			map<string, object> mCont = (map<string, object>) mAns.get('context');
			if(mCont != null && mCont.get('prompts') != null)
			{
				list<object> lPrompts = (list<object>) mCont.get('prompts');
				for (object oPrompt : lPrompts)
				{
					map<string, object>mPrompt = (map<string, object>) oPrompt;
					QnAPrompt pr = new QnAPrompt();
					pr.displayText = (string) mPrompt.get('displayText');
					pr.qnaId = (integer) mPrompt.get('qnaId');
					pr.displayOrder = (integer) mPrompt.get('displayOrder');
					ret.prompts.add(pr);
				}
			}
		}
		return ret;
	}
}
