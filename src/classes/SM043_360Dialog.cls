/**
Author:         serhiivolynets
Date:           15.11.2021
Description:   
**/

public with sharing class SM043_360Dialog
{
	/**
	 * sends the text message
	 *
	 * @param sTo client's phone number
	 * @param sFrom message text
	 * @param messageText message text
	 **/
	public static void sendTextMessage(String sTo, String sFrom, String messageText)
	{
		SM003_Http.request(getMessagesURL(), 'POST', getHeaders(sFrom), JSON.serialize(getBodyText(sTo, messageText)), 'D360OutText', null, 'SM043_360DialogMock');
	}
	/**
	 * @param sTo client's phone number
	 * @param sFrom image URL
	 * @param sImageURL image URL
	 * @param caption image caption, not required
	 **/
	public static void sendImage(String sTo, String sFrom, String sImageURL, String caption)
	{
		sendLink(sTo, sFrom, sImageURL, caption, 'image');
//		SM003_Http.request(getMessagesURL(), 'POST', getHeaders(), JSON.serialize(getImageBody(sTo, sImageURL, caption)), 'D360OutImage', null, 'SM004_SMSMock');
	}


	public static void sendVideo(String sTo, String sFrom, String sVideoURL, String caption)
	{
		sendLink(sTo, sFrom, sVideoURL, caption, 'video');
//		SM003_Http.request(getMessagesURL(), 'POST', getHeaders(), JSON.serialize(getImageBody(sTo, sImageURL, caption)), 'D360OutImage', null, 'SM004_SMSMock');
	}


	public static void sendFile(String sTo, String sFrom, String sVideoURL, String caption)
	{
		sendLink(sTo, sFrom, sVideoURL, caption, 'document');
	}


	public static void sendLink(String sTo, String sFrom, String sLinkURL, String caption, String sType)
	{
		SM003_Http.request(getMessagesURL(), 'POST', getHeaders(sFrom), JSON.serialize(getLinkBody(sTo, sLinkURL, caption, sType)), 'D360Out' + sType, null, 'SM043_360DialogMock');
	}

	/**
	 * @param sTo client's phone number
	 * @param sFrom string, right now 'interactive' or 'template'
	 * @param type string, right now 'interactive' or 'template'
	 * @param payload custom payload string or object
	 **/
	public static void sendCustom(String sTo, String sFrom, String type, Object payload)
	{
		SM003_Http.request(getMessagesURL(), 'POST', getHeaders(sFrom), JSON.serialize(getCustomBody(sTo, payload, type)), 'D360OutCustom', null, 'SM043_360DialogMock');
	}
	/**
	 * @return 360 dialog messages API URL
	 **/
	public static String getMessagesURL()
	{
		String sURL = SM010_Utils.getChat2aiValue2('D360URL');
		String sRet = sURL + '/messages';
		return sRet;
	}
	/**
	 * @param sFrom
	 *
	 * @return headers
	 **/
	public static Map<String, String> getHeaders(String sFrom)
	{
		String sKeySettingName = 'D360-API-KEY';
		if (sFrom != null && sFrom != '' && SM010_Utils.getChat2aiValue2('Multi ChatBots') == 'TRUE')
		{
			sKeySettingName = sKeySettingName + '_' + sFrom;
		}
		Map<String, String>mRet = new Map<String, String>();
		mRet.put('Accept', 'application/json');
		mRet.put('Content-Type', 'application/json');
		mRet.put('D360-API-KEY', SM010_Utils.getChat2aiValue2(sKeySettingName));
		return mRet;
	}


	/**
	 * @param sTo client's phone number
	 *
	 * @return template of request body
	 **/
	public static Map<String, Object> getBody(String sTo)
	{
		Map<String, Object>mRet = new Map<String, Object>();
		mRet.put('preview_url', false);
		mRet.put('recipient_type', 'individual');

		mRet.put('to', sTo);
		return mRet;
	}
	/**
	 * @param sTo client's phone number
	 * @param sText message text
	 *
	 * @return text message API body payload
	 **/
	public static Map<String, Object> getBodyText(String sTo, String sText)
	{
		Map<String, Object>mRet = getBody(sTo);
		mRet.put('type', 'text');
		if (sText != null)
			sText = sText.replaceAll('/n/r', '\n');
		mRet.put('text', new Map<String, Object>
		{
				'body' => sText
		});
		return mRet;
	}

//	/**
//	 * @param sTo  client's phone number
//	 * @param imageURL   image URL
//	 * @param caption  image capture
//	 *
//	 * @return  API body payload
//	 **/
//	public static Map<String, Object> getImageBody(String sTo, String imageURL, String caption)
//	{
//		Map<String, Object>mRet = getBody(sTo);
//		mRet.put('type', 'image');
//		Map<String, Object> mImage = new Map<String, Object>();
//		mImage.put('link', imageURL);
//		if (caption != null && caption != '')
//		{
//			mImage.put('caption', caption);
//		}
//		mRet.put('image', mImage);
//
//		return mRet;
//	}

	/**
	 * @param sTo client's phone number
	 * @param payload custom message payload
	 * @param sPayloadType interactive or template
	 *
	 * @return API body payload
	 **/
	public static Map<String, Object> getCustomBody(String sTo, Object payload, String sPayloadType)
	{
		Map<String, Object>mRet = new Map<String, Object>();
		mRet.put('type', sPayloadType);
		Object oPayload = payload;
		try
		{
			if (payload instanceof String)
				oPayload = JSON.deserializeUntyped((String) payload);

			Map<String, Object >mPayload = (Map<String, Object >) oPayload;
			if (mPayload.containsKey('type'))
				mRet = mPayload;
			else
					mRet.put(sPayloadType, oPayload);
		}
		catch (Exception e)
		{
			mRet.put(sPayloadType, oPayload);
		}
		if (!mRet.containsKey('to') || mRet.get('to') == null)
			mRet.put('to', sTo);
		return mRet;
	}

	/**
	 * @param sTo
	 * @param linkURL
	 * @param caption
	 * @param type
	 *
	 * @return
	 **/
	public static Map<String, Object> getLinkBody(String sTo, String linkURL, String caption, String type)
	{
		Map<String, Object>mRet = getBody(sTo);
		mRet.put('type', type);
		Map<String, Object> mImage = new Map<String, Object>();
		mImage.put('link', linkURL);
		if (caption != null && caption != '')
		{
			mImage.put('caption', caption);
		}
		mRet.put(type, mImage);

		return mRet;
	}


}
