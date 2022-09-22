/**
Author:         serhiivolynets
Date:           03.09.2021
Description:   
**/
@IsTest

public with sharing class SM093_LiveAgentTest
{
	@IsTest
	public static void testIt()
	{
		CVCH__Visitor__c vis = SM031_NexmoTEST.createExistingVisitor('Full Access');
		SM093_LiveAgentStartChat t = new SM093_LiveAgentStartChat();
		t.paramName1 = 'name1';t.paramValue1 = 'val1';
		t.paramName2 = 'name1';t.paramValue2 = 'val1';
		t.paramName3 = 'name1';t.paramValue3 = 'val1';
		t.paramName4 = 'name1';t.paramValue4 = 'val1';
		t.paramName5 = 'name1';t.paramValue5 = 'val1';
		t.visitorId = vis.Id;
		Test.startTest();
		SM093_LiveAgentStartChat.StartChat(new list<SM093_LiveAgentStartChat> {t});
		Test.stopTest();
	}


	@IsTest
	public static void testAvilability()
	{
		Test.startTest();
		SM093_LiveAgent.isAvailable('111111111111111111','111111111111111111');
		Test.stopTest();
	}
}
