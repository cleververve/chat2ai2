/**
Author:         serhiivolynets
Date:           22.06.2020
Description:   
**/

global class SM042_nexmoOut4
{
	global static map<string,string> getAuthHeader()
	{
		return null;
	}
	global static map<string,string> getAuthHeader(string sPhone)
	{
		map<string,string> headers = new map <string,string>();

		string token = JWT.getAccessToken(sPhone );
		string sAuth = 'Bearer '+token;
		system.debug('sAuth=>'+sAuth);
		headers.put('Authorization',sAuth);
		headers.put('Content-Type', 'application/json');
		return headers;
	}


	global static void sendText(string sTo,string sFrom, string messageText)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());

		Object o = SM003_Http.request(SM042_NexmoOut2.getNexmoURL(), 'POST', getAuthHeader(sFrom), getBodyText(sTo, messageText,sFrom), 'NexmoOut3', null);
	}

	global static void sendCustom(string sTo,string sFrom, string messageText)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request(SM042_NexmoOut2.getNexmoURL(), 'POST', getAuthHeader(sFrom), getBodyCustom(sTo, messageText,sFrom), 'NexmoOutCustom', null);
	}

	global static void sendCustom2(string sTo,string sFrom, string messageText)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request(SM042_NexmoOut2.getNexmoURLV1(), 'POST', getAuthHeader(sFrom), getBodyCustom2(sTo, messageText,sFrom), 'NexmoOutCustom2', null);
	}

	global static string getBodyCustom(string sTo,string messageText,string sFrom)
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

		mret.put('message',mMess);
		mMess.put('content',JSON.deserializeUntyped(messageText));

		return JSON.serialize(mret);//.replaceAll('%A9%','\r');//
	}

	global static string getBodyCustom2(string sTo,string messageText,string sFrom)
	{
		map<string,object> mret = new map<string,object>();
		mRet.put('custom',JSON.deserializeUntyped(messageText));
		mRet.put('message_type','custom');
		mret.put('channel','whatsapp');
		mret.put('to',sTo);
		mret.put('from', sFrom);
		return JSON.serialize(mret);//.replaceAll('%A9%','\r');//
	}

	global static string getBodyText(string sTo,string messageText,string sFrom)
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
		if(messageText != null)
			mCont.put('text', messageText.replaceAll('/n/r', '\n'));
		else
				mCont.put('text', messageText);
		mMess.put('content',mCont);
		mret.put('message', mMess);
        //system.debug('serialized text: '+messageText.replaceAll('/n/r', '\n'));
		return JSON.serialize(mret);//.replaceAll('%A9%','\r');//
	}



    @future(Callout=true)
	global static void sendFile(string sTo,string sFrom, string sFile,string sCaption)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request(SM042_NexmoOut2.getNexmoURL(), 'POST', getAuthHeader(sFrom), getBodyFile(sTo, sFile,sCaption,sFrom), 'NexmoOut2', null);

	}


	global static string getBodyFile(string sTo,string fileURL,string sCaption,string sFrom)
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
		SM010_Utils.addResponse(mCont);
		return JSON.serialize(mret);
	}

    @future(Callout=true)
	global static void sendVideo(string sTo,string sFrom, string sVideoURL, string sCaption)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request(SM042_NexmoOut2.getNexmoURL(), 'POST', getAuthHeader(sFrom), getBodyVideo(sTo, sVideoURL, sCaption, sFrom), 'NexmoOut2', null);

	}

	global static string getBodyVideo(string sTo,string VideoURL,string caption, string sFrom)
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

	@future(CallOut=true)
	global static void sendTextAsync(string sTo, string messageText,string sFrom,string sAuth)
	{
	}
	@future(callout=true)
	global static void sendImageAsync(string sTo,string sFrom, string sImageURL)
	{
	}

	global static void sendImage(string sTo,string sFrom, string sImageURL)
	{

	}

	global static void sendImage(string sTo, string sFrom, string imageurl, string caption)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request(SM042_NexmoOut2.getNexmoURL(), 'POST', getAuthHeader(sFrom), getBodyImage(sTo, sFrom, imageurl, caption), 'NexmoOut2', null);
	}


	private static string getBodyImage(string sTo, string sFrom, string imageURL, string sCaption)
	{
		map<string, object> mret = new map<string, object>();
		map<string, string> mFrom = new map<string, string>();
		mFrom.put('type', 'whatsapp');
		mFrom.put('number', sFrom);
		mret.put('from', mFrom);


		map<string, string> mTo = new map<string, string>();
		mTo.put('type', 'whatsapp');
		mTo.put('number', sTo);
		mret.put('to', mTo);

		map<string, object> mMess = new map<string, object>();
		map<string, object> mCont = new map<string, object>();
		mCont.put('type', 'image');
		map <string, object> mImage = new map<string, object>();
		mImage.put('url', imageURL);
		if (sCaption != null)
			mImage.put('caption', sCaption.replaceAll('/n/r', '\n'));
		mCont.put('image', mImage);
		mMess.put('content', mCont);
		mret.put('message', mMess);
		return JSON.serialize(mret).replaceAll('\\n', '\n');
	}

	global static string getBodyImage(string sTo,string imageURL,string sFrom)
	{
		return null;
	}
}
