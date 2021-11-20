/**
Author:         serhiivolynets
Date:           26.03.2021
Description:   
**/


global class FlowSendCustomMessage
{

        @AuraEnabled @InvocableVariable global id visitorId;
        @AuraEnabled @InvocableVariable global string content;
        @AuraEnabled @InvocableVariable global boolean async;


    @InvocableMethod(label='Send Custom Message' description='sends a custom MTM message ')
    global static void sendMessage(list<FlowSendCustomMessage> lParam)
    {
        system.debug('FlowSendCustomMessage.start');

        set<id>sids = new set<id>();
        for(FlowSendCustomMessage inp: lParam)
        {
            sids.add((id)inp.visitorId);
        }
        map<id,CVCH__Visitor__c> mVis = new map<id,CVCH__Visitor__c>(DM080_Visitor.getRecords(sids));
        for(FlowSendCustomMessage inp: lParam)
        {
            if(inp.async == null)
                inp.async = false;
            CVCH__Visitor__c vis = mVis.get((id)inp.visitorId);
            system.debug('inp.message: '+inp.content);
            SM042_NexmoOut2.sendCustomText(vis.CVCH__Id__c,inp.content,vis.CVCH__Chat_Number__c,inp.async);
            if (inp.async == true)
                SM010_Utils.saveTran();
            SM042_NexmoOut2.pause(800);
        }
        SM005_Logs.save();
    }
}
