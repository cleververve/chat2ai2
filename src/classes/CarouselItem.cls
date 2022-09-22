/**
Author:         serhiivolynets
Date:           04.08.2020
Description:   
**/

global class CarouselItem
{
	@AuraEnabled @InvocableVariable global string imageURL;
	@AuraEnabled @InvocableVariable global string videoURL;
	@AuraEnabled @InvocableVariable global string title='';
	@AuraEnabled @InvocableVariable global string subtitle='';
	@AuraEnabled @InvocableVariable global string subtitle2='';
	@AuraEnabled @InvocableVariable global Option button1;
	@AuraEnabled @InvocableVariable global Option button2;
	@AuraEnabled @InvocableVariable global Option button3;
	@AuraEnabled @InvocableVariable global string contentType;

	public string getBody()
	{
		string sRet = '';
		if(title != '' && title != null)
			sRet = sRet+title+'\n';
		if(subtitle != '' && subtitle != null)
			sRet = sRet+subtitle+'\n';
		if(subtitle2 != '' && subtitle2 != null)
			sRet = sRet+subtitle2+'\n';
		if(button1 != null && button1.sLabel != '' && button1.sLabel != null)
			sRet = sRet+button1.getBody()+'\n';
		if(button2 != null && button2.sLabel != '' && button2.sLabel != null)
			sRet = sRet+button2.getBody()+'\n';
		if(button3 != null && button3.sLabel != '' && button3.sLabel != null)
			sRet = sRet+button3.getBody();
		if(sRet.endsWith('\n'))
			sRet = sRet.substring(0,sRet.length()-1);
		return sRet;
	}

	@InvocableMethod(label='CarouselItem to JSON' description='converts Item to JSON')
	global static list<string> toJSON(list<CarouselItem> lItems)
	{
		system.debug('toJSON.start '+lItems);
		list<string>lret = new list<string>();
		for(CarouselItem it: lItems)
		{
			lret.add(JSON.serialize(it,true));
		}
		system.debug('toJSON.return '+lret);
		return lret;
	}
}
