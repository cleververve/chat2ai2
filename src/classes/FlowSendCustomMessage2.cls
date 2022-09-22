/**
Author:         serhiivolynets
Date:           17.10.2021
Description:   
**/

global class FlowSendCustomMessage2
{
	@AuraEnabled @InvocableVariable global Id visitorId;
	@AuraEnabled @InvocableVariable global String content;
	@AuraEnabled @InvocableVariable global Boolean async;

	@InvocableMethod(Label='Send Custom Message 2' Description='sends a custom interactive message ')
	global static void sendMessage(List<FlowSendCustomMessage2> lParam)
	{
		System.debug('FlowSendCustomMessage2.start');

		Set<Id>sids = new Set<Id>();
		for(FlowSendCustomMessage2 inp: lParam)
		{
			sids.add((Id)inp.visitorId);
		}
		Map<Id,CVCH__Visitor__c> mVis = new Map<Id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendCustomMessage2 inp: lParam)
		{
			if(inp.async == null)
				inp.async = false;
			CVCH__Visitor__c vis = mVis.get((Id)inp.visitorId);
			SM010_Utils.setVisitor(vis);
			System.debug('inp.message: '+inp.content);
			SM042_NexmoOut2.sendCustomText2(vis.CVCH__Id__c,inp.content,vis.CVCH__Chat_Number__c,inp.async);
			if (inp.async == true)
				SM010_Utils.saveTran();
			SM042_NexmoOut2.pause(800);
		}
		SM005_Logs.save();
	}
}
