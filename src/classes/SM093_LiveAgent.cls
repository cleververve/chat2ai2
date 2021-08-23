/**
Author:         serhiivolynets
Date:           20.08.2021
Description:   
**/

public class SM093_LiveAgent
{
	public static string X_LIVEAGENT_API_VERSION = '45';
	public class InitSessionResponse
	{
		public string key;
		public string id;
		public integer clientPollTimeout;
		public string affinityToken;
	}
	public static InitSessionResponse initSession(string clientAffinity)
	{
		HttpResponse resp = SM003_Http.request(
				SM010_Utils.getChat2aiValue('Salesforce Chat URL')+'System/SessionId',
				'GET',
				new map<string,string>{'X-LIVEAGENT-API-VERSION'=> X_LIVEAGENT_API_VERSION,'X-LIVEAGENT-AFFINITY' => clientAffinity},
				null,'Salesforce Chat SessionId',
				null
		);
		map<string,object> mObj = (map<string,object>)JSON.deserializeUntyped(resp.getBody());
		InitSessionResponse ret = new InitSessionResponse();
		ret.key= (string)mObj.get('key');
		ret.id = (string)mObj.get('id');
		ret.clientPollTimeout = (integer) mObj.get('clientPollTimeout');
		ret.affinityToken = (string) mObj.get('affinityToken');
		return ret;
	}



	public static void ChasitorInit(string clientAffinity, string key)
	{
		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Salesforce Chat URL')+'Chasitor/ChatMessage',
				'POST',
				new map<string,string>{'X-LIVEAGENT-API-VERSION'=> X_LIVEAGENT_API_VERSION,'X-LIVEAGENT-AFFINITY' => clientAffinity, 'X-LIVEAGENT-SESSION-KEY' => key, 'X-LIVEAGENT-SEQUENCE' => '1'  },
				null,
				'Salesforce Chat ChasitorInit',
				null
		);
	}

	public static void ChatMessage(string sMessage, string clientAffinity, string key)
	{
		string sBody = JSON.serialize(new map<string,Object>{'text'=> sMessage});
		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Salesforce Chat URL')+'Chasitor/ChatMessage',
				'POST',
				new map<string,string>{'X-LIVEAGENT-API-VERSION'=> X_LIVEAGENT_API_VERSION,'X-LIVEAGENT-AFFINITY' => clientAffinity, 'X-LIVEAGENT-SESSION-KEY' => key },
				sBody,
				'Salesforce Chat ChatMessage',
				null
		);
	}
}
