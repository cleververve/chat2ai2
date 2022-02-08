/**
Author:         serhiivolynets
Date:           02.09.2021
Description:   
**/
@IsTest
public with sharing class LiveChatMonitorTest
{
	@IsTest
	public static void testIt()
	{
		CVCH__Visitor__c vis = SM031_NexmoTEST.createExistingVisitor('Full Access');
		vis.Livechat_Session_Key__c = '1234';
		update vis;
		LiveChatMonitor.logAgentReply(null,'aaa',null,null);
		LiveChatMonitor.chatEnded(null);
	}

}
