/**
Author:         serhiivolynets
Date:           20.08.2021
Description:   
**/

global class SM093_LiveAgent
{
	public static String X_LIVEAGENT_API_VERSION = '45';
	public static String sMockName = 'SM093_LiveAgentMock';
	global class InitSessionResponse
	{
		public String key;
		public String id;
		public Integer clientPollTimeout;
		public String affinityToken;
	}
	global static InitSessionResponse initSession(String clientAffinity)
	{
		return initSession(clientAffinity,null);
	}

	global static InitSessionResponse initSession(String clientAffinity,string sChatNumber)
	{

		string sSettingName = 'Chat URL';
		if(SM010_Utils.getChat2aiValue2('Multi ChatBots')=='TRUE')
		{
			sSettingName = sSettingName+'_'+sChatNumber;
		}
		HttpResponse resp = SM003_Http.request(
				SM010_Utils.getChat2aiValue(sSettingName) + 'System/SessionId',
				'GET',
				new Map<String, String>
				{
						'X-LIVEAGENT-API-VERSION' => X_LIVEAGENT_API_VERSION, 'X-LIVEAGENT-AFFINITY' => clientAffinity
				},
				null, 'Salesforce Chat SessionId',
				null,
				sMockName
		);
		Map<String, Object> mObj = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
		InitSessionResponse ret = new InitSessionResponse();
		ret.key = (String) mObj.get('key');
		ret.id = (String) mObj.get('id');
		ret.clientPollTimeout = (Integer) mObj.get('clientPollTimeout');
		ret.affinityToken = (String) mObj.get('affinityToken');
		return ret;
	}


	public static String getBody(String sessionId, String sVisitorName, string sDetails)
	{
		String orgId = SM010_Utils.getChat2aiValue2('Org ID');
		String deploymentId = SM010_Utils.getChat2aiValue2('Chat Deployment ID');
		String buttonId = SM010_Utils.getChat2aiValue2('Chat Button ID');
		return '{ "sessionId": "' + sessionId + '", "organizationId": "' + orgId + '", "deploymentId": "' + deploymentId + '", "buttonId": "' + buttonId + '", "userAgent": "", "language": "en-US", "screenResolution": "1900x1080", "visitorName": "' + sVisitorName + '", "prechatDetails": ' +
				sDetails
				+ ', "prechatEntities": [], "receiveQueueUpdates": true, "isPost": true }';
	}
	global static void ChasitorInit(String clientAffinity, String key, String sessionId, String sVisitorName)
	{
		ChasitorInit(clientAffinity, key, sessionId, sVisitorName, '[]');
	}
	global static void ChasitorInit(String clientAffinity, String key, String sessionId, String sVisitorName, string sDetails)
	{
		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Chat URL') + 'Chasitor/ChasitorInit',
				'POST',
				new Map<String, String>
				{
						'X-LIVEAGENT-API-VERSION' => X_LIVEAGENT_API_VERSION, 'X-LIVEAGENT-AFFINITY' => clientAffinity, 'X-LIVEAGENT-SESSION-KEY' => key, 'X-LIVEAGENT-SEQUENCE' => '1'
				},
				getBody(sessionId, sVisitorName, sDetails),
				'Salesforce Chat ChasitorInit',
				null,
				sMockName
		);
	}

	global static void ChatMessage(String sMessage, String clientAffinity, String key)
	{
		String sBody = JSON.serialize(new Map<String, Object>
		{
				'text' => sMessage
		});
		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Chat URL') + 'Chasitor/ChatMessage',
				'POST',
				new Map<String, String>
				{
						'X-LIVEAGENT-API-VERSION' => X_LIVEAGENT_API_VERSION, 'X-LIVEAGENT-AFFINITY' => clientAffinity, 'X-LIVEAGENT-SESSION-KEY' => key
				},
				sBody,
				'Salesforce Chat ChatMessage',
				null,
				sMockName
		);
	}

	global static Boolean isAvailable()
	{
		String orgId = SM010_Utils.getChat2aiValue2('Org ID');
		String deploymentId = SM010_Utils.getChat2aiValue2('Chat Deployment ID');
		String buttonId = SM010_Utils.getChat2aiValue2('Chat Button ID');

		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Chat URL') + 'Visitor/Availability?Availability.prefix=Visitor&Availability.ids=' + buttonId + '&deployment_id=' + deploymentId + '&org_id=' + orgId,
				'GET',
				new Map<String, String>
				{
						'X-LIVEAGENT-API-VERSION' => X_LIVEAGENT_API_VERSION
				},
				null,
				'Salesforce Chat Availability',
				null,
				sMockName
		);
		Object obj = JSON.deserializeUntyped(resp.getBody());
		Boolean bRet = (Boolean) JPath.get0(obj, 'messages/[1]/message/results/[1]/isAvailable');
		if (bRet != true)
			bRet = false;
		if (Test.isRunningTest())
			bRet = true;
		return bRet;
	}
}
