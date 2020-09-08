/**
Author:         serhiivolynets
Date:           23.08.2020
Description:
**/
@IsTest
public with sharing class FlowSendVideoTest
{
	@IsTest
	public static void test()
	{
		TestDataFactory data1 = new TestDataFactory();
		FlowSendVideo.SendVideoInput inp = new FlowSendVideo.SendVideoInput();
		inp.visitorId = data1.vis.Id;
		inp.caption = 'caption';
		inp.fileURL = 'google.com';
		Test.startTest();
		FlowSendVideo.sendVideo(new list<FlowSendVideo.SendVideoInput>
		{
				inp
		});
		Test.stopTest();
	}

	@IsTest
	public static void test2()
	{
		TestDataFactory data1 = new TestDataFactory();
		FlowSendVideo2 inp = new FlowSendVideo2();
		inp.visitorId = data1.vis.Id;
		inp.caption = 'caption';
		inp.fileURL = 'google.com';
		Test.startTest();
		FlowSendVideo2.sendVideo(new list<FlowSendVideo2>
		{
				inp
		});
		Test.stopTest();
	}
}