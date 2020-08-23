/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@isTest
public class FlowSendMessageTest
{
	@IsTest
	public static void send()
	{
		TestDataFactory data = new TestDataFactory();
		FlowSendMessage.SendMsgInput inp = new FlowSendMessage.SendMsgInput();
		inp.visitorId = data.vis.id;
		inp.async = false;
		inp.message = 'mess';
		Test.startTest();
		FlowSendMessage.sendMessage(new list<FlowSendMessage.SendMsgInput>
		{
				inp
		});
		Test.stopTest();
	}
}
