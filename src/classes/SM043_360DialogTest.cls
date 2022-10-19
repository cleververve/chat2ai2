/**
Author:         serhiivolynets
Date:           28.11.2021
Description:   
**/
@IsTest
public with sharing class SM043_360DialogTest
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		SM043_360Dialog.sendTextMessage('111','1111','1111');
		SM043_360Dialog.sendCustom('111','1111','Interactive','111');
		SM043_360Dialog.sendImage('111','111','google.com','111');
		Test.stopTest();
	}


	@IsTest
	public static void testReplyTo()
	{
		Test.startTest();
		SM043_360Dialog.sendTextMessage('111','1111','liveagent text');
		SM005_Logs.save();
		List<CallOut__c> lCallOuts = [SELECT Id FROM CallOut__c WHERE CVCH__ResponseId__c <> NULL];
		System.assert(lCallOuts.size()>0);
		NexmoMessage__c mess = SM031_Nexmo.parse('{"contacts": [{"profile": {"name": "Vika"}, "wa_id": "971552713278"}], "messages": [{"context": {"from": "9718006636255", "id": "test_d360"}, "from": "971552713278", "id": "ABEGlxVScTJ4Ago-sAzG-X4pBjhV", "text": {"body": "Good afternoon Ahmed"}, "timestamp": "1665140243", "type": "text"}], "to": "9718006636255"}');
		system.assertEquals(mess.ReplyToId__c, 'test_d360');
		String sText = SM093_LiveAgent.getMessageText(mess);
		Test.stopTest();
		System.assertEquals(sText,'Replying to "liveagent text"\nGood afternoon Ahmed');
	}


	@IsTest
	public static void testReplyToCapture()
	{
		Test.startTest();
		SM043_360Dialog.sendImage('111','1111','google.com','capture1');
		SM005_Logs.save();
		List<CallOut__c> lCallOuts = [SELECT Id FROM CallOut__c WHERE CVCH__ResponseId__c <> NULL];
		System.assert(lCallOuts.size()>0);
		NexmoMessage__c mess = SM031_Nexmo.parse('{"contacts": [{"profile": {"name": "Vika"}, "wa_id": "971552713278"}], "messages": [{"context": {"from": "9718006636255", "id": "test_d360"}, "from": "971552713278", "id": "ABEGlxVScTJ4Ago-sAzG-X4pBjhV", "text": {"body": "Good afternoon Ahmed"}, "timestamp": "1665140243", "type": "text"}], "to": "9718006636255"}');
		system.assertEquals(mess.ReplyToId__c, 'test_d360');
		String sText = SM093_LiveAgent.getMessageText(mess);
		Test.stopTest();
		System.assertEquals(sText,'Replying to "google.com"\nGood afternoon Ahmed');
	}

}
