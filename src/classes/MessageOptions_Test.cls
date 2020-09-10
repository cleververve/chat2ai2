/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@IsTest
public class MessageOptions_Test
{
	@IsTest
	public static void sendWF()
	{
		TestDataFactory data1 = new TestDataFactory();

		list<MessageOptions> lMess = new list<MessageOptions>();
		MessageOptions mess = new MessageOptions();
		mess.visitorId = data1.vis.id;
		mess.sMessage = 'message';
		mess.sType = 'Carousel';

		MessageOptions.CarouselJSON car = new MessageOptions.CarouselJSON();
		CarouselItem item = new CarouselItem();
		item.imageURL='google.com';
		item.title = 'title';
		item.subtitle = 'subtitle';
		item.subtitle2 = 'subtitle2';

		Option opt = new Option();
		opt.sLabel = 'button1';
		opt.sType = 'QnA';
		opt.sName2 = '1111';

		opt.sName = 'pageNum';
		opt.sValue = '1';
		opt.sName2 = 'keyword';
		opt.sValue2 = 'keyword';
		opt.sName3 = 'gender';
		opt.sValue3 = 'gender';
		item.button1 = opt;

		Option opt2 = new Option();
		opt2.sLabel = 'button1';
		opt2.sType = 'QnA';
		opt2.sName2 = '1111';

		opt2.sName = 'pageNum';
		opt2.sValue = '1';
		opt2.sName2 = 'keyword';
		opt2.sValue2 = 'keyword';
		opt2.sName3 = 'gender';
		opt2.sValue3 = 'gender';
		item.button2 = opt2;

		Option opt3 = new Option();
		opt3.sLabel = 'button1';
		opt3.sType = 'QnA';
		opt3.sName2 = '1111';

		opt3.sName = 'pageNum';
		opt3.sValue = '1';
		opt3.sName2 = 'keyword';
		opt3.sValue2 = 'keyword';
		opt3.sName3 = 'gender';
		opt3.sValue3 = 'gender';
		item.button3 = opt3;
		car.items = new list<CarouselItem>();
		car.items.add(item);

		CarouselItem.toJSON(car.items);

		lMess.add(mess);
		Test.startTest();
		mess.lItems = car.items;
		MessageOptions.sendWF(lMess);
		mess.content = JSON.serialize(car);
		MessageOptions.sendWF(lMess);
		Test.stopTest();
	}

	@IsTest
	public static void sendWFOptions()
	{
		TestDataFactory data1 = new TestDataFactory();

		list<MessageOptions> lMess = new list<MessageOptions>();
		MessageOptions mess = new MessageOptions();
		mess.visitorId = data1.vis.id;
		mess.sMessage = 'message';
		mess.sType = '';
		MessageOptions.OptionsJSON json1 = new MessageOptions.OptionsJSON();
		json1.sType = '';
		json1.a = new list<Option>();

		Option opt = new Option();
		opt.sLabel = 'button1';
		opt.sType = 'QnA';
		opt.sName2 = '1111';

		opt.sName = 'pageNum';
		opt.sValue = '1';
		opt.sName2 = 'keyword';
		opt.sValue2 = 'keyword';
		opt.sName3 = 'gender';
		opt.sValue3 = 'gender';
		json1.a.add(opt);

		Option opt2 = new Option();
		opt2.sLabel = 'button1';
		opt2.sType = 'QnA';
		opt2.sName2 = '1111';

		opt2.sName = 'pageNum';
		opt2.sValue = '1';
		opt2.sName2 = 'keyword';
		opt2.sValue2 = 'keyword';
		opt2.sName3 = 'gender';
		opt2.sValue3 = 'gender';
		json1.a.add(opt);

		Option opt3 = new Option();
		opt3.sLabel = 'button1';
		opt3.sType = 'QnA';
		opt3.sName2 = '1111';

		opt3.sName = 'pageNum';
		opt3.sValue = '1';
		opt3.sName2 = 'keyword';
		opt3.sValue2 = 'keyword';
		opt3.sName3 = 'gender';
		opt3.sValue3 = 'gender';
		json1.a.add(opt);


		lMess.add(mess);
		Test.startTest();
		mess.content = JSON.serialize(json1);
		Option.toJSON(json1.a);
		MessageOptions.sendWF(lMess);

		Test.stopTest();
	}


	@IsTest
	public static void sendWFOptions2()
	{
		TestDataFactory data1 = new TestDataFactory();

		list<MessageOptions2> lMess = new list<MessageOptions2>();
		MessageOptions2 mess = new MessageOptions2();
		mess.visitorId = data1.vis.id;
		mess.sMessage = 'message';


		mess.option1 = new Option();
		mess.option1.sLabel = 'button1';
		mess.option1.sType = 'QnA';
		mess.option1.sName2 = '1111';

		mess.option1.sName = 'pageNum';
		mess.option1.sValue = '1';
		mess.option1.sName2 = 'keyword';
		mess.option1.sValue2 = 'keyword';
		mess.option1.sName3 = 'gender';
		mess.option1.sValue3 = 'gender';

		mess.option2 = new Option();
		mess.option2.sLabel = 'button1';
		mess.option2.sType = 'QnA';
		mess.option2.sName2 = '1111';

		mess.option2.sName = 'pageNum';
		mess.option2.sValue = '1';
		mess.option2.sName2 = 'keyword';
		mess.option2.sValue2 = 'keyword';
		mess.option2.sName3 = 'gender';
		mess.option2.sValue3 = 'gender';

		mess.option2 = new Option();
		mess.option2.sLabel = 'button1';
		mess.option2.sType = 'QnA';
		mess.option2.sName2 = '1111';

		mess.option2.sName = 'pageNum';
		mess.option2.sValue = '1';
		mess.option2.sName2 = 'keyword';
		mess.option2.sValue2 = 'keyword';
		mess.option2.sName3 = 'gender';
		mess.option2.sValue3 = 'gender';

		lMess.add(mess);

		Test.startTest();
		MessageOptions2.sendWF(lMess);

		Test.stopTest();
	}


	@IsTest
	public static void sendCarousel()
	{
		TestDataFactory data1 = new TestDataFactory();

		list<Carousel> lMess = new list<Carousel>();
		Carousel mess = new Carousel();
		mess.visitorId = data1.vis.id;
		mess.sMessage = 'message';

		CarouselItem item = new CarouselItem();
		item.imageURL='google.com';
		item.title = 'title';
		item.subtitle = 'subtitle';
		item.subtitle2 = 'subtitle2';

		Option opt = new Option();
		opt.sLabel = 'button1';
		opt.sType = 'QnA';
		opt.sName2 = '1111';

		opt.sName = 'pageNum';
		opt.sValue = '1';
		opt.sName2 = 'keyword';
		opt.sValue2 = 'keyword';
		opt.sName3 = 'gender';
		opt.sValue3 = 'gender';
		item.button1 = opt;

		Option opt2 = new Option();
		opt2.sLabel = 'button1';
		opt2.sType = 'QnA';
		opt2.sName2 = '1111';

		opt2.sName = 'pageNum';
		opt2.sValue = '1';
		opt2.sName2 = 'keyword';
		opt2.sValue2 = 'keyword';
		opt2.sName3 = 'gender';
		opt2.sValue3 = 'gender';
		item.button2 = opt2;

		Option opt3 = new Option();
		opt3.sLabel = 'button1';
		opt3.sType = 'QnA';
		opt3.sName2 = '1111';

		opt3.sName = 'pageNum';
		opt3.sValue = '1';
		opt3.sName2 = 'keyword';
		opt3.sValue2 = 'keyword';
		opt3.sName3 = 'gender';
		opt3.sValue3 = 'gender';
		item.button3 = opt3;


		mess.item1 = item;
		mess.item2 = item.clone();
		mess.item3 = item.clone();

		lMess.add(mess);

		Test.startTest();
		Carousel.sendWF(lMess);
		Test.stopTest();
	}


}