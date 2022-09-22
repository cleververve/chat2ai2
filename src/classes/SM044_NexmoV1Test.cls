/**
Author:         serhiivolynets
Date:           08.12.2021
Description:   
**/
@IsTest
public with sharing class SM044_NexmoV1Test
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		SM044_NexmoV1.sendText('111','1111','1111');
		SM044_NexmoV1.sendCustom('111','1111','111');
		SM044_NexmoV1.sendLink('111','1111','google.com','111','image');
		SM005_Logs.save();
		Test.stopTest();
		List<CallOut__c> lCalls = [SELECT Id FROM CallOut__c WHERE ResponseId__c = '111222333'];
		System.assert(lCalls.size()>0);
	}

	@IsTest
	public static void testReplyTo()
	{
		SM044_NexmoV1.sendText('111','1111','liveagent text');
		SM005_Logs.save();
		Test.startTest();
		NexmoMessage__c mess = SM031_Nexmo.parse('{"to":"971800226255","from":"917978025200","channel":"whatsapp","message_uuid":"991cc4a7-d0a0-4f85-9b0e-b546f062342c","timestamp":"2022-09-15T08:36:58Z","message_type":"text","text":"No.. thank you","profile":{"name":"Ak"},"context":{"message_uuid":"111222333"}}');
		String sText = SM093_LiveAgent.getMessageText(mess);
		Test.stopTest();
		System.assertEquals(sText,'Replying to "liveagent text"\nNo.. thank you');
	}


	@IsTest
	public static void testgettext()
	{
		Test.startTest();
		String sText = SM093_LiveAgent.getText('{"message_type":"custom","custom":{"interactive":{"action":{"buttons":[{"reply":{"title":"Feedback","id":"flow_Get_NPS_1"},"type":"reply"},{"reply":{"title":"Start a new chat","id":"flow_Live_Chat"},"type":"reply"}]},"body":{"text":"test custom text"},"type":"button"},"type":"interactive"},"channel":"whatsapp","from":"971800226255","to":"917978025200"}');
		Test.stopTest();
		system.assertEquals(sText,'test custom text');
	}
}
