/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendImage2
{
	@AuraEnabled @InvocableVariable global id visitorId;
	@AuraEnabled @InvocableVariable global string imageURL;
	@AuraEnabled @InvocableVariable global boolean async;

	@InvocableMethod(label='Send Image' description='sends an image')
	global static void sendImage(list<FlowSendImage2> lParam)
	{
		system.debug('FlowSendImage.start');
		set<id>sids = new set<id>();
		for (FlowSendImage2 inp : lParam)
		{
			sids.add((id) inp.visitorId);
		}
		map<id, CVCH__Visitor__c> mVis = new map<id, CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		for (FlowSendImage2 inp : lParam)
		{
			if (inp.async == null)
				inp.async = false;
			CVCH__Visitor__c vis = mVis.get((id) inp.visitorId);

			MessageOptions mo = new MessageOptions();
			CarouselItem item = new CarouselItem();
			item.imageURL = inp.imageurl;
			mo.lItems.add(item);
			mo.sType = 'Carousel';
			mo.visitorId = vis.Id;
			SM010_Utils.setVisitor(vis);
			SM042_NexmoOut2.sendComplexType(mo, vis.CVCH__Id__c, vis.CVCH__Chat_Number__c);

			SM042_NexmoOut2.pause(1000);
		}
	}
}
