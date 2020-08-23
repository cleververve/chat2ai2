/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@IsTest
public class FlowSendFileTest
{
	@IsTest
	public static void send()
	{
		TestDataFactory data1 = new TestDataFactory();
		FlowSendFile.SendFileInput inp = new FlowSendFile.SendFileInput();
		inp.visitorId = data1.vis.Id;
		inp.caption = 'caption';
		Test.startTest();
		FlowSendFile.sendFile(new list<FlowSendFile.SendFileInput>{inp});
		Test.stopTest();
	}

}
