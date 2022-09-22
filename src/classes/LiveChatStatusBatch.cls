/**
Author:         serhiivolynets
Date:           09.09.2022
Description:   
**/

global with sharing class LiveChatStatusBatch implements Database.Batchable<SObject>, Database.AllowsCallouts
{

	global static void start()
	{
		Database.executeBatch(new LiveChatStatusBatch(), 1);
	}
	global Iterable<SObject> start(Database.BatchableContext param1)
	{
		String sQuery = 'SELECT Id, Livechat_Session_Key__c, Livechat_affinityToken__c, Livechat_Last_Poll_Time__c, language__c, Chat_Number__c, Chanel__c FROM Visitor__c WHERE Livechat_Session_Key__c <> NULL';
		return Database.getQueryLocator(sQuery);
	}

	global void execute(Database.BatchableContext param1, List<SObject> lRecords)
	{

		try
		{


			Visitor__c vis = (Visitor__c) lRecords[0];
			if (SM093_LiveAgent.canPoll(vis))
			{

				String sState = pollSessionState(vis.Livechat_Session_Key__c, vis.Livechat_affinityToken__c);
				Boolean isTerminated = false;
				if (sState != null)
				{
					Visitor__c visr = DM080_Visitor.getRecords(new set<id>
					{
							vis.Id
					})[0];

					if (sState != 'Error')
					{
						isTerminated = true;

						terminateChat(visr);
						SM005_Logs.save();
					}


				}
				if (!isTerminated)
				{
					update (new Visitor__c(Livechat_Last_Poll_Time__c = Datetime.now(), Id = vis.Id));
				}
			}
		}
		catch (Exception e)
		{
			system.debug('Error: ' + e.getMessage());
		}

	}

	global void finish(Database.BatchableContext param1)
	{
		pause(SM093_LiveAgent.getPollTimeout() * 1000);
		if (!Test.isRunningTest() && SM010_Utils.getChat2aiValue2('Stop Polling Loop') != 'TRUE')
		{
			start();
		}
	}

	public static void terminateChat(Visitor__c visr)
	{
		SM010_Utils.setVisitor(visr);
		id visitorId = visr.Id;

		CVCH__Visitor__c upd = [SELECT Id,CVCH__Livechat_Session_Key__c,CVCH__Livechat_Session_Id__c,CVCH__Livechat_affinityToken__c FROM Visitor__c WHERE Id = :visitorId];
		if (upd.CVCH__Livechat_Session_Key__c != null || upd.CVCH__Livechat_Session_Id__c != null)
		{
			upd.CVCH__Livechat_Session_Key__c = null;
			upd.CVCH__Livechat_Session_Id__c = null;
			upd.CVCH__Livechat_affinityToken__c = null;
			upd.CVCH__Livechat_Last_Poll_Time__c = null;
			update upd;

			String sFlowName = SM010_Utils.getChat2aiValue2('Session Expired Flow');
			if (sFlowName != '')
			{
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				Flow.Interview flow = SM010_Utils.getFlow(sFlowName, visr.Chat_Number__c, params);
				flow.start();
			}
			else
			{
				CVCH.SM042_NexmoOut2.sendText(visr.CVCH__Id__c, SM010_Utils.translate('Sorry, your chat session is expired..', visr.CVCH__language__c), visr.CVCH__Chat_Number__c, false);
			}
		}
	}

	public static String pollSessionState(String sKey, String token)
	{
		String sState = null;
		try
		{
			HttpResponse resp = SM093_LiveAgent.makePollRequest(sKey, token);
			String sBody = resp.getBody();
			if (sBody.contains(SM093_LiveAgent.sessionRequired))
			{
				sState = 'Terminated';
			}
			else
			{
				Map <String, Object> mRet = (Map <String, Object>) JSON.deserializeUntyped(sBody);
				List<Object> messages = (List<Object>) mRet.get('messages');
				String sEnded = SM093_LiveAgent.sessionIsEnded(messages);
				if (sEnded != null)
				{
					sState = sEnded;
				}
			}
		}
		catch (Exception e)
		{
			String errorMess = e.getMessage();
			if (errorMess.contains(SM093_LiveAgent.sessionRequired))
			{
				sState = 'Terminated';
			}
			else
			{
				sState = 'Error';
			}
		}
		return sState;
	}

	public static void pause(Integer delayInMilliseconds)
	{
		Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
		while (System.now().getTime() - startingTime < delayInMilliseconds)
		{
			// Do nothing until desired delay has passed
		}
	}


}
