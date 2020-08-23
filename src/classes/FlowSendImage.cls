global class FlowSendImage
{   
    global class SendImgInput
    {
        @AuraEnabled @InvocableVariable global id visitorId;
        @AuraEnabled @InvocableVariable global string imageURL;
        @AuraEnabled @InvocableVariable global boolean async;
    }
    
    @InvocableMethod(label='Send Image' description='sends an image')
	global static void sendImage(list<SendImgInput> lParam)
	{
        system.debug('FlowSendImage.start');
		set<id>sids = new set<id>();
		for(SendImgInput inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));
		for(SendImgInput inp: lParam)
		{
            if(inp.async == null)
            {
                inp.async = false;
            }
			Visitor__c vis = mVis.get((id)inp.visitorId);
            if(inp.async)
            {
                SM042_NexmoOut4.sendImageAsync(vis.Id__c,vis.Chat_Number__c,inp.imageURL);
            }else
            {
                SM042_NexmoOut4.sendImage(vis.Id__c,vis.Chat_Number__c,inp.imageURL);
            }
			
            SM042_NexmoOut2.pause(1000);
		}
    }
}
