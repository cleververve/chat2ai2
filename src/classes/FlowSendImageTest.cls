/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@IsTest
public class FlowSendImageTest
{
	@IsTest
	public static void test()
	{
		TestDataFactory data = new TestDataFactory();
		FlowSendImage.SendImgInput inp = new FlowSendImage.SendImgInput();
		inp.visitorId = data.vis.id;
		inp.imageURL = 'google.com';
		inp.async = false;
		Test.startTest();
		FlowSendImage.sendImage(new list<FlowSendImage.SendImgInput>{inp});
		inp.async = true;
		FlowSendImage.sendImage(new list<FlowSendImage.SendImgInput>{inp});
		Test.stopTest();
	}


}