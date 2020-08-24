global class FlowSendCarousel
{

	global class SendCrsInput
	{
		/*moved*/@AuraEnabled @InvocableVariable global id visitorId;
		/*moved*/@AuraEnabled @InvocableVariable global string imageurl;
		/*moved*/@AuraEnabled @InvocableVariable global string caption;
		/*moved*/@AuraEnabled @InvocableVariable global boolean async;
	}

	/*moved*/@InvocableMethod(label='Send Carousel' description='sends a carousel')
	global static void sendMessage(list<SendcrsInput> lParam)
	{
		system.debug('FlowSendCarousel.start');
		set<id>sids = new set<id>();
        
		for(SendcrsInput inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));
		for(SendcrsInput inp: lParam)
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
