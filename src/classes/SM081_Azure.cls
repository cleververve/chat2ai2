/**
Author:         serhiivolynets
Date:           07.09.2020
Description:   
**/

public with sharing class SM081_Azure
{
	public static void sendCard(CVCH__NexmoMessage__c mess, list<CarouselItem> items)
	{
		HttpResponse resp = SM003_Http.request(getURL(mess.CVCH__conversationId__c,mess.CVCH__activityId__c), 'POST', getHeaders(), getBodyCard(mess,items), 'Azure card', NULL, 'SM081_AzureTokenMock');
	}

	public static void sendText(CVCH__NexmoMessage__c mess)
	{
		HttpResponse resp = SM003_Http.request(getURL(mess.CVCH__conversationId__c,mess.CVCH__activityId__c), 'POST', getHeaders(), getBodyText(mess), 'Azure text', NULL, 'SM081_AzureTokenMock');
	}

	public static string getURL(string sConversation, string activityid)
	{
		string sRET = 'https://smba.trafficmanager.net/apis/v3';
		sRET+='/conversations'+sConversation+'/activities/'+activityid;
		return sRET;
	}

	public static void addButton(list<object> lButtons,Option button)
	{
		if(button!= null && button.sLabel != null && button.sLabel != '')
		{
			map<string,object>mButton = new map<string,object>();

			mButton.put('value',''+button.iNumber);
			mButton.put('title',button.sLabel);
			mButton.put('type','postBack');
			lButtons.add(button);
		}
	}
	public static map<string,object>getBodyTemplate(CVCH__NexmoMessage__c mess)
	{
		map<string,object>mRet = new map<string,object>();
		mRet.put('replyToId',mess.CVCH__activityId__c);
		map<string,object>mRecipient = new map<string,object>();
		mRecipient.put('name',mess.CVCH__To_Name__c);
		mRecipient.put('id',mess.CVCH__To__c);
		mRet.put('recipient',mRecipient);
		map<string,object>mConv = new map<string,object>();
		mConv.put('name',mess.CVCH__conversationId__c);
		mConv.put('id',mess.CVCH__conversationId__c);
		mRet.put('conversation',mConv);
		map<string,object>mFrom = new map<string,object>();
		mFrom.put('name',mess.CVCH__From_Name__c);
		mFrom.put('id',mess.CVCH__From__c);
		mRet.put('from',mFrom);
		mRet.put('type','message');
		return mRet;
	}

	public static string getBodyCard(CVCH__NexmoMessage__c mess, list<CarouselItem> items)
	{
		map<string,object>mRet = getBodyTemplate(mess);
//		mRet.put('replyToId',mess.CVCH__activityId__c);
		list<object>lAtt = new list<object>();

		mRet.put('attachments',lAtt);
		for(CarouselItem item: items)
		{
			map<string,object>mAtt = new map<string,object>();
			map<string,object>mContent = new map<string,object>();
			mAtt.put('content',mContent);
			mAtt.put('contentType','application/vnd.microsoft.card.hero');

			list<object>lButtons = new list<object>();
			mContent.put('buttons',lButtons);
			addButton(lButtons,item.button1);
			addButton(lButtons,item.button2);
			addButton(lButtons,item.button3);
			list<object>lIm = new list<object>();
			mContent.put('images',lIm);
			map<string,object>mIm = new map<string,object>();
			lIm.add(mIm);
			mIm.put('url',item.imageURL);
			mContent.put('text',item.subtitle2);
			mContent.put('subtitle',item.subtitle);
			mContent.put('title',item.title);
		}
//		map<string,object>mRecipient = new map<string,object>();
//		mRecipient.put('name',mess.CVCH__To_Name__c);
//		mRecipient.put('id',mess.CVCH__To__c);
//		mRet.put('recipient',mRecipient);
//		map<string,object>mConv = new map<string,object>();
//		mConv.put('name',mess.CVCH__conversationId__c);
//		mConv.put('id',mess.CVCH__conversationId__c);
//		mRet.put('conversation',mConv);
//		map<string,object>mFrom = new map<string,object>();
//		mFrom.put('name',mess.CVCH__From_Name__c);
//		mFrom.put('id',mess.CVCH__From__c);
//		mRet.put('from',mFrom);
//		mRet.put('type','message');
		return JSON.serialize(mRet);
	}

	public static string getBodyText(CVCH__NexmoMessage__c mess)
	{
		map<string,object>mRet = getBodyTemplate(mess);
		mRet.put('text',mess.CVCH__Text__c);
		return JSON.serialize(mRet);
	}

	public static map<string,string>getHeaders()
	{
		map<string,string>mRet = new map<string,string>();
		mRet.put('Content-Type','application/json');
		mRet.put('Authorization','Bearer '+SM081_AzureToken.getToken());
		return mRet;
	}
}
