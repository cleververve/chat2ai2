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
		map<id,CVCH__Visitor__c> mVis = new map<id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
//		for(FlowSendCarousel2 inp: lParam)
//		{
//			CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
//			if(vis.CVCH__language__c != 'en' && vis.CVCH__language__c != null && vis.CVCH__language__c != '')
//				inp.caption = SM010_Utils.translate(inp.caption,vis.CVCH__language__c);
//			if(inp.async == null || inp.async == false)
//			{
//				sm042_nexmoout2.sendcarousel(vis.CVCH__id__c,vis.CVCH__Chat_Number__c, inp.imageurl, inp.caption);
//				SM042_NexmoOut2.pause(800);
//			}
//			else
//			{
//				sm042_nexmoout2.sendCarouselAsync(vis.CVCH__id__c,vis.CVCH__Chat_Number__c, inp.imageurl, inp.caption);
//			}
//		}
		for(FlowSendCarousel2 inp : lParam)
		{
			CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
			MessageOptions mo = new MessageOptions();
			CarouselItem item = new CarouselItem();
			item.title = inp.caption;
			item.imageURL = inp.imageurl;
			mo.lItems.add(item);
			mo.sType = 'Carousel';
//			mo.visitorId = mess.visitorId;
			mo.sMessage = inp.caption;
			mo.async = inp.async;
			SM042_NexmoOut2.sendComplexType(mo, vis.CVCH__id__c, vis.CVCH__Chat_Number__c);
			SM042_NexmoOut2.pause(1000);
		}
	}
}