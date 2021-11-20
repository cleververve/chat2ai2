/**
Author:         serhiivolynets
Date:           15.11.2021
Description:   
**/

public with sharing class SM043_360Dialog
{
	/**
	 * @param sTo
	 * @param messageText
	 * @param sFrom
	 **/
	public static void sendTextMessage(string sTo, string messageText, string sFrom)
	{
		Object o = SM003_Http.request(getMessagesURL(), 'POST', getHeaders(), JSON.serialize(getBodyText(sTo, messageText, sFrom)), 'D360OutText', null);
	}
	/**
	 * @param sTo
	 * @param sImageURL
	 * @param sFrom
	 **/
	public static void sendImage(string sTo, string sImageURL, string sFrom)
	{
		Object o = SM003_Http.request(getMessagesURL(), 'POST', getHeaders(), JSON.serialize(getImageBody(sTo, sImageURL, null, null)), 'D360OutImage', null);
	}
	/**
	 * @param sTo
	 * @param type
	 * @param payload
	 **/
	public static void sendCustom(string sTo, string type, object payload)
	{
		Object o = SM003_Http.request(getMessagesURL(), 'POST', getHeaders(), JSON.serialize(getCustomBody(sTo, payload, type)), 'D360OutCustom', null);
	}
	/**
	 * @return
	 **/
	public static string getMessagesURL()
	{
		string sURL = SM010_Utils.getChat2aiValue2('D360URL');
		string sRet = sURL + '/messages';
		return sRet;
	}
	/**
	 * @return
	 **/
	public static map<string, string> getHeaders()
	{
		map<string, string>mRet = new map<string, string>();
		mRet.put('Accept', 'application/json');
		mRet.put('D360-API-KEY', SM010_Utils.getChat2aiValue2('D360Key'));
		return mRet;
	}
	/**
	 * @param sTo
	 *
	 * @return
	 **/
	public static map<string, object> getBody(string sTo)
	{
		map<string, object>mRet = new map<string, object>();
		mret.put('preview_url', false);
		mret.put('recipient_type','individual');

		mret.put('to', sTo);
		return mRet;
	}
	/**
	 * @param sTo
	 * @param sText
	 * @param sFrom
	 *
	 * @return
	 **/
	public static map<string, object> getBodyText(string sTo, string sText, string sFrom)
	{
		map<string, object>mRet = getBody(sTo);
		mRet.put('type', 'text');
		mRet.put('text', new map<string, object>
		{
				'body' => sText
		});
		return mRet;
	}

	/**
	 * @param sTo
	 * @param imageURL
	 * @param caption
	 * @param providerName
	 *
	 * @return
	 **/
	public static map<string, object> getImageBody(string sTo, string imageURL, string caption, string providerName)
	{
		map<string, object>mRet = getBody(sTo);
		mRet.put('type', 'text');
		map<string, object> mImage = new map<string, Object>();
		mImage.put('link', imageURL);
		if (caption != null && caption != '')
		{
			mImage.put('caption', caption);
		}
		mRet.put('image', mImage);

		return mRet;
	}

	/**
	 * @param sTo
	 * @param payload
	 * @param sPayloadType
	 *
	 * @return
	 **/
	public static map<string, object> getCustomBody(string sTo, object payload, string sPayloadType)
	{
		map<string, object>mRet = new map<string, object>();
		mret.put('to', sTo);
		mRet.put('type', sPayloadType);
		if (payload instanceof String)
			mRet.put(sPayloadType, JSON.deserializeUntyped((string) payload));
		else
				mRet.put(sPayloadType, payload);
		return mRet;
	}
}
