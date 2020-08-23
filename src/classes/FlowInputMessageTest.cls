/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@IsTest
public class FlowInputMessageTest
{
	@IsTest
	public static void send()
	{
		TestDataFactory data1 = new TestDataFactory();
		FlowInputMessage mess = new FlowInputMessage();
		mess.visitorId = data1.vis.id;
		mess.sMessage = 'mess';
		mess.sFlow = '';
		mess.sFieldName = 'field1';
		mess.sConfirmMessage = 'confirm';
		Test.startTest();
		FlowInputMessage.send(new list<FlowInputMessage>
		{
				mess
		});
		Test.stopTest();
	}
}
