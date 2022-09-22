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
			MessageOptions mo = new MessageOptions();
			CarouselItem item = new CarouselItem();
			item.title = inp.caption;
			item.imageURL = inp.imageurl;
			mo.lItems.add(item);
			mo.sType = 'Carousel';
			mo.async = inp.async;
			SM010_Utils.setVisitor(vis);
			SM042_NexmoOut2.sendComplexType(mo, vis.CVCH__id__c, vis.CVCH__Chat_Number__c);
			SM042_NexmoOut2.pause(1000);
		}
	}
}
