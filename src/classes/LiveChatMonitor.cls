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
		system.debug('logAgentReply:' + recordId);

		string sKey = getChatKey(recordId);
		list<CVCH__Visitor__c> lvisr =
		[
				SELECT id,CVCH__Id__c,CVCH__Chat_Number__c
				from CVCH__Visitor__c
				where CVCH__Livechat_Session_Id__c = :sKey
		];
		if (!lvisr.isEmpty())
		{
			CVCH__Visitor__c vis = lvisr[0];
			CVCH.SM042_NexmoOut2.sendText(vis.CVCH__Id__c, content, vis.CVCH__Chat_Number__c, false);
		}
	}

	@AuraEnabled
	public static void chatEnded(String recordId)
	{

		string sKey = getChatKey(recordId);

		list<CVCH__Visitor__c> lvisr =
		[
				SELECT id, CVCH__Id__c,CVCH__Chat_Number__c,CVCH__language__c
				from CVCH__Visitor__c
				where CVCH__Livechat_Session_Id__c = :sKey
		];
		if (!lvisr.isEmpty())
		{
			CVCH__Visitor__c vis = lvisr[0];
			CVCH.SM042_NexmoOut2.sendText(vis.CVCH__Id__c, SM010_Utils.translate('The chat is disconnected',vis.CVCH__language__c), vis.CVCH__Chat_Number__c, false);
			vis.CVCH__Livechat_Session_Key__c = null;
			vis.CVCH__Livechat_Session_Id__c = null;
			vis.CVCH__Livechat_affinityToken__c = null;
			update vis;
			SM010_Utils.saveTran();
		}
	}
	public static string getChatKey(string recordId)
	{
		if (Test.isRunningTest())
			return recordId;
		return [
				select id,ChatKey
				from LiveChatTranscript
				where id = :recordId
		].ChatKey;
	}
}
