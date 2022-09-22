/**
Author:         serhiivolynets
Date:           18.07.2020
Description:   
**/

global class FlowSendMessage
{

	global class SendMsgInput
	{
		@AuraEnabled @InvocableVariable global id visitorId;
		@AuraEnabled @InvocableVariable global string message;
        @AuraEnabled @InvocableVariable global boolean async;
	}

	@InvocableMethod(label='old do not use' description='sends a chat message ')
	global static void sendMessage(list<SendMsgInput> lParam)
	{
		system.debug('FlowSendMessage.start');
        
		set<id>sids = new set<id>();
		for(SendMsgInput inp: lParam)
		{
			sids.add((id)inp.visitorId);
		}
		map<id,Visitor__c> mVis = new map<id,Visitor__c>(DM080_Visitor.getRecords(sids));
		for(SendMsgInput inp: lParam)
		{
            if(inp.async == null)
                inp.async = false;
			Visitor__c vis = mVis.get((id)inp.visitorId);
			if(vis.language__c != 'en' && vis.language__c != null && vis.language__c != '')
				inp.message = SM010_Utils.translate(inp.message,vis.language__c);
            system.debug('inp.message: '+inp.message);

//            if(inp.async){
//                SM042_NexmoOut4.sendTextAsync(vis.Id__c,inp.message,vis.Chat_Number__c,vis.Chat_Number__c);
//            }else
//            	SM042_NexmoOut4.sendText(vis.Id__c,vis.Chat_Number__c,inp.message);
//            SM042_NexmoOut2.pause(800);
			SM010_Utils.setVisitor(vis);
			SM042_NexmoOut2.sendText(vis.CVCH__Id__c,inp.message,vis.CVCH__Chat_Number__c,inp.async);
			if (inp.async == true)
				SM010_Utils.saveTran();
			SM042_NexmoOut2.pause(800);
		}
	}
}
