/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendCarousel2
{

		@AuraEnabled @InvocableVariable global id visitorId;
		@AuraEnabled @InvocableVariable global string imageurl;
		@AuraEnabled @InvocableVariable global string caption;
		@AuraEnabled @InvocableVariable global boolean async;


	@InvocableMethod(label='Send Carousel' description='sends a carousel')
	global static void sendMessage(list<FlowSendCarousel2> lParam)
	{
		system.debug('FlowSendCarousel.start');
		set<id>sids = new set<id>();

		for(FlowSendCarousel2 inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendCarousel2 inp: lParam)
		{
			Visitor__c vis = mVis.get((id)inp.visitorId);
			if(vis.language__c != 'en' && vis.language__c != null && vis.language__c != '')
				inp.caption = SM010_Utils.translate(inp.caption,vis.language__c);
			if(inp.async == null || inp.async == false)
			{
				sm042_nexmoout2.sendcarousel(vis.id__c,vis.Chat_Number__c, inp.imageurl, inp.caption);
				SM042_NexmoOut2.pause(800);
			}
			else
			{
				sm042_nexmoout2.sendCarouselAsync(vis.id__c,vis.Chat_Number__c, inp.imageurl, inp.caption);
			}
		}
	}
}