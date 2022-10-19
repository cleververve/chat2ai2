/**
Author:         serhiivolynets
Date:           20.08.2021
Description:   
**/

global class SM093_LiveAgent
{
	public static String sessionRequired = 'Session required but was invalid';
	public static String X_LIVEAGENT_API_VERSION = '53';
	public static String sMockName = 'SM093_LiveAgentMock';
	global class InitSessionResponse
	{
		public String key;
		public String id;
		public Integer clientPollTimeout;
		public String affinityToken;
	}

	private static String getTextInner(Object o)
	{
		String sRet = null;
		try
		{
			Map<String, Object> mo = (Map<String, Object>) o;
			sRet = (String) mo.get('text');
			if (sRet != null)
			{
				return sRet;
			}
			for (String sKey : mo.keySet())
			{
				sRet = getTextInner(mo.get(sKey));
				if (sRet != null)
				{
					return sRet;
				}
			}
		}
		catch (Exception e)
		{
		}
		return sRet;
	}

	public static String getText(String sResp)
	{
		System.debug('SM093_LiveAgent.getText.start');

		System.debug(sResp);
		Object obj = JSON.deserializeUntyped(sResp);
		String sRet = (String)JPath.safeGet(obj,'/text/body');
		if(sRet != null && sRet != '')
			return sRet;
		sRet = (String)JPath.safeGet(obj,'/image/link');
		if(sRet != null && sRet != '')
			return sRet;
		sRet = (String)JPath.safeGet(obj,'/image/url');
		if(sRet != null && sRet != '')
			return sRet;

		return getTextInner(obj);
	}
	public static String getMessageText(NexmoMessage__c mess)
	{
		String sRet = mess.CVCH__Text__c;

		if (mess.ReplyToId__c != null && mess.ReplyToId__c != '')
		{
			List<CallOut__c> lCallOuts =
			[
					SELECT Request__c
					FROM CallOut__c
					WHERE ResponseId__c = :mess.ReplyToId__c
			];
			if (!lCallOuts.isEmpty())
			{
				CallOut__c call = lCallOuts[0];
				String sReplyToText = getText(call.Request__c);
				if (sReplyToText != null)
				{
					sRet = 'Replying to "' + sReplyToText + '"\n' + sRet;
				}
			}
		}

		return sRet;
	}

	global static InitSessionResponse initSession(String clientAffinity)
	{
		return initSession(clientAffinity, null);
	}

	global static InitSessionResponse initSession(String clientAffinity, String sChatNumber)
	{

		String sSettingName = 'Chat URL';
		if (SM010_Utils.getChat2aiValue2('Multi ChatBots') == 'TRUE')
		{
			sSettingName = sSettingName + '_' + sChatNumber;
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


	public static String getBody(String sessionId, String sVisitorName, String sDetails, String buttonId, String deploymentId)
	{
		String orgId = SM010_Utils.getChat2aiValue2('Org ID');
		if (deploymentId == null || deploymentId == '')
			deploymentId = SM010_Utils.getChat2aiValue2('Chat Deployment ID');
		if (buttonId == '' || buttonId == null)
			buttonId = SM010_Utils.getChat2aiValue2('Chat Button ID');
		return '{ "sessionId": "' + sessionId + '", "organizationId": "' + orgId + '", "deploymentId": "' + deploymentId + '", "buttonId": "' + buttonId + '", "userAgent": "", "language": "en-US", "screenResolution": "1900x1080", "visitorName": "' + sVisitorName + '", "prechatDetails": ' +
				sDetails
				+ ', "prechatEntities": [], "receiveQueueUpdates": true, "isPost": true }';
	}
	global static void ChasitorInit(String clientAffinity, String key, String sessionId, String sVisitorName, String sDetails)
	{
		ChasitorInit(clientAffinity, key, sessionId, sVisitorName, sDetails, '', '');
	}

	global static void ChasitorInit(String clientAffinity, String key, String sessionId, String sVisitorName)
	{
		ChasitorInit(clientAffinity, key, sessionId, sVisitorName, '[]', '', '');
	}
	global static void ChasitorInit(String clientAffinity, String key, String sessionId, String sVisitorName, String sDetails, String chatButtonId, String chatDeploymentId)
	{
		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Chat URL') + 'Chasitor/ChasitorInit',
				'POST',
				new Map<String, String>
				{
						'X-LIVEAGENT-API-VERSION' => X_LIVEAGENT_API_VERSION, 'X-LIVEAGENT-AFFINITY' => clientAffinity, 'X-LIVEAGENT-SESSION-KEY' => key, 'X-LIVEAGENT-SEQUENCE' => '1'
				},
				getBody(sessionId, sVisitorName, sDetails, chatButtonId, chatDeploymentId),
				'Salesforce Chat ChasitorInit',
				null,
				sMockName
		);
	}

	global static void ChatMessage(String sMessage, String clientAffinity, String key)
	{

	}
//	public static Boolean sessionExpired(Visitor__c vis)
//	{
//		Boolean bRet = null;
//		List<Object> lMessages;
//		try
//		{
//			lMessages = getMessages(vis);
//			if(lMessages != null)
//			{
//				bRet = false;
//				if(sessionIsEnded(lMessages) != null)
//				{
//					bRet = true;
//				}
//			}
//		}
//		catch (Exception e)
//		{
//		}
//		return bRet;
//	}
	global static void ChatMessage(String sMessage, Visitor__c vis)//String clientAffinity, String key, id visitorId)
	{
//		Boolean bExp;
		try
		{
//			bExp= sessionExpired(vis);
//
//
//		if (bExp == true)
//		{
//			throw new MyException(SM093_LiveAgent.sessionRequired);
//		}

			String sBody = JSON.serialize(new Map<String, Object>
			{
					'text' => sMessage
			});
			HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Chat URL') + 'Chasitor/ChatMessage',
					'POST',
					getHeaders(vis.Livechat_affinityToken__c, vis.Livechat_Session_Key__c),
					sBody,
					'Salesforce Chat ChatMessage',
					null,
					sMockName
			);
		}
		catch (Exception e)
		{
			throw e;
		}
		finally
		{
//			if (bExp != null)
//			{
//				Visitor__c v = new Visitor__c(Id = vis.Id, Livechat_Last_Poll_Time__c = Datetime.now());
//				update v;
//			}
		}
	}
	public static Map<String, String> getHeaders(String clientAffinity, String key)
	{
		return new Map<String, String>
		{
				'X-LIVEAGENT-API-VERSION' => X_LIVEAGENT_API_VERSION, 'X-LIVEAGENT-AFFINITY' => clientAffinity, 'X-LIVEAGENT-SESSION-KEY' => key
		};
	}

	public static Integer getPollTimeout()
	{
		Integer ret = 25;
		try
		{
			ret = Integer.valueOf(SM010_Utils.getChat2aiValue2('Liveagent Poll Timeout'));
		}
		catch (Exception e)
		{
		}
		return ret;
	}

	public static Boolean canPoll(Visitor__c v)
	{
		if (v.Livechat_Last_Poll_Time__c == null)
			return true;
		Datetime dt = v.Livechat_Last_Poll_Time__c;
		dt = dt.addSeconds(getPollTimeout());
		System.debug('dt:' + dt.format());
		System.debug('now:' + Datetime.now().format());
		if (Datetime.now() < dt)
			return false;
		return true;
	}

	public static HttpResponse makePollRequest(String sKey, String sToken)
	{
		HttpResponse resp = SM003_Http.request(SM010_Utils.getChat2aiValue('Chat URL') + 'System/Messages',
				'GET',
				getHeaders(sToken, sKey),
				null,
				'Salesforce Chat GetMessages',
				null,
				'SM093_LiveAgentGetMessagesMock'
		);
		return resp;
	}
//	public static List<Object> getMessages(Visitor__c vis)
//	{
//		System.debug('getMessages');
//
//		if(!canPoll(vis))
//			return null;
//		HttpResponse resp = makePollRequest(vis.Livechat_Session_Key__c,vis.Livechat_affinityToken__c);
//
//		Map <String, Object> mRet = (Map <String, Object>) JSON.deserializeUntyped(resp.getBody());
//		List<Object> lRet = (List<Object>) mRet.get('messages');
//		return lRet;
//	}
	public static String sessionIsEnded(List<Object>lObj)
	{
		String sRet = null;
		for (Object obj : lObj)
		{
			Map<String, Object> mRecord = (Map<String, Object>) obj;
			String sType = (String) mRecord.get('type');
			if (sType == 'ChatEnded')
			{
				sRet = sType;
				break;
			}
			if (sType == 'ChatRequestFail')
			{
				sRet = sType;
				break;
			}
		}
		return sRet;
	}

	global static Boolean isAvailable()
	{
		return isAvailable('', '');
	}

	global static Boolean isAvailable(String buttonId, String deploymentId)
	{
		String orgId = SM010_Utils.getChat2aiValue2('Org ID');
		if (deploymentId == '' || deploymentId == null)
			deploymentId = SM010_Utils.getChat2aiValue2('Chat Deployment ID');
		if (buttonId == '' || buttonId == null)
			buttonId = SM010_Utils.getChat2aiValue2('Chat Button ID');

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
