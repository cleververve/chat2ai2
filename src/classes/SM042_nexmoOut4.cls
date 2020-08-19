/**
Author:         serhiivolynets
Date:           22.06.2020
Description:   
**/

public with sharing class SM042_nexmoOut4
{
//	public static void sendTemplate(string sTo, string sFrom, string snamespace, string sTemplate)
//	{
//		if (Test.isRunningTest())
//			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
//		Object o = SM003_Http.request('https://api.nexmo.com/v0.1/messages', 'POST', getAuthHeader(), getMDMbody(sTo, sFrom,snamespace,sTemplate), 'NexmoOut2MDM', null);
//
//	}

	public static map<string,string> getAuthHeader()
	{
		map<string,string> headers = new map <string,string>();
		string token = JWT.getAccessToken();
		string sAuth = 'Bearer '+token;
		system.debug('sAuth=>'+sAuth);
		headers.put('Authorization',sAuth);
		headers.put('Content-Type', 'application/json');
		return headers;
	}




//	public static string getMDMbody(string sTo,string sFrom, string sNamespace, string sTemplateName)
//	{
//		map<string, object> mRet = new map<string,object>();
//		map<string,object> mMess = new map<string,object>();
//		map<string,object> mContent = new map<string,object>();
//		map<string,object> mTemplate = new map<string,object>();
//		map<string, object> mFrom = new map<string,object>();
//		map<string, object> mTo = new map<string,object>();
//		mRet.put('message',mMess);
//		mMess.put('content',mContent);
//		mContent.put('template',mTemplate);
//		mContent.put('type','template');
//		mRet.put('from',mFrom);
//		mRet.put('to',mTo);
//
//
//		mTo.put('type','whatsapp');
//		mTo.put('number',sTo);
//
//		mFrom.put('type','whatsapp');
//		mFrom.put('number',sFrom);
//
//		mTemplate.put('parameters',new list<object>());
//		mTemplate.put('name',sNamespace+':'+sTemplateName);
//
//		string sRet = JSON.serialize(mRet);
//		return sRet;
//
//	}

//    public static void send(string sTo, string sFrom, string message, string payload, string url, string type)
//    {
//
//
//    }

	@future(CallOut=true)
	public static void sendTextAsync(string sTo, string messageText,string sFrom,string sAuth)
	{
		try
		{
//            sendText(sTo,messageText,sFrom,sAuth);
			SM042_nexmoOut4.sendText(sTo,sFrom,messageText);
		}
		catch( Exception ex)
		{
		}
		finally
		{
			SM005_Logs.save();
		}
	}

	public static void sendText(string sTo,string sFrom, string messageText)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request('https://api.nexmo.com/v0.1/messages', 'POST', getAuthHeader(), getBodyText(sTo, messageText,sFrom), 'NexmoOut3', null);

	}

//	public static void sendButton(string sTo, string sFrom ,string payload, string text)
//	{
//		if (Test.isRunningTest())
//			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
//		Object o = SM003_Http.request('https://api.nexmo.com/v0.1/messages', 'POST', getAuthHeader(), getBodyButton(sTo,sFrom,  payload,text), 'NexmoOut2', null);
//
//	}


//	public static string getBodyButton(string sTo,string sFrom,string payload,string text)
//	{
//		map<string,object> mret = new map<string,object>();
//		map<string,string> mFrom = new map<string,string>();
//		mFrom.put('type','whatsapp');
//		mFrom.put('number',sFrom);
//		mret.put('from', mFrom);
//
//
//		map<string,string> mTo = new map<string,string>();
//		mTo.put('type','whatsapp');
//		mTo.put('number',sTo);
//		mret.put('to', mTo);
//
//		map<string,object> mMess = new map<string,object>();
//		map<string,object> mCont = new map<string,object>();
//		map<string,string> mButton = new map<string,string>();
//		mCont.put('type', 'button');
//
//		mCont.put('button', mButton);
//		mMess.put('content',mCont);
//		mret.put('message', mMess);
//		mButton.put('payload',payload);
//		mButton.put('text',text);
//		return JSON.serialize(mret);
//	}


	public static string getBodyText(string sTo,string messageText,string sFrom)
	{
		map<string,object> mret = new map<string,object>();
		map<string,string> mFrom = new map<string,string>();
		mFrom.put('type','whatsapp');
		mFrom.put('number',sFrom);
		mret.put('from', mFrom);


		map<string,string> mTo = new map<string,string>();
		mTo.put('type','whatsapp');
		mTo.put('number',sTo);
		mret.put('to', mTo);

		map<string,object> mMess = new map<string,object>();
		map<string,string> mCont = new map<string,string>();
		mCont.put('type', 'text');
        system.debug('messageText: '+messageText);
		mCont.put('text', messageText.replaceAll('/n/r', '\n'));
		mMess.put('content',mCont);
		mret.put('message', mMess);
        //system.debug('serialized text: '+messageText.replaceAll('/n/r', '\n'));
		return JSON.serialize(mret);//.replaceAll('%A9%','\r');//
	}

	@future(callout=true)
    public static void sendImageAsync(string sTo,string sFrom, string sImageURL)
    {
        sendImage(sTo,sFrom,sImageURL);
    }
    
	public static void sendImage(string sTo,string sFrom, string sImageURL)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request('https://api.nexmo.com/v0.1/messages', 'POST', getAuthHeader(), getBodyImage(sTo, sImageURL,sFrom), 'NexmoOut2', null);

	}

	public static string getBodyImage(string sTo,string imageURL,string sFrom)
	{
		map<string,object> mret = new map<string,object>();
		map<string,string> mFrom = new map<string,string>();
		mFrom.put('type','whatsapp');
		mFrom.put('number',sFrom);
		mret.put('from', mFrom);


		map<string,string> mTo = new map<string,string>();
		mTo.put('type','whatsapp');
		mTo.put('number',sTo);
		mret.put('to', mTo);

		map<string,object> mMess = new map<string,object>();
		map<string,object> mCont = new map<string,object>();
		mCont.put('type', 'image');
		map <string,object> mImage = new map<string,object>();
		mImage.put('url',imageURL);
		mCont.put('image', mImage);
		mMess.put('content',mCont);
		mret.put('message', mMess);
		return JSON.serialize(mret).replaceAll('\\n','\n');
	}

    @future(Callout=true)
	public static void sendFile(string sTo,string sFrom, string sFile,string sCaption)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request('https://api.nexmo.com/v0.1/messages', 'POST', getAuthHeader(), getBodyFile(sTo, sFile,sCaption,sFrom), 'NexmoOut2', null);

	}


	public static string getBodyFile(string sTo,string fileURL,string sCaption,string sFrom)
	{
		map<string,object> mret = new map<string,object>();
		map<string,string> mFrom = new map<string,string>();
		mFrom.put('type','whatsapp');
		mFrom.put('number',sFrom);
		mret.put('from', mFrom);


		map<string,string> mTo = new map<string,string>();
		mTo.put('type','whatsapp');
		mTo.put('number',sTo);
		mret.put('to', mTo);

		map<string,object> mMess = new map<string,object>();
		map<string,object> mCont = new map<string,object>();
		mCont.put('type', 'file');
		map <string,object> mFile = new map<string,object>();
		mFile.put('url',fileURL);
		mFile.put('caption',sCaption);
		mCont.put('file', mFile);
		mMess.put('content',mCont);
		mret.put('message', mMess);
		return JSON.serialize(mret);
	}
    
    @future(Callout=true)
    public static void sendVideo(string sTo,string sFrom, string sVideoURL, string sCaption)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request('https://api.nexmo.com/v0.1/messages', 'POST', getAuthHeader(), getBodyVideo(sTo, sVideoURL, sCaption, sFrom), 'NexmoOut2', null);

	}
    
    public static string getBodyVideo(string sTo,string VideoURL,string caption, string sFrom)
	{
		map<string,object> mret = new map<string,object>();
		map<string,string> mFrom = new map<string,string>();
		mFrom.put('type','whatsapp');
		mFrom.put('number',sFrom);
		mret.put('from', mFrom);


		map<string,string> mTo = new map<string,string>();
		mTo.put('type','whatsapp');
		mTo.put('number',sTo);
		mret.put('to', mTo);

		map<string,object> mMess = new map<string,object>();
		map<string,object> mCont = new map<string,object>();
		mCont.put('type', 'video');
		map <string,object> mVideo = new map<string,object>();
		mVideo.put('url',videoURL);
        mVideo.put('caption',caption);
		mCont.put('video', mVideo);
		mMess.put('content',mCont);
		mret.put('message', mMess);
		return JSON.serialize(mret);
	}

}