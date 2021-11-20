global class FlowSendWelcomeCarousel
{

	global class SendCrsInput
	{
        @AuraEnabled @InvocableVariable global string imageurl;
        @AuraEnabled @InvocableVariable global string caption;
        @AuraEnabled @InvocableVariable global boolean async;
        @AuraEnabled @InvocableVariable global string visphone;
        @AuraEnabled @InvocableVariable global string ChatNumber;
	}

	@InvocableMethod(label='old do not use' description='sends a carousel')
	global static void sendMessage(list<SendcrsInput> lParam)
	{
		system.debug('FlowSendWelcomeCarousel.start');
		for(SendcrsInput inp: lParam)
		{
			MessageOptions mo = new MessageOptions();
			CarouselItem item = new CarouselItem();
			item.title = inp.caption;
			item.imageURL = inp.imageurl;
			mo.lItems.add(item);
			mo.sType = 'Carousel';
			mo.sMessage = inp.caption;
			mo.async = inp.async;
			SM042_NexmoOut2.sendComplexType(mo, inp.visphone, inp.ChatNumber);
//            if(inp.async == null || inp.async == false)
//        	{
//            	sm042_nexmoout2.sendcarousel(inp.visphone,inp.ChatNumber, inp.imageurl, inp.caption);
//                SM042_NexmoOut2.pause(800);
//        	}
//            else
//            {
//                sm042_nexmoout2.sendCarouselAsync(inp.visphone,inp.ChatNumber, inp.imageurl, inp.caption);
//            }
		}
	}
}
