/**
Author:         serhiivolynets
Date:           31.08.2021
Description:   
**/

public with sharing class LiveChatMonitor
{
	@AuraEnabled
	public static void logAgentReply(String recordId, String content, String name, String type)
	{
		System.debug('logAgentReply:' + recordId);

		String sKey = getChatKey(recordId);
		List<CVCH__Visitor__c> lvisr =
		[
				SELECT Id,CVCH__Id__c,CVCH__Chat_Number__c,CVCH__Livechat_Session_Id__c
				from CVCH__Visitor__c
				where CVCH__Livechat_Session_Id__c = :sKey
		];
		if (!lvisr.isEmpty())
		{
			CVCH__Visitor__c vis = lvisr[0];
			CVCH.SM042_NexmoOut2.sendText(vis.CVCH__Id__c, content, vis.CVCH__Chat_Number__c, false);
		}
	}

	public static void Disconnect(CVCH__Visitor__c vis)
	{

		if(vis.CVCH__Livechat_Session_Key__c != null || vis.CVCH__Livechat_Session_Id__c != null || vis.CVCH__Livechat_affinityToken__c != null)
		{
			CVCH.SM042_NexmoOut2.sendText(vis.CVCH__Id__c, SM010_Utils.translate('The chat is disconnected',vis.CVCH__language__c), vis.CVCH__Chat_Number__c, false);


			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', vis.Id);
			params.put('Livechat_Session_Key', vis.CVCH__Livechat_Session_Key__c);
			params.put('Livechat_Session_Id',vis.CVCH__Livechat_Session_Id__c);
			params.put('Livechat_affinityToken',vis.CVCH__Livechat_affinityToken__c);


			CVCH__Visitor__c visr = new CVCH__Visitor__c();
			visr.Id = vis.Id;
			visr.CVCH__Livechat_Session_Key__c = null;
			visr.CVCH__Livechat_Session_Id__c = null;
			visr.CVCH__Livechat_affinityToken__c = null;
			update visr;
			String sFlow = SM010_Utils.getChat2aiValue2('Livechat Survey Flow');
			if (sFlow != '')
			{
				SM010_Utils.getFlow(sFlow,vis.Chat_Number__c, params).start();
			}
		}
	}

	@AuraEnabled
	public static void chatEnded(String recordId)
	{

		try
		{
			String sKey = getChatKey(recordId);

			List<CVCH__Visitor__c> lvisr =
			[
					SELECT Id, CVCH__Id__c,CVCH__Chat_Number__c,CVCH__language__c,CVCH__Livechat_affinityToken__c,CVCH__Livechat_Session_Id__c,CVCH__Livechat_Session_Key__c,Chat_Number__c
					from CVCH__Visitor__c
					where CVCH__Livechat_Session_Id__c = :sKey
			];

			if (!lvisr.isEmpty())
			{
				CVCH__Visitor__c vis = lvisr[0];
				Disconnect(vis);
				SM010_Utils.saveTran();
			}
		}catch(Exception e)
		{
			System.debug('Error: '+e.getMessage()+' '+e.getStackTraceString());
		}
	}
	public static String getChatKey(String recordId)
	{
		if (Test.isRunningTest())
			return recordId;
		List<SObject> lObj = Database.query('select id,ChatKey from LiveChatTranscript where id = :recordId');
		if(lObj.isEmpty())
			throw new MyException('Can not find the Chat with the key '+recordId);
		return (String) lObj[0].get('ChatKey');
//		return [
//				select id,ChatKey
//				from LiveChatTranscript
//				where id = :recordId
//		].ChatKey;
	}
}
