/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendMessage2
{

		@AuraEnabled @InvocableVariable public id visitorId;
		@AuraEnabled @InvocableVariable public string message;
		@AuraEnabled @InvocableVariable public boolean async;


	@InvocableMethod(label='Send Message' description='sends a chat message ')
	global static void sendMessage(list<FlowSendMessage2> lParam)
	{
		system.debug('FlowSendMessage.start');

		set<id>sids = new set<id>();
		for(FlowSendMessage2 inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendMessage2 inp: lParam)
		{
			if(inp.async == null)
			{
				inp.async = false;
			}
			Visitor__c vis = mVis.get((id)inp.visitorId);
			if(vis.language__c != 'en' && vis.language__c != null && vis.language__c != '')
				inp.message = SM010_Utils.translate(inp.message,vis.language__c);
			system.debug('inp.message: '+inp.message);
			if(inp.async){
				SM042_NexmoOut4.sendTextAsync(vis.Id__c,inp.message,vis.Chat_Number__c,vis.Chat_Number__c);
			}else
					SM042_NexmoOut4.sendText(vis.Id__c,vis.Chat_Number__c,inp.message);
			//SM042_NexmoOut2.sendText(vis.Id__c,inp.message,vis.Chat_Number__c);
			SM042_NexmoOut2.pause(800);
//			SM033_NexmoOut.sendTextAsync(vis.Id__c,inp.message,vis.Chat_Number__c,vis.Chat_Number__c);

		}
	}
}
