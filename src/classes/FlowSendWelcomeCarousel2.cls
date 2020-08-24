/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendWelcomeCarousel2
{

		@AuraEnabled @InvocableVariable public string imageurl;
		@AuraEnabled @InvocableVariable public string caption;
		@AuraEnabled @InvocableVariable public boolean async;
		@AuraEnabled @InvocableVariable public string visphone;
		@AuraEnabled @InvocableVariable public string ChatNumber;

	@InvocableMethod(label='Send Welcome Carousel' description='sends a carousel')
	global static void sendMessage(list<FlowSendWelcomeCarousel2> lParam)
	{
		system.debug('FlowSendWelcomeCarousel.start');
		set<id>sids = new set<id>();

		/*for(SendcrsInput inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));*/
		for(FlowSendWelcomeCarousel2 inp: lParam)
		{
			//Visitor__c vis = mVis.get((id)inp.visitorId);
			if(inp.async == null || inp.async == false)
			{
				sm042_nexmoout2.sendcarousel(inp.visphone,inp.ChatNumber, inp.imageurl, inp.caption);
				SM042_NexmoOut2.pause(800);
			}
			else
			{
				sm042_nexmoout2.sendCarouselAsync(inp.visphone,inp.ChatNumber, inp.imageurl, inp.caption);
			}


		}
	}
}