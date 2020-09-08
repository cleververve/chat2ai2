/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendMessage2
{

		@AuraEnabled @InvocableVariable global id visitorId;
		@AuraEnabled @InvocableVariable global string message;
		@AuraEnabled @InvocableVariable global boolean async;


	@InvocableMethod(label='Send Message' description='sends a chat message ')
	global static void sendMessage(list<FlowSendMessage2> lParam)
	{
		system.debug('FlowSendMessage.start');

		set<id>sids = new set<id>();
		for(FlowSendMessage2 inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,CVCH__Visitor__c> mVis = new map<id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendMessage2 inp: lParam)
		{
			if(inp.async == null)
			{
				inp.async = false;
			}
			CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
			if(vis.CVCH__language__c != 'en' && vis.CVCH__language__c != null && vis.CVCH__language__c != '')
				inp.message = SM010_Utils.translate(inp.message,vis.CVCH__language__c);
			system.debug('inp.message: '+inp.message);
			if(inp.async){
				SM042_NexmoOut4.sendTextAsync(vis.CVCH__Id__c,inp.message,vis.CVCH__Chat_Number__c,vis.CVCH__Chat_Number__c);
			}else
					SM042_NexmoOut4.sendText(vis.CVCH__Id__c,vis.CVCH__Chat_Number__c,inp.message);
			//SM042_NexmoOut2.sendText(vis.Id__c,inp.message,vis.Chat_Number__c);
			if (inp.async == true)
            {
                SM010_Utils.saveTran();
            }
			SM042_NexmoOut2.pause(800);
//			SM033_NexmoOut.sendTextAsync(vis.Id__c,inp.message,vis.Chat_Number__c,vis.Chat_Number__c);

		}
	}

}