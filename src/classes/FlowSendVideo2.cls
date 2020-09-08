/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendVideo2
{

		@AuraEnabled @InvocableVariable global id visitorId;
		@AuraEnabled @InvocableVariable global string fileURL;
		@AuraEnabled @InvocableVariable global string caption;


	@InvocableMethod(label='Send Video' description='sends a Video')
	global static void sendVideo(list<FlowSendVideo2> lParam)
	{
		system.debug('FlowSendVideo.start');
		set<id>sids = new set<id>();
		for(FlowSendVideo2 inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,CVCH__Visitor__c> mVis = new map<id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendVideo2 inp: lParam)
		{
			CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
			if(vis.CVCH__language__c != 'en' && vis.CVCH__language__c != null && vis.CVCH__language__c != '')
				inp.caption = SM010_Utils.translate(inp.caption,vis.CVCH__language__c);
			SM042_NexmoOut4.sendVideo(vis.CVCH__Id__c,vis.CVCH__Chat_Number__c,inp.fileURL, inp.caption);
			SM042_NexmoOut2.pause(800);
		}
	}

}