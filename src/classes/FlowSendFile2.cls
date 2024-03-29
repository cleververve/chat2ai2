/**
Author:         serhiivolynets
Date:           24.08.2020
Description:   
**/

global class FlowSendFile2
{

		@AuraEnabled @InvocableVariable global id visitorId;
		@AuraEnabled @InvocableVariable global string fileURL;
		@AuraEnabled @InvocableVariable global string caption;


	@InvocableMethod(label='Send File' description='sends a file')
	global static void sendFile(list<FlowSendFile2> lParam)
	{
		system.debug('FlowSendFile.start');
		set<id>sids = new set<id>();
		for(FlowSendFile2 inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,CVCH__Visitor__c> mVis = new map<id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
		for(FlowSendFile2 inp: lParam)
		{
//			CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
//			SM042_NexmoOut4.sendFile(vis.CVCH__Id__c,vis.CVCH__Chat_Number__c,inp.fileURL,inp.caption);
//			SM042_NexmoOut2.pause(2000);
//

			CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
			SM010_Utils.setVisitor(vis);
			if(vis.CVCH__language__c != 'en' && vis.CVCH__language__c != null && vis.CVCH__language__c != '')
				inp.caption = SM010_Utils.translate(inp.caption,vis.CVCH__language__c);
			MessageOptions mo = new MessageOptions();
			CarouselItem item = new CarouselItem();
			item.videoURL = inp.fileURL;
			item.contentType = 'file';
			item.title = inp.caption;

			mo.lItems.add(item);
			mo.sType = 'Carousel';
			mo.visitorId = vis.Id;
			SM042_NexmoOut2.sendComplexType(mo, vis.CVCH__Id__c, vis.CVCH__Chat_Number__c);

			SM042_NexmoOut2.pause(1000);
		}
	}

}
