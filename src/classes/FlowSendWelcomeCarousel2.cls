/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendWelcomeCarousel2
{
		@AuraEnabled @InvocableVariable global string imageurl;
		@AuraEnabled @InvocableVariable global string caption;
		@AuraEnabled @InvocableVariable global boolean async;
		@AuraEnabled @InvocableVariable global string visphone;
		@AuraEnabled @InvocableVariable global string ChatNumber;

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
		list<MessageOptions>lMess =new list<MessageOptions>();
		for(FlowSendWelcomeCarousel2 inp: lParam)
		{
			MessageOptions mo = new MessageOptions();
			CarouselItem item = new CarouselItem();
			item.title = inp.caption;
			item.imageURL = inp.imageurl;
			mo.lItems.add(item);
			mo.sType = 'Carousel';
//			mo.visitorId = mess.visitorId;
			mo.sMessage = inp.caption;
			mo.async = inp.async;
			SM042_NexmoOut2.sendComplexType(mo, inp.visphone, inp.ChatNumber);
			lMess.add(mo);

			//Visitor__c vis = mVis.get((id)inp.visitorId);
//			if(inp.async == null || inp.async == false)
//			{
//				sm042_nexmoout2.sendcarousel(inp.visphone,inp.ChatNumber, inp.imageurl, inp.caption);
//				SM042_NexmoOut2.pause(800);
//			}
//			else
//			{
//				sm042_nexmoout2.sendCarouselAsync(inp.visphone,inp.ChatNumber, inp.imageurl, inp.caption);
//			}
		}
//		MessageOptions.sendWF(lMess);
	}
}