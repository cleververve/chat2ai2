/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@IsTest
public class FlowSendCarouselTest
{
	@IsTest
	public static void send()
	{
		TestDataFactory data1 = new TestDataFactory();
		FlowSendCarousel.SendCrsInput mess = new FlowSendCarousel.SendCrsInput();
		mess.visitorId = data1.vis.id;
		mess.caption = 'mess';
		mess.imageurl = 'http://google.com';

		Test.startTest();
		list<FlowSendCarousel.SendCrsInput> linp = new list<FlowSendCarousel.SendCrsInput>();
		linp.add(mess);
		FlowSendCarousel.sendMessage(linp);
		Test.stopTest();
	}

	@IsTest
	public static void send2()
	{
		TestDataFactory data1 = new TestDataFactory();
		FlowSendCarousel2 mess = new FlowSendCarousel2();
		mess.visitorId = data1.vis.id;
		mess.caption = 'mess';
		mess.imageurl = 'http://google.com';

		Test.startTest();
		list<FlowSendCarousel2> linp = new list<FlowSendCarousel2>();
		linp.add(mess);
		FlowSendCarousel2.sendMessage(linp);
		Test.stopTest();
	}
}
