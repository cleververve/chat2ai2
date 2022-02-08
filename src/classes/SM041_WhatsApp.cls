/**
Author:         serhiivolynets
Date:           20.11.2021
Description:   
**/

public class SM041_WhatsApp
{

	public static void sendText(String sTo, String sFrom, String sMessage, String channel)
	{
		if (channel == 'D360')
			SM043_360Dialog.sendTextMessage(sTo, sMessage);
		else if (channel == 'NexmoV1')
			SM044_NexmoV1.sendText(sTo, sFrom, sMessage);
		else
				SM042_nexmoOut4.sendText(sTo, sFrom, sMessage);
	}

	public static void sendImage(String sTo, String sFrom, String imageURL, String sCaption, String channel)
	{
		system.debug('sendImage.caption='+sCaption);
		if (channel == 'D360')
			SM043_360Dialog.sendImage(sTo, imageURL, sCaption);
		else if (channel == 'NexmoV1')
			SM044_NexmoV1.sendLink(sTo, sFrom, imageURL, sCaption, 'image');
		else
				SM042_nexmoOut4.sendImage(sTo, sFrom, imageURL, sCaption);

	}

	public static void sendCustom(String sTo, String sFrom, Object payload, String channel)
	{
		if (channel == 'D360')
			SM043_360Dialog.sendCustom(sTo, 'interactive', payload);
		else if (channel == 'NexmoV1')
			SM044_NexmoV1.sendCustom(sTo, sFrom, (String) payload);
		else
				SM042_nexmoOut4.sendCustom(sTo, sFrom, (String) payload);
	}

	public static void sendTemplate(String sTo, String sFrom, Object payload,String locale,  String channel)
	{
		if (channel == 'D360')
			SM043_360Dialog.sendCustom(sTo, 'template', payload);
		else if (channel == 'NexmoV1')
			SM044_NexmoV1.sendTemplate(sTo, sFrom, (String) payload,locale);
		else
				SM042_nexmoOut4.sendCustom(sTo, sFrom, (String) payload);
	}

	public static void sendVideo(String sTo, String sFrom, String videoURL, String sCaption, String channel)
	{
		if (channel == 'D360')
			SM043_360Dialog.sendVideo(sTo, videoURL, sCaption);
		else if (channel == 'NexmoV1')
			SM044_NexmoV1.sendLink(sTo, sFrom, videoURL, sCaption, 'video');
		else
				SM042_nexmoOut4.sendVideo(sTo, sFrom, videoURL, sCaption);
	}
}
