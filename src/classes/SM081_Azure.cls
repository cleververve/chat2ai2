/**
Author:         serhiivolynets
Date:           07.09.2020
Description:   
**/

public with sharing class SM081_Azure
{

	static String getChannelId(CVCH__NexmoMessage__c mess)
	{
		if(mess.CVCH__ChannelId__c != null && mess.CVCH__ChannelId__c != '')
			return mess.CVCH__ChannelId__c;
		Visitor__c vis = DM080_Visitor.getVisitorById(mess.Visitor__c);
		if(vis != null && vis.CVCH__Last_Inbound_Message__r != null  && vis.CVCH__Last_Inbound_Message__r.ChannelId__c != null && vis.CVCH__Last_Inbound_Message__r.ChannelId__c != '')
		{
			return vis.CVCH__Last_Inbound_Message__r.ChannelId__c;
		}
		if(SM042_NexmoOut2.inboundMess != null && SM042_NexmoOut2.inboundMess.ChannelId__c !=  null && SM042_NexmoOut2.inboundMess.ChannelId__c !=  '')
			return SM042_NexmoOut2.inboundMess.ChannelId__c;
		return null;
	}
	public static String getURL(NexmoMessage__c mess)
	{
		String sConversation = mess.conversationId__c;
		String activityid = mess.activityId__c;
		String channelId = getChannelId(mess);
		String sURLSettingName = 'Azure Bot URL';
		if(channelId == 'telegram')
			sURLSettingName = 'Azure Telegram Bot URL';
		if(channelId == 'facebook')
			sURLSettingName = 'Azure Facebook Bot URL';
		if(channelId == 'webchat')
			sURLSettingName = 'Azure Website Bot URL';
		String sRET = SM010_Utils.getChat2aiValue(sURLSettingName); //'https://webchat.botframework.com/v3'
		sRET += '/conversations/' + sConversation + '/activities/' + activityid;
		return sRET;
	}

	public static void sendCarousel(CVCH__NexmoMessage__c mess, List<CarouselItem> items)
	{
		HttpResponse resp = SM003_Http.request(getURL(mess), 'POST', getHeaders(), getBodyCarousel(mess, items), 'Azure card '+mess.ChannelId__c, NULL, 'SM042_NexmoOutMock');
	}

	public static void sendText(CVCH__NexmoMessage__c mess)
	{
		HttpResponse resp = SM003_Http.request(getURL(mess), 'POST', getHeaders(), getBodyText(mess), 'Azure text '+mess.ChannelId__c, NULL, 'SM042_NexmoOutMock');
	}

	public static void sendOptions(CVCH__NexmoMessage__c mess, MessageOptions mo)
	{
		HttpResponse resp = SM003_Http.request(getURL(mess), 'POST', getHeaders(), getBodyOptions(mess, mo), 'Azure options '+mess.ChannelId__c, NULL, 'SM042_NexmoOutMock');
	}

	public static void addButton(List<Object> lButtons, Option button)
	{
		if (button != null && button.sLabel != null && button.sLabel != '')
		{
			Map<String, Object>mButton = new Map<String, Object>();

			mButton.put('value', '' + button.iNumber);
			mButton.put('title', button.sLabel);
			mButton.put('type', 'postBack');
			lButtons.add(mButton);
		}
	}
	public static Map<String, Object>getBodyTemplate(CVCH__NexmoMessage__c mess)
	{
		Map<String, Object>mRet = new Map<String, Object>();
		mRet.put('replyToId', mess.CVCH__activityId__c);
		Map<String, Object>mRecipient = new Map<String, Object>();
		mRecipient.put('name', mess.CVCH__To_Name__c);
		mRecipient.put('id', mess.CVCH__To__c);
		mRet.put('recipient', mRecipient);
		Map<String, Object>mConv = new Map<String, Object>();
		mConv.put('name', mess.CVCH__conversationId__c);
		mConv.put('id', mess.CVCH__conversationId__c);
		mRet.put('conversation', mConv);
		Map<String, Object>mFrom = new Map<String, Object>();
		mFrom.put('name', mess.CVCH__From_Name__c);
		mFrom.put('id', mess.CVCH__From__c);
		mRet.put('from', mFrom);
		mRet.put('type', 'message');
		return mRet;
	}

	public static String getBodyCarousel(CVCH__NexmoMessage__c mess, List<CarouselItem> items)
	{
		Map<String, Object>mRet = getBodyTemplate(mess);
//		mRet.put('replyToId',mess.CVCH__activityId__c);
		List<Object>lAtt = new List<Object>();

		mRet.put('attachments', lAtt);
		for (CarouselItem item : items)
		{
			Map<String, Object>mAtt = new Map<String, Object>();
			Map<String, Object>mContent = new Map<String, Object>();
			mAtt.put('content', mContent);
			mAtt.put('contentType', 'application/vnd.microsoft.card.hero');

			List<Object>lButtons = new List<Object>();
			mContent.put('buttons', lButtons);
			addButton(lButtons, item.button1);
			addButton(lButtons, item.button2);
			addButton(lButtons, item.button3);
			if(item.imageURL != null && item.imageURL != '')
			{
				List<Object>lIm = new List<Object>();
				mContent.put('images', lIm);
				Map<String, Object>mIm = new Map<String, Object>();
				lIm.add(mIm);
				mIm.put('url', item.imageURL);
			}



			mContent.put('text', item.subtitle2);
			mContent.put('subtitle', item.subtitle);
			mContent.put('title', item.title);
			lAtt.add(mAtt);
		}
		return JSON.serialize(mRet);
	}

	public static String getBodyText(CVCH__NexmoMessage__c mess)
	{
		Map<String, Object>mRet = getBodyTemplate(mess);
		mRet.put('text', mess.CVCH__Text__c);
		return JSON.serialize(mRet);
	}

	public static String getBodyOptions(CVCH__NexmoMessage__c mess, MessageOptions mo)
	{
		Map<String, Object>mRet = getBodyTemplate(mess);

		List<Object>lAtt = new List<Object>();
		mRet.put('attachments', lAtt);

		Map<String, Object>mAtt = new Map<String, Object>();
		lAtt.add(mAtt);
		Map<String, Object>mContent = new Map<String, Object>();
		mAtt.put('content', mContent);
		mAtt.put('contentType', 'application/vnd.microsoft.card.hero');

		List<Object>lButtons = new List<Object>();
		mContent.put('buttons', lButtons);
		List<Option> lOpt = mo.mOptions.values();
		for(Integer i = lOpt.size()-1;i>=0;i--)
		{
			Option opt = lOpt[i];
			addButton(lButtons, opt);
		}

		List<Object>lIm = new List<Object>();
		mContent.put('images', lIm);
		mContent.put('title', mo.sMessage);
		if(mo.sBody != null && mo.sBody !='')
			mContent.put('text', mo.sBody);
		return JSON.serialize(mRet);
	}


	public static Map<String, String>getHeaders()
	{
		Map<String, String>mRet = new Map<String, String>();
		mRet.put('Content-Type', 'application/json');
		mRet.put('Authorization', 'Bearer ' + SM081_AzureToken.getToken());
		return mRet;
	}
}
