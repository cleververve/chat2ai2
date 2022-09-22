/**
Author:         serhiivolynets
Date:           13.12.2021
Description:   
**/

global class FlowSendMTM
{
	@AuraEnabled @InvocableVariable global Id visitorId;
	@AuraEnabled @InvocableVariable global String content;
	@AuraEnabled @InvocableVariable global Boolean async;
	@AuraEnabled @InvocableVariable global String locale;

	@InvocableMethod(label='Send MTM' description='Send MTM')
	global static void sendMessage(List<FlowSendMTM> lParam)
	{
		System.debug('FlowSendCustomMessage.start');

		Set<Id>sids = new Set<Id>();
		for(FlowSendMTM inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		Map<Id,CVCH__Visitor__c> mVis = new Map<Id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendMTM inp: lParam)
		{
			if(inp.async == null)
				inp.async = false;
			CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
			System.debug('inp.message: '+inp.content);
			CVCH__NexmoMessage__c mess = SM042_NexmoOut2.initMessage(vis.CVCH__Id__c, vis.CVCH__Chat_Number__c,vis.Id);

			mess.CVCH__Text__c = inp.content;
			if (mess.CVCH__Text__c != null && mess.CVCH__Text__c.length() > 254)
				mess.CVCH__Text__c = mess.CVCH__Text__c.substring(0, 254);
			mess.CVCH__FullText__c = inp.content;
			mess.CVCH__Status__c = 'Queued';
			mess.CVCH__Type__c = 'Template';
			mess.CVCH__Locale__c = inp.locale;
			SM010_Utils.setVisitor(vis);
			SM042_NexmoOut2.sendOrEnqueue(mess, inp.async);


			if (inp.async == true)
				SM010_Utils.saveTran();
			SM042_NexmoOut2.pause(800);
		}
		SM005_Logs.save();
	}
}
