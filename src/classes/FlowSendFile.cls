global class FlowSendFile 
{
	global class SendFileInput
    {
        @AuraEnabled @InvocableVariable global id visitorId;
        @AuraEnabled @InvocableVariable global string fileURL;
        @AuraEnabled @InvocableVariable global string caption;
    }
    
    @InvocableMethod(label='old do not use' description='sends a file')
	global static void sendFile(list<SendFileInput> lParam)
	{
        system.debug('FlowSendFile.start');
		set<id>sids = new set<id>();
		for(SendFileInput inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));
		for(SendFileInput inp: lParam)
		{
			Visitor__c vis = mVis.get((id)inp.visitorId);
			SM042_NexmoOut4.sendFile(vis.Id__c,vis.Chat_Number__c,inp.fileURL,inp.caption);
            SM042_NexmoOut2.pause(2000);
		}
    }
	
}