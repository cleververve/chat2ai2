/**
Author:         serhiivolynets
Date:           09.09.2022
Description:   
**/
@IsTest
public with sharing class LiveChatStatusBatchTest
{
	@TestSetup
	public static void prepareData()
	{
		Visitor__c v = SM031_NexmoTEST.createExistingVisitor('Full Access');
		v.Chat_Number__c ='111';
		v.Livechat_Session_Key__c = '111';
		v.Livechat_affinityToken__c = '111';
		update v;
	}

	@IsTest
	public static void testBatch()
	{
		Test.startTest();
		LiveChatStatusBatch.start();
		Test.stopTest();
	}

}
