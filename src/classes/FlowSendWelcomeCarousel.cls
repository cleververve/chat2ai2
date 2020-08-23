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

	@InvocableMethod(label='Send Welcome Carousel' description='sends a carousel')
	global static void sendMessage(list<SendcrsInput> lParam)
	{
		system.debug('FlowSendWelcomeCarousel.start');
		set<id>sids = new set<id>();
        
		/*for(SendcrsInput inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));*/
		for(SendcrsInput inp: lParam)
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
