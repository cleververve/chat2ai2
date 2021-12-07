/**
Author:         serhiivolynets
Date:           20.11.2021
Description:   
**/

public class SM041_WhatsApp
{
	public static void sendText(String sTo, String sFrom, String sMessage, String channel)
	{
		if(channel == 'D360')
			SM043_360Dialog.sendTextMessage(sTo,sMessage);
		else
			SM042_nexmoOut4.sendText(sTo,sFrom,sMessage);
	}

	public static void sendImage(String sTo, string sFrom , string imageURL, string sCaption, String channel)
	{
		if(channel == 'D360')
			SM043_360Dialog.sendImage(sTo,imageURL,sCaption);
		else
				SM042_nexmoOut4.sendImage(sTo,sFrom,imageURL,sCaption);
	}

	public static void sendCustom(String sTo, string sFrom, object payload, string channel)
	{
		if(channel == 'D360')
			SM043_360Dialog.sendCustom(sTo,'interactive',payload);
		else
				SM042_nexmoOut4.sendCustom(sTo,sFrom, (String) payload);
	}

	public static void sendVideo(String sTo, string sFrom , string videoURL, string sCaption, String channel)
	{
		if(channel == 'D360')
			SM043_360Dialog.sendVideo(sTo,videoURL,sCaption);
		else
				SM042_nexmoOut4.sendVideo(sTo,sFrom,videoURL,sCaption);
	}
}
