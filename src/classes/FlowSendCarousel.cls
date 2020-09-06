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
		map<id,CVCH__Visitor__c> mVis = new map<id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		for(SendcrsInput inp: lParam)
		{
			CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
			if(vis.CVCH__language__c != 'en' && vis.CVCH__language__c != null && vis.CVCH__language__c != '')
				inp.caption = SM010_Utils.translate(inp.caption,vis.CVCH__language__c);
            if(inp.async == null || inp.async == false)
        	{
            	sm042_nexmoout2.sendcarousel(vis.CVCH__id__c,vis.CVCH__Chat_Number__c, inp.imageurl, inp.caption);
                SM042_NexmoOut2.pause(800);
        	}
            else
            {
                sm042_nexmoout2.sendCarouselAsync(vis.CVCH__id__c,vis.CVCH__Chat_Number__c, inp.imageurl, inp.caption);
            }
		}
	}

}