/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendImage2
{

	@AuraEnabled @InvocableVariable public id visitorId;
	@AuraEnabled @InvocableVariable public string imageURL;
	@AuraEnabled @InvocableVariable public boolean async;


	@InvocableMethod(label='Send Image' description='sends an image')
	global static void sendImage(list<FlowSendImage2> lParam)
	{
		system.debug('FlowSendImage.start');
		set<id>sids = new set<id>();
		for(FlowSendImage2 inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendImage2 inp: lParam)
		{
			if(inp.async == null)
			{
				inp.async = false;
			}
			Visitor__c vis = mVis.get((id)inp.visitorId);
			if(inp.async)
			{
				SM042_NexmoOut4.sendImageAsync(vis.Id__c,vis.Chat_Number__c,inp.imageURL);
			}else
			{
				SM042_NexmoOut4.sendImage(vis.Id__c,vis.Chat_Number__c,inp.imageURL);
			}

			SM042_NexmoOut2.pause(1000);
		}
	}
}
