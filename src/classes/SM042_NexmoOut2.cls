public class SM042_NexmoOut2 implements Queueable
{
	public id messId;
	public SM042_NexmoOut2(id messId0)
	{
		messId = messId0;
	}
	public static void pause(integer delayInMilliseconds)
	{
		Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
		while (System.now().getTime() - startingTime < delayInMilliseconds)
		{
			// Do nothing until desired delay has passed
		}
	}

	public void execute(QueueableContext context)
	{
		SM042_NexmoOut2.executeF(messId);
	}

	@future(Callout =true)
	public static void executeF(id messId)
	{
		list<NexmoMessage__c> lMess =
		[
				select id, from__c,to__c,Text__c,Status__c,FullText__c,JSON__c,Type__c
				from NexmoMessage__c
				where id = :messId
		];
		try
		{
			for (NexmoMessage__c mess : lMess)
			{
				system.debug(mess);
				if (mess.Type__c == 'Carousel')
				{
					MessageOptions mo = (MessageOptions) JSON.deserializeStrict(mess.JSON__c, MessageOptions.class);
					if(mo.sMessage != null && mo.sMessage != '')
					{
						SM042_nexmoOut4.sendText(mess.To__c, mess.From__c, mo.sMessage);
						SM042_NexmoOut2.pause(800);
					}


//					for(integer i=mo.mOptions.size()-1;i>=0;i--)
					for(CarouselItem it : mo.lItems)
					{
//						CarouselItem it = mo.lItems[i];
						if(it.imageURL != null && it.imageURL != '')
						{
							try
							{
								SM042_NexmoOut2.sendCarousel(mess.To__c, mess.From__c,  it.imageURL,it.getBody());
//							if(i<0)
//								break;
								SM042_NexmoOut2.pause(800);
							}catch(Exception e)
							{
								SM042_nexmoOut4.sendText(mess.To__c, mess.From__c, e.getMessage());
							}

						}
					}
					SM005_Logs.save();

				}
				else
						SM042_nexmoOut4.sendText(mess.To__c, mess.From__c, mess.FullText__c);
				mess.Status__c = 'Done';
			}

		}
		catch (Exception e)
		{

		}
		finally
		{
			SM005_Logs.save();
			update lmess;
		}
	}

	public static void sendText(string sTo, string sText, string sFrom)
	{
		NexmoMessage__c mess = new NexmoMessage__c();
		mess.From__c = sFrom;
		mess.To__c = sTo;
		mess.Text__c = sText;
		if (mess.Text__c != null && mess.Text__c.length() > 254)
			mess.Text__c = mess.Text__c.substring(0, 254);
		mess.FullText__c = sText;
		mess.Status__c = 'Queued';

		insert mess;
		SM042_NexmoOut2 job = new SM042_NexmoOut2(mess.id);
		System.enqueueJob(job);
	}

	public static void sendCarousel(MessageOptions opt, string sto, string sFrom)
	{
		NexmoMessage__c mess = new NexmoMessage__c();
		mess.From__c = sFrom;
		mess.To__c = sTo;
		mess.Type__c = 'Carousel';
		mess.JSON__c = JSON.serializePretty(opt);
		mess.Status__c = 'Queued';
		system.debug(mess);
		insert mess;
		SM042_NexmoOut2 job = new SM042_NexmoOut2(mess.id);
		System.enqueueJob(job);
	}

//	public static void sendImage(string sTo, string sFrom, string sText, string sImageURL)
//	{
//		NexmoMessage__c mess = new NexmoMessage__c();
//		mess.From__c = sFrom;
//		mess.To__c = sTo;
//		mess.Text__c = sText;
//		mess.Type__c = 'Image';
//		mess.ImageURL__c = sImageURL;
//		if (mess.Text__c != null && mess.Text__c.length() > 254)
//			mess.Text__c = mess.Text__c.substring(0, 254);
//		mess.FullText__c = sText;
//		mess.Status__c = 'Queued';
//
//		insert mess;
//		SM042_NexmoOut2 job = new SM042_NexmoOut2(mess.id);
//		System.enqueueJob(job);
//	}

	public static map<string, string> getAuthHeader()
	{
		map<string, string> headers = new map <string, string>();
		string token = JWT.getAccessToken();
		string sAuth = 'Bearer ' + token;
		system.debug('sAuth=>' + sAuth);
		headers.put('Authorization', sAuth);
		headers.put('Content-Type', 'application/json');
		return headers;
	}

	public static string getBody(string sTo, string messageText, string sFrom)
	{
		map<string, object> mret = new map<string, object>();
		map<string, string> mFrom = new map<string, string>();
		mFrom.put('type', 'whatsapp');
		mFrom.put('number', sFrom);
		//       mFrom.put('number','447418342138');
		mret.put('from', mFrom);


		map<string, string> mTo = new map<string, string>();
		mTo.put('type', 'whatsapp');
		mTo.put('number', sTo);
		mret.put('to', mTo);

		map<string, object> mMess = new map<string, object>();
		map<string, string> mCont = new map<string, string>();
		mCont.put('type', 'text');
		mCont.put('text', messageText.replaceAll('\n', '%A9%'));
		mMess.put('content', mCont);
		mret.put('message', mMess);
		return JSON.serialize(mret);
	}

//	@future(CallOut=true)
//	public static void sendTextAsync(string sTo, string messageText)
//	{
//		try
//		{
//			sendText(sTo, messageText);
//		}
//		catch (Exception e)
//		{
//			if (test.isRunningTest())
//				throw e;
//		}
//		SM005_Logs.save();
//	}
	public static void sendText(string sTo, string messageText)
	{
		sendText2(sTo, '97144099000', messageText);
	}

	public static void sendText2(string sTo, string sFrom, string messageText)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request('https://api.nexmo.com/v0.1/messages', 'POST', getAuthHeader(), getBody(sTo, messageText, sFrom), 'NexmoOut2', null);
	}
    
//    @future(Callout=true)
//    public static void sendText2Async(string sTo, string sFrom, string messageText)
//    {
//        sendText2(sTo,sFrom,messageText);
//    }

//	@Future(callout = true)
//	public static void sendImageFuture(string sTo, string sFrom, string imageurl, string caption)
//	{
//		try
//		{
//			sendCarousel(sTo, sFrom, imageurl, caption);
//		}
//		catch (Exception e)
//		{
//			if (test.isRunningTest())
//				throw e;
//		}
//		SM005_Logs.save();
//	}

    @future(callout=true)
    public static void sendCarouselAsync(string sTo, string sFrom, string imageurl, string caption)
    {
        sendCarousel(Sto,sFrom,imageurl,caption);
    }
    
	public static void sendCarousel(string sTo, string sFrom, string imageurl, string caption)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request('https://api.nexmo.com/v0.1/messages', 'POST', getAuthHeader(), getBodyCarousel(sTo, sFrom, imageurl, caption), 'NexmoOut2', null);
	}

	public static string getBodyCarousel(string sTo, string sFrom, string imageURL, string sCaption)
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
		mImage.put('caption', sCaption);
		mCont.put('image', mImage);
		mMess.put('content', mCont);
		mret.put('message', mMess);
		return JSON.serialize(mret);
	}
}
