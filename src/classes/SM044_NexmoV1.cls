/**
Author:         serhiivolynets
Date:           08.12.2021
Description:   
**/

public with sharing class SM044_NexmoV1
{
	public static Map<String, String> getAuthHeader(String sPhone)
	{
		return SM042_nexmoOut4.getAuthHeader(sPhone);
	}

	public static String getURL()
	{
		return SM042_NexmoOut2.getNexmoURLV1();
	}

	public static void sendCustom(String sTo, String sFrom, String messageText)
	{
		Object o = SM003_Http.request(getURL(), 'POST', getAuthHeader(sFrom), getBodyCustom(sTo, messageText, sFrom), 'NexmoOutCustom', null, 'SM042_NexmoOutMock');
	}

	public static void sendTemplate(String sTo, String sFrom, String messageText, String locale)
	{
		Object o = SM003_Http.request(getURL(), 'POST', getAuthHeader(sFrom), getBodyTemplate(sTo, messageText, sFrom, locale), 'NexmoOutCustom', null, 'SM042_NexmoOutMock');
	}


	public static void sendText(String sTo, String sFrom, String messageText)
	{
		Object o = SM003_Http.request(getURL(), 'POST', getAuthHeader(sFrom), getBodyText(sTo, messageText, sFrom), 'NexmoOut3', null, 'SM042_NexmoOutMock');
	}

	public static String getBodyText(String sTo, String messageText, String sFrom)
	{
		Map<String, Object> mret = getBody(sTo, sFrom);
		mret.put('message_type', 'text');

		System.debug('messageText: ' + messageText);
		if (messageText != null)
		{
			mret.put('text', messageText.replaceAll('/n/r', '\n'));
		}
		else
		{
			mret.put('text', messageText);
		}

		return JSON.serialize(mret);
	}


	public static void sendLink(String sTo, String sFrom, String sFile, String sCaption, String sType)
	{
		Object o = SM003_Http.request(getURL(), 'POST', getAuthHeader(sFrom), getBodyLink(sTo, sFile, sCaption, sFrom, sType), 'NexmoOut2', null, 'SM042_NexmoOutMock');
		if (sCaption != null && sCaption != '' && sType != 'image')
		{
			SM042_NexmoOut2.pause(800);
			sendText(sTo, sFrom, sCaption.replaceAll('/n/r', '\n'));
		}
	}


	public static String getBodyLink(String sTo, String sURL, String caption, String sFrom, String sType)
	{
		Map<String, Object> mret = getBody(sTo, sFrom);
		mret.put('message_type', sType);
		Map <String, Object> mLink = new Map<String, Object>();
		mLink.put('url', sURL);
		if (sType == 'image')
		{
			if (caption != null && caption != '')
			{
				String sCapt = caption.replaceAll('/n/r', '\n').replace('\\n','\n');
				System.debug('sCapt=[' + sCapt+']');
				mLink.put('caption', sCapt);
			}
		}


		mret.put(sType, mLink);
		System.debug(mret);

		String sRet = JSON.serialize(mret);
		System.debug('sRet=' + sRet);
		sRet = sRet.replaceAll('\\n', '\n');
		System.debug('getBodyLink=' + sRet);
		return sRet;

	}
	public static String getBodyCustom(String sTo, String messageText, String sFrom)
	{
		Map<String, Object> mret = getBody(sTo, sFrom);
		mret.put('custom', JSON.deserializeUntyped(messageText));
		mret.put('message_type', 'custom');
		return JSON.serialize(mret);//.replaceAll('%A9%','\r');//
	}

	public static String getBodyTemplate(String sTo, String messageText, String sFrom, String locale)
	{
		if (locale == null || locale == '')
			locale = 'en-US';

		Map<String, Object> mret = getBody(sTo, sFrom);
		mret.put('template', JSON.deserializeUntyped(messageText));
		mret.put('message_type', 'template');
		Map<String, Object>mWhatsApp = new Map<String, Object>();
		mWhatsApp.put('policy', 'deterministic');
		mWhatsApp.put('locale', locale);
		mret.put('whatsapp', mWhatsApp);
		return JSON.serialize(mret);//.replaceAll('%A9%','\r');//
	}


	public static Map<String, Object> getBody(String sTo, String sFrom)
	{
		Map<String, Object> mret = new Map<String, Object>();
		mret.put('to', sTo);
		mret.put('from', sFrom);
		mret.put('channel', 'whatsapp');
		return mret;
	}
}
