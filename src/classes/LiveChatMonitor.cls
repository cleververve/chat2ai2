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
		try
		{
			String sKey = getChatKey(recordId);
			List<CVCH__Visitor__c> lvisr = DM080_Visitor.getRecordsbySessionId(sKey);
			if (!lvisr.isEmpty())
			{
				CVCH__Visitor__c vis = lvisr[0];
				SM010_Utils.setVisitor(vis);
				if (content != null && !content.contains(' '))
				{
					if (content.endsWith('.jpeg') || content.endsWith('.jpg') || content.endsWith('.png'))
					{
						MessageOptions mo = new MessageOptions();
						CarouselItem item = new CarouselItem();
						item.imageURL = content;
						mo.lItems.add(item);
						mo.sType = 'Carousel';
						mo.visitorId = vis.Id;
						SM042_NexmoOut2.sendComplexType(mo, vis.CVCH__Id__c, vis.CVCH__Chat_Number__c);
					}
					else if (content.endsWith('.pdf'))
					{
						MessageOptions mo = new MessageOptions();
						CarouselItem item = new CarouselItem();
						item.videoURL = content;
						item.contentType = 'file';
						mo.lItems.add(item);
						mo.sType = 'Carousel';
						mo.visitorId = vis.Id;
						SM042_NexmoOut2.sendComplexType(mo, vis.CVCH__Id__c, vis.CVCH__Chat_Number__c);
					}
					else if (content.endsWith('.mp4'))
					{
						MessageOptions mo = new MessageOptions();
						CarouselItem item = new CarouselItem();
						item.videoURL = content;
						mo.lItems.add(item);
						mo.sType = 'Carousel';
						mo.visitorId = vis.Id;
						SM042_NexmoOut2.sendComplexType(mo, vis.CVCH__Id__c, vis.CVCH__Chat_Number__c);
					}
					else
					{
						CVCH.SM042_NexmoOut2.sendText(vis.CVCH__Id__c, content, vis.CVCH__Chat_Number__c, false);
					}

				}
				else
				{
					CVCH.SM042_NexmoOut2.sendText(vis.CVCH__Id__c, content, vis.CVCH__Chat_Number__c, false);
				}

				Visitor__c vis2 = new Visitor__c(Id = vis.Id, Livechat_Agent_Responded_Time__c = Datetime.now());
				update vis2;
				CVCH.SM005_Logs.save();
			}
		}
		catch (Exception e)
		{
			throw new MyException(e.getMessage() + ' ' + e.getStackTraceString());
		}
	}

	public static void Disconnect(CVCH__Visitor__c vis)
	{
		if (SM042_NexmoOut2.inboundMess != null && SM042_NexmoOut2.inboundMess.From__c != null)
			vis.Chat_Number__c = SM042_NexmoOut2.inboundMess.To__c;

		if (vis.CVCH__Livechat_Session_Key__c != null || vis.CVCH__Livechat_Session_Id__c != null || vis.CVCH__Livechat_affinityToken__c != null)
		{

			Map<String, Object> params = new Map<String, Object>();
			params.put('visitorId', vis.Id);
			params.put('Livechat_Session_Key', vis.CVCH__Livechat_Session_Key__c);
			params.put('Livechat_Session_Id', vis.CVCH__Livechat_Session_Id__c);
			params.put('Livechat_affinityToken', vis.CVCH__Livechat_affinityToken__c);

			Id visitorId = vis.Id;

			CVCH__Visitor__c upd = [SELECT Id,CVCH__Livechat_Session_Key__c,CVCH__Livechat_Session_Id__c,CVCH__Livechat_affinityToken__c FROM Visitor__c WHERE Id = :visitorId];
			if (upd.CVCH__Livechat_Session_Key__c != null || upd.CVCH__Livechat_Session_Id__c != null)
			{
				upd.CVCH__Livechat_Session_Key__c = null;
				upd.CVCH__Livechat_Session_Id__c = null;
				upd.CVCH__Livechat_affinityToken__c = null;
				upd.CVCH__Livechat_Last_Poll_Time__c = null;
				update upd;
				String sFlow = SM010_Utils.getChat2aiValue2('Livechat Survey Flow');
				if (sFlow != '')
				{
					SM010_Utils.getFlow(sFlow, vis.Chat_Number__c, params).start();
				}
				else
				{
					CVCH.SM042_NexmoOut2.sendText(vis.CVCH__Id__c, SM010_Utils.translate('The chat is disconnected', vis.CVCH__language__c), vis.CVCH__Chat_Number__c, false);
				}
				CVCH.SM005_Logs.save();
			}
		}
	}

	@AuraEnabled
	public static void chatEnded(String recordId)
	{

		try
		{
			String sKey = getChatKey(recordId);
			List<CVCH__Visitor__c> lvisr = DM080_Visitor.getRecordsbySessionId(sKey);

			if (!lvisr.isEmpty())
			{
				CVCH__Visitor__c vis = lvisr[0];
				Disconnect(vis);
				SM010_Utils.saveTran();
			}
		}
		catch (Exception e)
		{
			System.debug('Error: ' + e.getMessage() + ' ' + e.getStackTraceString());
		}
	}
	public static String getChatKey(String recordId)
	{
		if (Test.isRunningTest())
			return recordId;
		List<SObject> lObj = Database.query('select id,ChatKey from LiveChatTranscript where id = :recordId');
		if (lObj.isEmpty())
			throw new MyException('Can not find the Chat with the key ' + recordId);
		return (String) lObj[0].get('ChatKey');
//		return [
//				select id,ChatKey
//				from LiveChatTranscript
//				where id = :recordId
//		].ChatKey;
	}
}
