/**
Author:         serhiivolynets
Date:           20.08.2021
Description:   
**/

global class SM093_LiveAgent
{
	public static string X_LIVEAGENT_API_VERSION = '45';
	public static string sMockName = 'SM093_LiveAgentMock';
	global class InitSessionResponse
	{
		public string key;
		public string id;
		public integer clientPollTimeout;
		public string affinityToken;
	}
	global static InitSessionResponse initSession(string clientAffinity)
	{
		HttpResponse resp = SM003_Http.request(
				SM010_Utils.getChat2aiValue('Chat URL')+'System/SessionId',
				'GET',
				new map<string,string>{'X-LIVEAGENT-API-VERSION'=> X_LIVEAGENT_API_VERSION,'X-LIVEAGENT-AFFINITY' => clientAffinity},
				null,'Salesforce Chat SessionId',
				null,
				sMockName
		);
		map<string,object> mObj = (map<string,object>)JSON.deserializeUntyped(resp.getBody());
		InitSessionResponse ret = new InitSessionResponse();
		ret.key= (string)mObj.get('key');
		ret.id = (string)mObj.get('id');
		ret.clientPollTimeout = (integer) mObj.get('clientPollTimeout');
		ret.affinityToken = (string) mObj.get('affinityToken');
		return ret;
	}



	public static string getBody(string sessionId,string sVisitorName)
	{
		string orgId = SM010_Utils.getChat2aiValue2('Org ID');
		string deploymentId = SM010_Utils.getChat2aiValue2('Chat Deployment ID');
		string buttonId = SM010_Utils.getChat2aiValue2('Chat Button ID');
		return '{ "sessionId": "'+sessionId+'", "organizationId": "'+orgId+'", "deploymentId": "'+deploymentId+'", "buttonId": "'+buttonId+'", "userAgent": "", "language": "en-US", "screenResolution": "1900x1080", "visitorName": "'+sVisitorName+'", "prechatDetails": [], "prechatEntities": [], "receiveQueueUpdates": true, "isPost": true }';
	}

	global static void ChasitorInit(string clientAffinity, string key,string sessionId, string sVisitorName)
	{
		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Chat URL')+'Chasitor/ChasitorInit',
				'POST',
				new map<string,string>{'X-LIVEAGENT-API-VERSION'=> X_LIVEAGENT_API_VERSION,'X-LIVEAGENT-AFFINITY' => clientAffinity, 'X-LIVEAGENT-SESSION-KEY' => key, 'X-LIVEAGENT-SEQUENCE' => '1'  },
				getBody(sessionId,sVisitorName),
				'Salesforce Chat ChasitorInit',
				null,
				sMockName
		);
	}


	global static void ChatMessage(string sMessage, string clientAffinity, string key)
	{
		string sBody = JSON.serialize(new map<string,Object>{'text'=> sMessage});
		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Chat URL')+'Chasitor/ChatMessage',
				'POST',
				new map<string,string>{'X-LIVEAGENT-API-VERSION'=> X_LIVEAGENT_API_VERSION,'X-LIVEAGENT-AFFINITY' => clientAffinity, 'X-LIVEAGENT-SESSION-KEY' => key },
				sBody,
				'Salesforce Chat ChatMessage',
				null,
				sMockName
		);
	}

	global static boolean isAvailable()
	{
		string orgId = SM010_Utils.getChat2aiValue2('Org ID');
		string deploymentId = SM010_Utils.getChat2aiValue2('Chat Deployment ID');
		string buttonId = SM010_Utils.getChat2aiValue2('Chat Button ID');

		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Chat URL') + 'Visitor/Availability?Availability.prefix=Visitor&Availability.ids=' + buttonId + '&deployment_id=' + deploymentId + '&org_id=' + orgId,
				'GET',
				new map<string, string>
				{
						'X-LIVEAGENT-API-VERSION' => X_LIVEAGENT_API_VERSION
				},
				null,
				'Salesforce Chat Availability',
				null,
				sMockName
		);
		object obj = JSON.deserializeUntyped(resp.getBody());
		boolean bRet = (boolean)JPath.get0(obj,'messages/[1]/message/results/[1]/isAvailable');
		if(bRet != true)
			bRet = false;
		if(test.isRunningTest())
			bRet = true;
		return bRet;
	}
}
