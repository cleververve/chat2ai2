/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendVideo2
{

		@AuraEnabled @InvocableVariable public id visitorId;
		@AuraEnabled @InvocableVariable public string fileURL;
		@AuraEnabled @InvocableVariable public string caption;


	@InvocableMethod(label='Send Video' description='sends a Video')
	global static void sendVideo(list<FlowSendVideo2> lParam)
	{
		system.debug('FlowSendVideo.start');
		set<id>sids = new set<id>();
		for(FlowSendVideo2 inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendVideo2 inp: lParam)
		{
			Visitor__c vis = mVis.get((id)inp.visitorId);
			if(vis.language__c != 'en' && vis.language__c != null && vis.language__c != '')
				inp.caption = SM010_Utils.translate(inp.caption,vis.language__c);
			SM042_NexmoOut4.sendVideo(vis.Id__c,vis.Chat_Number__c,inp.fileURL, inp.caption);
			SM042_NexmoOut2.pause(800);
		}
	}
}
