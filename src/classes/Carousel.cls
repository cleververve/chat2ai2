/**
Author:         serhiivolynets
Date:           26.08.2020
Description:   
**/

global class Carousel
{
	@AuraEnabled @InvocableVariable global string sMessage;
	@AuraEnabled @InvocableVariable global id visitorId;

	@AuraEnabled @InvocableVariable global CarouselItem item1;
	@AuraEnabled @InvocableVariable global CarouselItem item2;
	@AuraEnabled @InvocableVariable global CarouselItem item3;
	@AuraEnabled @InvocableVariable global CarouselItem item4;
	@AuraEnabled @InvocableVariable global CarouselItem item5;
	@AuraEnabled @InvocableVariable global CarouselItem item6;
	@AuraEnabled @InvocableVariable global CarouselItem item7;
	@AuraEnabled @InvocableVariable global CarouselItem item8;
	@AuraEnabled @InvocableVariable global CarouselItem item9;
	@AuraEnabled @InvocableVariable global CarouselItem item10;
	@AuraEnabled @InvocableVariable global boolean async;


	@InvocableMethod(label='Send Carousel' description='Send Carousel')
	global static void sendWF(list<Carousel> message)
	{
		list<MessageOptions>lMess =new list<MessageOptions>();
		for(Carousel mess : message)
		{
			MessageOptions mo = new MessageOptions();
			addItem(mess.item1,mo.lItems);
			addItem(mess.item2,mo.lItems);
			addItem(mess.item3,mo.lItems);
			addItem(mess.item4,mo.lItems);
			addItem(mess.item5,mo.lItems);
			addItem(mess.item6,mo.lItems);
			addItem(mess.item7,mo.lItems);
			addItem(mess.item8,mo.lItems);
			addItem(mess.item9,mo.lItems);
			addItem(mess.item10,mo.lItems);
			mo.sType = 'carousel';
			mo.visitorId = mess.visitorId;
			mo.sMessage = mess.sMessage;
			mo.async = mess.async;
			lMess.add(mo);
			MessageOptions.sendWF(lMess);
		}

	}
	public static void addItem(CarouselItem opt, list<CarouselItem> lopt)
	{
		if(opt != null && opt.imageURL != null && opt.imageURL !='')
			lopt.add(opt);
	}
}
