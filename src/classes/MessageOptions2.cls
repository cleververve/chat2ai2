global class MessageOptions2
{
	@AuraEnabled @InvocableVariable global string sMessage;
	@AuraEnabled @InvocableVariable global id visitorId;

	@AuraEnabled @InvocableVariable global Option option1;
	@AuraEnabled @InvocableVariable global Option option2;
	@AuraEnabled @InvocableVariable global Option option3;
	@AuraEnabled @InvocableVariable global Option option4;
	@AuraEnabled @InvocableVariable global Option option5;
	@AuraEnabled @InvocableVariable global Option option6;
	@AuraEnabled @InvocableVariable global Option option7;
	@AuraEnabled @InvocableVariable global Option option8;
	@AuraEnabled @InvocableVariable global Option option9;
	@AuraEnabled @InvocableVariable global Option option10;
	@AuraEnabled @InvocableVariable global boolean async;

	@InvocableMethod(label='Send Message with Options2' description='Send Message with Options2')
	global static void sendWF(list<MessageOptions2> message)
	{
		list<MessageOptions>lMess =new list<MessageOptions>();
		for(MessageOptions2 mess : message)
		{
			MessageOptions mo = new MessageOptions();
			addOpt(mess.option1,mo.lOptions);
			addOpt(mess.option2,mo.lOptions);
			addOpt(mess.option3,mo.lOptions);
			addOpt(mess.option4,mo.lOptions);
			addOpt(mess.option5,mo.lOptions);
			addOpt(mess.option6,mo.lOptions);
			addOpt(mess.option7,mo.lOptions);
			addOpt(mess.option8,mo.lOptions);
			addOpt(mess.option9,mo.lOptions);
			addOpt(mess.option10,mo.lOptions);
			mo.sType = 'Options';
			mo.visitorId = mess.visitorId;
			mo.sMessage = mess.sMessage;
			mo.async = mess.async;
			lMess.add(mo);
			MessageOptions.sendWF(lMess);
		}

	}
	public static void addOpt(Option opt, list<Option> lopt)
	{
		if(opt != null && opt.sLabel != null && opt.sLabel !='')
			lopt.add(opt);
	}
}