/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@IsTest
public class FlowSendWelcomeCarouselTest
{
	@IsTest
	public static void testIt()
	{
		TestDataFactory data = new TestDataFactory();

		FlowSendWelcomeCarousel.SendCrsInput inp = new FlowSendWelcomeCarousel.SendCrsInput();
		inp.caption = 'caption';
		inp.async = false;
		inp.imageurl = 'google.com';
		inp.ChatNumber = '2345';
		inp.visphone = '54321';
		Test.startTest();
		FlowSendWelcomeCarousel.sendMessage(new list<FlowSendWelcomeCarousel.SendCrsInput> {inp});
		Test.stopTest();
	}
}