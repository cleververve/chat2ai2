global class FlowSendVideo
{
	global class SendVideoInput
    {
        @AuraEnabled @InvocableVariable global id visitorId;
        @AuraEnabled @InvocableVariable global string fileURL;
        @AuraEnabled @InvocableVariable global string caption;
    }
    
    @InvocableMethod(label='Send Video' description='sends a Video')
	global static void sendVideo(list<SendVideoInput> lParam)
	{
        system.debug('FlowSendVideo.start');
		set<id>sids = new set<id>();
		for(SendVideoInput inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));
		for(SendVideoInput inp: lParam)
		{
			Visitor__c vis = mVis.get((id)inp.visitorId);
            if(vis.language__c != 'en' && vis.language__c != null && vis.language__c != '')
				inp.caption = SM010_Utils.translate(inp.caption,vis.language__c);
			SM042_NexmoOut4.sendVideo(vis.Id__c,vis.Chat_Number__c,inp.fileURL, inp.caption);
            SM042_NexmoOut2.pause(800);
		}
    }
}
