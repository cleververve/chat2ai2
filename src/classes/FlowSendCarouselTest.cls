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
}