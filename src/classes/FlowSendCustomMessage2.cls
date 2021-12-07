/**
Author:         serhiivolynets
Date:           17.10.2021
Description:   
**/

global class FlowSendCustomMessage2
{
	@AuraEnabled @InvocableVariable global id visitorId;
	@AuraEnabled @InvocableVariable global string content;
	@AuraEnabled @InvocableVariable global boolean async;

	@InvocableMethod(label='Send Custom Message 2' description='sends a custom interactive message ')
	global static void sendMessage(list<FlowSendCustomMessage2> lParam)
	{
		system.debug('FlowSendCustomMessage2.start');

		set<id>sids = new set<id>();
		for(FlowSendCustomMessage2 inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,CVCH__Visitor__c> mVis = new map<id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendCustomMessage2 inp: lParam)
		{
			if(inp.async == null)
				inp.async = false;
			CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
			system.debug('inp.message: '+inp.content);
			SM042_NexmoOut2.sendCustomText2(vis.CVCH__Id__c,inp.content,vis.CVCH__Chat_Number__c,inp.async);
			if (inp.async == true)
				SM010_Utils.saveTran();
			SM042_NexmoOut2.pause(800);
		}
		SM005_Logs.save();
	}
}
