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
		for(FlowSendWelcomeCarousel2 inp: lParam)
		{
			MessageOptions mo = new MessageOptions();
			CarouselItem item = new CarouselItem();
			item.title = inp.caption;
			item.imageURL = inp.imageurl;
			mo.lItems.add(item);
			mo.sType = 'Carousel';
//			mo.sMessage = inp.caption;
			mo.async = inp.async;
			SM042_NexmoOut2.sendComplexType(mo, inp.visphone, inp.ChatNumber);
		}
	}
}
